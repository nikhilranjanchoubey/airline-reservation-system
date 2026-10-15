package com.skytech.controller.api;

import com.airline.model.Role;
import com.airline.model.User;
import com.airline.service.ServiceResult;
import com.airline.service.UserService;
import com.airline.util.ValidationUtil;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import com.skytech.dto.UserDto;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * RESTful authentication controller supporting:
 *   - POST /api/auth/login
 *   - POST /api/auth/register
 *   - POST /api/auth/logout
 *   - GET  /api/auth/me
 *
 * Integrates directly with existing UserService, PasswordUtil, and UserDao.
 * Sets secure session cookies and emits safe UserDto payloads (never password hashes or salts).
 */
@WebServlet(name = "AuthApiController", urlPatterns = {
        "/api/auth/login",
        "/api/auth/register",
        "/api/auth/logout",
        "/api/auth/me"
})
public class AuthApiController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AuthApiController.class.getName());

    private static final Gson GSON = new GsonBuilder()
            .registerTypeAdapter(LocalDate.class, (JsonSerializer<LocalDate>) (date, type, context) ->
                    date == null ? null : new JsonPrimitive(date.format(DateTimeFormatter.ISO_LOCAL_DATE)))
            .registerTypeAdapter(LocalDate.class, (JsonDeserializer<LocalDate>) (json, type, context) -> {
                String val = json.getAsString();
                return (val == null || val.trim().isEmpty()) ? null : LocalDate.parse(val.trim());
            })
            .create();

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/api/auth/me".equalsIgnoreCase(path)) {
            handleGetCurrentUser(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Method not allowed");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path.toLowerCase()) {
            case "/api/auth/login":
                handleLogin(request, response);
                break;
            case "/api/auth/register":
                handleRegister(request, response);
                break;
            case "/api/auth/logout":
                handleLogout(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
    }

    /**
     * POST /api/auth/login
     */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Map<String, String> body = readJsonBody(request);
        String email = body != null ? body.get("email") : null;
        String password = body != null ? body.get("password") : null;

        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Email and password are required.");
            return;
        }

        email = ValidationUtil.clean(email);
        ServiceResult<User> result = userService.login(email, password);

        if (result.isSuccess()) {
            User user = result.getData();

            // Session fixation protection
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);

            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success", true);
            resp.put("message", "Login successful.");
            resp.put("user", UserDto.fromEntity(user));

            writeJsonResponse(response, HttpServletResponse.SC_OK, resp);
        } else {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, result.getMessage());
        }
    }

    /**
     * POST /api/auth/register
     */
    private void handleRegister(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Map<String, String> body = readJsonBody(request);
        if (body == null) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing JSON payload.");
            return;
        }

        String firstName = ValidationUtil.clean(body.get("firstName"));
        String lastName = ValidationUtil.clean(body.get("lastName"));
        String email = ValidationUtil.clean(body.get("email"));
        String phone = ValidationUtil.clean(body.get("phone"));
        String passport = ValidationUtil.clean(body.get("passportNumber"));
        String password = body.get("password");
        String confirmPassword = body.get("confirmPassword");
        String dobStr = ValidationUtil.clean(body.get("dateOfBirth"));

        LocalDate dob = null;
        if (!dobStr.isEmpty()) {
            try {
                dob = LocalDate.parse(dobStr);
            } catch (DateTimeParseException e) {
                writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid date format for Date of Birth. Use YYYY-MM-DD.");
                return;
            }
        }

        User user = new User();
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setPassportNumber(passport.isEmpty() ? null : passport);
        user.setDateOfBirth(dob);
        user.setRole(Role.PASSENGER);

        ServiceResult<User> result = userService.register(user, password, confirmPassword);

        if (result.isSuccess()) {
            User createdUser = result.getData();

            // Auto-login newly registered passenger
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", createdUser);

            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success", true);
            resp.put("message", "Registration successful! Welcome to SkyTech.");
            resp.put("user", UserDto.fromEntity(createdUser));

            writeJsonResponse(response, HttpServletResponse.SC_CREATED, resp);
        } else {
            int statusCode = result.getMessage().contains("already exists") ?
                    HttpServletResponse.SC_CONFLICT : HttpServletResponse.SC_BAD_REQUEST;
            writeError(response, statusCode, result.getMessage());
        }
    }

    /**
     * POST /api/auth/logout
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("success", true);
        resp.put("message", "Logged out successfully.");
        writeJsonResponse(response, HttpServletResponse.SC_OK, resp);
    }

    /**
     * GET /api/auth/me
     */
    private void handleGetCurrentUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthenticated. Please sign in.");
            return;
        }

        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("success", true);
        resp.put("user", UserDto.fromEntity(currentUser));
        writeJsonResponse(response, HttpServletResponse.SC_OK, resp);
    }

    @SuppressWarnings("unchecked")
    private Map<String, String> readJsonBody(HttpServletRequest request) {
        try {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            if (sb.length() == 0) {
                return null;
            }
            return GSON.fromJson(sb.toString(), Map.class);
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "Failed to parse JSON body: " + e.getMessage());
            return null;
        }
    }

    private void writeJsonResponse(HttpServletResponse response, int status, Object data) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try (PrintWriter out = response.getWriter()) {
            out.print(GSON.toJson(data));
            out.flush();
        }
    }

    private void writeError(HttpServletResponse response, int status, String message) throws IOException {
        Map<String, Object> error = new LinkedHashMap<>();
        error.put("success", false);
        error.put("error", message);
        writeJsonResponse(response, status, error);
    }
}
