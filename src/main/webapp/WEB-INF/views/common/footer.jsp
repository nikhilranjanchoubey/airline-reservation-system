<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:choose>
    <c:when test="${activePage == 'login' || activePage == 'register'}">
        <!-- Sleek minimal footer for authentication pages -->
        <footer class="py-3 text-center text-secondary bg-transparent" style="position: relative; z-index: 10;">
            <div class="container">
                <span class="text-white-50 small">&copy; <%= java.time.Year.now().getValue() %> SkyTech Airlines &bull; Airline Reservation System</span>
            </div>
        </footer>
    </c:when>
    <c:otherwise>
        <footer class="skytech-cinematic-footer mt-auto" id="contactSection">
            <!-- Part A: Cinematic Aviation Hero Banner above footer -->
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
                                Engineering seamless passenger journeys, real-time flight reservations, and cloud-native airline operations worldwide.
                            </p>
                        </div>
                        <div class="col-lg-5 text-lg-end mt-3 mt-lg-0">
                            <a href="${pageContext.request.contextPath}/#searchPanelSection" class="btn btn-sky-electric btn-lg rounded-pill px-4 shadow-cyan-glow">
                                <i class="bi bi-ticket-perforated-fill me-2"></i> Book Your Flight
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Glowing Curved Cyan Divider Line -->
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
                                    <i class="bi bi-airplane-fill"></i>
                                </div>
                                <div class="brand-text-stack">
                                    <span class="text-white fw-bold fs-4 tracking-tight font-heading">SkyTech</span>
                                    <span class="text-sky-cyan text-uppercase fs-7 font-monospace tracking-widest d-block">Airlines</span>
                                </div>
                            </div>
                            <p class="text-muted-slate small mb-4 pe-lg-3">
                                Fast, secure, and reliable airline reservation and passenger portal services worldwide. Experience premium cloud-native aviation solutions.
                            </p>
                            <!-- Social Links with Hover Lift & Glow -->
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

                        <!-- Column 2: Quick Links -->
                        <div class="col-lg-2 col-md-6 col-6">
                            <h6 class="text-white fw-bold mb-3 font-heading text-uppercase fs-7 tracking-wider text-sky-cyan">Quick Links</h6>
                            <ul class="list-unstyled small d-flex flex-column gap-2 mb-0 footer-link-list">
                                <li><a href="${pageContext.request.contextPath}/"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Home</a></li>
                                <li><a href="${pageContext.request.contextPath}/#searchPanelSection"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Flight Results</a></li>
                                <li><a href="${pageContext.request.contextPath}/#searchPanelSection"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Seat Selection</a></li>
                                <li><a href="${pageContext.request.contextPath}/#servicesSection"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Airport Services</a></li>
                                <li><a href="${pageContext.request.contextPath}/about"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> About SkyTech</a></li>
                            </ul>
                        </div>

                        <!-- Column 3: Account -->
                        <div class="col-lg-2 col-md-6 col-6">
                            <h6 class="text-white fw-bold mb-3 font-heading text-uppercase fs-7 tracking-wider text-sky-cyan">Account</h6>
                            <ul class="list-unstyled small d-flex flex-column gap-2 mb-0 footer-link-list">
                                <li><a href="${pageContext.request.contextPath}/login"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Sign In</a></li>
                                <li><a href="${pageContext.request.contextPath}/register"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Create Account</a></li>
                                <li><a href="${pageContext.request.contextPath}/profile"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Passenger Profile</a></li>
                                <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-chevron-right me-1 text-sky-cyan fs-8"></i> Admin Dashboard</a></li>
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

                    <!-- Bottom Bar: Copyright & Tech Credits -->
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

<!-- Bootstrap 5.3 Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
<!-- Client-side Auth Validation -->
<script src="${pageContext.request.contextPath}/js/auth-validation.js"></script>
</body>
</html>
