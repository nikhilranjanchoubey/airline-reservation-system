<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="container my-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb small">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/search-flights" class="text-decoration-none">Search</a></li>
            <li class="breadcrumb-item active" aria-current="page">Flight Details</li>
        </ol>
    </nav>

    <!-- Error State if flight not found -->
    <c:if test="${empty schedule}">
        <div class="empty-state-box my-4">
            <div class="empty-state-icon text-danger">
                <i class="bi bi-exclamation-triangle"></i>
            </div>
            <h4 class="fw-bold text-dark mb-2">Flight Not Found</h4>
            <p class="text-muted mb-4">${not empty errorMessage ? errorMessage : 'The requested flight details are unavailable.'}</p>
            <a href="${pageContext.request.contextPath}/search-flights" class="btn btn-primary px-4">
                <i class="bi bi-arrow-left me-1"></i> Back to Search
            </a>
        </div>
    </c:if>

    <c:if test="${not empty schedule}">
        <div class="row g-4">
            <!-- Left Main Details Column -->
            <div class="col-lg-8">
                <div class="flight-details-card">
                    <!-- Airline & Flight Header -->
                    <div class="d-flex flex-wrap justify-content-between align-items-center border-bottom pb-3 mb-4 gap-2">
                            <c:set var="aCode" value="${schedule.flight.airline.airlineCode}" />
                            <div class="airline-logo-box" style="width: 52px; height: 52px; min-width: 52px; border-radius: 12px; overflow: hidden; display: flex; align-items: center; justify-content: center; background: #ffffff; border: 1px solid #e2e8f0; padding: 4px;">
                                <c:choose>
                                    <c:when test="${aCode eq '6E' || aCode eq 'AI' || aCode eq 'QP' || aCode eq 'UK'}">
                                        <img src="${pageContext.request.contextPath}/assets/images/airlines/${aCode}.svg" alt="${schedule.flight.airline.airlineName}" style="max-width: 100%; max-height: 100%; object-fit: contain;">
                                    </c:when>
                                    <c:otherwise>
                                        <span class="fw-bold text-primary fs-5">${aCode}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div>
                                <h4 class="fw-bold text-dark mb-0">${schedule.flight.airline.airlineName}</h4>
                                <div class="text-muted small">
                                    Flight Number: <strong class="text-dark">${schedule.flight.flightNumber}</strong> &bull; 
                                    Aircraft: <strong>${schedule.flight.aircraftModel}</strong>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-2">
                            <span class="badge ${schedule.seatsBadgeClass} badge-seats">
                                <i class="bi bi-person-check me-1"></i> ${schedule.seatsAvailabilityText}
                            </span>
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle">
                                ${travelClass}
                            </span>
                        </div>
                    </div>

                    <!-- Flight Itinerary Timeline -->
                    <div class="mb-4">
                        <h6 class="fw-bold text-dark text-uppercase small tracking-wide mb-3">Flight Itinerary</h6>
                        
                        <div class="ps-2">
                            <!-- Departure Node -->
                            <div class="details-timeline-node mb-4">
                                <div class="node-icon-circle">
                                    <i class="bi bi-geo-alt-fill"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="d-flex flex-wrap justify-content-between align-items-start">
                                        <div>
                                            <div class="fs-4 fw-bold text-dark">${schedule.flight.formattedDepartureTime}</div>
                                            <div class="fw-semibold text-dark">${schedule.flight.sourceAirport.city} (${schedule.flight.sourceAirport.airportCode})</div>
                                            <div class="small text-muted">${schedule.flight.sourceAirport.airportName}</div>
                                            <div class="small text-primary fw-medium mt-1">
                                                <i class="bi bi-door-open me-1"></i> ${schedule.flight.sourceAirport.terminal}
                                            </div>
                                        </div>
                                        <div class="text-lg-end mt-2 mt-lg-0">
                                            <span class="badge bg-light text-dark border">${schedule.formattedFlightDate}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Flight Enroute Specs -->
                            <div class="ms-5 ps-3 mb-4 border-start border-2 border-primary border-opacity-25 py-2">
                                <div class="d-flex align-items-center gap-3 text-muted small">
                                    <span><i class="bi bi-clock me-1"></i> Duration: <strong>${schedule.flight.formattedDuration}</strong></span>
                                    <span>&bull;</span>
                                    <span><i class="bi bi-arrow-repeat me-1"></i> <strong>${schedule.flight.stopsDescription}</strong></span>
                                </div>
                            </div>

                            <!-- Arrival Node -->
                            <div class="details-timeline-node">
                                <div class="node-icon-circle text-danger bg-danger-subtle">
                                    <i class="bi bi-geo-fill"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="d-flex flex-wrap justify-content-between align-items-start">
                                        <div>
                                            <div class="fs-4 fw-bold text-dark">${schedule.flight.formattedArrivalTime}</div>
                                            <div class="fw-semibold text-dark">${schedule.flight.destinationAirport.city} (${schedule.flight.destinationAirport.airportCode})</div>
                                            <div class="small text-muted">${schedule.flight.destinationAirport.airportName}</div>
                                            <div class="small text-danger fw-medium mt-1">
                                                <i class="bi bi-door-open me-1"></i> ${schedule.flight.destinationAirport.terminal}
                                            </div>
                                        </div>
                                        <div class="text-lg-end mt-2 mt-lg-0">
                                            <span class="badge bg-light text-dark border">${schedule.formattedFlightDate}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Baggage & Amenities Information -->
                    <div class="border-top pt-4">
                        <h6 class="fw-bold text-dark text-uppercase small tracking-wide mb-3">Baggage Allowance &amp; In-Flight</h6>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <div class="d-flex align-items-center gap-3 p-3 bg-light rounded-3">
                                    <i class="bi bi-briefcase text-primary fs-3"></i>
                                    <div>
                                        <div class="fw-bold small text-dark">Cabin Baggage</div>
                                        <div class="text-muted small">7 kg (1 standard bag) per passenger</div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="d-flex align-items-center gap-3 p-3 bg-light rounded-3">
                                    <i class="bi bi-luggage text-primary fs-3"></i>
                                    <div>
                                        <div class="fw-bold small text-dark">Check-in Baggage</div>
                                        <div class="text-muted small">15 kg (1 piece) included in fare</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Back Action -->
                <div>
                    <button type="button" class="btn btn-outline-secondary" onclick="window.history.back()">
                        <i class="bi bi-arrow-left me-1"></i> Back to Results
                    </button>
                </div>
            </div>

            <!-- Right Fare Summary & Booking Handoff Column -->
            <div class="col-lg-4">
                <div class="flight-details-card sticky-top" style="top: 90px;">
                    <h5 class="fw-bold text-dark mb-3">Fare Breakdown</h5>
                    
                    <div class="fare-breakdown-box mb-4">
                        <div class="fare-breakdown-row">
                            <span>Base Fare (${passengers} &times; &#8377;<fmt:formatNumber value="${perPassengerFare}" type="number" maxFractionDigits="0" />)</span>
                            <span class="fw-semibold text-dark">&#8377;<fmt:formatNumber value="${baseTotal}" type="number" maxFractionDigits="0" /></span>
                        </div>
                        <div class="fare-breakdown-row">
                            <span>Airport Taxes &amp; GST (12%)</span>
                            <span class="fw-semibold text-dark">&#8377;<fmt:formatNumber value="${taxesAndFees}" type="number" maxFractionDigits="0" /></span>
                        </div>
                        <div class="fare-breakdown-row total-row">
                            <span>Total Payable</span>
                            <span class="text-primary">&#8377;<fmt:formatNumber value="${grandTotal}" type="number" maxFractionDigits="0" /></span>
                        </div>
                    </div>

                    <!-- Seat Map & Booking Actions -->
                    <a href="${pageContext.request.contextPath}/seat-selection?id=${schedule.scheduleId}&travelClass=${travelClass}&passengers=${passengers}"
                       class="btn btn-primary w-100 py-2 fw-semibold mb-2 d-flex align-items-center justify-content-center gap-2">
                        <i class="bi bi-grid-3x3"></i> SELECT SEAT
                    </a>

                    <!-- Booking CTA Button -->
                    <button type="button" class="btn btn-outline-primary w-100 py-2 fw-semibold d-flex align-items-center justify-content-center gap-2"
                            data-bs-toggle="modal" data-bs-target="#bookingHandoffModal">
                        Continue to Passenger Details <i class="bi bi-arrow-right"></i>
                    </button>
                </div>
            </div>
        </div>

        <!-- Reservation Confirmation Modal -->
        <div class="modal fade" id="bookingHandoffModal" tabindex="-1" aria-labelledby="bookingHandoffModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content shadow border-0 rounded-4">
                    <div class="modal-header border-bottom">
                        <h5 class="modal-title fw-bold" id="bookingHandoffModalLabel">
                            <i class="bi bi-ticket-perforated text-primary me-2"></i>Flight Reservation
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-center py-4">
                        <div class="display-6 text-primary mb-3">
                            <i class="bi bi-airplane-engines-fill"></i>
                        </div>
                        <h5 class="fw-bold mb-2">Ready to Book</h5>
                        <p class="text-muted small mb-3">
                            You have selected <strong>${schedule.flight.airline.airlineName} ${schedule.flight.flightNumber}</strong> 
                            (${schedule.flight.sourceAirport.airportCode} &rarr; ${schedule.flight.destinationAirport.airportCode}) 
                            for ${passengers} passenger(s).
                        </p>
                        <div class="p-3 bg-light rounded-3 text-start small text-muted">
                            <i class="bi bi-info-circle text-primary me-1"></i>
                            <strong>Next Step:</strong> Passenger manifest capture and ticket confirmation will proceed upon checkout.
                        </div>
                    </div>
                    <div class="modal-footer border-top">
                        <button type="button" class="btn btn-primary btn-sm rounded-pill px-4" data-bs-dismiss="modal">Proceed</button>
                    </div>
                </div>
            </div>
        </div>
    </c:if>
</main>

<jsp:include page="../common/footer.jsp" />
