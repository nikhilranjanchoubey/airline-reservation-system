<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
</main>
<footer class="skytech-footer">
    <div class="container">
        <div class="row g-4">
            <div class="col-lg-5 col-md-6">
                <div class="skytech-logo-container mb-3">
                    <svg class="skytech-logo-plane" style="width:32px;height:32px;" viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path fill="#19A7D8" d="M 20 1.5 C 21.2 0 22.8 0 24 1.5 C 24.8 2.8 25.3 4.8 25.3 7.5 L 25.3 17.5 L 39 24.2 C 40.5 25 41 26.2 41 27.6 L 41 31 C 41 31.8 40.2 32.5 39.4 32.3 L 25.3 30 L 24.4 33.8 L 28.3 37.5 C 28.8 38 29.1 38.7 29.1 39.5 L 29.1 42 L 22 38.8 L 14.9 42 L 14.9 39.5 C 14.9 38.7 15.2 38 15.7 37.5 L 19.6 33.8 L 18.7 30 L 4.6 32.3 C 3.8 32.5 3 31.8 3 31 L 3 27.6 C 3 26.2 3.5 25 5 24.2 L 18.7 17.5 L 18.7 7.5 C 18.7 4.8 19.2 2.8 20 1.5 Z"/>
                    </svg>
                    <div class="skytech-logo-text">
                        <span class="skytech-logo-title" style="font-size:1.35rem;">SKYTECH</span>
                        <span class="skytech-logo-subtitle" style="font-size:0.55rem;letter-spacing:3.8px;">AIRLINES</span>
                    </div>
                </div>
                <p class="small text-muted mb-3">
                    Premium scheduled air travel connecting key domestic and international destinations. Experience modern aircraft comfort, transparent pricing, and instant reservation confirmation.
                </p>
                <div class="d-flex gap-2 text-white small flex-wrap">
                    <span class="badge bg-dark border border-secondary border-opacity-50"><i class="bi bi-shield-lock-fill text-success me-1"></i> 256-Bit SSL</span>
                    <span class="badge bg-dark border border-secondary border-opacity-50"><i class="bi bi-patch-check-fill text-info me-1"></i> PCI-DSS Compliant</span>
                    <span class="badge bg-dark border border-secondary border-opacity-50"><i class="bi bi-headset text-warning me-1"></i> 24/7 Support</span>
                </div>
            </div>
            <div class="col-lg-3 col-md-6">
                <h6>Passenger Services</h6>
                <ul class="list-unstyled small">
                    <li class="mb-1"><a href="${pageContext.request.contextPath}/" class="text-secondary text-decoration-none">&bull; Flight Schedules &amp; Booking</a></li>
                    <li class="mb-1"><a href="${pageContext.request.contextPath}/booking/my-bookings" class="text-secondary text-decoration-none">&bull; Manage My Reservations</a></li>
                    <li class="mb-1"><a href="#" class="text-secondary text-decoration-none">&bull; Baggage Allowance &amp; Policies</a></li>
                    <li class="mb-1"><a href="#" class="text-secondary text-decoration-none">&bull; Web Check-In &amp; Boarding Passes</a></li>
                    <li class="mb-1"><a href="#" class="text-secondary text-decoration-none">&bull; Special Assistance &amp; Care</a></li>
                </ul>
            </div>
            <div class="col-lg-4 col-md-12">
                <h6>Verified Security &amp; Payment</h6>
                <div class="p-3 bg-dark bg-opacity-50 rounded border border-secondary border-opacity-25 small">
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">Reservation Engine:</span>
                        <span class="text-success fw-semibold"><i class="bi bi-check-circle-fill"></i> Fully Operational</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">Payment Provider:</span>
                        <span class="text-info fw-semibold"><i class="bi bi-shield-check"></i> Razorpay Secure Gateway</span>
                    </div>
                    <div class="d-flex justify-content-between">
                        <span class="text-muted">E-Ticket Delivery:</span>
                        <span class="text-light"><i class="bi bi-envelope-check-fill text-primary"></i> Instant E-Mail &amp; SMS</span>
                    </div>
                </div>
            </div>
        </div>
        <hr class="border-secondary border-opacity-25 my-4">
        <div class="d-flex flex-wrap justify-content-between align-items-center small text-muted">
            <div>&copy; 2026 SKYTECH AIRLINES Ltd. All rights reserved. Official Passenger Reservation System.</div>
            <div>Safety First &bull; Punctual Service &bull; Best Fare Guarantee</div>
        </div>
    </div>
</footer>
<!-- Bootstrap 5 Bundle JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
