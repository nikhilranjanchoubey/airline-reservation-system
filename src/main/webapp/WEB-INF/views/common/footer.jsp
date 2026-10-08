<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Professional Airline Footer -->
<footer class="skytech-footer mt-auto bg-skytech text-light pt-5 pb-4 border-top border-secondary-subtle">
    <div class="container">
        <!-- Top Footer Brand & Value Proposition -->
        <div class="row g-4 pb-4 mb-4 border-bottom border-secondary border-opacity-25 align-items-center">
            <div class="col-lg-6">
                <div class="d-flex align-items-center gap-2 mb-2">
                    <i class="bi bi-airplane-engines-fill text-skytech-accent fs-3"></i>
                    <span class="fs-4 fw-bold tracking-wide">SKYTECH AIRLINES</span>
                </div>
                <p class="text-white-75 mb-0" style="max-width: 520px;">
                    Travel smarter. Fly better. Search and compare flights with SkyTech.
                </p>
            </div>
            <div class="col-lg-6 text-lg-end">
                <div class="d-inline-flex flex-column align-items-lg-end gap-2">
                    <span class="small text-white-50 text-uppercase tracking-wider">Connect With Us</span>
                    <div class="d-flex gap-2">
                        <span class="social-icon-btn text-white-50" title="Instagram (Official)"><i class="bi bi-instagram"></i></span>
                        <span class="social-icon-btn text-white-50" title="Facebook (Official)"><i class="bi bi-facebook"></i></span>
                        <span class="social-icon-btn text-white-50" title="LinkedIn (Official)"><i class="bi bi-linkedin"></i></span>
                        <span class="social-icon-btn text-white-50" title="X (Official)"><i class="bi bi-twitter-x"></i></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- 4 Airline Footer Columns -->
        <div class="row g-4 footer-links-section pb-4">
            <!-- Col 1: BOOK & TRAVEL -->
            <div class="col-lg-3 col-md-6 footer-column">
                <h6 class="footer-heading d-flex justify-content-between align-items-center" onclick="toggleFooterCol(this)">
                    <span>BOOK &amp; TRAVEL</span>
                    <i class="bi bi-chevron-down d-lg-none transition-transform"></i>
                </h6>
                <ul class="list-unstyled footer-links mb-0">
                    <li><a href="${pageContext.request.contextPath}/search-flights">Search Flights</a></li>
                    <li><a href="${pageContext.request.contextPath}/search-flights">Flight Schedule</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#popularRoutesSection">Popular Destinations</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#travelExperienceSection">Travel Offers</a></li>
                    <li><a href="${pageContext.request.contextPath}/search-flights">Seat Selection</a></li>
                </ul>
            </div>

            <!-- Col 2: MANAGE YOUR TRIP -->
            <div class="col-lg-3 col-md-6 footer-column">
                <h6 class="footer-heading d-flex justify-content-between align-items-center" onclick="toggleFooterCol(this)">
                    <span>MANAGE YOUR TRIP</span>
                    <i class="bi bi-chevron-down d-lg-none transition-transform"></i>
                </h6>
                <ul class="list-unstyled footer-links mb-0">
                    <li><a href="${pageContext.request.contextPath}/manage-booking">Manage Booking</a></li>
                    <li><a href="${pageContext.request.contextPath}/flight-status">Flight Status</a></li>
                    <li><a href="${pageContext.request.contextPath}/travel-information#checkin">Check-in</a></li>
                    <li><a href="${pageContext.request.contextPath}/travel-information#baggage">Baggage</a></li>
                    <li><a href="${pageContext.request.contextPath}/travel-information">Travel Information</a></li>
                </ul>
            </div>

            <!-- Col 3: ABOUT SKYTECH -->
            <div class="col-lg-3 col-md-6 footer-column">
                <h6 class="footer-heading d-flex justify-content-between align-items-center" onclick="toggleFooterCol(this)">
                    <span>ABOUT SKYTECH</span>
                    <i class="bi bi-chevron-down d-lg-none transition-transform"></i>
                </h6>
                <ul class="list-unstyled footer-links mb-0">
                    <li><a href="${pageContext.request.contextPath}/home#whySkyTechSection">About SkyTech</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#travelExperienceSection">Travel Experience</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#whySkyTechSection">Careers</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#helpSection">Contact Us</a></li>
                </ul>
            </div>

            <!-- Col 4: HELP & SUPPORT -->
            <div class="col-lg-3 col-md-6 footer-column">
                <h6 class="footer-heading d-flex justify-content-between align-items-center" onclick="toggleFooterCol(this)">
                    <span>HELP &amp; SUPPORT</span>
                    <i class="bi bi-chevron-down d-lg-none transition-transform"></i>
                </h6>
                <ul class="list-unstyled footer-links mb-0">
                    <li><a href="${pageContext.request.contextPath}/home#helpSection">Help Centre</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#helpSection">FAQs</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#helpSection">Contact Us</a></li>
                    <li><a href="${pageContext.request.contextPath}/travel-information#guidelines">Terms &amp; Conditions</a></li>
                    <li><a href="${pageContext.request.contextPath}/travel-information#guidelines">Privacy Policy</a></li>
                    <li><a href="${pageContext.request.contextPath}/travel-information#guidelines">Cookie Policy</a></li>
                </ul>
            </div>
        </div>

        <!-- Bottom Bar: Clean Airline Copyright -->
        <div class="row pt-4 border-top border-secondary border-opacity-25 align-items-center">
            <div class="col-md-8 text-center text-md-start mb-2 mb-md-0">
                <p class="small text-white-50 mb-0">
                    &copy; 2026 SkyTech Airlines. All rights reserved.
                </p>
            </div>
            <div class="col-md-4 text-center text-md-end">
                <a href="${pageContext.request.contextPath}/project" class="text-white-50 text-decoration-none small hover-underline" title="Academic Evaluation Documentation">
                    <i class="bi bi-file-earmark-code me-1"></i> Project Documentation
                </a>
            </div>
        </div>
    </div>
</footer>

<!-- Floating Back to Top Button -->
<button type="button" class="btn btn-primary rounded-circle shadow-lg back-to-top-btn" id="backToTopBtn"
        title="Back to top" aria-label="Scroll back to top" onclick="scrollToTop()">
    <i class="bi bi-arrow-up fs-5"></i>
</button>

<!-- Bootstrap 5 JS Bundle via CDN -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>

<!-- Global Interactions (Sticky Navbar, Back to Top, Scroll Animations, Footer Mobile Accordions) -->
<script>
    // Sticky Navbar & Back to Top Controller
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

    // Mobile Footer Accordion Toggle
    function toggleFooterCol(headerElem) {
        if (window.innerWidth < 992) {
            const col = headerElem.closest('.footer-column');
            if (col) {
                col.classList.toggle('active');
            }
        }
    }

    // Scroll-triggered animations with IntersectionObserver
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

<!-- Custom App Scripts -->
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
