<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.skytech.airlines.booking.model.Booking" %>
<%@ page import="com.skytech.airlines.booking.model.BookingStatus" %>
<%@ page import="com.skytech.airlines.booking.integration.FlightSummary" %>
<%@ page import="com.skytech.airlines.booking.model.Passenger" %>
<%@ page import="com.skytech.airlines.booking.model.Payment" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("stepNumber", 6);
    Booking booking = (Booking) request.getAttribute("booking");
    FlightSummary flight = (FlightSummary) request.getAttribute("flight");
    @SuppressWarnings("unchecked")
    List<Passenger> passengers = (List<Passenger>) request.getAttribute("passengers");
    Payment payment = (Payment) request.getAttribute("payment");
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
    boolean isCancelled = (booking != null && booking.getBookingStatus() == BookingStatus.CANCELLED);
%>
<jsp:include page="/includes/header.jsp" />
<jsp:include page="/includes/stepper.jsp" />

<div class="container pb-5">
    <% if (isCancelled) { %>
        <!-- Cancelled State Banner -->
        <div class="text-center mb-4">
            <div class="d-inline-flex align-items-center justify-content-center bg-danger text-white rounded-circle mb-3" style="width: 70px; height: 70px;">
                <i class="bi bi-x-lg fs-1"></i>
            </div>
            <h2 class="fw-bold text-navy">Booking Cancelled</h2>
            <p class="text-muted">This reservation has been cancelled. Allocated seats have been released and a full refund of <strong><%= booking != null ? nf.format(booking.getTotalAmount()) : "" %></strong> has been initiated.</p>
        </div>
    <% } else { %>
        <!-- Confirmed State Banner -->
        <div class="text-center mb-4">
            <div class="d-inline-flex align-items-center justify-content-center bg-success text-white rounded-circle mb-3" style="width: 70px; height: 70px;">
                <i class="bi bi-check-lg fs-1"></i>
            </div>
            <h2 class="fw-bold text-navy">Booking Confirmed!</h2>
            <p class="text-muted">Your seats have been confirmed and payment was verified successfully via Razorpay.</p>
        </div>
    <% } %>

    <div class="row justify-content-center">
        <div class="col-lg-8">
            <!-- Printable E-Ticket Card -->
            <div class="skytech-card mb-4" id="eTicketCard">
                <div class="skytech-card-header bg-navy text-white" style="background-color: #071629; color: white;">
                    <div class="d-flex align-items-center gap-2">
                        <svg class="skytech-logo-plane" style="width:28px;height:28px;" viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path fill="#19A7D8" d="M 20 1.5 C 21.2 0 22.8 0 24 1.5 C 24.8 2.8 25.3 4.8 25.3 7.5 L 25.3 17.5 L 39 24.2 C 40.5 25 41 26.2 41 27.6 L 41 31 C 41 31.8 40.2 32.5 39.4 32.3 L 25.3 30 L 24.4 33.8 L 28.3 37.5 C 28.8 38 29.1 38.7 29.1 39.5 L 29.1 42 L 22 38.8 L 14.9 42 L 14.9 39.5 C 14.9 38.7 15.2 38 15.7 37.5 L 19.6 33.8 L 18.7 30 L 4.6 32.3 C 3.8 32.5 3 31.8 3 31 L 3 27.6 C 3 26.2 3.5 25 5 24.2 L 18.7 17.5 L 18.7 7.5 C 18.7 4.8 19.2 2.8 20 1.5 Z"/>
                        </svg>
                        <div class="skytech-logo-text">
                            <span class="skytech-logo-title" style="font-size:1.15rem;">SKYTECH</span>
                            <span class="skytech-logo-subtitle" style="font-size:0.5rem;letter-spacing:3px;">AIRLINES</span>
                        </div>
                        <span class="ms-2 text-white-50 small">&bull; ELECTRONIC TICKET</span>
                    </div>
                    <% if (isCancelled) { %>
                        <span class="badge bg-danger px-3 py-2 fs-6">CANCELLED</span>
                    <% } else { %>
                        <span class="badge bg-success px-3 py-2 fs-6">CONFIRMED</span>
                    <% } %>
                </div>
                <div class="skytech-card-body p-4">
                    <!-- PNR and Booking Date -->
                    <div class="row border-bottom pb-3 mb-3">
                        <div class="col-6">
                            <span class="text-muted small d-block">Booking Reference (PNR):</span>
                            <span class="fs-2 fw-bold text-primary font-monospace"><%= booking != null ? booking.getPnr() : "SK8M2P" %></span>
                        </div>
                        <div class="col-6 text-end">
                            <span class="text-muted small d-block">Booking Date &amp; Time:</span>
                            <span class="fw-semibold text-navy"><%= booking != null ? booking.getFormattedBookingDate() : "" %></span>
                        </div>
                    </div>

                    <!-- Flight Itinerary -->
                    <% if (flight != null) { %>
                    <div class="row align-items-center text-center text-md-start py-3 border-bottom mb-3">
                        <div class="col-md-4 mb-2 mb-md-0">
                            <span class="text-muted small">Origin</span>
                            <div class="fs-3 fw-bold text-navy"><%= flight.getOriginAirportCode() %></div>
                            <small class="text-muted"><%= flight.getOriginCity() %></small>
                            <div class="fw-bold text-primary mt-1"><%= flight.getFormattedDeparture() %></div>
                        </div>
                        <div class="col-md-4 mb-2 mb-md-0 text-center">
                            <span class="badge bg-light text-dark border px-3 py-1 mb-1"><%= flight.getFlightNumber() %> &bull; <%= flight.getFormattedDuration() %></span>
                            <div class="text-primary"><i class="bi bi-airplane-fill fs-4"></i></div>
                            <span class="text-success small fw-semibold">Non-stop Direct</span>
                        </div>
                        <div class="col-md-4 text-md-end">
                            <span class="text-muted small">Destination</span>
                            <div class="fs-3 fw-bold text-navy"><%= flight.getDestAirportCode() %></div>
                            <small class="text-muted"><%= flight.getDestCity() %></small>
                            <div class="fw-bold text-primary mt-1"><%= flight.getFormattedArrival() %></div>
                        </div>
                    </div>
                    <div class="row bg-light rounded p-2 mb-3 border small">
                        <div class="col-md-6 mb-1 mb-md-0">
                            <i class="bi bi-person-badge-fill text-primary me-1"></i><strong>Flight Commander:</strong> 
                            <span class="text-navy fw-semibold"><%= flight.getCaptainName() %></span>
                        </div>
                        <div class="col-md-6 text-md-end">
                            <i class="bi bi-airplane-fill text-primary me-1"></i><strong>Aircraft Fleet:</strong> 
                            <span class="text-navy fw-semibold"><%= flight.getAircraftModel() %></span>
                        </div>
                    </div>
                    <% } %>

                    <!-- Passenger & Seat Table -->
                    <h6 class="fw-bold text-navy mb-2"><i class="bi bi-people-fill text-primary me-2"></i> Passenger Manifest:</h6>
                    <div class="table-responsive mb-4">
                        <table class="table table-bordered align-middle mb-0">
                            <thead class="table-light small">
                                <tr>
                                    <th>#</th>
                                    <th>Passenger Name</th>
                                    <th>Category</th>
                                    <th>Gender</th>
                                    <th>Seat Assigned</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (passengers != null) {
                                    for (int i = 0; i < passengers.size(); i++) {
                                        Passenger p = passengers.get(i);
                                %>
                                <tr>
                                    <td><%= (i + 1) %></td>
                                    <td class="fw-bold text-navy"><%= p.getFullName() %></td>
                                    <td><%= p.getPassengerType() %></td>
                                    <td><%= p.getGender() %></td>
                                    <td>
                                        <% if (isCancelled) { %>
                                            <span class="badge bg-secondary fs-6"><%= p.getSeatNumber() %> (Released)</span>
                                        <% } else { %>
                                            <span class="badge bg-primary fs-6"><%= p.getSeatNumber() %></span>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Payment Verification Box -->
                    <div class="p-3 bg-light rounded border mb-3 small">
                        <div class="row g-2">
                            <div class="col-md-4">
                                <span class="text-muted d-block">Payment Status:</span>
                                <% if (isCancelled) { %>
                                    <span class="badge bg-danger"><i class="bi bi-arrow-counterclockwise"></i> REFUNDED</span>
                                <% } else { %>
                                    <span class="badge bg-success"><i class="bi bi-check-circle-fill"></i> <%= (payment != null && payment.getPaymentStatus() != null) ? payment.getPaymentStatus() : "SUCCESS" %></span>
                                <% } %>
                            </div>
                            <div class="col-md-4">
                                <span class="text-muted d-block">Razorpay Payment ID:</span>
                                <code><%= (payment != null && payment.getRazorpayPaymentId() != null) ? payment.getRazorpayPaymentId() : "pay_verified_001" %></code>
                            </div>
                            <div class="col-md-4">
                                <span class="text-muted d-block"><%= isCancelled ? "Refunded Amount:" : "Total Paid:" %></span>
                                <span class="fw-bold text-navy fs-6"><%= booking != null ? nf.format(booking.getTotalAmount()) : "" %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Frequent Flyer Program Credited Box -->
                    <div class="p-3 rounded border mb-3 small" style="background: #F0F7FF; border-color: #BAE6FD;">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <div>
                                <i class="bi bi-award-fill text-primary me-1"></i>
                                <strong>Frequent Flyer Program:</strong> 
                                <span class="badge bg-primary"><%= flight != null ? flight.getFrequentFlyerTier() : "Silver Tier" %></span>
                                <span class="text-muted font-monospace ms-2">ID: SKY-884920</span>
                            </div>
                            <div class="text-end fw-bold text-primary">
                                <i class="bi bi-stars text-warning me-1"></i>+<%= flight != null ? flight.getFrequentFlyerMiles() : 750 %> SkyPoints Credited
                            </div>
                        </div>
                        <div class="text-muted small mt-1">
                            <i class="bi bi-check2-circle text-success me-1"></i>Tier Privileges Applied: <%= flight != null ? flight.getFrequentFlyerPerks() : "Standard Privileges" %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2">
                <button type="button" class="btn btn-outline-dark" onclick="window.print()">
                    <i class="bi bi-printer-fill me-1"></i> <%= isCancelled ? "Print Cancellation Receipt" : "Print E-Ticket" %>
                </button>
                <div class="d-flex gap-2">
                    <% if (!isCancelled) { %>
                    <button type="button" class="btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="#cancelModal">
                        <i class="bi bi-x-circle me-1"></i> Cancel Booking
                    </button>
                    <% } %>
                    <a href="${pageContext.request.contextPath}/booking/my-bookings" class="btn btn-skytech-primary">
                        <i class="bi bi-journal-bookmark-fill me-1"></i> Go to My Bookings
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Cancellation Confirmation Modal -->
<% if (!isCancelled && booking != null) { %>
<div class="modal fade" id="cancelModal" tabindex="-1" aria-labelledby="cancelModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title fw-bold" id="cancelModalLabel">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> Cancel Flight Reservation
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/booking/cancel" method="POST">
                <div class="modal-body">
                    <p class="mb-3">Are you sure you want to cancel your flight reservation for <strong>PNR: <%= booking.getPnr() %></strong>?</p>
                    
                    <div class="p-3 bg-light rounded border small mb-3">
                        <% if (flight != null) { %>
                        <div class="d-flex justify-content-between mb-1">
                            <span class="text-muted">Flight Route:</span>
                            <strong class="text-navy"><%= flight.getOriginAirportCode() %> &rarr; <%= flight.getDestAirportCode() %> (<%= flight.getFlightNumber() %>)</strong>
                        </div>
                        <% } %>
                        <div class="d-flex justify-content-between mb-1">
                            <span class="text-muted">Allocated Seat(s):</span>
                            <strong class="text-primary"><%= booking.getAllocatedSeatNumbersDisplay() %></strong>
                        </div>
                        <div class="d-flex justify-content-between text-success fw-bold">
                            <span>Refund Amount:</span>
                            <span><%= nf.format(booking.getTotalAmount()) %></span>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Reason for Cancellation:</label>
                        <select name="reason" class="form-select form-select-sm" required>
                            <option value="Change of travel plans">Change of travel plans</option>
                            <option value="Personal emergency">Personal emergency</option>
                            <option value="Schedule conflict">Schedule conflict</option>
                            <option value="Found alternative flight">Found alternative flight</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>

                    <input type="hidden" name="pnr" value="<%= booking.getPnr() %>">

                    <p class="text-muted small mb-0">
                        <i class="bi bi-info-circle me-1"></i> Once cancelled, your seat allocation will be released immediately and a 100% refund will be processed to your original payment method.
                    </p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Keep Booking</button>
                    <button type="submit" class="btn btn-danger fw-bold">
                        <i class="bi bi-x-circle-fill me-1"></i> Confirm Cancellation &amp; Refund
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
<% } %>

<jsp:include page="/includes/footer.jsp" />
