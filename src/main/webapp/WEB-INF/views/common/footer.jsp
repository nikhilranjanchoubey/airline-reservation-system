<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<footer class="mt-auto" id="contactSection">
    <div class="container">
        <div class="row g-4 mb-4">
            <div class="col-lg-4">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <span class="brand-icon-wrap" style="width: 32px; height: 32px;">
                        <i class="bi bi-airplane-fill" style="font-size: 0.9rem;"></i>
                    </span>
                    <span class="text-white fw-bold fs-5">SkyTech</span>
                </div>
                <p class="text-secondary small mb-3">
                    Fast, secure, and reliable airline reservation and passenger portal services worldwide. Experience premium cloud-native aviation solutions.
                </p>
                <div class="d-flex gap-2">
                    <a href="#" class="btn btn-sm btn-outline-secondary rounded-circle"><i class="bi bi-twitter-x"></i></a>
                    <a href="#" class="btn btn-sm btn-outline-secondary rounded-circle"><i class="bi bi-facebook"></i></a>
                    <a href="#" class="btn btn-sm btn-outline-secondary rounded-circle"><i class="bi bi-linkedin"></i></a>
                    <a href="#" class="btn btn-sm btn-outline-secondary rounded-circle"><i class="bi bi-instagram"></i></a>
                </div>
            </div>
            <div class="col-6 col-md-3 col-lg-2">
                <h6 class="text-white fw-semibold mb-3">Quick Links</h6>
                <ul class="list-unstyled small d-flex flex-column gap-2 mb-0">
                    <li><a href="${pageContext.request.contextPath}/">Home</a></li>
                    <li><a href="${pageContext.request.contextPath}/#flightsSection">Flight Results</a></li>
                    <li><a href="${pageContext.request.contextPath}/#checkinSection">Seat Selection</a></li>
                    <li><a href="${pageContext.request.contextPath}/#servicesSection">Airport Services</a></li>
                </ul>
            </div>
            <div class="col-6 col-md-3 col-lg-2">
                <h6 class="text-white fw-semibold mb-3">Account</h6>
                <ul class="list-unstyled small d-flex flex-column gap-2 mb-0">
                    <li><a href="${pageContext.request.contextPath}/login">Sign In</a></li>
                    <li><a href="${pageContext.request.contextPath}/register">Create Account</a></li>
                    <li><a href="${pageContext.request.contextPath}/profile">Passenger Profile</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard">Admin Dashboard</a></li>
                </ul>
            </div>
            <div class="col-md-6 col-lg-4">
                <h6 class="text-white fw-semibold mb-3">Customer Support</h6>
                <p class="small text-secondary mb-2"><i class="bi bi-geo-alt-fill text-info me-2"></i> SkyTech Terminal 3, Global Aviation Boulevard</p>
                <p class="small text-secondary mb-2"><i class="bi bi-telephone-fill text-info me-2"></i> +1 (800) 555-SKYTECH</p>
                <p class="small text-secondary mb-0"><i class="bi bi-envelope-fill text-info me-2"></i> support@skytech-airlines.com</p>
            </div>
        </div>

        <hr class="border-secondary opacity-25">

        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center small text-secondary py-2">
            <div>&copy; 2026 SkyTech Airlines - Modern Airline Reservation System. All rights reserved.</div>
            <div class="mt-2 mt-md-0">Powered by Java 21 &bull; Jakarta EE 10 &bull; MySQL 8.3 &bull; Tomcat 10.1</div>
        </div>
    </div>
</footer>

<!-- Bootstrap 5.3 Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
<!-- Client-side Auth Validation -->
<script src="${pageContext.request.contextPath}/js/auth-validation.js"></script>
</body>
</html>
