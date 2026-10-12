package com.airline.controller;

import com.airline.model.User;
import com.airline.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;

/**
 * Controller securely serving user profile avatars with content-type verification
 * and path traversal prevention.
 */
@WebServlet(name = "AvatarServlet", urlPatterns = {"/avatar", "/avatar/*"})
public class AvatarServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int targetUserId = -1;
        String uidParam = request.getParameter("uid");
        if (uidParam != null && !uidParam.isBlank()) {
            try {
                targetUserId = Integer.parseInt(uidParam.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        // If not specified in query param, check session
        if (targetUserId <= 0) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                User currentUser = (User) session.getAttribute("currentUser");
                if (currentUser != null) {
                    targetUserId = currentUser.getUserId();
                }
            }
        }

        if (targetUserId <= 0) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Avatar not found");
            return;
        }

        User user = userService.getUserById(targetUserId);
        if (user == null || user.getProfilePhoto() == null || user.getProfilePhoto().isBlank()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No avatar for user");
            return;
        }

        String photoPath = user.getProfilePhoto();
        // Extract simple filename to avoid any path traversal
        String fileName = new File(photoPath).getName();
        if (fileName.contains("..") || fileName.contains("/") || fileName.contains("\\")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file name");
            return;
        }

        // 1. Try webapp uploads directory
        File targetFile = null;
        String webappUploadPath = getServletContext().getRealPath("/uploads/avatars");
        if (webappUploadPath != null) {
            File cand = new File(webappUploadPath, fileName);
            if (cand.exists() && cand.isFile()) {
                targetFile = cand;
            }
        }

        // 2. Try persistent user directory fallback
        if (targetFile == null) {
            File persistentDir = new File(System.getProperty("user.home"), ".skytech" + File.separator + "avatars");
            File cand = new File(persistentDir, fileName);
            if (cand.exists() && cand.isFile()) {
                targetFile = cand;
            }
        }

        if (targetFile == null || !targetFile.exists() || !targetFile.canRead()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Avatar image file not found");
            return;
        }

        // Determine MIME type
        String mimeType = getServletContext().getMimeType(targetFile.getName());
        if (mimeType == null || !mimeType.startsWith("image/")) {
            if (fileName.toLowerCase().endsWith(".png")) {
                mimeType = "image/png";
            } else if (fileName.toLowerCase().endsWith(".webp")) {
                mimeType = "image/webp";
            } else {
                mimeType = "image/jpeg";
            }
        }

        response.setContentType(mimeType);
        response.setContentLengthLong(targetFile.length());
        response.setHeader("Cache-Control", "public, max-age=86400, must-revalidate");
        response.setHeader("X-Content-Type-Options", "nosniff");

        try (FileInputStream in = new FileInputStream(targetFile);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
            out.flush();
        }
    }
}
