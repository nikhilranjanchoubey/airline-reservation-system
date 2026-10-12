package com.skytech.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Controller serving the academic PBL project specification documentation.
 * Isolated strictly to /project for evaluation without contaminating customer UX.
 */
@WebServlet(name = "ProjectController", urlPatterns = {"/project"})
public class ProjectController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "SkyTech - Academic Project & Architecture Specifications");
        request.getRequestDispatcher("/WEB-INF/views/project.jsp").forward(request, response);
    }
}
