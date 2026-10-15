package com.skytech.controller;

import com.airline.model.User;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.skytech.service.AiChatService;
import com.skytech.service.AiChatService.ChatMessage;
import com.skytech.service.AiChatService.ChatResponse;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller handling SkyTech AI Flight Assistant chat interactions.
 * Endpoint: POST /api/ai/chat
 */
@WebServlet(name = "AiChatController", urlPatterns = "/api/ai/chat")
public class AiChatController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AiChatController.class.getName());
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper().findAndRegisterModules();

    private final AiChatService aiChatService;

    public AiChatController() {
        this.aiChatService = new AiChatService();
    }

    public AiChatController(AiChatService aiChatService) {
        this.aiChatService = aiChatService;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        response.getWriter().write("{\"error\": \"Only POST requests are supported for AI chat.\"}");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(true);
        String clientId = (session != null) ? session.getId() : request.getRemoteAddr();

        // Check Rate Limiting
        if (aiChatService.isRateLimited(clientId)) {
            response.setStatus(429); // Too Many Requests
            ChatResponse rateLimitResp = new ChatResponse();
            rateLimitResp.success = false;
            rateLimitResp.reply = "You're sending messages too fast. Please wait a moment before asking another question.";
            rateLimitResp.error = "Rate limit exceeded";
            OBJECT_MAPPER.writeValue(response.getWriter(), rateLimitResp);
            return;
        }

        StringBuilder buffer = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
                if (buffer.length() > 10000) { // Max payload limit
                    break;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[AI-CHAT] Failed reading request body: " + e.getMessage());
        }

        String rawJson = buffer.toString().trim();
        if (rawJson.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            ChatResponse badReq = new ChatResponse();
            badReq.success = false;
            badReq.reply = "Please enter a message.";
            OBJECT_MAPPER.writeValue(response.getWriter(), badReq);
            return;
        }

        String userMessage = null;
        boolean resetRequested = false;
        List<ChatMessage> history = new ArrayList<>();

        try {
            JsonNode rootNode = OBJECT_MAPPER.readTree(rawJson);
            JsonNode msgNode = rootNode.path("message");
            if (!msgNode.isMissingNode()) {
                userMessage = msgNode.asText();
            }

            resetRequested = rootNode.path("reset").asBoolean(false);

            String action = null;
            JsonNode actionNode = rootNode.path("action");
            if (!actionNode.isMissingNode() && !actionNode.isNull()) {
                action = actionNode.asText().trim();
            }

            JsonNode historyNode = rootNode.path("history");
            if (historyNode.isArray()) {
                for (JsonNode hItem : historyNode) {
                    String role = hItem.path("role").asText("user");
                    String text = hItem.path("text").asText("");
                    if (!text.trim().isEmpty()) {
                        history.add(new ChatMessage(role, text));
                    }
                }
            }

            if ((userMessage == null || userMessage.trim().isEmpty()) && (action == null || action.trim().isEmpty())) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                ChatResponse emptyResp = new ChatResponse();
                emptyResp.success = false;
                emptyResp.reply = "Please type a question or travel inquiry.";
                OBJECT_MAPPER.writeValue(response.getWriter(), emptyResp);
                return;
            }

            User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
            String contextPath = request.getContextPath();

            com.skytech.service.AiConversationState state = null;
            if (session != null) {
                state = (com.skytech.service.AiConversationState) session.getAttribute("ai_conversation_state");
                if (resetRequested && state != null) {
                    state.clear();
                }
            }
            if (state == null) {
                state = new com.skytech.service.AiConversationState();
                if (session != null) {
                    session.setAttribute("ai_conversation_state", state);
                }
            }

            ChatResponse chatResponse;
            if (action != null && !action.trim().isEmpty()) {
                chatResponse = aiChatService.processAction(action, currentUser, contextPath, state);
            } else {
                chatResponse = aiChatService.processChat(userMessage, history, currentUser, contextPath, state);
            }

            if (session != null && chatResponse.state != null) {
                session.setAttribute("ai_conversation_state", chatResponse.state);
            }
            OBJECT_MAPPER.writeValue(response.getWriter(), chatResponse);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[AI-CHAT] Unexpected error processing chat message: " + e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_OK);
            ChatResponse errResp = new ChatResponse();
            errResp.success = false;
            errResp.reply = "I encountered a temporary issue connecting to flight services. Please try again or search directly below.";
            errResp.error = e.getMessage();
            java.util.Map<String, String> retryBtn = new java.util.HashMap<>();
            retryBtn.put("label", "Retry Search");
            retryBtn.put("action", "retry");
            errResp.actionButtons.add(retryBtn);
            java.util.Map<String, String> searchBtn = new java.util.HashMap<>();
            searchBtn.put("label", "Open Flight Search");
            searchBtn.put("url", request.getContextPath() + "/search-flights");
            errResp.actionButtons.add(searchBtn);
            OBJECT_MAPPER.writeValue(response.getWriter(), errResp);
        }
    }
}
