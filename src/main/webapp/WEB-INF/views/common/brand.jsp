<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="brandThemeClass" value="${param.theme eq 'light' ? 'skytech-brand--light-bg' : ''}" />
<c:set var="brandExtraClass" value="${not empty param.extraClass ? param.extraClass : ''}" />
<a href="${pageContext.request.contextPath}/"
   class="skytech-brand ${brandThemeClass} ${brandExtraClass}"
   aria-label="SkyTech Home">
    <span class="skytech-brand__icon">
        <i class="bi bi-airplane-engines-fill"></i>
    </span>
    <span class="skytech-brand__text">SkyTech</span>
</a>
