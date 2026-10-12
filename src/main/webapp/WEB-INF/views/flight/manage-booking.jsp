<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Manage Booking - SkyTech" />
    <jsp:param name="activePage" value="manage" />
</jsp:include>
<jsp:include page="../common/navbar.jsp" />

<main class="container py-4 py-lg-5" style="max-width: 1000px;">
    <!-- Page Title Header -->
    <div class="text-center mb-4">
        <span class="badge bg-primary-subtle text-primary fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill">
            Guest Self-Service Portal
        </span>
        <h1 class="display-6 fw-bold text-dark font-heading">Manage Your Flight Booking</h1>
        <p class="text-muted small">Retrieve your electronic ticket, check flight schedules, or process ticket cancellation.</p>
    </div>

    <!-- Flash Notifications -->
    <c:if test="${not empty flashSuccess}">
        <div class="alert alert-success alert-dismissible fade show rounded-4 shadow-sm mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            <c:out value="${flashSuccess}" />
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${not empty flashError}">
        <div class="alert alert-danger alert-dismissible fade show rounded-4 shadow-sm mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <c:out value="${flashError}" />
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-warning alert-dismissible fade show rounded-4 shadow-sm mb-4" role="alert">
            <i class="bi bi-info-circle-fill me-2 fs-5"></i>
            <c:out value="${errorMessage}" />
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Search Form Card (if no booking retrieved yet) -->
    <c:if test="${empty booking}">
        <div class="card sky-card border-0 rounded-4 p-4 p-md-5 bg-white shadow-sm mb-4">
            <form action="${pageContext.request.contextPath}/manage-booking" method="POST">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label for="pnrInput" class="form-label fw-bold small text-uppercase text-muted">
                            Booking Reference / PNR *
                        </label>
                        <div class="input-group input-group-lg">
                            <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-ticket-perforated"></i></span>
                            <input type="text" class="form-control bg-light border-start-0 text-uppercase font-monospace fw-bold" id="pnrInput" name="pnr"
                                   placeholder="e.g. SKYT99" maxlength="15" required value="${searchedPnr}">
                        </div>
                        <div class="form-text small text-muted">Found on your booking confirmation or SMS alert.</div>
                    </div>

                    <div class="col-md-6">
                        <label for="lastNameInput" class="form-label fw-bold small text-uppercase text-muted">
                            Passenger Last Name *
                        </label>
                        <div class="input-group input-group-lg">
                            <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-person"></i></span>
                            <input type="text" class="form-control bg-light border-start-0 fw-semibold" id="lastNameInput" name="lastName"
                                   placeholder="e.g. Choubey" required value="${searchedLastName}">
                        </div>
                        <div class="form-text small text-muted">Required for guest verification and identity safety.</div>
                    </div>
                </div>

                <div class="mt-4">
                    <button type="submit" class="btn btn-primary btn-lg w-100 rounded-pill py-3 fw-bold shadow-sm d-flex align-items-center justify-content-center gap-2">
                        <i class="bi bi-search"></i> Retrieve Reservation
                    </button>
                </div>
            </form>
        </div>

        <!-- Quick Logged-In User Bookings Shortcut -->
        <c:if test="${not empty userBookings}">
            <div class="card sky-card border-0 rounded-4 shadow-sm p-4 bg-white mb-4">
                <h6 class="fw-bold text-dark mb-3">Your Recent Bookings:</h6>
                <div class="list-group list-group-flush">
                    <c:forEach var="ub" items="${userBookings}">
                        <a href="${pageContext.request.contextPath}/manage-booking?pnr=${not empty ub.pnr ? ub.pnr : ub.bookingReference}"
                           class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3">
                            <div>
                                <span class="font-monospace fw-bold text-primary">${not empty ub.pnr ? ub.pnr : ub.bookingReference}</span>
                                <span class="text-dark fw-semibold ms-2">${ub.originCode} &rarr; ${ub.destinationCode}</span>
                                <small class="text-muted ms-2">(${ub.departureDate})</small>
                            </div>
                            <div>
                                <span class="badge ${ub.status == 'CONFIRMED' ? 'bg-success' : (ub.status == 'CANCELLED' ? 'bg-danger' : 'bg-warning text-dark')} px-3 py-1 rounded-pill">
                                    ${ub.status}
                                </span>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </div>
        </c:if>
    </c:if>

    <!-- Retrieved Booking Details Display -->
    <c:if test="${not empty booking}">
        <div class="card sky-card border-0 rounded-4 shadow-sm overflow-hidden mb-4 bg-white">
            <div class="card-header bg-dark text-white p-3 px-4 d-flex align-items-center justify-content-between">
                <div>
                    <span class="text-sky-cyan small text-uppercase font-monospace fw-bold">Booking Reference (PNR)</span>
                    <h4 class="mb-0 font-monospace fw-bold text-white">${booking.pnr != null ? booking.pnr : booking.bookingReference}</h4>
                </div>
                <div>
                    <c:choose>
                        <c:when test="${booking.status == 'CONFIRMED'}">
                            <span class="badge bg-success font-monospace px-3 py-2 fs-7">CONFIRMED</span>
                        </c:when>
                        <c:when test="${booking.status == 'CANCELLED'}">
                            <span class="badge bg-danger font-monospace px-3 py-2 fs-7">CANCELLED</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-warning text-dark font-monospace px-3 py-2 fs-7">${booking.status}</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card-body p-4">
                <!-- Flight Summary -->
                <div class="row align-items-center text-center text-md-start mb-4">
                    <div class="col-md-5">
                        <div class="display-6 fw-bold text-dark">${booking.originCode}</div>
                        <div class="text-muted small">Origin Airport</div>
                        <div class="badge bg-light text-dark border mt-1">Date: ${booking.departureDate}</div>
                    </div>
                    <div class="col-md-2 text-center my-3 my-md-0">
                        <i class="bi bi-arrow-right fs-3 text-primary d-none d-md-inline"></i>
                        <i class="bi bi-arrow-down fs-3 text-primary d-inline d-md-none"></i>
                        <div class="small text-muted font-monospace">${booking.flightNumber}</div>
                    </div>
                    <div class="col-md-5 text-md-end">
                        <div class="display-6 fw-bold text-dark">${booking.destinationCode}</div>
                        <div class="text-muted small">Destination Airport</div>
                        <div class="badge bg-light text-dark border mt-1">Class: ${booking.travelClass}</div>
                    </div>
                </div>

                <hr class="my-3">

                <!-- Passengers List -->
                <h6 class="fw-bold text-dark mb-3">Passenger &amp; Seat Manifest</h6>
                <div class="table-responsive mb-4">
                    <table class="table table-bordered table-sm align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Passenger</th>
                                <th>Type</th>
                                <th>Assigned Seat</th>
                                <th>Ticket Number</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${booking.passengers}">
                                <tr>
                                    <td class="fw-semibold text-dark"><i class="bi bi-person me-1"></i> ${p.fullName}</td>
                                    <td>${p.passengerType}</td>
                                    <td><span class="badge bg-primary">${not empty p.seatNumber ? p.seatNumber : 'Assigned at check-in'}</span></td>
                                    <td class="font-monospace">${not empty p.ticketNumber ? p.ticketNumber : ('098-' += booking.id)}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Financial / Cancellation Breakdown -->
                <c:if test="${booking.status == 'CANCELLED' && not empty booking.cancellation}">
                    <div class="alert alert-danger border-0 rounded-3 p-3 mb-4">
                        <h6 class="fw-bold mb-1"><i class="bi bi-exclamation-triangle-fill me-1"></i> Reservation Cancelled</h6>
                        <div class="small">
                            Reason: <strong><c:out value="${booking.cancellation.cancellationReason}" /></strong><br>
                            Cancellation Fee Applied: <strong>&#8377;<fmt:formatNumber value="${booking.cancellation.cancellationFee}" type="number" maxFractionDigits="2" /></strong><br>
                            Refund Amount Processed: <strong>&#8377;<fmt:formatNumber value="${booking.cancellation.refundAmount}" type="number" maxFractionDigits="2" /></strong><br>
                            Refund Reference: <span class="font-monospace">${booking.cancellation.refundReference}</span>
                        </div>
                    </div>
                </c:if>

                <!-- Actions Bar -->
                <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 pt-2 border-top">
                    <div>
                        <a href="${pageContext.request.contextPath}/manage-booking" class="btn btn-outline-secondary rounded-pill px-3">
                            <i class="bi bi-arrow-left me-1"></i> Search Another Booking
                        </a>
                    </div>
                    <div class="d-flex gap-2">
                        <c:if test="${booking.status == 'CONFIRMED'}">
                            <a href="${pageContext.request.contextPath}/ticket/download?id=${booking.id}"
                               class="btn btn-primary rounded-pill px-4 d-flex align-items-center gap-2">
                                <i class="bi bi-file-earmark-pdf-fill"></i> Download E-Ticket
                            </a>
                            <button type="button" class="btn btn-outline-dark rounded-pill px-3" onclick="window.print()">
                                <i class="bi bi-printer"></i> Print
                            </button>
                            <button type="button" class="btn btn-outline-danger rounded-pill px-4"
                                    data-bs-toggle="modal" data-bs-target="#cancelBookingModal">
                                <i class="bi bi-x-circle me-1"></i> Cancel Booking
                            </button>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cancellation Policy Confirmation Modal -->
        <div class="modal fade" id="cancelBookingModal" tabindex="-1" aria-labelledby="cancelBookingModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content shadow border-0 rounded-4">
                    <form action="${pageContext.request.contextPath}/booking/cancel" method="POST">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="bookingId" value="${booking.id}">
                        <input type="hidden" name="pnr" value="${booking.pnr}">

                        <div class="modal-header border-bottom">
                            <h5 class="modal-title fw-bold text-danger" id="cancelBookingModalLabel">
                                <i class="bi bi-exclamation-octagon-fill me-2"></i>Confirm Flight Cancellation
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body p-4">
                            <p class="text-muted small mb-3">
                                Are you sure you wish to cancel reservation <strong>${booking.pnr}</strong> (${booking.flightNumber})?
                            </p>

                            <!-- Academic Project Cancellation Policy Notice -->
                            <div class="p-3 bg-light rounded-3 border small mb-3">
                                <strong class="d-block text-dark mb-1">Academic Project Cancellation Policy:</strong>
                                <ul class="mb-0 ps-3 text-muted">
                                    <li>Standard cancellation fee: 25% of fare (capped at &#8377;1,000/passenger).</li>
                                    <li>Total Paid: <strong>&#8377;<fmt:formatNumber value="${booking.totalAmount}" type="number" maxFractionDigits="2" /></strong></li>
                                    <li>Estimated Refund: <strong>75%+ of eligible ticket value</strong></li>
                                    <li>Seat assignments will be immediately released to inventory.</li>
                                </ul>
                            </div>

                            <div class="mb-3">
                                <label for="cancelReason" class="form-label fw-semibold small text-muted">Reason for Cancellation</label>
                                <select class="form-select" id="cancelReason" name="reason">
                                    <option value="Change of travel plans">Change of travel plans</option>
                                    <option value="Personal / Medical emergency">Personal / Medical emergency</option>
                                    <option value="Found alternate schedule">Found alternate schedule</option>
                                    <option value="College project demonstration test">College project demonstration test</option>
                                </select>
                            </div>
                        </div>
                        <div class="modal-footer border-top">
                            <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Keep Booking</button>
                            <button type="submit" class="btn btn-danger rounded-pill px-4 fw-semibold">Confirm Cancellation</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </c:if>
</main>

<jsp:include page="../common/footer.jsp" />
