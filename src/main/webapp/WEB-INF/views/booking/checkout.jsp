<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Secure Checkout - SkyTech Airlines" />
    <jsp:param name="activePage" value="flights" />
</jsp:include>
<jsp:include page="../common/navbar.jsp" />

<style>
:root {
  --sky-navy: #071A35;
  --sky-deep-blue: #0B2D52;
  --sky-blue: #168BFF;
  --sky-cyan: #56CCF2;
  --sky-cloud: #F4F8FC;
  --sky-white: #FFFFFF;
  --sky-success: #18A878;
  --sky-danger: #E5484D;
  --sky-text: #172B45;
  --sky-muted: #64748B;
  --sky-border: #D8E3EF;
  --sky-radius-sm: 8px;
  --sky-radius-md: 14px;
  --sky-radius-lg: 22px;
  --sky-shadow: 0 10px 30px rgba(7, 26, 53, 0.10);
  --sky-transition: 220ms ease;
}

body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  background-color: var(--sky-cloud) !important;
  color: var(--sky-text);
  overflow-x: hidden;
}

.sky-checkout-main {
  background-color: var(--sky-cloud);
  min-height: calc(100vh - 160px);
}

.sky-checkout-container {
  max-width: 1040px;
  margin: 0 auto;
}

.font-heading {
  font-family: 'Manrope', 'Plus Jakarta Sans', sans-serif !important;
}

/* Four-Step Booking Progress Tracker */
.sky-stepper {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 0.25rem;
  margin-bottom: 1.25rem;
}

.sky-step-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  font-weight: 600;
  font-family: 'Manrope', sans-serif;
  white-space: nowrap;
}

.sky-step-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  font-size: 0.8rem;
  font-weight: 700;
}

.sky-step-done {
  color: var(--sky-deep-blue);
}
.sky-step-done .sky-step-badge {
  background: var(--sky-deep-blue);
  color: var(--sky-white);
}

.sky-step-active {
  color: var(--sky-blue);
  font-weight: 700;
}
.sky-step-active .sky-step-badge {
  background: var(--sky-blue);
  color: var(--sky-white);
  box-shadow: 0 0 0 4px rgba(22, 139, 255, 0.20);
}

.sky-step-pending {
  color: var(--sky-muted);
}
.sky-step-pending .sky-step-badge {
  background: var(--sky-white);
  color: var(--sky-muted);
  border: 1px solid var(--sky-border);
}

.sky-step-connector {
  flex-grow: 1;
  height: 2px;
  margin: 0 0.75rem;
}
.sky-step-connector.completed {
  background: var(--sky-blue);
}
.sky-step-connector.upcoming {
  background: var(--sky-border);
}

/* Checkout Cards */
.sky-checkout-card {
  background: var(--sky-white);
  border: 1px solid var(--sky-border);
  border-radius: var(--sky-radius-lg);
  box-shadow: var(--sky-shadow);
  padding: 1.75rem;
  transition: box-shadow var(--sky-transition);
}

.sky-checkout-card:hover {
  box-shadow: 0 14px 34px rgba(7, 26, 53, 0.12);
}

.sky-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: 1rem;
  margin-bottom: 1.25rem;
  border-bottom: 1px solid var(--sky-border);
}

.sky-card-title {
  font-family: 'Manrope', sans-serif;
  font-weight: 800;
  font-size: 1.25rem;
  color: var(--sky-navy);
  margin: 0;
}

/* Payable Amount Box */
.sky-amount-box {
  background: var(--sky-cloud);
  border: 1px solid var(--sky-border);
  border-radius: var(--sky-radius-md);
  padding: 1.25rem 1.5rem;
  margin-bottom: 1.5rem;
}

.sky-amount-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 0.75rem;
}

.sky-amount-label {
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-weight: 600;
  color: var(--sky-muted);
}

.sky-amount-value {
  font-family: 'Manrope', sans-serif;
  font-size: 2.2rem;
  font-weight: 800;
  color: var(--sky-navy);
  letter-spacing: -0.5px;
  line-height: 1.1;
}

.sky-amount-value .currency-symbol {
  color: var(--sky-blue);
  font-size: 1.75rem;
  font-weight: 700;
  margin-right: 1px;
}

.sky-info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.55rem 0;
  font-size: 0.85rem;
  border-top: 1px solid var(--sky-border);
  color: var(--sky-muted);
}

.sky-info-row .row-val {
  color: var(--sky-navy);
  font-weight: 600;
}

/* Pay Button */
.btn-sky-pay {
  background: var(--sky-blue);
  color: var(--sky-white);
  border: none;
  border-radius: var(--sky-radius-md);
  font-family: 'Manrope', sans-serif;
  font-weight: 700;
  font-size: 1.05rem;
  padding: 0.95rem 1.5rem;
  box-shadow: 0 6px 18px rgba(22, 139, 255, 0.32);
  transition: all var(--sky-transition);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.6rem;
  width: 100%;
  cursor: pointer;
  text-decoration: none;
}

.btn-sky-pay:hover:not(:disabled) {
  background: var(--sky-deep-blue);
  color: var(--sky-white);
  transform: translateY(-2px);
  box-shadow: 0 10px 26px rgba(7, 26, 53, 0.24);
}

.btn-sky-pay:focus-visible {
  outline: 3px solid var(--sky-cyan);
  outline-offset: 2px;
}

.btn-sky-pay:disabled {
  background: var(--sky-muted);
  cursor: not-allowed;
  opacity: 0.7;
  transform: none;
  box-shadow: none;
}

/* Subtle Payment Method Details */
.sky-method-card {
  background: var(--sky-cloud);
  border: 1px dashed var(--sky-border);
  border-radius: var(--sky-radius-sm);
  padding: 0.75rem 1rem;
  text-align: center;
  margin-top: 1rem;
}

/* Route Display */
.sky-route-banner {
  background: var(--sky-cloud);
  border: 1px solid var(--sky-border);
  border-radius: var(--sky-radius-md);
  padding: 1rem 1.25rem;
  margin-bottom: 1.25rem;
}

.sky-route-code {
  font-family: 'Manrope', sans-serif;
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--sky-navy);
}

.sky-passenger-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.65rem 0;
  border-bottom: 1px solid var(--sky-border);
  font-size: 0.88rem;
  color: var(--sky-text);
}
.sky-passenger-item:last-child {
  border-bottom: none;
}

/* Security and Status Badges */
.badge-sky-ssl {
  background: rgba(24, 168, 120, 0.08);
  color: var(--sky-success);
  border: 1px solid rgba(24, 168, 120, 0.25);
  font-size: 0.75rem;
  font-weight: 600;
  padding: 5px 11px;
  border-radius: 999px;
}

.badge-sky-mode {
  background: rgba(22, 139, 255, 0.08);
  color: var(--sky-blue);
  border: 1px solid rgba(22, 139, 255, 0.22);
  font-size: 0.75rem;
  font-weight: 600;
  padding: 5px 11px;
  border-radius: 999px;
}
</style>

<main class="sky-checkout-main py-3 py-md-4">
    <div class="container sky-checkout-container px-3 px-sm-4">

        <!-- Four-Step Booking Progress Tracker -->
        <div class="sky-stepper">
            <div class="sky-step-item sky-step-done">
                <span class="sky-step-badge"><i class="bi bi-check-lg"></i></span>
                <span class="d-none d-sm-inline">Flight Search</span>
            </div>
            <div class="sky-step-connector completed"></div>
            <div class="sky-step-item sky-step-done">
                <span class="sky-step-badge"><i class="bi bi-check-lg"></i></span>
                <span class="d-none d-sm-inline">Passenger Details</span>
            </div>
            <div class="sky-step-connector completed"></div>
            <div class="sky-step-item sky-step-active">
                <span class="sky-step-badge">3</span>
                <span>Secure Payment</span>
            </div>
            <div class="sky-step-connector upcoming"></div>
            <div class="sky-step-item sky-step-pending">
                <span class="sky-step-badge">4</span>
                <span class="d-none d-sm-inline">Confirmation</span>
            </div>
        </div>

        <!-- Payment Error Notice (if any) -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm mb-4" role="alert" style="border: 1px solid var(--sky-danger);">
                <i class="bi bi-shield-x me-2 fs-5"></i>
                <strong>Payment Notice:</strong> <c:out value="${errorMessage}" />
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Fullscreen Loading Overlay for Payment Processing -->
        <div id="loadingOverlay" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(7,26,53,0.78); z-index:9999; align-items:center; justify-content:center; flex-direction:column; color:white; backdrop-filter:blur(5px);">
            <div class="spinner-border text-info mb-3" style="width: 3.5rem; height: 3.5rem;" role="status"></div>
            <h5 class="fw-bold font-heading mb-1 text-white">Verifying Payment Signature...</h5>
            <p class="small text-white-50 mb-0">Confirming reservation with MySQL. Please do not refresh.</p>
        </div>

        <!-- Checkout Columns -->
        <div class="row g-4 align-items-start">
            <!-- Left Column: Payment Checkout Card -->
            <div class="col-12 col-lg-7">
                <div class="sky-checkout-card mb-3">
                    <div class="sky-card-header">
                        <h4 class="sky-card-title">Payment Checkout</h4>
                        <div class="d-flex align-items-center gap-2">
                            <c:if test="${isRazorpayConfigured}">
                                <span class="badge-sky-mode">
                                    <i class="bi bi-shield-check me-1"></i>Test Mode
                                </span>
                            </c:if>
                            <span class="badge-sky-ssl">
                                <i class="bi bi-lock-fill me-1"></i>256-Bit SSL
                            </span>
                        </div>
                    </div>

                    <!-- Prominent Payable Amount & Details -->
                    <div class="sky-amount-box">
                        <div class="sky-amount-header">
                            <span class="sky-amount-label">Total Payable Amount</span>
                            <div class="sky-amount-value">
                                <span class="currency-symbol">&#8377;</span><fmt:formatNumber value="${booking.totalAmount}" pattern="#,##,##0.00" />
                            </div>
                        </div>

                        <div class="sky-info-row">
                            <span>Razorpay Order Reference</span>
                            <span class="font-monospace small px-2 py-1 rounded row-val" style="background: var(--sky-white); border: 1px solid var(--sky-border); word-break: break-all; max-width: 60%; text-align: right;">${payment.razorpayOrderId}</span>
                        </div>
                        <div class="sky-info-row">
                            <span>Currency &amp; Breakdown</span>
                            <span class="row-val">INR (Paise: ${amountInPaise})</span>
                        </div>
                    </div>

                    <!-- Case A: Razorpay Configured (Official Razorpay Standard Checkout) -->
                    <c:if test="${isRazorpayConfigured}">
                        <div>
                            <button type="button" id="rzp-button1" class="btn-sky-pay" aria-label="Pay Securely with Razorpay">
                                <i class="bi bi-shield-lock-fill fs-5"></i>
                                <span>Pay Securely with Razorpay</span>
                            </button>
                        </div>

                        <!-- Subtle Environment & Payment Method Info -->
                        <div class="sky-method-card">
                            <div class="d-flex align-items-center justify-content-center gap-2 flex-wrap text-muted small mb-1">
                                <span class="d-inline-flex align-items-center gap-1"><i class="bi bi-qr-code text-primary"></i> UPI (GPay / PhonePe / Paytm)</span>
                                <span>&bull;</span>
                                <span class="d-inline-flex align-items-center gap-1"><i class="bi bi-credit-card-2-front text-primary"></i> Cards</span>
                                <span>&bull;</span>
                                <span class="d-inline-flex align-items-center gap-1"><i class="bi bi-bank text-primary"></i> NetBanking</span>
                            </div>
                            <small class="text-muted d-block" style="font-size: 0.76rem;">
                                Official Razorpay Test Sandbox &bull; Real-time cryptographic signature verification
                            </small>
                        </div>
                    </c:if>

                    <!-- Case B: Unconfigured Gateway Warning -->
                    <c:if test="${!isRazorpayConfigured}">
                        <div class="alert alert-danger border-0 rounded-4 p-3 mt-2">
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <i class="bi bi-exclamation-triangle-fill text-danger fs-5"></i>
                                <strong class="text-dark">Razorpay Gateway Not Configured</strong>
                            </div>
                            <p class="small text-muted mb-0">
                                Please set <code>RAZORPAY_KEY_ID</code> and <code>RAZORPAY_KEY_SECRET</code> in <code>.env</code> and restart the application.
                            </p>
                        </div>
                    </c:if>
                </div>

                <div class="text-center mt-2">
                    <a href="${pageContext.request.contextPath}/search-flights" class="text-decoration-none small" style="color: var(--sky-muted); font-weight: 500;">
                        <i class="bi bi-arrow-left me-1"></i> Cancel and Return to Flight Search
                    </a>
                </div>
            </div>

            <!-- Right Column: Booking Summary Card -->
            <div class="col-12 col-lg-5">
                <div class="sky-checkout-card">
                    <div class="sky-card-header">
                        <h4 class="sky-card-title">Booking Summary</h4>
                        <span class="badge font-monospace" style="background: rgba(11, 45, 82, 0.08); color: var(--sky-deep-blue); border: 1px solid var(--sky-border); font-size: 0.82rem; padding: 5px 10px; border-radius: var(--sky-radius-sm); letter-spacing: 0.5px;">
                            ${booking.bookingReference}
                        </span>
                    </div>

                    <!-- Flight Route Banner -->
                    <div class="sky-route-banner">
                        <div class="d-flex align-items-center justify-content-between">
                            <div class="text-start">
                                <div class="sky-route-code">${booking.originCode}</div>
                                <small class="text-muted">Origin</small>
                            </div>
                            <div class="d-flex flex-column align-items-center px-3">
                                <i class="bi bi-airplane-fill fs-5" style="color: var(--sky-blue); transform: rotate(90deg);"></i>
                                <span class="badge rounded-pill mt-1" style="background: rgba(22, 139, 255, 0.1); color: var(--sky-blue); font-size: 0.72rem; font-weight: 600;">Non-stop</span>
                            </div>
                            <div class="text-end">
                                <div class="sky-route-code">${booking.destinationCode}</div>
                                <small class="text-muted">Destination</small>
                            </div>
                        </div>
                    </div>

                    <!-- Flight Details Grid -->
                    <div class="mb-3">
                        <div class="d-flex justify-content-between small py-1" style="color: var(--sky-muted);">
                            <span>Flight Number:</span>
                            <strong style="color: var(--sky-navy);">${booking.flightNumber}</strong>
                        </div>
                        <div class="d-flex justify-content-between small py-1" style="color: var(--sky-muted);">
                            <span>Departure Date:</span>
                            <strong style="color: var(--sky-navy);">${booking.departureDate}</strong>
                        </div>
                        <div class="d-flex justify-content-between small py-1" style="color: var(--sky-muted);">
                            <span>Cabin Class:</span>
                            <strong style="color: var(--sky-navy);">${booking.travelClass}</strong>
                        </div>
                        <div class="d-flex justify-content-between small py-1" style="color: var(--sky-muted);">
                            <span>Selected Seat(s):</span>
                            <strong style="color: var(--sky-navy);">${not empty booking.seatNumbers ? booking.seatNumbers : 'Auto-allocated'}</strong>
                        </div>
                    </div>

                    <hr class="my-3" style="border-color: var(--sky-border);">

                    <!-- Passenger Manifest from Real Database Model -->
                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="small fw-bold" style="color: var(--sky-navy); text-transform: uppercase; letter-spacing: 0.5px;">Passenger Manifest</span>
                            <span class="badge rounded-pill" style="background: var(--sky-cloud); color: var(--sky-muted); border: 1px solid var(--sky-border); font-size: 0.72rem;">
                                ${not empty booking.passengers ? booking.passengers.size() : 1} Passenger(s)
                            </span>
                        </div>

                        <c:choose>
                            <c:when test="${not empty booking.passengers}">
                                <div class="passenger-list">
                                    <c:forEach var="p" items="${booking.passengers}">
                                        <div class="sky-passenger-item">
                                            <div class="d-flex align-items-center gap-2">
                                                <i class="bi bi-person-circle fs-5" style="color: var(--sky-blue);"></i>
                                                <span class="fw-semibold text-truncate" style="color: var(--sky-navy); max-width: 180px;"><c:out value="${p.fullName}" /></span>
                                            </div>
                                            <div class="d-flex align-items-center gap-2">
                                                <c:if test="${not empty p.seatNumber}">
                                                    <span class="badge" style="background: var(--sky-cloud); color: var(--sky-text); border: 1px solid var(--sky-border); font-size: 0.75rem;">
                                                        Seat <c:out value="${p.seatNumber}" />
                                                    </span>
                                                </c:if>
                                                <span class="badge" style="background: rgba(22, 139, 255, 0.1); color: var(--sky-blue); font-size: 0.75rem;">
                                                    <c:out value="${p.passengerType}" />
                                                </span>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-2 text-muted small" style="background: var(--sky-cloud); border: 1px dashed var(--sky-border); border-radius: var(--sky-radius-sm);">
                                    <i class="bi bi-info-circle me-1"></i> Passenger information registered under booking ref <c:out value="${booking.bookingReference}" />.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <hr class="my-3" style="border-color: var(--sky-border);">

                    <!-- Total Payable Row -->
                    <div class="d-flex justify-content-between align-items-center pt-1">
                        <span class="fw-bold font-heading" style="color: var(--sky-navy); font-size: 1.05rem;">Total Payable:</span>
                        <span class="fw-bold fs-4 font-heading" style="color: var(--sky-blue);">&#8377;<fmt:formatNumber value="${booking.totalAmount}" pattern="#,##,##0.00" /></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Razorpay Standard Checkout Script (if Key ID configured) -->
<c:if test="${isRazorpayConfigured}">
    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
    <form id="razorpayVerificationForm" action="${pageContext.request.contextPath}/booking/verify-payment" method="POST" style="display: none;">
        <input type="hidden" name="bookingId" value="${booking.id}">
        <input type="hidden" name="razorpay_order_id" id="rzp_order_id">
        <input type="hidden" name="razorpay_payment_id" id="rzp_payment_id">
        <input type="hidden" name="razorpay_signature" id="rzp_signature">
    </form>

    <script>
        function showLoading() {
            var overlay = document.getElementById('loadingOverlay');
            if (overlay) overlay.style.display = 'flex';
            var btn = document.getElementById('rzp-button1');
            if (btn) {
                btn.disabled = true;
                btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Processing Payment...';
            }
        }

        function hideLoading() {
            var overlay = document.getElementById('loadingOverlay');
            if (overlay) overlay.style.display = 'none';
            var btn = document.getElementById('rzp-button1');
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = '<i class="bi bi-shield-lock-fill fs-5"></i> <span>Pay Securely with Razorpay</span>';
            }
        }

        const options = {
            "key": "${razorpayKeyId}",
            "amount": "${amountInPaise}",
            "currency": "INR",
            "name": "SkyTech Airlines",
            "description": "Flight Reservation ${booking.bookingReference}",
            "order_id": "${payment.razorpayOrderId}",
            "handler": function (response) {
                showLoading();
                document.getElementById('rzp_order_id').value = response.razorpay_order_id;
                document.getElementById('rzp_payment_id').value = response.razorpay_payment_id;
                document.getElementById('rzp_signature').value = response.razorpay_signature;
                document.getElementById('razorpayVerificationForm').submit();
            },
            "prefill": {
                "name": "${booking.passengers[0].fullName}",
                "email": "${booking.contactEmail}",
                "contact": "${booking.contactPhone}"
            },
            "theme": {
                "color": "#168BFF"
            },
            "modal": {
                "ondismiss": function() {
                    hideLoading();
                }
            }
        };

        const rzp1 = new Razorpay(options);
        rzp1.on('payment.failed', function (response) {
            hideLoading();
            const errDesc = (response && response.error && response.error.description) 
                ? response.error.description 
                : 'Payment was declined or cancelled.';
            window.location.href = "${pageContext.request.contextPath}/booking/checkout?bookingId=${booking.id}&error=" + encodeURIComponent(errDesc);
        });

        document.getElementById('rzp-button1').onclick = function (e) {
            e.preventDefault();
            showLoading();
            rzp1.open();
        };
    </script>
</c:if>

<jsp:include page="../common/footer.jsp" />
