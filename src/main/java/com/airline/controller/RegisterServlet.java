package com.airline.controller;

import com.airline.model.Role;
import com.airline.model.User;
import com.airline.service.ServiceResult;
import com.airline.service.UserService;
import com.airline.util.ConfigUtil;
import com.airline.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/**
 * Controller handling passenger registration.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        request.setAttribute("googleClientId", ConfigUtil.getGoogleClientId());
        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String firstName = ValidationUtil.clean(request.getParameter("firstName"));
        String lastName = ValidationUtil.clean(request.getParameter("lastName"));
        String email = ValidationUtil.clean(request.getParameter("email"));
        String phone = ValidationUtil.clean(request.getParameter("phone"));
        String passportNumber = ValidationUtil.clean(request.getParameter("passportNumber"));
        String dobStr = ValidationUtil.clean(request.getParameter("dateOfBirth"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        LocalDate dob = null;
        if (!dobStr.isEmpty()) {
            try {
                dob = LocalDate.parse(dobStr);
            } catch (DateTimeParseException e) {
                request.setAttribute("errorMessage", "Invalid date format for Date of Birth. Use YYYY-MM-DD.");
                request.setAttribute("googleClientId", ConfigUtil.getGoogleClientId());
                preserveFormState(request, firstName, lastName, email, phone, passportNumber, dobStr);
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }
        }

        User user = new User();
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setPassportNumber(passportNumber.isEmpty() ? null : passportNumber);
        user.setDateOfBirth(dob);
        user.setRole(Role.PASSENGER);

        ServiceResult<User> result = userService.register(user, password, confirmPassword);

        if (result.isSuccess()) {
            HttpSession session = request.getSession(true);
            session.setAttribute("flashSuccess", "Account created successfully! Please log in with your credentials.");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            request.setAttribute("errorMessage", result.getMessage());
            request.setAttribute("googleClientId", ConfigUtil.getGoogleClientId());
            preserveFormState(request, firstName, lastName, email, phone, passportNumber, dobStr);
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
        }
    }

    private void preserveFormState(HttpServletRequest request, String firstName, String lastName,
                                   String email, String phone, String passportNumber, String dobStr) {
        request.setAttribute("regFirstName", firstName);
        request.setAttribute("regLastName", lastName);
        request.setAttribute("regEmail", email);
        request.setAttribute("regPhone", phone);
        request.setAttribute("regPassport", passportNumber);
        request.setAttribute("regDob", dobStr);
    }
}
