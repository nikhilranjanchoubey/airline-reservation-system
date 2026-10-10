<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Footer -->
<footer class="skytech-footer mt-auto text-light border-top border-white border-opacity-10 py-4" role="contentinfo" aria-label="SkyTech Corporate and Travel Information">
    <div class="container">
        <!-- Main Footer Navigation Grid -->
        <div class="row g-4 pb-3">
            <!-- Brand & Tagline Area -->
            <div class="col-lg-4 col-md-12">
                <div class="d-flex align-items-center gap-2 mb-2">
                    <i class="bi bi-airplane-engines-fill text-skytech-accent fs-4"></i>
                    <span class="fs-4 fw-bold tracking-wide text-white">SKYTECH</span>
                </div>
                <p class="fw-semibold text-skytech-accent mb-1 small">
                    Travel smarter. Fly better.
                </p>
                <p class="text-white-50 small mb-0" style="max-width: 320px; line-height: 1.5;">
                    Search, compare and manage your flights with SkyTech.
                </p>
            </div>

            <!-- 3 Compact Navigation Columns -->
            <div class="col-lg-8 col-md-12">
                <nav class="row g-3" aria-label="Footer Navigation">
                    <!-- Column 1: BOOK & MANAGE -->
                    <div class="col-sm-4 col-12 footer-column">
                        <h6 class="footer-heading mb-2">BOOK &amp; MANAGE</h6>
                        <ul class="list-unstyled footer-links mb-0 small">
                            <li><a href="${pageContext.request.contextPath}/search-flights">Search Flights</a></li>
                            <li><a href="${pageContext.request.contextPath}/manage-booking">Manage Booking</a></li>
                            <li><a href="${pageContext.request.contextPath}/flight-status">Flight Status</a></li>
                            <li><a href="${pageContext.request.contextPath}/search-flights">Flight Schedule</a></li>
                        </ul>
                    </div>

                    <!-- Column 2: TRAVEL -->
                    <div class="col-sm-4 col-12 footer-column">
                        <h6 class="footer-heading mb-2">TRAVEL</h6>
                        <ul class="list-unstyled footer-links mb-0 small">
                            <li><a href="${pageContext.request.contextPath}/travel-information">Travel Information</a></li>
                            <li><a href="${pageContext.request.contextPath}/travel-information#baggage">Baggage Information</a></li>
                            <li><a href="${pageContext.request.contextPath}/travel-information#documents">Travel Documents</a></li>
                            <li><a href="${pageContext.request.contextPath}/travel-information#airports">Airport Information</a></li>
                        </ul>
                    </div>

                    <!-- Column 3: SUPPORT -->
                    <div class="col-sm-4 col-12 footer-column">
                        <h6 class="footer-heading mb-2">SUPPORT</h6>
                        <ul class="list-unstyled footer-links mb-0 small">
                            <li><a href="${pageContext.request.contextPath}/travel-information#faqs">Help Centre</a></li>
                            <li><a href="${pageContext.request.contextPath}/travel-information#faqs">FAQs</a></li>
                            <li><a href="${pageContext.request.contextPath}/travel-information#help">Contact Us</a></li>
                        </ul>
                    </div>
                </nav>
            </div>
        </div>

        <!-- Subtle Divider -->
        <hr class="border-white border-opacity-10 my-3">

        <!-- Legal Links Row -->
        <div class="row align-items-center g-2 text-center text-md-start">
            <div class="col-md-7">
                <div class="d-flex flex-wrap justify-content-center justify-content-md-start align-items-center gap-2 gap-md-3 small footer-legal-links text-white-50">
                    <a href="${pageContext.request.contextPath}/travel-information#terms">Terms &amp; Conditions</a>
                    <span class="text-white-25">&bull;</span>
                    <a href="${pageContext.request.contextPath}/travel-information#privacy">Privacy Policy</a>
                    <span class="text-white-25">&bull;</span>
                    <a href="${pageContext.request.contextPath}/travel-information#cookies">Cookie Policy</a>
                    <span class="text-white-25">&bull;</span>
                    <a href="${pageContext.request.contextPath}/travel-information#accessibility">Accessibility</a>
                    <span class="text-white-25">&bull;</span>
                    <a href="${pageContext.request.contextPath}/travel-information#passenger-rights">Passenger Rights</a>
                </div>
            </div>
            <div class="col-md-5 text-center text-md-end">
                <p class="small text-white-50 mb-0">
                    &copy; <%= java.time.Year.now().getValue() %> SkyTech. All rights reserved.
                </p>
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

<!-- SkyTech Reusable Toast Container & Library -->
<div class="skytech-toast-container" id="skytech-toast-container" aria-live="polite" aria-atomic="true"></div>
<script src="${pageContext.request.contextPath}/assets/js/skytech-toast.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/skytech-calendar.js"></script>

<!-- Global Interactions (Sticky Navbar, Back to Top, Scroll Animations) -->
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
