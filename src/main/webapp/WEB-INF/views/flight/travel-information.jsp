<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="container my-5">
    <!-- Header -->
    <div class="text-center mb-5">
        <span class="badge bg-primary-subtle text-primary fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill">
            Passenger Guidance
        </span>
        <h1 class="display-6 fw-bold text-dark">Travel Information &amp; Guidelines</h1>
        <p class="text-muted">Everything you need to know before your flight with SkyTech Airlines.</p>
    </div>

    <div class="row g-4">
        <!-- Baggage Section -->
        <div class="col-lg-6" id="baggage">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white">
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
                        <span><strong>Cabin Baggage:</strong> 1 handbag or laptop bag (up to 7 kg). Dimensions: 55 x 35 x 25 cm.</span>
                        <span class="badge bg-success-subtle text-success">Included</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                        <span><strong>Checked Baggage (Economy):</strong> 1 piece up to 15 kg on domestic routes.</span>
                        <span class="badge bg-primary-subtle text-primary">Standard</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                        <span><strong>Checked Baggage (Business):</strong> Up to 30 kg combined across 2 pieces.</span>
                        <span class="badge bg-info-subtle text-info">Premium</span>
                    </li>
                </ul>
            </div>
        </div>

        <!-- Check-in Section -->
        <div class="col-lg-6" id="checkin">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-success-subtle text-success rounded-circle fs-4">
                        <i class="bi bi-qr-code-scan"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Check-in Procedures</h4>
                        <small class="text-muted">Timelines and boarding passes</small>
                    </div>
                </div>
                <ul class="list-group list-group-flush small">
                    <li class="list-group-item px-0 py-3">
                        <strong>Web Check-in:</strong> Opens 48 hours prior to scheduled departure and closes 60 minutes before takeoff.
                    </li>
                    <li class="list-group-item px-0 py-3">
                        <strong>Airport Counters:</strong> Check-in desks close strictly 60 minutes prior to departure.
                    </li>
                    <li class="list-group-item px-0 py-3">
                        <strong>Boarding Gates:</strong> Close 25 minutes prior to departure. Please arrive early at your departure gate.
                    </li>
                </ul>
            </div>
        </div>

        <!-- ID Proof Guidelines -->
        <div class="col-lg-6" id="guidelines">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-info-subtle text-info rounded-circle fs-4">
                        <i class="bi bi-person-badge-fill"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Valid Photo Identification</h4>
                        <small class="text-muted">Required documents for domestic flights</small>
                    </div>
                </div>
                <p class="small text-muted mb-2">Every passenger must present one of the following government-issued photo IDs at airport security:</p>
                <div class="d-flex flex-wrap gap-2 small">
                    <span class="badge bg-light text-dark border p-2">Aadhaar Card</span>
                    <span class="badge bg-light text-dark border p-2">Valid Passport</span>
                    <span class="badge bg-light text-dark border p-2">Driving Licence</span>
                    <span class="badge bg-light text-dark border p-2">Voter ID</span>
                    <span class="badge bg-light text-dark border p-2">Student ID (Govt. recognised)</span>
                </div>
            </div>
        </div>

        <!-- FAQs & Help -->
        <div class="col-lg-6" id="faqs">
            <div class="card h-100 border-0 shadow-sm rounded-4 p-4 bg-white">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="p-3 bg-warning-subtle text-warning-emphasis rounded-circle fs-4">
                        <i class="bi bi-question-circle-fill"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">Help &amp; FAQs</h4>
                        <small class="text-muted">Common questions answered</small>
                    </div>
                </div>
                <div class="accordion accordion-flush" id="faqAccordion">
                    <div class="accordion-item">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed py-2 px-0 small fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                                Can I select my seat in advance?
                            </button>
                        </h2>
                        <div id="faq1" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body px-0 small text-muted">
                                Yes, SkyTech allows seat selection during the search and flight review process with our interactive cabin seat map.
                            </div>
                        </div>
                    </div>
                    <div class="accordion-item">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed py-2 px-0 small fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                                What if my flight is delayed or rescheduled?
                            </button>
                        </h2>
                        <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body px-0 small text-muted">
                                You can check live status in real time via our <a href="${pageContext.request.contextPath}/flight-status">Flight Status</a> tool.
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
