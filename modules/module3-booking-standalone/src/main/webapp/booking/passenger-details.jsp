<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.skytech.airlines.booking.integration.FlightSummary" %>
<%@ page import="com.skytech.airlines.booking.model.Passenger" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    request.setAttribute("stepNumber", 2);
    FlightSummary flight = (FlightSummary) request.getAttribute("flight");
    String userName = (String) request.getAttribute("userName");
    String userEmail = (String) request.getAttribute("userEmail");
    String validationError = (String) request.getAttribute("validationError");
    @SuppressWarnings("unchecked")
    List<Passenger> formPax = (List<Passenger>) request.getAttribute("passengersForm");
    String formEmail = (String) request.getAttribute("contactEmailForm");
    String formPhone = (String) request.getAttribute("contactPhoneForm");
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>
<jsp:include page="/includes/header.jsp" />
<jsp:include page="/includes/stepper.jsp" />

<div class="container pb-5">
    <% if (validationError != null) { %>
        <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> <strong>Validation Notice:</strong> <%= validationError %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <div class="row g-4">
        <!-- Flight Summary Bar -->
        <div class="col-lg-4 order-lg-2">
            <div class="skytech-card sticky-top" style="top: 90px;">
                <div class="skytech-card-header">
                    <div><i class="bi bi-airplane-fill text-primary me-2"></i> Selected Flight</div>
                    <span class="badge bg-primary"><%= flight != null ? flight.getFlightNumber() : "SK-701" %></span>
                </div>
                <div class="skytech-card-body">
                    <% if (flight != null) { %>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <h4 class="fw-bold text-navy mb-0"><%= flight.getOriginAirportCode() %></h4>
                                <small class="text-muted"><%= flight.getOriginCity() %></small>
                            </div>
                            <div class="text-center text-primary"><i class="bi bi-arrow-right fs-4"></i></div>
                            <div class="text-end">
                                <h4 class="fw-bold text-navy mb-0"><%= flight.getDestAirportCode() %></h4>
                                <small class="text-muted"><%= flight.getDestCity() %></small>
                            </div>
                        </div>
                        <div class="small border-top pt-2 text-muted mb-2">
                            <div><strong>Departure:</strong> <%= flight.getFormattedDeparture() %></div>
                            <div><strong>Duration:</strong> <%= flight.getFormattedDuration() %> (Non-stop)</div>
                            <div><strong>Aircraft:</strong> <%= flight.getAircraftModel() %></div>
                            <div><strong>Commander:</strong> <span class="text-navy fw-semibold"><%= flight.getCaptainName() %></span></div>
                        </div>
                        <div class="p-2 rounded border mb-2 small" style="background: #F0F7FF; border-color: #BAE6FD;">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <span class="text-navy fw-bold"><i class="bi bi-award-fill text-primary me-1"></i>Loyalty Tier:</span>
                                <span class="badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25"><%= flight.getFrequentFlyerTier() %></span>
                            </div>
                            <div class="text-primary fw-bold"><i class="bi bi-stars text-warning me-1"></i>+<%= flight.getFrequentFlyerMiles() %> SkyPoints</div>
                            <div class="text-muted small mt-1 text-truncate" title="<%= flight.getFrequentFlyerPerks() %>"><%= flight.getFrequentFlyerPerks() %></div>
                        </div>
                        <div class="border-top pt-2">
                            <span class="small text-muted">Base Fare per Adult:</span>
                            <div class="fs-4 fw-bold text-primary"><%= nf.format(flight.getBaseFare()) %></div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Passenger Entry Form -->
        <div class="col-lg-8 order-lg-1">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="fw-bold text-navy mb-0">
                    <i class="bi bi-people-fill text-primary me-2"></i> Passenger Information
                </h4>
                <button type="button" id="btnAddPassenger" class="btn btn-outline-primary btn-sm">
                    <i class="bi bi-person-plus-fill me-1"></i> Add Passenger
                </button>
            </div>

            <form action="${pageContext.request.contextPath}/booking/passengers" method="POST">
                <div id="passengerListContainer">
                    <div class="skytech-card passenger-card mb-3">
                        <div class="skytech-card-header bg-light">
                            <div><i class="bi bi-person-fill text-primary me-2"></i> Passenger #1 (Primary)</div>
                        </div>
                        <div class="skytech-card-body">
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label small fw-semibold">First Name *</label>
                                    <input type="text" name="firstName[]" class="form-control" value="<%= (formPax != null && !formPax.isEmpty()) ? formPax.get(0).getFirstName() : "Rajesh" %>" required minlength="2" maxlength="50">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small fw-semibold">Last Name *</label>
                                    <input type="text" name="lastName[]" class="form-control" value="<%= (formPax != null && !formPax.isEmpty()) ? formPax.get(0).getLastName() : "Sharma" %>" required minlength="2" maxlength="50">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small fw-semibold">Date of Birth *</label>
                                    <input type="date" name="dateOfBirth[]" class="form-control" value="<%= (formPax != null && !formPax.isEmpty() && formPax.get(0).getDateOfBirth() != null) ? formPax.get(0).getDateOfBirth() : "1988-06-15" %>" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small fw-semibold">Gender *</label>
                                    <select name="gender[]" class="form-select" required>
                                        <option value="MALE" selected>Male</option>
                                        <option value="FEMALE">Female</option>
                                        <option value="OTHER">Other</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small fw-semibold">Category *</label>
                                    <select name="passengerType[]" class="form-select" required>
                                        <option value="ADULT" selected>Adult (12+ yrs)</option>
                                        <option value="CHILD">Child (2-11 yrs)</option>
                                        <option value="INFANT">Infant (&lt;2 yrs)</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small fw-semibold">Passport / Govt ID</label>
                                    <input type="text" name="passportOrId[]" class="form-control" placeholder="Optional for domestic" value="<%= (formPax != null && !formPax.isEmpty()) ? formPax.get(0).getPassportOrId() : "" %>">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Frequent Flyer Loyalty Program Selection -->
                <div class="skytech-card mb-4">
                    <div class="skytech-card-header">
                        <div><i class="bi bi-award-fill text-primary me-2"></i> Frequent Flyer &amp; Loyalty Rewards</div>
                        <span class="badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25"><%= flight != null ? flight.getFrequentFlyerTier() : "Silver Tier" %></span>
                    </div>
                    <div class="skytech-card-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label small fw-semibold">Frequent Flyer Program Option</label>
                                <select name="frequentFlyerOption" class="form-select">
                                    <option value="SKYTECH SkyRewards (<%= flight != null ? flight.getFrequentFlyerTier() : "Silver Tier" %>)" selected>SKYTECH SkyRewards (<%= flight != null ? flight.getFrequentFlyerTier() : "Silver Tier" %> &bull; +<%= flight != null ? flight.getFrequentFlyerMiles() : 750 %> SkyPoints)</option>
                                    <option value="Star Alliance Partner (Silver Tier)">Star Alliance Partner (Silver Tier)</option>
                                    <option value="OneWorld Priority (Gold Tier)">OneWorld Priority (Gold Tier)</option>
                                    <option value="SkyTeam Elite (Platinum Tier)">SkyTeam Elite (Platinum Tier)</option>
                                    <option value="Standard Non-Member">Standard / No Loyalty Membership</option>
                                </select>
                                <small class="text-muted d-block mt-1">Flight Perks: <%= flight != null ? flight.getFrequentFlyerPerks() : "Standard Privileges" %></small>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-semibold">Frequent Flyer Number / Member ID</label>
                                <input type="text" name="frequentFlyerNumber" class="form-control" placeholder="e.g. SKY-884920" value="SKY-884920">
                                <small class="text-muted d-block mt-1">Earn +<%= flight != null ? flight.getFrequentFlyerMiles() : 750 %> SkyPoints credited directly to your loyalty account upon departure.</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Contact Information Card -->
                <div class="skytech-card mb-4">
                    <div class="skytech-card-header">
                        <div><i class="bi bi-envelope-at-fill text-primary me-2"></i> Booking Contact Details</div>
                        <span class="badge bg-light text-dark border">For E-ticket Delivery</span>
                    </div>
                    <div class="skytech-card-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label small fw-semibold">Contact Email *</label>
                                <input type="email" name="contactEmail" class="form-control" value="<%= (formEmail != null) ? formEmail : (userEmail != null ? userEmail : "rajesh.sharma@example.com") %>" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-semibold">Mobile Number *</label>
                                <input type="tel" name="contactPhone" class="form-control" value="<%= (formPhone != null) ? formPhone : "+91 9876543210" %>" required>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-between align-items-center">
                    <a href="${pageContext.request.contextPath}/" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i> Back to Flights
                    </a>
                    <button type="submit" class="btn btn-skytech-primary btn-lg">
                        Proceed to Seat Selection <i class="bi bi-arrow-right ms-1"></i>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/passenger-form.js"></script>
<jsp:include page="/includes/footer.jsp" />
