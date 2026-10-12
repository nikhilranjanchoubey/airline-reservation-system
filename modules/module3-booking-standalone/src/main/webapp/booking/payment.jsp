<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.skytech.airlines.booking.service.PaymentService.PaymentOrderDetails" %>
<%@ page import="com.skytech.airlines.booking.model.Booking" %>
<%@ page import="com.skytech.airlines.booking.integration.FlightSummary" %>
<%@ page import="com.skytech.airlines.booking.model.Passenger" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("stepNumber", 5);
    PaymentOrderDetails orderDetails = (PaymentOrderDetails) request.getAttribute("orderDetails");
    Booking booking = (Booking) request.getAttribute("booking");
    FlightSummary flight = (FlightSummary) request.getAttribute("flight");
    @SuppressWarnings("unchecked")
    List<Passenger> passengers = (List<Passenger>) request.getAttribute("passengers");
    String razorpayKeyId = (String) request.getAttribute("razorpayKeyId");
    String razorpayOrderId = (String) request.getAttribute("razorpayOrderId");
    Long amountInPaise = (Long) request.getAttribute("amountInPaise");
    Long remainingHoldSeconds = (Long) request.getAttribute("remainingHoldSeconds");
    String userName = (String) request.getAttribute("userName");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("errorMessage");

    if (remainingHoldSeconds == null) remainingHoldSeconds = 900L;
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>
<jsp:include page="/includes/header.jsp" />
<jsp:include page="/includes/stepper.jsp" />

<div class="container pb-5">
    <% if (errorMessage != null) { %>
        <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> <strong>Payment Notice:</strong> <%= errorMessage %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold text-navy mb-1">
                <i class="bi bi-credit-card-2-front-fill text-primary me-2"></i> Secure Payment Checkout
            </h4>
            <p class="text-muted small mb-0">Complete flight payment via official Razorpay Standard Checkout to confirm your seats and generate your e-ticket.</p>
        </div>
        <div class="d-flex align-items-center gap-2 mt-2 mt-md-0">
            <span class="badge bg-light text-dark border p-2">Step 5 of 6</span>
            <span class="badge bg-primary p-2"><i class="bi bi-lock-fill"></i> 256-bit Encrypted</span>
        </div>
    </div>

    <!-- 15-Minute Seat Hold Countdown Alert -->
    <div class="alert alert-warning border border-warning shadow-sm d-flex flex-wrap align-items-center justify-content-between mb-4">
        <div class="d-flex align-items-center mb-2 mb-md-0">
            <i class="bi bi-clock-history fs-3 text-warning me-3"></i>
            <div>
                <strong class="text-dark">Temporary Seat Hold Active</strong>
                <div class="small text-muted">
                    Seats <strong><%= booking != null ? booking.getAllocatedSeatNumbersDisplay() : "Selected" %></strong> are reserved for you. Complete payment before the timer expires.
                </div>
            </div>
        </div>
        <div class="d-flex align-items-center gap-2">
            <span class="small text-muted fw-semibold">Hold Expires In:</span>
            <span id="countdownTimer" class="badge bg-dark fs-6 px-3 py-2 font-monospace">--:--</span>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-7">
            <!-- Flight Card -->
            <div class="skytech-card mb-4">
                <div class="skytech-card-header">
                    <div>
                        <i class="bi bi-airplane-engines text-primary me-2"></i>
                        <span>Flight Details &bull; <%= (flight != null) ? flight.getFlightNumber() : "Flight" %></span>
                    </div>
                    <span class="badge bg-primary"><%= (flight != null) ? flight.getAircraftModel() : "Commercial" %></span>
                </div>
                <div class="skytech-card-body">
                    <% if (flight != null) { %>
                    <div class="row align-items-center text-center text-md-start">
                        <div class="col-md-4 mb-2 mb-md-0">
                            <span class="text-muted small">From</span>
                            <div class="fw-bold fs-3 text-navy"><%= flight.getOriginAirportCode() %></div>
                            <div class="text-muted small"><%= flight.getOriginCity() %></div>
                            <div class="fw-semibold text-primary mt-1"><%= flight.getFormattedDeparture() %></div>
                        </div>
                        <div class="col-md-4 mb-2 mb-md-0 text-center">
                            <span class="badge bg-light text-dark border px-3 py-1 mb-1"><i class="bi bi-clock"></i> <%= flight.getFormattedDuration() %></span>
                            <div class="text-primary"><i class="bi bi-airplane-fill fs-5"></i></div>
                            <span class="text-success small fw-semibold">Non-stop Direct</span>
                        </div>
                        <div class="col-md-4 text-md-end">
                            <span class="text-muted small">To</span>
                            <div class="fw-bold fs-3 text-navy"><%= flight.getDestAirportCode() %></div>
                            <div class="text-muted small"><%= flight.getDestCity() %></div>
                            <div class="fw-semibold text-primary mt-1"><%= flight.getFormattedArrival() %></div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Booking Info Card -->
            <div class="skytech-card mb-4">
                <div class="skytech-card-header">
                    <div><i class="bi bi-ticket-perforated-fill text-primary me-2"></i> Reservation Header</div>
                    <span class="badge bg-warning text-dark">Status: <%= booking != null ? booking.getBookingStatus() : "PENDING" %></span>
                </div>
                <div class="skytech-card-body">
                    <div class="row g-3">
                        <div class="col-6">
                            <small class="text-muted d-block">Generated PNR Reference:</small>
                            <span class="fs-4 fw-bold text-navy"><%= booking != null ? booking.getPnr() : "SK...." %></span>
                        </div>
                        <div class="col-6">
                            <small class="text-muted d-block">Allocated Seats:</small>
                            <span class="fs-5 fw-bold text-primary"><%= booking != null ? booking.getAllocatedSeatNumbersDisplay() : "" %></span>
                        </div>
                        <div class="col-6">
                            <small class="text-muted d-block">Contact Email:</small>
                            <span class="fw-semibold text-navy"><%= booking != null ? booking.getContactEmail() : "" %></span>
                        </div>
                        <div class="col-6">
                            <small class="text-muted d-block">Contact Phone:</small>
                            <span class="fw-semibold text-navy"><%= booking != null ? booking.getContactPhone() : "" %></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Checkout Action Card -->
        <div class="col-lg-5">
            <div class="skytech-card sticky-top" style="top: 90px;">
                <div class="skytech-card-header">
                    <div><i class="bi bi-shield-check text-primary me-2"></i> Payment Details</div>
                    <span class="badge bg-primary">Razorpay Standard</span>
                </div>
                <div class="skytech-card-body">
                    <% if (booking != null) { %>
                    <div class="d-flex justify-content-between mb-2 small">
                        <span class="text-muted">Base Airfare</span>
                        <span class="fw-semibold"><%= nf.format(booking.getBaseFare()) %></span>
                    </div>
                    <div class="d-flex justify-content-between mb-2 small">
                        <span class="text-muted">Seat Selection Surcharges</span>
                        <span class="fw-semibold"><%= nf.format(booking.getSeatFees()) %></span>
                    </div>
                    <div class="d-flex justify-content-between mb-2 small">
                        <span class="text-muted">Aviation Tax &amp; GST (12%)</span>
                        <span class="fw-semibold"><%= nf.format(booking.getTaxAmount()) %></span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <span class="fs-5 fw-bold text-navy">Total Amount</span>
                        <span class="fs-4 fw-bold text-primary"><%= nf.format(booking.getTotalAmount()) %></span>
                    </div>

                    <div class="p-3 bg-light rounded border mb-4 small text-muted">
                        <div class="fw-bold text-navy mb-1"><i class="bi bi-wallet2 text-primary me-1"></i> Supported Payment Modes:</div>
                        UPI (Google Pay, PhonePe, Paytm), All Debit / Credit Cards (Visa, MasterCard, RuPay), and NetBanking.
                    </div>

                    <div class="d-grid gap-2">
                        <button type="button" id="btnPaySecurely" class="btn btn-skytech-primary btn-lg shadow-sm py-3 fw-bold">
                            <i class="bi bi-shield-lock-fill me-2"></i> Pay Securely <%= nf.format(booking.getTotalAmount()) %>
                        </button>
                        <a href="${pageContext.request.contextPath}/booking/review" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left me-1"></i> Back to Review
                        </a>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Hidden POST form for PaymentCallbackServlet -->
<form id="paymentCallbackForm" action="${pageContext.request.contextPath}/booking/payment-callback" method="POST" style="display: none;">
    <input type="hidden" name="pnr" value="<%= booking != null ? booking.getPnr() : "" %>">
    <input type="hidden" id="callback_order_id" name="razorpay_order_id" value="">
    <input type="hidden" id="callback_payment_id" name="razorpay_payment_id" value="">
    <input type="hidden" id="callback_signature" name="razorpay_signature" value="">
</form>

<!-- Full-page processing overlay -->
<div id="paymentProcessingOverlay" class="position-fixed top-0 start-0 w-100 h-100 bg-dark bg-opacity-75 align-items-center justify-content-center text-center text-white" style="display: none; z-index: 9999;">
    <div>
        <div class="spinner-border text-primary mb-3" style="width: 3.5rem; height: 3.5rem;" role="status"></div>
        <h4 class="fw-bold">Verifying Payment &amp; Confirming Seats...</h4>
        <p class="text-white-50">Please do not refresh or close this browser window.</p>
    </div>
</div>

<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<script>
let remainingSeconds = <%= remainingHoldSeconds %>;
const timerDisplay = document.getElementById("countdownTimer");
const payBtn = document.getElementById("btnPaySecurely");

function updateTimer() {
    if (remainingSeconds <= 0) {
        timerDisplay.innerText = "EXPIRED";
        timerDisplay.classList.remove("bg-dark");
        timerDisplay.classList.add("bg-danger");
        payBtn.disabled = true;
        payBtn.innerHTML = '<i class="bi bi-x-circle me-2"></i> Seat Hold Expired';
        alert("Your 15-minute seat reservation has expired. Held seats have been released.");
        window.location.href = "${pageContext.request.contextPath}/booking/my-bookings";
        return;
    }
    const minutes = Math.floor(remainingSeconds / 60);
    const seconds = remainingSeconds % 60;
    timerDisplay.innerText = (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds);
    remainingSeconds--;
    setTimeout(updateTimer, 1000);
}
updateTimer();

payBtn.addEventListener("click", function(e) {
    e.preventDefault();
    if (remainingSeconds <= 0) {
        alert("Seat hold has expired.");
        return;
    }

    const options = {
        "key": "<%= razorpayKeyId %>",
        "amount": "<%= amountInPaise %>",
        "currency": "INR",
        "name": "SKYTECH AIRLINES",
        "description": "Flight <%= flight != null ? flight.getFlightNumber() : "" %> Ticket (PNR: <%= booking != null ? booking.getPnr() : "" %>)",
        "order_id": "<%= razorpayOrderId %>",
        "handler": function (response) {
            document.getElementById("callback_order_id").value = response.razorpay_order_id;
            document.getElementById("callback_payment_id").value = response.razorpay_payment_id;
            document.getElementById("callback_signature").value = response.razorpay_signature;
            document.getElementById("paymentProcessingOverlay").style.display = "flex";
            document.getElementById("paymentCallbackForm").submit();
        },
        "prefill": {
            "name": "<%= userName != null ? userName : "Capt. Rajesh Sharma" %>",
            "email": "<%= booking != null ? booking.getContactEmail() : "" %>",
            "contact": "<%= booking != null ? booking.getContactPhone() : "" %>"
        },
        "theme": { "color": "#0879E8" }
    };

    try {
        const rzp = new Razorpay(options);
        rzp.on('payment.failed', function (response) {
            alert("Payment Transaction Failed: " + (response.error.description || "Payment could not be completed."));
        });
        rzp.open();
    } catch (err) {
        console.error("Razorpay open error:", err);
        // Test mode auto-fallback for offline development
        if (confirm("Sandbox Test Mode: Simulate successful Razorpay payment?")) {
            const orderId = "<%= razorpayOrderId %>";
            const mockPayId = "pay_sim_" + Date.now();
            document.getElementById("callback_order_id").value = orderId;
            document.getElementById("callback_payment_id").value = mockPayId;
            document.getElementById("callback_signature").value = "sig_simulated";
            document.getElementById("paymentProcessingOverlay").style.display = "flex";
            document.getElementById("paymentCallbackForm").submit();
        }
    }
});
</script>

<jsp:include page="/includes/footer.jsp" />
