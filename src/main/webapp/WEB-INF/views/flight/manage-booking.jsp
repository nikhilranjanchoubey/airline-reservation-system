<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="container my-5">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-xl-7">
            <!-- Header -->
            <div class="text-center mb-4">
                <span class="badge bg-primary-subtle text-primary fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill">
                    Guest Services
                </span>
                <h1 class="display-6 fw-bold text-dark">Manage Your Booking</h1>
                <p class="text-muted">Retrieve your itinerary, select seats, or view flight updates.</p>
            </div>

            <!-- Manage Booking Card -->
            <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5 bg-white">
                <c:if test="${not empty infoMessage}">
                    <div class="alert alert-info border-0 rounded-3 mb-4 d-flex align-items-center gap-2">
                        <i class="bi bi-info-circle-fill fs-5"></i>
                        <div><c:out value="${infoMessage}" /></div>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/manage-booking" method="POST">
                    <div class="mb-4">
                        <label for="pnrInput" class="form-label fw-bold small text-uppercase text-muted">
                            Booking Reference / PNR
                        </label>
                        <div class="input-group input-group-lg">
                            <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-ticket-perforated"></i></span>
                            <input type="text" class="form-control bg-light border-start-0 text-uppercase fw-bold" id="pnrInput" name="pnr"
                                   placeholder="e.g. SKY789" maxlength="10" required value="${searchedPnr}">
                        </div>
                        <div class="form-text small text-muted">Found on your e-ticket receipt or booking confirmation.</div>
                    </div>

                    <div class="mb-4">
                        <label for="lastNameInput" class="form-label fw-bold small text-uppercase text-muted">
                            Passenger Last Name
                        </label>
                        <div class="input-group input-group-lg">
                            <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-person"></i></span>
                            <input type="text" class="form-control bg-light border-start-0 fw-semibold" id="lastNameInput" name="lastName"
                                   placeholder="e.g. Choubey" required value="${searchedLastName}">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-lg w-100 rounded-pill py-3 fw-bold shadow-sm">
                        <i class="bi bi-search me-1"></i> Retrieve Booking
                    </button>
                </form>

                <div class="mt-4 pt-4 border-top text-center text-muted small">
                    Need urgent flight assistance? Reach out to our 24/7 guest care desk at <strong>support@skytech.com</strong>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
