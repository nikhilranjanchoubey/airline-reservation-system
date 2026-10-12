<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Forward root requests to the central HomeController servlet which loads dynamic flight data
    response.sendRedirect(request.getContextPath() + "/home");
%>
