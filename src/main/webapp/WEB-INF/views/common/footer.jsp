<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:choose>
    <c:when test="${activePage == 'login' || activePage == 'register' || param.activePage == 'login' || param.activePage == 'register'}">
        <!-- Minimal footer for authentication pages -->
        <footer class="py-3 text-center text-secondary bg-transparent mt-auto" style="position: relative; z-index: 10;">
            <div class="container">
                <span class="text-white-50 small">&copy; 2026 SkyTech. All rights reserved.</span>
            </div>
        </footer>
    </c:when>
    <c:otherwise>
        <!-- Polished Public Airline Footer -->
        <footer class="skytech-airline-footer mt-auto" role="contentinfo" aria-label="SkyTech Corporate and Travel Information">
            <!-- Aviation Hero Banner Above Footer -->
            <div class="skytech-footer-hero-banner">
                <div class="footer-hero-overlay"></div>
                <img src="${pageContext.request.contextPath}/images/footer-cinematic-hero.jpg" alt="SkyTech Jet Cruising Above Clouds" class="footer-hero-bg-img" loading="lazy">
                
                <div class="container footer-hero-content position-relative">
                    <div class="row align-items-center py-4 py-lg-5">
                        <div class="col-lg-7">
                            <div class="badge bg-sky-cyan-glow text-dark text-uppercase font-monospace fw-bold mb-2 px-3 py-2 rounded-pill">
                                <i class="bi bi-airplane-fill me-1"></i> SkyTech NextGen Aviation
                            </div>
                            <h2 class="display-6 fw-extrabold text-white mb-2 font-heading">
                                Soar Higher with <span class="text-sky-cyan">SkyTech</span>
                            </h2>
                            <p class="text-cloud-white opacity-85 lead fs-6 mb-0">
                                Experience seamless passenger journeys, convenient flight search, seat selection, and reliable airline operations worldwide.
                            </p>
                        </div>
                        <div class="col-lg-5 text-lg-end mt-3 mt-lg-0">
                            <a href="${pageContext.request.contextPath}/search-flights" class="btn btn-sky-electric btn-lg rounded-pill px-4 shadow-cyan-glow">
                                <i class="bi bi-search me-2"></i> Search Flights Now
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Glowing Curved Divider Line -->
                <div class="skytech-cyan-divider">
                    <svg viewBox="0 0 1440 48" fill="none" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none">
                        <path d="M0 48C360 0 1080 0 1440 48H0Z" fill="#071A35"/>
                        <path d="M0 46C360 -2 1080 -2 1440 46" stroke="#56CCF2" stroke-width="3" filter="drop-shadow(0px 0px 8px #56CCF2)"/>
                    </svg>
                </div>
            </div>

            <div class="skytech-footer-body py-5 bg-midnight-navy">
                <div class="container">
                    <div class="row g-4 mb-4">
                        <!-- SECTION A: SKYTECH -->
                        <div class="col-lg-4 col-md-6">
                            <div class="d-flex align-items-center mb-3">
                                <a href="${pageContext.request.contextPath}/" class="skytech-brand" aria-label="SkyTech Home">
                                    <span class="skytech-brand__icon">
                                        <i class="bi bi-airplane-engines-fill"></i>
                                    </span>
                                    <span class="skytech-brand__text">SkyTech</span>
                                </a>
                            </div>
                            <p class="text-muted-slate small mb-0 pe-lg-3" style="line-height: 1.65;">
                                Explore flight options, review your bookings, and plan your journey with SkyTech.
                            </p>
                        </div>

                        <!-- SECTION B: BOOK & TRAVEL -->
                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <h6 class="text-white fw-bold mb-3 font-heading text-uppercase fs-7 tracking-wider text-sky-cyan">Book &amp; Travel</h6>
                            <ul class="list-unstyled small d-flex flex-column gap-2 mb-0 footer-link-list">
                                <li>
                                    <a href="${pageContext.request.contextPath}/search-flights">
                                        <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Search Flights
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/flight-status">
                                        <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Flight Status
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/manage-booking">
                                        <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Manage Booking
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/my-bookings">
                                        <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> My Trips
                                    </a>
                                </li>
                            </ul>
                        </div>

                        <!-- SECTION C: PASSENGER SERVICES -->
                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <h6 class="text-white fw-bold mb-3 font-heading text-uppercase fs-7 tracking-wider text-sky-cyan">Passenger Services</h6>
                            <ul class="list-unstyled small d-flex flex-column gap-2 mb-0 footer-link-list">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.currentUser}">
                                        <li>
                                            <c:choose>
                                                <c:when test="${sessionScope.currentUser.role == 'ADMIN'}">
                                                    <a href="${pageContext.request.contextPath}/admin/profile">
                                                        <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Admin Profile
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/profile">
                                                        <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Passenger Profile
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </li>
                                        <li>
                                            <a href="${pageContext.request.contextPath}/my-bookings">
                                                <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> My Trips
                                            </a>
                                        </li>
                                        <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                                            <li>
                                                <a href="${pageContext.request.contextPath}/admin/dashboard" class="text-warning">
                                                    <i class="bi bi-shield-lock-fill me-1 text-warning fs-8"></i> Admin Dashboard
                                                </a>
                                            </li>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <li>
                                            <a href="${pageContext.request.contextPath}/login">
                                                <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Sign In
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${pageContext.request.contextPath}/register">
                                                <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Create Account
                                            </a>
                                        </li>
                                    </c:otherwise>
                                </c:choose>
                                <li>
                                    <a href="${pageContext.request.contextPath}/travel-information">
                                        <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Travel Information
                                    </a>
                                </li>
                            </ul>
                        </div>

                        <!-- SECTION D: HELP & INFORMATION -->
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <h6 class="text-white fw-bold mb-3 font-heading text-uppercase fs-7 tracking-wider text-sky-cyan">Help &amp; Information</h6>
                            <ul class="list-unstyled small d-flex flex-column gap-2 mb-0 footer-link-list">
                                <li>
                                    <a href="${pageContext.request.contextPath}/about">
                                        <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> About SkyTech
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/travel-information#faqs">
                                        <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Travel FAQs
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/travel-information#baggage">
                                        <i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Baggage Guidelines
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>

                    <hr class="border-secondary opacity-20 my-4" style="border-color: rgba(216, 227, 239, 0.15) !important;">

                    <!-- Bottom Bar: Copyright -->
                    <div class="d-flex flex-column flex-md-row justify-content-between align-items-center small text-muted-slate py-2 gap-2">
                        <div>
                            &copy; 2026 SkyTech. All rights reserved.
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <a href="${pageContext.request.contextPath}/travel-information" class="text-muted-slate text-decoration-none hover-sky-cyan small">Travel Information</a>
                            <span class="opacity-25">&bull;</span>
                            <a href="${pageContext.request.contextPath}/about" class="text-muted-slate text-decoration-none hover-sky-cyan small">About SkyTech</a>
                        </div>
                    </div>
                </div>
            </div>
        </footer>
    </c:otherwise>
</c:choose>

<!-- Floating Back to Top Button -->
<button type="button" class="btn btn-primary rounded-circle shadow-lg back-to-top-btn" id="backToTopBtn"
        title="Back to top" aria-label="Scroll back to top" onclick="scrollToTop()">
    <i class="bi bi-arrow-up fs-5"></i>
</button>

<!-- SkyTech Reusable Toast Container & Library -->
<div class="skytech-toast-container" id="skytech-toast-container" aria-live="polite" aria-atomic="true"></div>

<!-- Bootstrap 5.3 Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Scripts from both modules -->
<script src="${pageContext.request.contextPath}/js/auth-validation.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/skytech-toast.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/skytech-calendar.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>

<!-- Global Interactions (Sticky Navbar, Back to Top, Scroll Animations) -->
<script>
    window.addEventListener('scroll', function() {
        const nav = document.getElementById('skyTechMainNavbar');
        const btt = document.getElementById('backToTopBtn');
        const scrollY = window.scrollY || document.documentElement.scrollTop;

        if (nav) {
            if (scrollY > 60) {
                nav.classList.add('navbar-compact', 'shadow');
            } else {
                nav.classList.remove('navbar-compact', 'shadow');
            }
        }

        if (btt) {
            if (scrollY > 400) {
                btt.classList.add('visible');
            } else {
                btt.classList.remove('visible');
            }
        }
    });

    function scrollToTop() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    document.addEventListener('DOMContentLoaded', function() {
        if (!('IntersectionObserver' in window) || window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
            document.querySelectorAll('.fade-in-on-scroll').forEach(el => el.classList.add('is-visible'));
            return;
        }

        const observer = new IntersectionObserver((entries, obs) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('is-visible');
                    obs.unobserve(entry.target);
                }
            });
        }, {
            threshold: 0.12,
            rootMargin: '0px 0px -40px 0px'
        });

        document.querySelectorAll('.fade-in-on-scroll').forEach(el => observer.observe(el));
    });
</script>
</body>
</html>
