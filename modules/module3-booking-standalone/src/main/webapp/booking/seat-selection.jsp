<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.skytech.airlines.booking.integration.FlightSummary" %>
<%@ page import="com.skytech.airlines.booking.model.Passenger" %>
<%@ page import="com.skytech.airlines.booking.model.Seat" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("stepNumber", 3);
    FlightSummary flight = (FlightSummary) request.getAttribute("flight");
    @SuppressWarnings("unchecked")
    List<Passenger> passengers = (List<Passenger>) request.getAttribute("passengers");
    @SuppressWarnings("unchecked")
    List<Seat> cabinSeats = (List<Seat>) request.getAttribute("cabinSeats");
    String seatError = (String) request.getAttribute("seatError");
%>
<jsp:include page="/includes/header.jsp" />
<jsp:include page="/includes/stepper.jsp" />

<div class="container pb-5">
    <% if (seatError != null) { %>
        <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= seatError %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <div class="row g-4">
        <!-- Interactive Aircraft Cabin Map -->
        <div class="col-lg-7">
            <div class="skytech-card">
                <div class="skytech-card-header">
                    <div><i class="bi bi-grid-3x3-gap-fill text-primary me-2"></i> Aircraft Seat Map</div>
                    <span class="badge bg-light text-dark border">Airbus A320neo &bull; 3-3 Configuration</span>
                </div>
                <div class="skytech-card-body text-center">
                    <!-- Legend -->
                    <div class="d-flex justify-content-center gap-3 flex-wrap mb-4 small">
                        <div class="d-flex align-items-center gap-1">
                            <span class="seat-box" style="width:20px;height:20px;font-size:0.5rem;"></span> Available
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <span class="seat-box selected" style="width:20px;height:20px;font-size:0.5rem;"></span> Selected
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <span class="seat-box business" style="width:20px;height:20px;font-size:0.5rem;"></span> Business (+₹1,500)
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <span class="seat-box premium" style="width:20px;height:20px;font-size:0.5rem;"></span> Extra Legroom (+₹500)
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <span class="seat-box occupied" style="width:20px;height:20px;font-size:0.5rem;"></span> Occupied
                        </div>
                    </div>

                    <!-- Aircraft Fuselage -->
                    <div class="airplane-cabin">
                        <div class="fw-bold text-muted small mb-3">COCKPIT / FRONT</div>
                        <%
                            if (cabinSeats != null) {
                                for (int r = 1; r <= 30; r++) {
                        %>
                        <div class="seat-row">
                            <!-- Left Group (A, B, C) -->
                            <div class="seat-col-group">
                                <% for (char c : new char[]{'A', 'B', 'C'}) {
                                    String sNum = r + String.valueOf(c);
                                    Seat sObj = null;
                                    for (Seat s : cabinSeats) { if (s.getSeatNumber().equals(sNum)) { sObj = s; break; } }
                                    boolean occ = (sObj != null && !sObj.isAvailable());
                                    String clsName = "seat-box";
                                    if (occ) clsName += " occupied";
                                    if (r <= 3) clsName += " business";
                                    else if (r >= 12 && r <= 14) clsName += " premium";
                                    double fee = (sObj != null && sObj.getPriceSurcharge() != null) ? sObj.getPriceSurcharge().doubleValue() : 0;
                                %>
                                <div class="<%= clsName %>" data-seat="<%= sNum %>" data-fee="<%= fee %>"><%= sNum %></div>
                                <% } %>
                            </div>

                            <div class="aisle-gap"><%= r %></div>

                            <!-- Right Group (D, E, F) -->
                            <div class="seat-col-group">
                                <% for (char c : new char[]{'D', 'E', 'F'}) {
                                    String sNum = r + String.valueOf(c);
                                    Seat sObj = null;
                                    for (Seat s : cabinSeats) { if (s.getSeatNumber().equals(sNum)) { sObj = s; break; } }
                                    boolean occ = (sObj != null && !sObj.isAvailable());
                                    String clsName = "seat-box";
                                    if (occ) clsName += " occupied";
                                    if (r <= 3) clsName += " business";
                                    else if (r >= 12 && r <= 14) clsName += " premium";
                                    double fee = (sObj != null && sObj.getPriceSurcharge() != null) ? sObj.getPriceSurcharge().doubleValue() : 0;
                                %>
                                <div class="<%= clsName %>" data-seat="<%= sNum %>" data-fee="<%= fee %>"><%= sNum %></div>
                                <% } %>
                            </div>
                        </div>
                        <%
                                }
                            }
                        %>
                        <div class="fw-bold text-muted small mt-3">GALLEY / REAR</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Selection Panel & Actions -->
        <div class="col-lg-5">
            <div class="skytech-card mb-4 sticky-top" style="top: 90px;">
                <div class="skytech-card-header">
                    <div><i class="bi bi-check-circle-fill text-primary me-2"></i> Seat Allocation Summary</div>
                    <span class="badge bg-primary"><%= passengers != null ? passengers.size() : 1 %> Passenger(s)</span>
                </div>
                <div class="skytech-card-body">
                    <input type="hidden" id="passengerCount" value="<%= passengers != null ? passengers.size() : 1 %>">
                    
                    <h6 class="fw-bold text-navy mb-2">Traveling Passengers:</h6>
                    <ul class="list-group list-group-flush mb-3 small">
                        <% if (passengers != null) {
                            for (int i = 0; i < passengers.size(); i++) {
                                Passenger p = passengers.get(i);
                        %>
                        <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                            <div>
                                <i class="bi bi-person text-primary me-1"></i>
                                <strong><%= p.getFullName() %></strong> (<%= p.getPassengerType() %>)
                            </div>
                            <span class="badge bg-light text-dark border">Seat #<%= (i + 1) %></span>
                        </li>
                        <% } } %>
                    </ul>

                    <h6 class="fw-bold text-navy mb-2">Selected Seats:</h6>
                    <div id="selectedSeatPills" class="d-flex gap-2 flex-wrap mb-3">
                        <span class="text-muted small">Click available seats on the aircraft map</span>
                    </div>

                    <div class="d-flex justify-content-between align-items-center border-top pt-3 mb-4">
                        <span class="text-muted">Total Seat Surcharges:</span>
                        <span id="totalSeatSurcharges" class="fw-bold fs-5 text-primary">₹0.00</span>
                    </div>

                    <form action="${pageContext.request.contextPath}/booking/seats" method="POST">
                        <div id="selectedSeatsInputContainer"></div>
                        <div class="d-grid gap-2">
                            <button type="submit" id="btnConfirmSeats" class="btn btn-skytech-primary btn-lg" disabled>
                                Confirm Seats &amp; Review <i class="bi bi-arrow-right ms-1"></i>
                            </button>
                            <a href="${pageContext.request.contextPath}/booking/passengers" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left me-1"></i> Back to Passenger Details
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/seat-selection.js"></script>
<jsp:include page="/includes/footer.jsp" />
