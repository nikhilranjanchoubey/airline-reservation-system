<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Passenger Details - SkyTech" />
    <jsp:param name="activePage" value="flights" />
</jsp:include>
<jsp:include page="../common/navbar.jsp" />


<main class="container py-4 py-lg-5" style="max-width: 1140px;">
    <!-- Step Progress Tracker -->
    <div class="d-flex align-items-center justify-content-between mb-4 px-2 px-md-4">
        <div class="d-flex align-items-center gap-2 text-primary fw-bold">
            <span class="badge bg-primary rounded-circle p-2 px-3">1</span>
            <span class="d-none d-sm-inline">Flight Search</span>
        </div>
        <div class="flex-grow-1 border-top border-primary mx-3"></div>
        <div class="d-flex align-items-center gap-2 text-primary fw-bold">
            <span class="badge bg-primary rounded-circle p-2 px-3">2</span>
            <span>Passenger Details</span>
        </div>
        <div class="flex-grow-1 border-top border-2 border-secondary opacity-25 mx-3"></div>
        <div class="d-flex align-items-center gap-2 text-muted">
            <span class="badge bg-secondary opacity-50 rounded-circle p-2 px-3">3</span>
            <span class="d-none d-sm-inline">Payment</span>
        </div>
        <div class="flex-grow-1 border-top border-2 border-secondary opacity-25 mx-3"></div>
        <div class="d-flex align-items-center gap-2 text-muted">
            <span class="badge bg-secondary opacity-50 rounded-circle p-2 px-3">4</span>
            <span class="d-none d-sm-inline">Confirmation</span>
        </div>
    </div>

    <!-- Error Alert Banner -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Booking Notice:</strong> <c:out value="${errorMessage}" />
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Left: Passenger Form -->
        <div class="col-lg-8">
            <form action="${pageContext.request.contextPath}/book-flight" method="POST" id="passengerDetailsForm" class="needs-validation" novalidate>
                <input type="hidden" name="scheduleId" value="${schedule.scheduleId}">
                <input type="hidden" name="travelClass" value="${travelClass}">
                <input type="hidden" name="passengersCount" value="${passengersCount}">
                <input type="hidden" name="selectedSeats" value="${selectedSeatsStr}">

                <!-- Contact Information Card -->
                <div class="card sky-card border-0 rounded-4 shadow-sm mb-4 overflow-hidden">
                    <div class="card-header bg-white py-3 px-4 border-bottom">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-envelope-at-fill text-primary fs-5"></i>
                            <h5 class="fw-bold mb-0 text-dark">Primary Contact Information</h5>
                        </div>
                        <small class="text-muted">Booking confirmation, e-tickets, and operational alerts will be sent here.</small>
                    </div>
                    <div class="card-body p-4">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="contactEmail" class="form-label fw-semibold small text-muted">Email Address *</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-envelope text-muted"></i></span>
                                    <input type="email" class="form-control border-start-0 ps-0" id="contactEmail" name="contactEmail"
                                           value="${not empty currentUser.email ? currentUser.email : ''}" required>
                                    <div class="invalid-feedback">A valid email address is required.</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label for="contactPhone" class="form-label fw-semibold small text-muted">Phone Number *</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-telephone text-muted"></i></span>
                                    <input type="tel" class="form-control border-start-0 ps-0" id="contactPhone" name="contactPhone"
                                           value="${not empty currentUser.phone ? currentUser.phone : ''}" required>
                                    <div class="invalid-feedback">A contact phone number is required.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Passenger Details Cards -->
                <c:forEach var="i" begin="1" end="${passengersCount}">
                    <div class="card sky-card border-0 rounded-4 shadow-sm mb-4 overflow-hidden">
                        <div class="card-header bg-white py-3 px-4 border-bottom d-flex align-items-center justify-content-between">
                            <div class="d-flex align-items-center gap-2">
                                <span class="badge bg-primary-subtle text-primary fw-bold px-2 py-1 rounded-pill">Traveler ${i}</span>
                                <h5 class="fw-bold mb-0 text-dark">
                                    <c:choose>
                                        <c:when test="${i == 1}">Lead Traveler (Account Holder)</c:when>
                                        <c:otherwise>Passenger ${i}</c:otherwise>
                                    </c:choose>
                                </h5>
                            </div>
                            <c:if test="${not empty selectedSeats && selectedSeats.size() >= i}">
                                <span class="badge bg-light text-dark border">
                                    <i class="bi bi-grid me-1 text-primary"></i>Seat: <strong>${selectedSeats[i - 1]}</strong>
                                </span>
                            </c:if>
                        </div>
                        <div class="card-body p-4">
                            <div class="row g-3">
                                <div class="col-md-2">
                                    <label class="form-label fw-semibold small text-muted">Title</label>
                                    <select class="form-select" name="title_${i}">
                                        <option value="MR">Mr</option>
                                        <option value="MS">Ms</option>
                                        <option value="MRS">Mrs</option>
                                    </select>
                                </div>
                                <div class="col-md-5">
                                    <label class="form-label fw-semibold small text-muted">First Name *</label>
                                    <input type="text" class="form-control" name="firstName_${i}"
                                           value="${i == 1 ? currentUser.firstName : ''}" required>
                                    <div class="invalid-feedback">First name is required.</div>
                                </div>
                                <div class="col-md-5">
                                    <label class="form-label fw-semibold small text-muted">Last Name *</label>
                                    <input type="text" class="form-control" name="lastName_${i}"
                                           value="${i == 1 ? currentUser.lastName : ''}" required>
                                    <div class="invalid-feedback">Last name is required.</div>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label fw-semibold small text-muted">Date of Birth</label>
                                    <input type="date" class="form-control" name="dob_${i}"
                                           value="${i == 1 && not empty currentUser.dateOfBirth ? currentUser.dateOfBirth : ''}">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold small text-muted">Gender</label>
                                    <select class="form-select" name="gender_${i}">
                                        <option value="MALE">Male</option>
                                        <option value="FEMALE">Female</option>
                                        <option value="OTHER">Other</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold small text-muted">Traveler Type</label>
                                    <select class="form-select" name="type_${i}">
                                        <option value="ADULT">Adult (12+ yrs)</option>
                                        <option value="CHILD">Child (2-11 yrs)</option>
                                        <option value="INFANT">Infant (Under 2)</option>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold small text-muted">Government ID / Passport No.</label>
                                    <input type="text" class="form-control" name="passport_${i}"
                                           value="${i == 1 && not empty currentUser.passportNumber ? currentUser.passportNumber : ''}"
                                           placeholder="Optional for domestic travel">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold small text-muted">Nationality</label>
                                    <input type="text" class="form-control" name="nationality_${i}" value="Indian">
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <!-- Action Button -->
                <div class="d-flex align-items-center justify-content-between pt-2">
                    <a href="${pageContext.request.contextPath}/flight-details?id=${schedule.scheduleId}&travelClass=${travelClass}&passengers=${passengersCount}&departureDate=${departureDate}"
                       class="btn btn-outline-secondary px-4 py-2 rounded-pill">
                        <i class="bi bi-arrow-left me-1"></i> Back to Flight Details
                    </a>
                    <button type="submit" class="btn btn-primary px-5 py-2 rounded-pill fw-semibold shadow-sm d-flex align-items-center gap-2">
                        Continue to Payment <i class="bi bi-arrow-right"></i>
                    </button>
                </div>
            </form>
        </div>

        <!-- Right: Flight Summary Sidebar -->
        <div class="col-lg-4">
            <div class="sticky-top" style="top: 90px;">
                <!-- Flight Card -->
                <div class="card sky-card border-0 rounded-4 shadow-sm mb-4 overflow-hidden">
                    <div class="card-header bg-dark text-white p-3 d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-airplane-engines-fill text-skytech-accent"></i>
                            <span class="fw-bold">${schedule.flight.airline.airlineName}</span>
                        </div>
                        <span class="badge bg-light text-dark">${schedule.flight.flightNumber}</span>
                    </div>
                    <div class="card-body p-3">
                        <div class="d-flex align-items-center justify-content-between text-center mb-3">
                            <div>
                                <div class="display-6 fw-bold text-dark">${schedule.flight.sourceAirport.airportCode}</div>
                                <div class="text-muted small">${schedule.flight.sourceAirport.city}</div>
                                <div class="badge bg-light text-dark border mt-1">${schedule.flight.formattedDepartureTime}</div>
                            </div>
                            <div class="px-2 text-muted">
                                <i class="bi bi-arrow-right fs-4 text-primary"></i>
                                <div class="small">${schedule.flight.durationFormatted}</div>
                            </div>
                            <div>
                                <div class="display-6 fw-bold text-dark">${schedule.flight.destinationAirport.airportCode}</div>
                                <div class="text-muted small">${schedule.flight.destinationAirport.city}</div>
                                <div class="badge bg-light text-dark border mt-1">${schedule.flight.formattedArrivalTime}</div>
                            </div>
                        </div>

                        <ul class="list-unstyled small text-muted border-top pt-3 mb-0 d-flex flex-column gap-2">
                            <li class="d-flex justify-content-between">
                                <span>Travel Date:</span>
                                <strong class="text-dark">${schedule.formattedFlightDate}</strong>
                            </li>
                            <li class="d-flex justify-content-between">
                                <span>Cabin Class:</span>
                                <strong class="text-dark">${travelClass}</strong>
                            </li>
                            <li class="d-flex justify-content-between">
                                <span>Passengers:</span>
                                <strong class="text-dark">${passengersCount} Traveler(s)</strong>
                            </li>
                            <c:if test="${not empty selectedSeats}">
                                <li class="d-flex justify-content-between">
                                    <span>Selected Seat(s):</span>
                                    <strong class="text-primary">${selectedSeatsStr}</strong>
                                </li>
                            </c:if>
                        </ul>
                    </div>
                </div>

                <!-- Fare Breakdown Card -->
                <div class="card sky-card border-0 rounded-4 shadow-sm p-4">
                    <h5 class="fw-bold text-dark mb-3">Fare Breakdown</h5>
                    <div class="d-flex justify-content-between small text-muted mb-2">
                        <span>Base Fare (${passengersCount} &times; &#8377;<fmt:formatNumber value="${perPassengerFare}" type="number" maxFractionDigits="0" />)</span>
                        <span class="text-dark fw-semibold">&#8377;<fmt:formatNumber value="${baseTotal}" type="number" maxFractionDigits="0" /></span>
                    </div>
                    <c:if test="${seatFeesTotal > 0}">
                        <div class="d-flex justify-content-between small text-muted mb-2">
                            <span>Seat Preference Fees</span>
                            <span class="text-dark fw-semibold">&#8377;<fmt:formatNumber value="${seatFeesTotal}" type="number" maxFractionDigits="0" /></span>
                        </div>
                    </c:if>
                    <div class="d-flex justify-content-between small text-muted mb-3">
                        <span>Airport Taxes &amp; GST (12%)</span>
                        <span class="text-dark fw-semibold">&#8377;<fmt:formatNumber value="${taxesAndFees}" type="number" maxFractionDigits="0" /></span>
                    </div>
                    <hr class="my-2">
                    <div class="d-flex justify-content-between align-items-center pt-2">
                        <span class="fw-bold text-dark fs-6">Total Payable</span>
                        <span class="display-6 fw-bold text-primary">&#8377;<fmt:formatNumber value="${grandTotal}" type="number" maxFractionDigits="0" /></span>
                    </div>
                    <small class="text-muted text-end d-block mt-1">All statutory taxes and fees included</small>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
