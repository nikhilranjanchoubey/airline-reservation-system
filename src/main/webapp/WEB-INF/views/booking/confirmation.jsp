<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Booking Confirmed - SkyTech" />
    <jsp:param name="activePage" value="flights" />
</jsp:include>
<jsp:include page="../common/navbar.jsp" />


<main class="container py-4 py-lg-5" style="max-width: 900px;">
    <!-- Confirmation Banner -->
    <div class="card sky-card border-0 rounded-4 shadow-sm text-center p-4 p-md-5 mb-4 bg-white">
        <div class="display-3 text-success mb-3">
            <i class="bi bi-check-circle-fill"></i>
        </div>
        <h2 class="fw-bold text-dark mb-2 font-heading">Flight Booking Confirmed!</h2>
        <p class="text-muted lead fs-6 mb-4">
            Thank you for booking with SkyTech. Your electronic ticket receipt has been issued and seat assignments have been reserved.
        </p>

        <!-- Prominent PNR Badge -->
        <div class="p-3 bg-light rounded-4 d-inline-block mx-auto border mb-4">
            <span class="text-muted text-uppercase font-monospace small d-block mb-1">Booking Reference (PNR)</span>
            <span class="display-5 fw-bold font-monospace text-primary tracking-wider">${booking.pnr}</span>
        </div>

        <!-- Quick Action Buttons -->
        <div class="d-flex flex-wrap justify-content-center gap-3">
            <a href="${pageContext.request.contextPath}/ticket/download?id=${booking.id}"
               class="btn btn-primary btn-lg rounded-pill px-4 shadow-sm d-flex align-items-center gap-2">
                <i class="bi bi-file-earmark-pdf-fill"></i> Download E-Ticket (PDF)
            </a>
            <button type="button" class="btn btn-outline-dark btn-lg rounded-pill px-4 d-flex align-items-center gap-2"
                    onclick="window.print()">
                <i class="bi bi-printer-fill"></i> Print Itinerary
            </button>
            <a href="${pageContext.request.contextPath}/my-bookings"
               class="btn btn-outline-primary btn-lg rounded-pill px-4 d-flex align-items-center gap-2">
                <i class="bi bi-briefcase-fill"></i> View in My Trips
            </a>
        </div>
    </div>

    <!-- Ticket Summary Card -->
    <div class="card sky-card border-0 rounded-4 shadow-sm overflow-hidden mb-4">
        <div class="card-header bg-dark text-white p-3 px-4 d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-airplane-fill text-skytech-accent"></i>
                <span class="fw-bold fs-5">Flight Details</span>
            </div>
            <span class="badge bg-success font-monospace px-3 py-2">CONFIRMED</span>
        </div>
        <div class="card-body p-4">
            <div class="row align-items-center text-center text-md-start mb-4">
                <div class="col-md-5 mb-3 mb-md-0">
                    <div class="display-6 fw-bold text-dark">${booking.originCode}</div>
                    <div class="text-muted small">Origin Airport</div>
                    <div class="badge bg-light text-dark border mt-1">Scheduled Date: ${booking.departureDate}</div>
                </div>
                <div class="col-md-2 text-center mb-3 mb-md-0">
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

            <!-- Passenger and Ticket Numbers Table -->
            <h6 class="fw-bold text-dark mb-3">Issued Passenger E-Tickets</h6>
            <div class="table-responsive">
                <table class="table table-bordered table-sm align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Passenger Name</th>
                            <th>Type</th>
                            <th>Seat</th>
                            <th>Ticket Number</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${booking.passengers}">
                            <tr>
                                <td class="fw-semibold text-dark"><i class="bi bi-person me-1"></i> ${p.fullName}</td>
                                <td>${p.passengerType}</td>
                                <td><span class="badge bg-primary">${not empty p.seatNumber ? p.seatNumber : 'Assigned at check-in'}</span></td>
                                <td class="font-monospace">${not empty p.ticketNumber ? p.ticketNumber : ('098-' += booking.id)}</td>
                                <td><span class="badge bg-success-subtle text-success">ISSUED</span></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <hr class="my-3">

            <!-- Payment Details -->
            <div class="row g-3">
                <div class="col-md-6">
                    <small class="text-muted d-block">Contact Email</small>
                    <strong class="text-dark">${booking.contactEmail}</strong>
                </div>
                <div class="col-md-6 text-md-end">
                    <small class="text-muted d-block">Total Paid (Statutory GST Included)</small>
                    <strong class="fs-5 text-primary">&#8377;<fmt:formatNumber value="${booking.totalAmount}" type="number" maxFractionDigits="2" /></strong>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
