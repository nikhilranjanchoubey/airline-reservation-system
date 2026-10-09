<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="container my-5">
    <!-- Page Header -->
    <div class="text-center mb-5">
        <span class="badge bg-primary-subtle text-primary fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill tracking-wide">
            SkyTech Passenger Guidance &amp; Policies
        </span>
        <h1 class="display-6 fw-bold text-dark">Travel Information &amp; Support</h1>
        <p class="text-muted" style="max-width: 680px; margin: 0 auto;">
            Everything you need for a smooth and seamless journey with SkyTech — from check-in timelines and baggage allowances to passenger rights and legal policies.
        </p>
    </div>

    <!-- Quick Navigation Jump Bar -->
    <div class="card border-0 shadow-sm rounded-4 p-3 mb-5 bg-white">
        <div class="d-flex flex-wrap align-items-center justify-content-center gap-2 small">
            <span class="fw-bold text-muted text-uppercase me-2"><i class="bi bi-compass me-1"></i>Quick Jump:</span>
            <a href="#baggage" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1">Baggage</a>
            <a href="#checkin" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1">Check-in</a>
            <a href="#documents" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1">Travel Documents</a>
            <a href="#airports" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1">Airports</a>
            <a href="#guidelines" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1">Guidelines</a>
            <a href="#faqs" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1">FAQs</a>
            <a href="#help" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1">Customer Support</a>
            <a href="#passenger-rights" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1">Passenger Rights</a>
            <a href="#terms" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1">Legal Policies</a>
        </div>
    </div>

    <div class="row g-4">
        <!-- 1. Baggage Section -->
        <div class="col-lg-6" id="baggage">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white travel-info-card">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-primary-subtle text-primary rounded-circle fs-4">
                        <i class="bi bi-briefcase-fill"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Baggage Allowances</h4>
                        <small class="text-muted">Cabin and checked baggage regulations</small>
                    </div>
                </div>
                <ul class="list-group list-group-flush small">
                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                        <div>
                            <strong>Cabin Hand Baggage:</strong><br>
                            1 handbag or laptop bag up to 7 kg. Max dimensions: 55 &times; 35 &times; 25 cm.
                        </div>
                        <span class="badge bg-success-subtle text-success">Included</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                        <div>
                            <strong>Checked Baggage (Economy):</strong><br>
                            1 piece up to 15 kg on all domestic sectors across India.
                        </div>
                        <span class="badge bg-primary-subtle text-primary">Standard</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                        <div>
                            <strong>Checked Baggage (Business):</strong><br>
                            Up to 30 kg combined allowance across up to 2 checked bags.
                        </div>
                        <span class="badge bg-info-subtle text-info">Premium</span>
                    </li>
                    <li class="list-group-item px-0 py-3 text-muted">
                        <i class="bi bi-info-circle me-1 text-primary"></i> Excess baggage can be pre-booked at preferential rates up to 6 hours before departure.
                    </li>
                </ul>
            </div>
        </div>

        <!-- 2. Check-in Section -->
        <div class="col-lg-6" id="checkin">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white travel-info-card">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-success-subtle text-success rounded-circle fs-4">
                        <i class="bi bi-qr-code-scan"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Check-in Procedures</h4>
                        <small class="text-muted">Timelines, boarding passes &amp; airport counters</small>
                    </div>
                </div>
                <ul class="list-group list-group-flush small">
                    <li class="list-group-item px-0 py-3">
                        <strong>Web / Mobile Check-in:</strong><br>
                        Opens 48 hours prior to scheduled departure and closes 60 minutes before scheduled takeoff. Generates instant digital boarding pass.
                    </li>
                    <li class="list-group-item px-0 py-3">
                        <strong>Airport Baggage Drop &amp; Check-in Desks:</strong><br>
                        Counters open 2.5 hours prior and strictly close 60 minutes before departure for domestic flights.
                    </li>
                    <li class="list-group-item px-0 py-3">
                        <strong>Boarding Gate Closure:</strong><br>
                        Boarding gates close strictly 25 minutes before scheduled takeoff. Passengers must report with physical or electronic boarding pass.
                    </li>
                </ul>
            </div>
        </div>

        <!-- 3. Travel Documents Section -->
        <div class="col-lg-6" id="documents">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white travel-info-card">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-info-subtle text-info rounded-circle fs-4">
                        <i class="bi bi-file-earmark-person-fill"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Travel Documents</h4>
                        <small class="text-muted">Mandatory identification &amp; e-tickets</small>
                    </div>
                </div>
                <p class="small text-muted mb-3">
                    All passengers traveling on SkyTech flights must present original government-issued photo identification matching the passenger name on the ticket.
                </p>
                <div class="d-flex flex-wrap gap-2 small mb-3">
                    <span class="badge bg-light text-dark border p-2"><i class="bi bi-check2 text-success me-1"></i>Aadhaar Card (Physical / m-Aadhaar)</span>
                    <span class="badge bg-light text-dark border p-2"><i class="bi bi-check2 text-success me-1"></i>Valid Passport</span>
                    <span class="badge bg-light text-dark border p-2"><i class="bi bi-check2 text-success me-1"></i>Driving Licence</span>
                    <span class="badge bg-light text-dark border p-2"><i class="bi bi-check2 text-success me-1"></i>Voter ID Card</span>
                    <span class="badge bg-light text-dark border p-2"><i class="bi bi-check2 text-success me-1"></i>Government Employee ID</span>
                </div>
                <small class="text-muted">
                    For infants under 2 years, an official Birth Certificate or Passport is required at airport verification.
                </small>
            </div>
        </div>

        <!-- 4. Airport Information Section -->
        <div class="col-lg-6" id="airports">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white travel-info-card">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-secondary-subtle text-secondary rounded-circle fs-4">
                        <i class="bi bi-building"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Airport Information</h4>
                        <small class="text-muted">Terminal information across major hubs</small>
                    </div>
                </div>
                <ul class="list-group list-group-flush small">
                    <li class="list-group-item px-0 py-2 d-flex justify-content-between">
                        <span><strong>Delhi (DEL):</strong> Indira Gandhi International Airport</span>
                        <span class="badge bg-light text-dark border">Terminal 1 / 3</span>
                    </li>
                    <li class="list-group-item px-0 py-2 d-flex justify-content-between">
                        <span><strong>Mumbai (BOM):</strong> Chhatrapati Shivaji Maharaj International</span>
                        <span class="badge bg-light text-dark border">Terminal 2</span>
                    </li>
                    <li class="list-group-item px-0 py-2 d-flex justify-content-between">
                        <span><strong>Bengaluru (BLR):</strong> Kempegowda International Airport</span>
                        <span class="badge bg-light text-dark border">Terminal 1</span>
                    </li>
                    <li class="list-group-item px-0 py-2 d-flex justify-content-between">
                        <span><strong>Jaipur (JAI):</strong> Jaipur International Airport</span>
                        <span class="badge bg-light text-dark border">Terminal 2</span>
                    </li>
                </ul>
                <div class="mt-2 text-muted small">
                    <i class="bi bi-info-circle me-1 text-primary"></i> Please verify terminal info on your boarding pass as operational assignments may adjust.
                </div>
            </div>
        </div>

        <!-- 5. Travel Guidelines Section -->
        <div class="col-lg-6" id="guidelines">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white travel-info-card">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-warning-subtle text-warning-emphasis rounded-circle fs-4">
                        <i class="bi bi-shield-check"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Travel Guidelines &amp; Special Care</h4>
                        <small class="text-muted">Medical clearance, infant travel, &amp; security</small>
                    </div>
                </div>
                <ul class="list-group list-group-flush small">
                    <li class="list-group-item px-0 py-2">
                        <strong>Expectant Mothers:</strong> Travel permitted without clearance up to 28 weeks; medical fitness certificate required between 28 and 36 weeks.
                    </li>
                    <li class="list-group-item px-0 py-2">
                        <strong>Wheelchair &amp; Special Assistance:</strong> Complimentary wheelchair service can be requested up to 24 hours prior to scheduled departure.
                    </li>
                    <li class="list-group-item px-0 py-2">
                        <strong>Restricted Items:</strong> Power banks and e-cigarettes are strictly permitted in cabin baggage only; carriage in checked luggage is prohibited.
                    </li>
                </ul>
            </div>
        </div>

        <!-- 6. Passenger Rights Section -->
        <div class="col-lg-6" id="passenger-rights">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white travel-info-card">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-primary-subtle text-primary rounded-circle fs-4">
                        <i class="bi bi-award-fill"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Passenger Rights &amp; Delays</h4>
                        <small class="text-muted">Civil aviation passenger charter standards</small>
                    </div>
                </div>
                <p class="small text-muted mb-2">
                    In compliance with Directorate General of Civil Aviation (DGCA) regulations, SkyTech passengers enjoy guaranteed consumer protections:
                </p>
                <ul class="list-group list-group-flush small">
                    <li class="list-group-item px-0 py-2">
                        <strong>Flight Delays &gt; 2 Hours:</strong> Complimentary refreshments and meals provided at the boarding gate.
                    </li>
                    <li class="list-group-item px-0 py-2">
                        <strong>Flight Cancellations:</strong> Alternative flight accommodation or full fare refund without deduction.
                    </li>
                    <li class="list-group-item px-0 py-2">
                        <strong>Denied Boarding:</strong> Immediate alternative flight accommodation plus mandatory compensation.
                    </li>
                </ul>
            </div>
        </div>

        <!-- 7. Help & Customer Support Section -->
        <div class="col-lg-6" id="help">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white travel-info-card">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-info-subtle text-info rounded-circle fs-4">
                        <i class="bi bi-headset"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">SkyTech Customer Support</h4>
                        <small class="text-muted">Need help with your journey? We are here for you.</small>
                    </div>
                </div>
                <p class="small text-muted mb-3">
                    Our dedicated passenger assistance team is available round-the-clock to resolve reservation questions, handle refund requests, and support special needs.
                </p>
                <div class="p-3 bg-light rounded-3 mb-3 small">
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <i class="bi bi-telephone-fill text-primary"></i>
                        <span class="fw-bold">24&times;7 Dedicated Customer Helpline</span>
                    </div>
                    <div class="text-muted ps-4">Contact SkyTech Support through our official passenger portal.</div>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/manage-booking" class="btn btn-outline-primary btn-sm rounded-pill px-3">
                        Manage Booking
                    </a>
                    <a href="${pageContext.request.contextPath}/flight-status" class="btn btn-outline-secondary btn-sm rounded-pill px-3">
                        Check Flight Status
                    </a>
                </div>
            </div>
        </div>

        <!-- 8. Careers at SkyTech Section -->
        <div class="col-lg-6" id="careers">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white travel-info-card">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-success-subtle text-success rounded-circle fs-4">
                        <i class="bi bi-people-fill"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Careers at SkyTech</h4>
                        <small class="text-muted">Fly with passion &bull; Join the SkyTech team</small>
                    </div>
                </div>
                <p class="small text-muted mb-3">
                    SkyTech is expanding across domestic and regional hubs. We are always seeking passionate aviators, cabin crew professionals, ground operations experts, and software engineers to shape the future of air travel.
                </p>
                <ul class="list-group list-group-flush small mb-3">
                    <li class="list-group-item px-0 py-2 d-flex justify-content-between align-items-center">
                        <span>Flight Operations &amp; First Officers</span>
                        <span class="badge bg-primary-subtle text-primary">Hiring</span>
                    </li>
                    <li class="list-group-item px-0 py-2 d-flex justify-content-between align-items-center">
                        <span>Cabin Service Associates</span>
                        <span class="badge bg-primary-subtle text-primary">Hiring</span>
                    </li>
                    <li class="list-group-item px-0 py-2 d-flex justify-content-between align-items-center">
                        <span>Airport Customer Care Specialists</span>
                        <span class="badge bg-primary-subtle text-primary">Hiring</span>
                    </li>
                </ul>
                <small class="text-muted">
                    Submit inquiries and professional CVs via the SkyTech Talent Gateway.
                </small>
            </div>
        </div>

        <!-- 9. FAQs Section -->
        <div class="col-12" id="faqs">
            <div class="card border-0 shadow-sm rounded-4 p-4 bg-white travel-info-card">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-warning-subtle text-warning-emphasis rounded-circle fs-4">
                        <i class="bi bi-question-circle-fill"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Frequently Asked Questions (FAQs)</h4>
                        <small class="text-muted">Quick answers to common passenger questions</small>
                    </div>
                </div>
                <div class="accordion accordion-flush" id="faqAccordion">
                    <div class="accordion-item border-bottom">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed py-3 px-0 fw-semibold text-dark" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                                Can I select my seat in advance on SkyTech flights?
                            </button>
                        </h2>
                        <div id="faq1" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body px-0 text-muted small">
                                Yes. SkyTech provides an interactive cabin seat selection map during the flight review process. You can choose from window, aisle, middle seats, or extra-legroom emergency exit rows.
                            </div>
                        </div>
                    </div>
                    <div class="accordion-item border-bottom">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed py-3 px-0 fw-semibold text-dark" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                                What if my flight is rescheduled or delayed?
                            </button>
                        </h2>
                        <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body px-0 text-muted small">
                                You can check real-time gate and schedule information on our <a href="${pageContext.request.contextPath}/flight-status" class="fw-bold text-decoration-none">Flight Status</a> tool. In case of schedule revisions exceeding 2 hours, passengers may reschedule or request a full fare refund.
                            </div>
                        </div>
                    </div>
                    <div class="accordion-item border-bottom">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed py-3 px-0 fw-semibold text-dark" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                                What is the baggage allowance for domestic travel in India?
                            </button>
                        </h2>
                        <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body px-0 text-muted small">
                                Economy standard fare allows 1 piece of checked baggage up to 15 kg plus 1 piece of cabin baggage up to 7 kg. Business Class allows up to 30 kg checked baggage.
                            </div>
                        </div>
                    </div>
                    <div class="accordion-item border-bottom">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed py-3 px-0 fw-semibold text-dark" type="button" data-bs-toggle="collapse" data-bs-target="#faq4">
                                How can I retrieve or modify my flight reservation?
                            </button>
                        </h2>
                        <div id="faq4" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body px-0 text-muted small">
                                Visit our <a href="${pageContext.request.contextPath}/manage-booking" class="fw-bold text-decoration-none">Manage Booking</a> page with your 6-character PNR or booking reference and passenger surname to view and download your itinerary.
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 10. Legal & Policies Section (Terms, Privacy, Cookies, Accessibility) -->
        <div class="col-12" id="terms">
            <div class="card border-0 shadow-sm rounded-4 p-4 bg-white travel-info-card">
                <div class="d-flex align-items-center gap-3 mb-4">
                    <div class="p-3 bg-secondary-subtle text-secondary rounded-circle fs-4">
                        <i class="bi bi-file-earmark-text-fill"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Legal Terms &amp; Conditions of Carriage</h4>
                        <small class="text-muted">SkyTech passenger contractual guidelines</small>
                    </div>
                </div>
                <div class="row g-4">
                    <div class="col-md-6" id="privacy">
                        <h6 class="fw-bold text-dark"><i class="bi bi-shield-lock text-primary me-2"></i>Privacy Policy</h6>
                        <p class="small text-muted mb-0">
                            SkyTech values passenger confidentiality. We collect reservation data strictly for booking facilitation, regulatory travel compliance, and passenger notifications. We never sell personal data to unauthorized third parties.
                        </p>
                    </div>
                    <div class="col-md-6" id="cookies">
                        <h6 class="fw-bold text-dark"><i class="bi bi-cookie text-primary me-2"></i>Cookie Policy</h6>
                        <p class="small text-muted mb-0">
                            We utilize essential cookies to retain search criteria, session tokens, and security parameters across booking journeys. Performance cookies assist in optimizing flight availability load times.
                        </p>
                    </div>
                    <div class="col-md-6" id="accessibility">
                        <h6 class="fw-bold text-dark"><i class="bi bi-universal-access text-primary me-2"></i>Accessibility Commitment</h6>
                        <p class="small text-muted mb-0">
                            SkyTech digital platforms are built in alignment with WCAG 2.1 AA accessibility guidelines, enabling seamless keyboard navigation, high contrast legibility, and screen reader compatibility for all passengers.
                        </p>
                    </div>
                    <div class="col-md-6">
                        <h6 class="fw-bold text-dark"><i class="bi bi-receipt text-primary me-2"></i>Fare Rules &amp; Taxes</h6>
                        <p class="small text-muted mb-0">
                            All quoted airfares include transparent breakdowns of base airfare, applicable User Development Fees (UDF), Passenger Service Fees (PSF), and statutory GST with zero hidden fees.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
