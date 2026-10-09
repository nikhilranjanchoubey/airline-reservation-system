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
                    Live Flight Tracking
                </span>
                <h1 class="display-6 fw-bold text-dark">Flight Status</h1>
                <p class="text-muted">Check real-time departure, arrival, and terminal information.</p>
            </div>

            <!-- Flight Status Search Card -->
            <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5 bg-white mb-4">
                <form action="${pageContext.request.contextPath}/flight-status" method="GET">
                    <div class="row g-3 mb-4">
                        <div class="col-md-7">
                            <label for="flightNumberInput" class="form-label fw-bold small text-uppercase text-muted">
                                Flight Number
                            </label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-airplane"></i></span>
                                <input type="text" class="form-control bg-light border-start-0 text-uppercase fw-bold" id="flightNumberInput" name="flightNumber"
                                       placeholder="e.g. 6E 204 or AI 492" required value="${flightNumber}">
                            </div>
                            <div class="form-text small text-muted">Enter airline code and number (e.g. 6E 204).</div>
                        </div>
                        <div class="col-md-5">
                            <label for="statusDateInput" class="form-label fw-bold small text-uppercase text-muted">
                                Flight Date
                            </label>
                            <input type="date" class="form-control bg-light fw-bold" id="statusDateInput" name="departureDate"
                                   min="${minDate}" value="${selectedFlightDate}" required>
                            <div class="form-text small text-muted" id="statusDateLabel">${formattedFlightDate} &bull; ${flightDayOfWeek}</div>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-lg w-100 rounded-pill py-3 fw-bold shadow-sm">
                        <i class="bi bi-search me-1"></i> Track Flight
                    </button>
                </form>
            </div>

            <!-- Flight Status Results Card -->
            <c:if test="${searched}">
                <div class="card shadow-sm border-0 rounded-4 p-4 bg-white">
                    <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom">
                        <div>
                            <span class="fs-5 fw-bold text-dark">${flightNumber}</span>
                            <span class="badge bg-success-subtle text-success ms-2"><i class="bi bi-check-circle-fill me-1"></i>On Time</span>
                        </div>
                        <div class="text-end">
                            <span class="badge bg-light text-primary border">${formattedFlightDate}</span>
                            <small class="text-muted d-block">${flightDayOfWeek}</small>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${not empty flightSchedule}">
                            <div class="row g-3 text-center my-2">
                                <div class="col-5">
                                    <div class="fs-4 fw-bold text-dark">${flightSchedule.flight.formattedDepartureTime}</div>
                                    <div class="fw-semibold text-primary">${flightSchedule.flight.sourceAirport.city} (${flightSchedule.flight.sourceAirport.airportCode})</div>
                                    <small class="text-muted d-block">${flightSchedule.flight.sourceAirport.terminal} &bull; Gate 3</small>
                                </div>
                                <div class="col-2 d-flex align-items-center justify-content-center">
                                    <i class="bi bi-arrow-right fs-3 text-muted"></i>
                                </div>
                                <div class="col-5">
                                    <div class="fs-4 fw-bold text-dark">${flightSchedule.flight.formattedArrivalTime}</div>
                                    <div class="fw-semibold text-primary">${flightSchedule.flight.destinationAirport.city} (${flightSchedule.flight.destinationAirport.airportCode})</div>
                                    <small class="text-muted d-block">${flightSchedule.flight.destinationAirport.terminal} &bull; Carousel 4</small>
                                </div>
                            </div>

                            <div class="bg-light p-3 rounded-3 mt-3 small text-muted text-center">
                                Aircraft: ${flightSchedule.flight.aircraftModel} &bull; Estimated In-Air: ${flightSchedule.flight.formattedDuration} &bull; Baggage: Claim Area Active
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="row g-3 text-center my-2">
                                <div class="col-5">
                                    <div class="fs-4 fw-bold text-dark">06:15</div>
                                    <div class="fw-semibold text-primary">Jaipur (JAI)</div>
                                    <small class="text-muted d-block">Terminal 2 &bull; Gate 3</small>
                                </div>
                                <div class="col-2 d-flex align-items-center justify-content-center">
                                    <i class="bi bi-arrow-right fs-3 text-muted"></i>
                                </div>
                                <div class="col-5">
                                    <div class="fs-4 fw-bold text-dark">08:20</div>
                                    <div class="fw-semibold text-primary">Delhi (DEL)</div>
                                    <small class="text-muted d-block">Terminal 3 &bull; Carousel 4</small>
                                </div>
                            </div>

                            <div class="bg-light p-3 rounded-3 mt-3 small text-muted text-center">
                                Aircraft: Airbus A320neo &bull; Estimated In-Air: 1h 25m &bull; Baggage: Claim Area Active
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
