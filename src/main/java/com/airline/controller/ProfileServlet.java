package com.airline.controller;

import com.airline.model.User;
import com.airline.service.ServiceResult;
import com.airline.service.UserService;
import com.airline.util.ValidationUtil;
import com.skytech.dao.BookingDao;
import com.skytech.model.Booking;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller managing passenger and admin profile viewing, updating, avatar upload, and booking overview.
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 512,      // 512 KB
        maxFileSize = 2 * 1024 * 1024,        // 2 MB max file size
        maxRequestSize = 4 * 1024 * 1024      // 4 MB total request
)
public class ProfileServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProfileServlet.class.getName());
    private final UserService userService = new UserService();
    private final BookingDao bookingDao = new BookingDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (sessionUser == null) {
            if (session == null) {
                session = request.getSession(true);
            }
            session.setAttribute("redirectAfterLogin", request.getContextPath() + "/profile");
            response.sendRedirect(request.getContextPath() + "/login?redirect=/profile");
            return;
        }

        // If authenticated user is an administrator, direct them to the dedicated admin profile workspace
        if (sessionUser.getRole() == com.airline.model.Role.ADMIN) {
            response.sendRedirect(request.getContextPath() + "/admin/profile");
            return;
        }

        // Always refresh user details from the database using parameterized query
        User freshUser = userService.getUserById(sessionUser.getUserId());
        User activeUser = (freshUser != null) ? freshUser : sessionUser;
        session.setAttribute("currentUser", activeUser);
        request.setAttribute("user", activeUser);

        // Load genuine bookings for authenticated passenger
        List<Booking> userBookings = bookingDao.getBookingsByUserId(activeUser.getUserId());
        request.setAttribute("bookings", userBookings);

        int totalBookings = (userBookings != null) ? userBookings.size() : 0;
        long upcomingCount = 0;
        long completedCount = 0;
        long cancelledCount = 0;
        if (userBookings != null) {
            LocalDate today = LocalDate.now();
            for (Booking b : userBookings) {
                if ("CANCELLED".equalsIgnoreCase(b.getStatus())) {
                    cancelledCount++;
                } else if (b.getDepartureDate() != null && b.getDepartureDate().isBefore(today)) {
                    completedCount++;
                } else {
                    upcomingCount++;
                }
            }
        }
        request.setAttribute("totalBookings", totalBookings);
        request.setAttribute("upcomingCount", upcomingCount);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("cancelledCount", cancelledCount);

        // Deliver flash messages if any
        String flashSuccess = (String) session.getAttribute("flashSuccess");
        String flashError = (String) session.getAttribute("flashError");
        if (flashSuccess != null) {
            request.setAttribute("flashSuccess", flashSuccess);
            session.removeAttribute("flashSuccess");
        }
        if (flashError != null) {
            request.setAttribute("flashError", flashError);
            session.removeAttribute("flashError");
        }

        request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("upload_photo".equalsIgnoreCase(action)) {
            handlePhotoUpload(request, response, session, sessionUser);
        } else if ("remove_photo".equalsIgnoreCase(action)) {
            handlePhotoRemove(request, response, session, sessionUser);
        } else if ("change_password".equalsIgnoreCase(action)) {
            handlePasswordChange(request, response, session, sessionUser);
        } else {
            handleProfileUpdate(request, response, session, sessionUser);
        }
    }

    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response,
                                      HttpSession session, User sessionUser)
            throws ServletException, IOException {
        String firstName = ValidationUtil.clean(request.getParameter("firstName"));
        String lastName = ValidationUtil.clean(request.getParameter("lastName"));
        String phone = ValidationUtil.clean(request.getParameter("phone"));
        String passportNumber = ValidationUtil.clean(request.getParameter("passportNumber"));
        String dobStr = ValidationUtil.clean(request.getParameter("dateOfBirth"));

        LocalDate dob = null;
        if (!dobStr.isEmpty()) {
            try {
                dob = LocalDate.parse(dobStr);
            } catch (DateTimeParseException e) {
                request.setAttribute("errorMessage", "Invalid date format for Date of Birth. Use YYYY-MM-DD.");
                request.setAttribute("user", sessionUser);
                request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
                return;
            }
        }

        ServiceResult<User> result = userService.updateProfile(
                sessionUser.getUserId(), firstName, lastName, phone, passportNumber, dob
        );

        if (result.isSuccess()) {
            session.setAttribute("currentUser", result.getData());
            session.setAttribute("flashSuccess", "Your profile details have been updated successfully.");
            response.sendRedirect(request.getContextPath() + "/profile");
        } else {
            request.setAttribute("errorMessage", result.getMessage());
            request.setAttribute("user", sessionUser);
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
        }
    }

    private void handlePhotoUpload(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession session, User sessionUser)
            throws ServletException, IOException {
        try {
            Part filePart = request.getPart("profilePhotoFile");
            if (filePart == null || filePart.getSize() == 0) {
                session.setAttribute("flashError", "Please select an image file to upload.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }

            // Max size: 2MB
            if (filePart.getSize() > 2 * 1024 * 1024) {
                session.setAttribute("flashError", "Profile photo file size must not exceed 2MB.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }

            // MIME type check
            String contentType = filePart.getContentType();
            if (contentType == null || !contentType.toLowerCase().startsWith("image/")) {
                session.setAttribute("flashError", "Uploaded file must be a valid image (JPEG, PNG, or WebP).");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }

            // File extension check
            String submittedName = filePart.getSubmittedFileName();
            String ext = "";
            if (submittedName != null && submittedName.contains(".")) {
                ext = submittedName.substring(submittedName.lastIndexOf('.') + 1).toLowerCase().trim();
            }
            if (!ext.equals("jpg") && !ext.equals("jpeg") && !ext.equals("png") && !ext.equals("webp")) {
                session.setAttribute("flashError", "Unsupported image format. Allowed formats: JPG, JPEG, PNG, WEBP.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }

            // Verify raster content
            byte[] imageBytes = filePart.getInputStream().readAllBytes();
            if (!ext.equals("webp")) {
                try (ByteArrayInputStream bais = new ByteArrayInputStream(imageBytes)) {
                    BufferedImage img = ImageIO.read(bais);
                    if (img == null || img.getWidth() <= 0 || img.getHeight() <= 0) {
                        session.setAttribute("flashError", "Corrupt or invalid image content detected.");
                        response.sendRedirect(request.getContextPath() + "/profile");
                        return;
                    }
                }
            }

            // Generate secure randomized filename
            String safeFileName = "avatar_" + sessionUser.getUserId() + "_" + System.currentTimeMillis() + "." + (ext.equals("jpeg") ? "jpg" : ext);

            // Write to webapp uploads directory
            String uploadDirRealPath = request.getServletContext().getRealPath("/uploads/avatars");
            if (uploadDirRealPath != null) {
                File uploadDir = new File(uploadDirRealPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                File destFile = new File(uploadDir, safeFileName);
                try (FileOutputStream fos = new FileOutputStream(destFile)) {
                    fos.write(imageBytes);
                }
            }

            // Write to persistent user directory
            File persistentDir = new File(System.getProperty("user.home"), ".skytech" + File.separator + "avatars");
            if (!persistentDir.exists()) {
                persistentDir.mkdirs();
            }
            File persistentFile = new File(persistentDir, safeFileName);
            try (FileOutputStream fos = new FileOutputStream(persistentFile)) {
                fos.write(imageBytes);
            }

            // Write to workspace project source directory if accessible
            try {
                File srcDir = new File("src/main/webapp/uploads/avatars");
                if (srcDir.exists() || srcDir.mkdirs()) {
                    File srcFile = new File(srcDir, safeFileName);
                    try (FileOutputStream fos = new FileOutputStream(srcFile)) {
                        fos.write(imageBytes);
                    }
                }
            } catch (Exception ignored) {
            }

            // Save image path in database
            String photoUrl = "/uploads/avatars/" + safeFileName;
            ServiceResult<User> updateRes = userService.updateProfilePhoto(sessionUser.getUserId(), photoUrl);
            if (updateRes.isSuccess()) {
                sessionUser.setProfilePhoto(photoUrl);
                session.setAttribute("currentUser", sessionUser);
                session.setAttribute("flashSuccess", "Your profile photo has been updated successfully.");
            } else {
                session.setAttribute("flashError", updateRes.getMessage());
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to upload avatar: " + e.getMessage(), e);
            session.setAttribute("flashError", "Failed to upload image. Please try a different photo.");
        }
        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private void handlePhotoRemove(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession session, User sessionUser)
            throws ServletException, IOException {
        ServiceResult<User> updateRes = userService.updateProfilePhoto(sessionUser.getUserId(), null);
        if (updateRes.isSuccess()) {
            sessionUser.setProfilePhoto(null);
            session.setAttribute("currentUser", sessionUser);
            session.setAttribute("flashSuccess", "Profile photo removed.");
        } else {
            session.setAttribute("flashError", updateRes.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private void handlePasswordChange(HttpServletRequest request, HttpServletResponse response,
                                      HttpSession session, User sessionUser)
            throws ServletException, IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        ServiceResult<Void> result = userService.changePassword(
                sessionUser.getUserId(), currentPassword, newPassword, confirmPassword
        );

        if (result.isSuccess()) {
            session.setAttribute("flashSuccess", "Your password has been changed successfully.");
            response.sendRedirect(request.getContextPath() + "/profile");
        } else {
            request.setAttribute("passwordError", result.getMessage());
            request.setAttribute("user", sessionUser);
            request.setAttribute("activeTab", "password");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
        }
    }
}
