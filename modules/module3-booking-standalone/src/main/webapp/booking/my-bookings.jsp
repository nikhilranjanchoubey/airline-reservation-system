<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.skytech.airlines.booking.model.Booking" %>
<%@ page import="com.skytech.airlines.booking.model.BookingStatus" %>
<%@ page import="com.skytech.airlines.booking.integration.FlightSummary" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    @SuppressWarnings("unchecked")
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    @SuppressWarnings("unchecked")
    Map<Long, FlightSummary> flightMap = (Map<Long, FlightSummary>) request.getAttribute("flightMap");
    String userName = (String) request.getAttribute("userName");
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
    String successMsg = (String) session.getAttribute("successMessage");
    if (successMsg != null) {
        session.removeAttribute("successMessage");
    }
    String errorMsg = (String) session.getAttribute("errorMessage");
    if (errorMsg != null) {
        session.removeAttribute("errorMessage");
    }
%>
<jsp:include page="/includes/header.jsp" />

<div class="container py-4">
    <!-- Success / Error Alert Messages -->
    <% if (successMsg != null) { %>
    <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i> <%= successMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <% } %>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="fw-bold text-navy mb-1"><i class="bi bi-journal-bookmark-fill text-primary me-2"></i> My Flight Bookings</h3>
            <p class="text-muted small mb-0">Passenger Portal &bull; Welcome, <%= (userName != null) ? userName : "Capt. Rajesh Sharma" %>.</p>
        </div>
        <a href="${pageContext.request.contextPath}/" class="btn btn-skytech-primary">
            <i class="bi bi-plus-lg me-1"></i> Book New Flight
        </a>
    </div>

    <% if (bookings == null || bookings.isEmpty()) { %>
        <!-- Empty State -->
        <div class="skytech-card text-center p-5">
            <div class="my-4">
                <i class="bi bi-airplane text-muted display-1"></i>
                <h4 class="fw-bold text-navy mt-3">No Active Bookings Found</h4>
                <p class="text-muted small mb-4">You have not booked any flights yet. Select a flight from the schedule to begin.</p>
                <a href="${pageContext.request.contextPath}/" class="btn btn-skytech-primary btn-lg">
                    Browse Flights &amp; Book Now
                </a>
            </div>
        </div>
    <% } else { %>
        <div class="row g-4">
            <% for (Booking b : bookings) {
                FlightSummary f = (flightMap != null) ? flightMap.get(b.getFlightId()) : null;
                boolean isCancelled = (b.getBookingStatus() == BookingStatus.CANCELLED);
                boolean isConfirmed = (b.getBookingStatus() == BookingStatus.CONFIRMED);
            %>
            <div class="col-lg-6">
                <div class="skytech-card h-100">
                    <div class="skytech-card-header">
                        <div>
                            <span class="text-muted small">PNR:</span>
                            <span class="fw-bold text-primary font-monospace fs-5 ms-1"><%= b.getPnr() %></span>
                        </div>
                        <span class="badge <%= isCancelled ? "bg-danger" : (isConfirmed ? "bg-success" : "bg-warning text-dark") %>">
                            <%= b.getBookingStatus() %>
                        </span>
                    </div>
                    <div class="skytech-card-body">
                        <% if (f != null) { %>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <h4 class="fw-bold text-navy mb-0"><%= f.getOriginAirportCode() %></h4>
                                <small class="text-muted"><%= f.getOriginCity() %></small>
                            </div>
                            <div class="text-center">
                                <small class="badge bg-light text-dark border"><%= f.getFlightNumber() %></small>
                                <div class="text-primary"><i class="bi bi-arrow-right fs-4"></i></div>
                            </div>
                            <div class="text-end">
                                <h4 class="fw-bold text-navy mb-0"><%= f.getDestAirportCode() %></h4>
                                <small class="text-muted"><%= f.getDestCity() %></small>
                            </div>
                        </div>
                        <% } %>

                        <div class="border-top pt-3 mb-3 small text-muted">
                            <div class="d-flex justify-content-between mb-1">
                                <span>Travelers:</span>
                                <span class="fw-semibold text-dark"><%= b.getPassengers() != null ? b.getPassengers().size() : 1 %> Passenger(s)</span>
                            </div>
                            <% if (f != null) { %>
                            <div class="d-flex justify-content-between mb-1">
                                <span>Commander:</span>
                                <span class="fw-semibold text-navy"><%= f.getCaptainName() %></span>
                            </div>
                            <div class="d-flex justify-content-between mb-1">
                                <span>Frequent Flyer:</span>
                                <span class="badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25">
                                    <i class="bi bi-award-fill me-1"></i><%= f.getFrequentFlyerTier() %> (+<%= f.getFrequentFlyerMiles() %> pts)
                                </span>
                            </div>
                            <% } %>
                            <div class="d-flex justify-content-between mb-1">
                                <span>Allocated Seats:</span>
                                <% if (isCancelled) { %>
                                    <span class="text-muted text-decoration-line-through"><%= b.getAllocatedSeatNumbersDisplay() %> (Released)</span>
                                <% } else { %>
                                    <span class="fw-semibold text-primary"><%= b.getAllocatedSeatNumbersDisplay() %></span>
                                <% } %>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span>Booking Date:</span>
                                <span class="fw-semibold text-dark"><%= b.getFormattedBookingDate() %></span>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center border-top pt-3">
                            <div>
                                <small class="text-muted d-block"><%= isCancelled ? "Refunded Amount:" : "Total Fare:" %></small>
                                <span class="fs-5 fw-bold <%= isCancelled ? "text-danger" : "text-primary" %>"><%= nf.format(b.getTotalAmount()) %></span>
                            </div>
                            <div class="d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/booking/confirmation?pnr=<%= b.getPnr() %>" 
                                   class="btn btn-outline-primary btn-sm">
                                    <i class="bi bi-ticket-perforated"></i> View Ticket
                                </a>
                                <% if (isConfirmed) { %>
                                <button type="button" class="btn btn-outline-danger btn-sm" 
                                        data-bs-toggle="modal" data-bs-target="#cancelModal_<%= b.getPnr() %>">
                                    <i class="bi bi-x-circle"></i> Cancel
                                </button>
                                <% } %>
                                <% if ("PENDING".equals(b.getBookingStatus().name())) { %>
                                <a href="${pageContext.request.contextPath}/booking/payment?pnr=<%= b.getPnr() %>" 
                                   class="btn btn-success btn-sm">
                                    <i class="bi bi-credit-card"></i> Pay Now
                                </a>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Cancellation Modal for Booking PNR -->
            <% if (isConfirmed) { %>
            <div class="modal fade" id="cancelModal_<%= b.getPnr() %>" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header bg-danger text-white">
                            <h5 class="modal-title fw-bold">
                                <i class="bi bi-exclamation-triangle-fill me-2"></i> Cancel Flight Booking
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <form action="${pageContext.request.contextPath}/booking/cancel" method="POST">
                            <div class="modal-body">
                                <p class="mb-3">Are you sure you want to cancel your flight reservation for <strong>PNR: <%= b.getPnr() %></strong>?</p>
                                
                                <div class="p-3 bg-light rounded border small mb-3">
                                    <% if (f != null) { %>
                                    <div class="d-flex justify-content-between mb-1">
                                        <span class="text-muted">Flight Route:</span>
                                        <strong><%= f.getOriginAirportCode() %> &rarr; <%= f.getDestAirportCode() %> (<%= f.getFlightNumber() %>)</strong>
                                    </div>
                                    <% } %>
                                    <div class="d-flex justify-content-between mb-1">
                                        <span class="text-muted">Allocated Seat(s):</span>
                                        <strong class="text-primary"><%= b.getAllocatedSeatNumbersDisplay() %></strong>
                                    </div>
                                    <div class="d-flex justify-content-between text-success fw-bold">
                                        <span>Refund Amount:</span>
                                        <span><%= nf.format(b.getTotalAmount()) %></span>
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

                                <input type="hidden" name="pnr" value="<%= b.getPnr() %>">

                                <p class="text-muted small mb-0">
                                    <i class="bi bi-info-circle me-1"></i> Allocated seats will be released back into inventory immediately, and your payment will be refunded to your source payment method.
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

            <% } %>
        </div>
    <% } %>
</div>

<jsp:include page="/includes/footer.jsp" />
