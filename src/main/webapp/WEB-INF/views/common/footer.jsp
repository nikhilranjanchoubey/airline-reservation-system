<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:choose>
    <c:when test="${activePage == 'login' || activePage == 'register'}">
        <!-- Sleek minimal footer for authentication pages -->
        <footer class="py-3 text-center text-secondary bg-transparent mt-auto" style="position: relative; z-index: 10;">
            <div class="container">
                <span class="text-white-50 small">&copy; <%= java.time.Year.now().getValue() %> SkyTech Airlines &bull; Airline Reservation System</span>
            </div>
        </footer>
    </c:when>
    <c:otherwise>
        <!-- Full Cinematic & Travel Navigation Footer -->
        <footer class="skytech-cinematic-footer mt-auto" id="contactSection" role="contentinfo" aria-label="SkyTech Corporate and Travel Information">
            <!-- Part A: Cinematic Aviation Hero Banner -->
            <div class="skytech-footer-hero-banner">
                <div class="footer-hero-overlay"></div>
                <img src="${pageContext.request.contextPath}/images/footer-cinematic-hero.jpg" alt="SkyTech Airlines Jet Cruising Above Clouds" class="footer-hero-bg-img" loading="lazy">
                
                <div class="container footer-hero-content position-relative">
                    <div class="row align-items-center py-4 py-lg-5">
                        <div class="col-lg-7">
                            <div class="badge bg-sky-cyan-glow text-dark text-uppercase font-monospace fw-bold mb-2 px-3 py-2 rounded-pill">
                                <i class="bi bi-airplane-fill me-1"></i> SkyTech NextGen Aviation
                            </div>
                            <h2 class="display-6 fw-extrabold text-white mb-2 font-heading">
                                Soar Higher with <span class="text-sky-cyan">SkyTech Airlines</span>
                            </h2>
                            <p class="text-cloud-white opacity-85 lead fs-6 mb-0">
                                Engineering seamless passenger journeys, real-time flight search, seat selection, and reliable airline operations worldwide.
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

            <!-- Footer Main Content Grid -->
            <div class="skytech-footer-body py-5 bg-midnight-navy">
                <div class="container">
                    <div class="row g-4 mb-4">
                        <!-- Column 1: SkyTech Brand -->
                        <div class="col-lg-4 col-md-6">
                            <div class="d-flex align-items-center gap-2 mb-3">
                                <div class="brand-icon-wrap shadow-cyan-sm">
                                    <i class="bi bi-airplane-fill text-skytech-accent"></i>
                                </div>
                                <div class="brand-text-stack">
                                    <span class="text-white fw-bold fs-4 tracking-tight font-heading">SkyTech</span>
                                    <span class="text-sky-cyan text-uppercase fs-7 font-monospace tracking-widest d-block">Airlines</span>
                                </div>
                            </div>
                            <p class="text-muted-slate small mb-3 pe-lg-3">
                                Comprehensive Airline Reservation &amp; Passenger Management System featuring real-time flight search, interactive seat selection, and secure authentication.
                            </p>
                            <!-- Social Links -->
                            <div class="d-flex gap-2">
                                <a href="https://x.com" target="_blank" rel="noopener" class="skytech-social-btn" aria-label="SkyTech X (Twitter)">
                                    <i class="bi bi-twitter-x"></i>
                                </a>
                                <a href="https://facebook.com" target="_blank" rel="noopener" class="skytech-social-btn" aria-label="SkyTech Facebook">
                                    <i class="bi bi-facebook"></i>
                                </a>
                                <a href="https://linkedin.com" target="_blank" rel="noopener" class="skytech-social-btn" aria-label="SkyTech LinkedIn">
                                    <i class="bi bi-linkedin"></i>
                                </a>
                                <a href="https://instagram.com" target="_blank" rel="noopener" class="skytech-social-btn" aria-label="SkyTech Instagram">
                                    <i class="bi bi-instagram"></i>
                                </a>
                            </div>
                        </div>

                        <!-- Column 2: Book & Flight Operations -->
                        <div class="col-lg-2 col-md-6 col-6">
                            <h6 class="text-white fw-bold mb-3 font-heading text-uppercase fs-7 tracking-wider text-sky-cyan">Book &amp; Travel</h6>
                            <ul class="list-unstyled small d-flex flex-column gap-2 mb-0 footer-link-list">
                                <li><a href="${pageContext.request.contextPath}/"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Home</a></li>
                                <li><a href="${pageContext.request.contextPath}/search-flights"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Search Flights</a></li>
                                <li><a href="${pageContext.request.contextPath}/flight-status"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Flight Status</a></li>
                                <li><a href="${pageContext.request.contextPath}/manage-booking"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Manage Booking</a></li>
                                <li><a href="${pageContext.request.contextPath}/travel-information"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Travel Info</a></li>
                            </ul>
                        </div>

                        <!-- Column 3: Account & Management -->
                        <div class="col-lg-2 col-md-6 col-6">
                            <h6 class="text-white fw-bold mb-3 font-heading text-uppercase fs-7 tracking-wider text-sky-cyan">Account &amp; Docs</h6>
                            <ul class="list-unstyled small d-flex flex-column gap-2 mb-0 footer-link-list">
                                <li><a href="${pageContext.request.contextPath}/login"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Sign In</a></li>
                                <li><a href="${pageContext.request.contextPath}/register"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Create Account</a></li>
                                <li><a href="${pageContext.request.contextPath}/profile"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Passenger Profile</a></li>
                                <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Admin Dashboard</a></li>
                                <li><a href="${pageContext.request.contextPath}/project"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Project Architecture</a></li>
                                <li><a href="${pageContext.request.contextPath}/about"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Team &amp; Mentor</a></li>
                            </ul>
                        </div>

                        <!-- Column 4: Customer Support -->
                        <div class="col-lg-4 col-md-6">
                            <h6 class="text-white fw-bold mb-3 font-heading text-uppercase fs-7 tracking-wider text-sky-cyan">Customer Support</h6>
                            <ul class="list-unstyled small d-flex flex-column gap-3 mb-0 text-muted-slate">
                                <li class="d-flex align-items-start gap-2">
                                    <div class="support-icon-pill"><i class="bi bi-geo-alt-fill text-sky-cyan"></i></div>
                                    <span>SkyTech Terminal 3, Global Aviation Boulevard</span>
                                </li>
                                <li class="d-flex align-items-center gap-2">
                                    <div class="support-icon-pill"><i class="bi bi-telephone-fill text-sky-cyan"></i></div>
                                    <span>+1 (800) 555-SKYTECH</span>
                                </li>
                                <li class="d-flex align-items-center gap-2">
                                    <div class="support-icon-pill"><i class="bi bi-envelope-fill text-sky-cyan"></i></div>
                                    <a href="mailto:support@skytech-airlines.com" class="text-cloud-white text-decoration-none hover-sky-cyan">support@skytech-airlines.com</a>
                                </li>
                            </ul>
                        </div>
                    </div>

                    <hr class="border-secondary opacity-20 my-4">

                    <!-- Bottom Bar: Copyright & Tech Stack -->
                    <div class="d-flex flex-column flex-md-row justify-content-between align-items-center small text-muted-slate py-2 gap-2">
                        <div>
                            &copy; <%= java.time.Year.now().getValue() %> <strong class="text-white">SkyTech Airlines</strong> &bull; Airline Reservation System. All rights reserved.
                        </div>
                        <div class="font-monospace fs-8 text-md-end text-cloud-white opacity-75">
                            Powered by <span class="text-sky-cyan fw-semibold">Java 21</span> &bull; <span class="text-sky-cyan">Jakarta EE 10</span> &bull; <span class="text-sky-cyan">MySQL 8.3</span> &bull; <span class="text-sky-cyan">Tomcat 10.1</span>
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
