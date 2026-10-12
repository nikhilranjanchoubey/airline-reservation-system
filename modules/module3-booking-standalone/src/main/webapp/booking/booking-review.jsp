<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.skytech.airlines.booking.integration.FlightSummary" %>
<%@ page import="com.skytech.airlines.booking.model.Passenger" %>
<%@ page import="com.skytech.airlines.booking.model.FareBreakdown" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    request.setAttribute("stepNumber", 4);
    FlightSummary flight = (FlightSummary) request.getAttribute("flight");
    @SuppressWarnings("unchecked")
    List<Passenger> passengers = (List<Passenger>) request.getAttribute("passengers");
    @SuppressWarnings("unchecked")
    List<String> selectedSeats = (List<String>) request.getAttribute("selectedSeats");
    FareBreakdown fare = (FareBreakdown) request.getAttribute("fare");
    String contactEmail = (String) request.getAttribute("contactEmail");
    String contactPhone = (String) request.getAttribute("contactPhone");
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>
<jsp:include page="/includes/header.jsp" />
<jsp:include page="/includes/stepper.jsp" />

<div class="container pb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold text-navy mb-1"><i class="bi bi-file-earmark-check-fill text-primary me-2"></i> Review Your Booking</h4>
            <p class="text-muted small mb-0">Please verify flight details, passenger roster, allocated seats, and authoritative fare summary before proceeding to payment.</p>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-8">
            <!-- Flight Card -->
            <div class="skytech-card mb-4">
                <div class="skytech-card-header">
                    <div><i class="bi bi-airplane-engines text-primary me-2"></i> Flight Details</div>
                    <span class="badge bg-primary"><%= flight != null ? flight.getFlightNumber() : "SK-701" %></span>
                </div>
                <div class="skytech-card-body">
                    <% if (flight != null) { %>
                    <div class="row align-items-center text-center text-md-start">
                        <div class="col-md-4 mb-2 mb-md-0">
                            <span class="text-muted small">Origin</span>
                            <div class="fs-4 fw-bold text-navy"><%= flight.getOriginAirportCode() %></div>
                            <small class="text-muted"><%= flight.getOriginCity() %></small>
                            <div class="fw-semibold text-primary mt-1"><%= flight.getFormattedDeparture() %></div>
                        </div>
                        <div class="col-md-4 mb-2 mb-md-0 text-center">
                            <span class="badge bg-light text-dark border px-3 py-1 mb-1"><i class="bi bi-clock"></i> <%= flight.getFormattedDuration() %></span>
                            <div class="text-primary"><i class="bi bi-airplane-fill fs-5"></i></div>
                            <span class="text-success small fw-semibold">Non-stop Direct</span>
                        </div>
                        <div class="col-md-4 text-md-end">
                            <span class="text-muted small">Destination</span>
                            <div class="fs-4 fw-bold text-navy"><%= flight.getDestAirportCode() %></div>
                            <small class="text-muted"><%= flight.getDestCity() %></small>
                            <div class="fw-semibold text-primary mt-1"><%= flight.getFormattedArrival() %></div>
                        </div>
                    </div>
                    <div class="row pt-3 mt-3 border-top small text-muted">
                        <div class="col-6"><strong>Aircraft:</strong> <%= flight.getAircraftModel() %></div>
                        <div class="col-6 text-end"><strong>Flight Commander:</strong> <span class="text-navy fw-semibold"><%= flight.getCaptainName() %></span></div>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Passengers & Allocated Seats -->
            <div class="skytech-card mb-4">
                <div class="skytech-card-header">
                    <div><i class="bi bi-people-fill text-primary me-2"></i> Passenger &amp; Seat Allocation</div>
                    <span class="badge bg-light text-dark border"><%= passengers != null ? passengers.size() : 1 %> Travelers</span>
                </div>
                <div class="skytech-card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light small">
                                <tr>
                                    <th class="ps-4">Passenger Name</th>
                                    <th>Category</th>
                                    <th>Gender</th>
                                    <th>Seat</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (passengers != null) {
                                    for (Passenger p : passengers) { %>
                                <tr>
                                    <td class="ps-4 fw-semibold text-navy"><%= p.getFullName() %></td>
                                    <td><span class="badge bg-secondary"><%= p.getPassengerType() %></span></td>
                                    <td><%= p.getGender() %></td>
                                    <td><span class="badge bg-primary fs-6"><%= p.getSeatNumber() %></span></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Contact Information -->
            <div class="skytech-card mb-4">
                <div class="skytech-card-header">
                    <div><i class="bi bi-envelope-check text-primary me-2"></i> Contact &amp; E-Ticket Delivery</div>
                </div>
                <div class="skytech-card-body">
                    <div class="row">
                        <div class="col-md-6 mb-2 mb-md-0">
                            <small class="text-muted d-block">Delivery Email:</small>
                            <span class="fw-semibold text-navy"><%= contactEmail %></span>
                        </div>
                        <div class="col-md-6">
                            <small class="text-muted d-block">Mobile Phone:</small>
                            <span class="fw-semibold text-navy"><%= contactPhone %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Frequent Flyer Loyalty Accrual -->
            <%
                String ffOption = (String) session.getAttribute("frequentFlyerOption");
                if (ffOption == null || ffOption.isEmpty()) {
                    ffOption = (flight != null) ? "SKYTECH SkyRewards (" + flight.getFrequentFlyerTier() + ")" : "SKYTECH SkyRewards";
                }
                String ffNumber = (String) session.getAttribute("frequentFlyerNumber");
                if (ffNumber == null || ffNumber.isEmpty()) {
                    ffNumber = "SKY-884920";
                }
            %>
            <div class="skytech-card mb-4">
                <div class="skytech-card-header">
                    <div><i class="bi bi-award-fill text-primary me-2"></i> Frequent Flyer &amp; Loyalty Accrual</div>
                    <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25">+<%= flight != null ? flight.getFrequentFlyerMiles() : 750 %> SkyPoints</span>
                </div>
                <div class="skytech-card-body">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <div><span class="text-muted small d-block">Selected Program / Tier:</span><strong class="text-navy"><%= ffOption %></strong></div>
                        <div class="text-end"><span class="text-muted small d-block">Loyalty Member ID:</span><span class="badge bg-primary fs-6 font-monospace"><%= ffNumber %></span></div>
                    </div>
                    <div class="p-2 rounded border small text-muted bg-light mt-2"><i class="bi bi-gift-fill text-warning me-1"></i><strong>Eligible Flight Perks:</strong> <%= flight != null ? flight.getFrequentFlyerPerks() : "Standard Privileges" %></div>
                </div>
            </div>
        </div>

        <!-- Authoritative Fare Breakdown Sidebar -->
        <div class="col-lg-4">
            <div class="skytech-card sticky-top" style="top: 90px;">
                <div class="skytech-card-header">
                    <div><i class="bi bi-receipt text-primary me-2"></i> Fare Summary</div>
                    <span class="badge bg-success">Server Calculated</span>
                </div>
                <div class="skytech-card-body">
                    <% if (fare != null) { %>
                    <div class="d-flex justify-content-between mb-2 small">
                        <span class="text-muted">Base Airfare</span>
                        <span class="fw-semibold"><%= nf.format(fare.getBaseFare()) %></span>
                    </div>
                    <div class="d-flex justify-content-between mb-2 small">
                        <span class="text-muted">Seat Selection Surcharges</span>
                        <span class="fw-semibold"><%= nf.format(fare.getSeatFees()) %></span>
                    </div>
                    <div class="d-flex justify-content-between mb-2 small">
                        <span class="text-muted">Aviation Tax &amp; GST (12%)</span>
                        <span class="fw-semibold"><%= nf.format(fare.getTaxAmount()) %></span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <span class="fw-bold text-navy fs-5">Total Payable</span>
                        <span class="fw-bold text-primary fs-4"><%= nf.format(fare.getTotalAmount()) %></span>
                    </div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/booking/review" method="POST">
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-skytech-primary btn-lg fw-bold">
                                Proceed to Payment <i class="bi bi-lock-fill ms-1"></i>
                            </button>
                            <a href="${pageContext.request.contextPath}/booking/seats" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left me-1"></i> Modify Seats
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
