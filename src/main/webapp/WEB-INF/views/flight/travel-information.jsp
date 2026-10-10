<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="container my-5" style="max-width: 860px;">
    <!-- Page Header -->
    <div class="text-center mb-4">
        <h1 class="fw-bold text-dark mb-2" style="font-size: 2.25rem;">Travel Information</h1>
        <p class="text-muted mb-0" style="font-size: 1.05rem;">Everything you need to know before your flight.</p>
    </div>

    <!-- Quick Links Bar -->
    <nav aria-label="Travel Information Sections" class="card border border-light-subtle shadow-sm rounded-4 p-2 mb-4 bg-white">
        <div class="travel-nav-scroller d-flex align-items-center justify-content-center gap-2 p-1">
            <a href="#baggage" class="btn btn-sm btn-outline-primary rounded-pill px-3 py-1 flex-shrink-0">Baggage</a>
            <a href="#checkin" class="btn btn-sm btn-outline-primary rounded-pill px-3 py-1 flex-shrink-0">Check-in</a>
            <a href="#documents" class="btn btn-sm btn-outline-primary rounded-pill px-3 py-1 flex-shrink-0">Travel Documents</a>
            <a href="#airports" class="btn btn-sm btn-outline-primary rounded-pill px-3 py-1 flex-shrink-0">Airports</a>
            <a href="#faqs" class="btn btn-sm btn-outline-primary rounded-pill px-3 py-1 flex-shrink-0">FAQs</a>
        </div>
    </nav>

    <div class="d-flex flex-column gap-4">
        <!-- 1. Baggage -->
        <section id="baggage" class="card border border-light-subtle shadow-sm rounded-4 p-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-3">
                <i class="bi bi-briefcase text-primary fs-5"></i>
                <h2 class="h5 fw-bold text-dark mb-0">Baggage</h2>
            </div>
            
            <div class="d-flex flex-column gap-3 text-secondary small" style="line-height: 1.6;">
                <div>
                    <strong class="text-dark d-block">Cabin baggage:</strong>
                    Many airlines allow one cabin bag up to 7 kg. Size and weight limits depend on your airline and ticket.
                </div>
                <div>
                    <strong class="text-dark d-block">Checked baggage:</strong>
                    Your checked baggage allowance depends on your airline and fare. Check your ticket before travelling.
                </div>
                <div>
                    <strong class="text-dark d-block">Restricted items:</strong>
                    Some items, including spare lithium batteries and power banks, must be carried according to airline and airport safety rules.
                </div>
                <div class="text-muted pt-2 border-top">
                    <i class="bi bi-info-circle me-1 text-primary"></i>
                    Always check your airline's baggage rules before departure.
                </div>
            </div>
        </section>

        <!-- 2. Check-in -->
        <section id="checkin" class="card border border-light-subtle shadow-sm rounded-4 p-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-3">
                <i class="bi bi-qr-code text-primary fs-5"></i>
                <h2 class="h5 fw-bold text-dark mb-0">Check-in</h2>
            </div>
            
            <div class="d-flex flex-column gap-3 text-secondary small" style="line-height: 1.6;">
                <div>
                    <strong class="text-dark d-block">Online check-in:</strong>
                    Check in on your airline's website or app when available.
                </div>
                <div>
                    <strong class="text-dark d-block">Airport check-in:</strong>
                    Arrive early enough to check in, drop your bags, and pass security.
                </div>
                <div>
                    <strong class="text-dark d-block">Boarding:</strong>
                    Check your boarding pass for the boarding time and gate.
                </div>
            </div>
        </section>

        <!-- 3. Travel Documents -->
        <section id="documents" class="card border border-light-subtle shadow-sm rounded-4 p-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-3">
                <i class="bi bi-file-earmark-person text-primary fs-5"></i>
                <h2 class="h5 fw-bold text-dark mb-0">Travel Documents</h2>
            </div>
            
            <div class="d-flex flex-column gap-3 text-secondary small" style="line-height: 1.6;">
                <div>
                    <strong class="text-dark d-block">Domestic flights:</strong>
                    Carry a valid form of identification accepted by your airline.
                </div>
                <div>
                    <strong class="text-dark d-block">International flights:</strong>
                    You may need a valid passport, visa, or other documents required by your destination and transit countries.
                </div>
                <div>
                    <strong class="text-dark d-block">Children:</strong>
                    Check the identification and travel-document requirements for children travelling with you.
                </div>
                <div class="text-muted pt-2 border-top">
                    <i class="bi bi-info-circle me-1 text-primary"></i>
                    Check official requirements before departure.
                </div>
            </div>
        </section>

        <!-- 4. Airport Information -->
        <section id="airports" class="card border border-light-subtle shadow-sm rounded-4 p-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-3">
                <i class="bi bi-building text-primary fs-5"></i>
                <h2 class="h5 fw-bold text-dark mb-0">Airport Information</h2>
            </div>
            
            <p class="text-secondary small mb-0" style="line-height: 1.6;">
                Your terminal and gate may depend on your airline and flight. Check your boarding pass and airport departure screens before heading to your gate.
            </p>
        </section>

        <!-- 5. Frequently Asked Questions -->
        <section id="faqs" class="card border border-light-subtle shadow-sm rounded-4 p-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-3">
                <i class="bi bi-question-circle text-primary fs-5"></i>
                <h2 class="h5 fw-bold text-dark mb-0">Frequently Asked Questions</h2>
            </div>

            <div class="accordion accordion-flush" id="faqAccordion">
                <div class="accordion-item border-bottom">
                    <h3 class="accordion-header" id="headingOne">
                        <button class="accordion-button collapsed py-3 px-0 fw-semibold text-dark fs-6" type="button" data-bs-toggle="collapse" data-bs-target="#faq1" aria-expanded="false" aria-controls="faq1">
                            Are the flight times and prices up to date?
                        </button>
                    </h3>
                    <div id="faq1" class="accordion-collapse collapse" aria-labelledby="headingOne" data-bs-parent="#faqAccordion">
                        <div class="accordion-body px-0 text-secondary small" style="line-height: 1.6;">
                            SkyTech shows flight information and prices returned by its connected provider. Airlines can change schedules and fares, so check the final details before booking.
                        </div>
                    </div>
                </div>

                <div class="accordion-item border-bottom">
                    <h3 class="accordion-header" id="headingTwo">
                        <button class="accordion-button collapsed py-3 px-0 fw-semibold text-dark fs-6" type="button" data-bs-toggle="collapse" data-bs-target="#faq2" aria-expanded="false" aria-controls="faq2">
                            Can I confirm my seat on SkyTech?
                        </button>
                    </h3>
                    <div id="faq2" class="accordion-collapse collapse" aria-labelledby="headingTwo" data-bs-parent="#faqAccordion">
                        <div class="accordion-body px-0 text-secondary small" style="line-height: 1.6;">
                            SkyTech lets you explore seat preferences. Your seat is not confirmed unless the airline or booking system confirms it.
                        </div>
                    </div>
                </div>

                <div class="accordion-item border-bottom">
                    <h3 class="accordion-header" id="headingThree">
                        <button class="accordion-button collapsed py-3 px-0 fw-semibold text-dark fs-6" type="button" data-bs-toggle="collapse" data-bs-target="#faq3" aria-expanded="false" aria-controls="faq3">
                            How much baggage can I carry?
                        </button>
                    </h3>
                    <div id="faq3" class="accordion-collapse collapse" aria-labelledby="headingThree" data-bs-parent="#faqAccordion">
                        <div class="accordion-body px-0 text-secondary small" style="line-height: 1.6;">
                            Baggage limits depend on your airline and ticket. Check your booking details before travelling.
                        </div>
                    </div>
                </div>

                <div class="accordion-item">
                    <h3 class="accordion-header" id="headingFour">
                        <button class="accordion-button collapsed py-3 px-0 fw-semibold text-dark fs-6" type="button" data-bs-toggle="collapse" data-bs-target="#faq4" aria-expanded="false" aria-controls="faq4">
                            How can I view my booking?
                        </button>
                    </h3>
                    <div id="faq4" class="accordion-collapse collapse" aria-labelledby="headingFour" data-bs-parent="#faqAccordion">
                        <div class="accordion-body px-0 text-secondary small" style="line-height: 1.6;">
                            Open <a href="${pageContext.request.contextPath}/manage-booking" class="text-decoration-none fw-semibold text-primary">Manage Booking</a> and enter your booking details if you have a valid booking reference.
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
