<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="container my-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb small">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/search-flights" class="text-decoration-none">Search</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/flight-details?id=${schedule.scheduleId}&travelClass=${travelClass}&passengers=${passengers}" class="text-decoration-none">Flight Details</a></li>
            <li class="breadcrumb-item active" aria-current="page">Select Seats</li>
        </ol>
    </nav>

    <!-- Header Flight Strip -->
    <div class="search-summary-bar mb-4">
        <div class="row align-items-center gy-3">
            <div class="col-lg-8">
                <div class="d-flex flex-wrap align-items-center gap-3">
                    <c:set var="aCode" value="${schedule.flight.airline.airlineCode}" />
                    <div class="airline-logo-box" style="width: 44px; height: 44px; min-width: 44px; border-radius: 10px; overflow: hidden; display: flex; align-items: center; justify-content: center; background: #ffffff; border: 1px solid #e2e8f0; padding: 4px;">
                        <c:choose>
                            <c:when test="${aCode eq '6E' || aCode eq 'AI' || aCode eq 'QP' || aCode eq 'UK'}">
                                <img src="${pageContext.request.contextPath}/assets/images/airlines/${aCode}.svg" alt="${schedule.flight.airline.airlineName}" style="max-width: 100%; max-height: 100%; object-fit: contain;">
                            </c:when>
                            <c:otherwise>
                                <span class="fw-bold text-primary small">${aCode}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div>
                        <div class="fw-bold fs-5 text-dark">
                            ${schedule.flight.airline.airlineName} ${schedule.flight.flightNumber}
                            <span class="badge bg-primary-subtle text-primary ms-2 small">${travelClass}</span>
                        </div>
                        <div class="text-muted small">
                            ${schedule.flight.sourceAirport.city} (${schedule.flight.sourceAirport.airportCode})
                            &rarr;
                            ${schedule.flight.destinationAirport.city} (${schedule.flight.destinationAirport.airportCode})
                            &bull; ${schedule.formattedFlightDate} &bull; ${passengers} Passenger(s)
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 text-lg-end">
                <span class="badge bg-light text-muted border px-3 py-2">
                    <i class="bi bi-info-circle me-1"></i> Aircraft: ${schedule.flight.aircraftModel}
                </span>
            </div>
        </div>
    </div>

    <!-- Seat Map Workspace Grid -->
    <div class="row g-4">
        <!-- Aircraft Cabin Visual (Left / Center) -->
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm rounded-4 p-4 bg-white">
                <div class="d-flex flex-wrap justify-content-between align-items-center border-bottom pb-3 mb-4 gap-2">
                    <div>
                        <h5 class="fw-bold text-dark mb-1">Cabin Seat Map</h5>
                        <p class="text-muted small mb-0">Select your preferred seat(s) for ${passengers} traveller(s)</p>
                    </div>

                    <!-- Legend -->
                    <div class="d-flex flex-wrap align-items-center gap-3 small">
                        <div class="d-flex align-items-center gap-1">
                            <span class="legend-seat-sample legend-available"></span> Available
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <span class="legend-seat-sample legend-selected"></span> Selected
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <span class="legend-seat-sample legend-occupied"></span> Occupied
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <span class="legend-seat-sample legend-blocked"></span> Blocked
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <span class="legend-seat-sample legend-extra">⭐</span> Extra Legroom
                        </div>
                    </div>
                </div>

                <!-- Aircraft Fuselage Shell -->
                <div class="cabin-fuselage-wrapper">
                    <div class="cockpit-nose text-center py-2 mb-3">
                        <i class="bi bi-airplane-fill fs-3 text-primary"></i>
                        <span class="d-block small text-muted text-uppercase fw-bold tracking-wide">Front / Cockpit &uarr;</span>
                    </div>

                    <!-- Column Letters Header -->
                    <div class="seat-row-grid column-header-row mb-2">
                        <div class="row-num-placeholder"></div>
                        <div class="seat-col-label">A</div>
                        <div class="seat-col-label">B</div>
                        <div class="seat-col-label">C</div>
                        <div class="aisle-spacer">Aisle</div>
                        <div class="seat-col-label">D</div>
                        <div class="seat-col-label">E</div>
                        <div class="seat-col-label">F</div>
                    </div>

                    <!-- Rows Grid (Rows 1 to 20) -->
                    <div class="cabin-rows-container">
                        <c:forEach var="row" begin="1" end="20">
                            <div class="seat-row-grid mb-2">
                                <div class="row-number-badge">${row}</div>

                                <!-- Seat A -->
                                <c:forEach var="s" items="${seats}">
                                    <c:if test="${s.rowNumber == row && s.columnLetter == 'A'}">
                                        <div class="seat-cell ${s.cssClass}"
                                             data-seat="${s.seatNumber}"
                                             data-type="${s.seatType}"
                                             data-fee="${s.premiumFee}"
                                             data-status="${s.status}"
                                             onclick="toggleSeatSelection(this)"
                                             title="Seat ${s.seatNumber}: ${s.seatType} (${s.status})">
                                            ${s.extraLegroom ? '⭐' : s.columnLetter}
                                        </div>
                                    </c:if>
                                </c:forEach>

                                <!-- Seat B -->
                                <c:forEach var="s" items="${seats}">
                                    <c:if test="${s.rowNumber == row && s.columnLetter == 'B'}">
                                        <div class="seat-cell ${s.cssClass}"
                                             data-seat="${s.seatNumber}"
                                             data-type="${s.seatType}"
                                             data-fee="${s.premiumFee}"
                                             data-status="${s.status}"
                                             onclick="toggleSeatSelection(this)"
                                             title="Seat ${s.seatNumber}: ${s.seatType} (${s.status})">
                                            ${s.extraLegroom ? '⭐' : s.columnLetter}
                                        </div>
                                    </c:if>
                                </c:forEach>

                                <!-- Seat C -->
                                <c:forEach var="s" items="${seats}">
                                    <c:if test="${s.rowNumber == row && s.columnLetter == 'C'}">
                                        <div class="seat-cell ${s.cssClass}"
                                             data-seat="${s.seatNumber}"
                                             data-type="${s.seatType}"
                                             data-fee="${s.premiumFee}"
                                             data-status="${s.status}"
                                             onclick="toggleSeatSelection(this)"
                                             title="Seat ${s.seatNumber}: ${s.seatType} (${s.status})">
                                            ${s.extraLegroom ? '⭐' : s.columnLetter}
                                        </div>
                                    </c:if>
                                </c:forEach>

                                <!-- Aisle Spacer -->
                                <div class="aisle-spacer">${row}</div>

                                <!-- Seat D -->
                                <c:forEach var="s" items="${seats}">
                                    <c:if test="${s.rowNumber == row && s.columnLetter == 'D'}">
                                        <div class="seat-cell ${s.cssClass}"
                                             data-seat="${s.seatNumber}"
                                             data-type="${s.seatType}"
                                             data-fee="${s.premiumFee}"
                                             data-status="${s.status}"
                                             onclick="toggleSeatSelection(this)"
                                             title="Seat ${s.seatNumber}: ${s.seatType} (${s.status})">
                                            ${s.extraLegroom ? '⭐' : s.columnLetter}
                                        </div>
                                    </c:if>
                                </c:forEach>

                                <!-- Seat E -->
                                <c:forEach var="s" items="${seats}">
                                    <c:if test="${s.rowNumber == row && s.columnLetter == 'E'}">
                                        <div class="seat-cell ${s.cssClass}"
                                             data-seat="${s.seatNumber}"
                                             data-type="${s.seatType}"
                                             data-fee="${s.premiumFee}"
                                             data-status="${s.status}"
                                             onclick="toggleSeatSelection(this)"
                                             title="Seat ${s.seatNumber}: ${s.seatType} (${s.status})">
                                            ${s.extraLegroom ? '⭐' : s.columnLetter}
                                        </div>
                                    </c:if>
                                </c:forEach>

                                <!-- Seat F -->
                                <c:forEach var="s" items="${seats}">
                                    <c:if test="${s.rowNumber == row && s.columnLetter == 'F'}">
                                        <div class="seat-cell ${s.cssClass}"
                                             data-seat="${s.seatNumber}"
                                             data-type="${s.seatType}"
                                             data-fee="${s.premiumFee}"
                                             data-status="${s.status}"
                                             onclick="toggleSeatSelection(this)"
                                             title="Seat ${s.seatNumber}: ${s.seatType} (${s.status})">
                                            ${s.extraLegroom ? '⭐' : s.columnLetter}
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </c:forEach>
                    </div>

                    <div class="aircraft-tail text-center py-3 mt-3 border-top">
                        <small class="text-muted fw-bold text-uppercase">&darr; Rear of Aircraft / Galley</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Seat Selection Summary & Booking Handoff (Right) -->
        <div class="col-lg-4">
            <div class="flight-details-card sticky-top" style="top: 90px;">
                <h5 class="fw-bold text-dark mb-3">Selected Seats</h5>

                <div class="mb-3">
                    <div class="small text-muted mb-1">
                        Allowed selection: <strong>${passengers}</strong> passenger(s)
                    </div>
                    <div id="selectedSeatsChips" class="d-flex flex-wrap gap-2 min-vh-20">
                        <span class="text-muted small fst-italic" id="noSeatsChosenText">No seats selected yet. Click an available seat on the map.</span>
                    </div>
                </div>

                <hr class="my-3">

                <!-- Dynamic Seat Pricing Calculation -->
                <div class="fare-breakdown-box mb-4">
                    <div class="fare-breakdown-row">
                        <span>Flight Base Fare (${passengers} &times; &#8377;<fmt:formatNumber value="${perPassengerFare}" type="number" maxFractionDigits="0" />)</span>
                        <strong class="text-dark">&#8377;<fmt:formatNumber value="${baseFareTotal}" type="number" maxFractionDigits="0" /></strong>
                    </div>
                    <div class="fare-breakdown-row">
                        <span>Selected Seat(s)</span>
                        <strong id="summarySeatList" class="text-dark">-</strong>
                    </div>
                    <div class="fare-breakdown-row">
                        <span>Seat Preference Fee</span>
                        <strong id="summarySeatFee" class="text-dark">&#8377;0</strong>
                    </div>
                    <div class="fare-breakdown-row">
                        <span>Airport Taxes &amp; GST (12%)</span>
                        <strong id="summaryTaxes" class="text-dark">&#8377;<fmt:formatNumber value="${initialTaxes}" type="number" maxFractionDigits="0" /></strong>
                    </div>
                    <div class="fare-breakdown-row total-row">
                        <span>Total Payable</span>
                        <span class="text-primary fs-5" id="summaryTotalSeatCost">&#8377;<fmt:formatNumber value="${initialGrandTotal}" type="number" maxFractionDigits="0" /></span>
                    </div>
                </div>

                <!-- Continue CTA Button -->
                <button type="button" class="btn btn-primary w-100 py-2 fw-semibold d-flex align-items-center justify-content-center gap-2 mb-2"
                        data-bs-toggle="modal" data-bs-target="#seatHandoffModal">
                    Confirm Seats &amp; Continue <i class="bi bi-arrow-right"></i>
                </button>

                <div class="mt-2 text-center">
                    <a href="${pageContext.request.contextPath}/flight-details?id=${schedule.scheduleId}&travelClass=${travelClass}&passengers=${passengers}"
                       class="btn btn-link btn-sm text-decoration-none text-muted">
                        &larr; Return to Flight Details
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Seat Confirmation Modal -->
    <div class="modal fade" id="seatHandoffModal" tabindex="-1" aria-labelledby="seatHandoffModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow border-0 rounded-4">
                <div class="modal-header border-bottom">
                    <h5 class="modal-title fw-bold" id="seatHandoffModalLabel">
                        <i class="bi bi-airplane-fill text-primary me-2"></i>Seats Confirmed
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center py-4">
                    <div class="display-6 text-success mb-3">
                        <i class="bi bi-check-circle"></i>
                    </div>
                    <h5 class="fw-bold mb-2">Seat Assignment Ready!</h5>
                    <p class="text-muted small mb-3">
                        Flight: <strong>${schedule.flight.airline.airlineName} ${schedule.flight.flightNumber}</strong><br>
                        Seats: <strong id="modalSeatsAssigned" class="text-primary">-</strong>
                    </p>
                    <div class="p-3 bg-light rounded-3 text-start small text-muted">
                        <i class="bi bi-info-circle text-primary me-1"></i>
                        <strong>Next Step:</strong> Complete passenger information and proceed to payment.
                    </div>
                </div>
                <div class="modal-footer border-top">
                    <button type="button" class="btn btn-primary btn-sm rounded-pill px-4" data-bs-dismiss="modal">Proceed</button>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Interactive Seat Selection Logic Script -->
<script>
    const MAX_PASSENGERS = ${passengers};
    let selectedSeats = [];

    function toggleSeatSelection(el) {
        const status = el.getAttribute('data-status');
        if (status === 'OCCUPIED' || status === 'BLOCKED') {
            return; // Cannot select occupied or blocked seats
        }

        const seatNum = el.getAttribute('data-seat');
        const fee = parseFloat(el.getAttribute('data-fee')) || 0;
        const type = el.getAttribute('data-type');

        const index = selectedSeats.findIndex(s => s.number === seatNum);

        if (index >= 0) {
            // Deselect
            selectedSeats.splice(index, 1);
            el.classList.remove('seat-selected');
        } else {
            // Check if already reached max passengers
            if (selectedSeats.length >= MAX_PASSENGERS) {
                alert('You have already selected ' + MAX_PASSENGERS + ' seat(s) for ' + MAX_PASSENGERS + ' passenger(s). Deselect a seat first to choose a different one.');
                return;
            }
            // Select
            selectedSeats.push({ number: seatNum, fee: fee, type: type });
            el.classList.add('seat-selected');
        }

        updateSeatSummary();
    }

    function updateSeatSummary() {
        const chipsContainer = document.getElementById('selectedSeatsChips');
        const summarySeats = document.getElementById('summarySeatList');
        const summaryFee = document.getElementById('summarySeatFee');
        const summaryTaxes = document.getElementById('summaryTaxes');
        const summaryTotal = document.getElementById('summaryTotalSeatCost');
        const modalSeats = document.getElementById('modalSeatsAssigned');

        const baseFare = Number('${baseFareTotal}');

        if (selectedSeats.length === 0) {
            chipsContainer.innerHTML = '<span class="text-muted small fst-italic" id="noSeatsChosenText">No seats selected yet. Click an available seat on the map.</span>';
            summarySeats.textContent = '-';
            summaryFee.textContent = '\u20B90';
            const taxes = Math.round(baseFare * 0.12);
            if (summaryTaxes) summaryTaxes.textContent = '\u20B9' + taxes.toLocaleString('en-IN');
            summaryTotal.textContent = '\u20B9' + (baseFare + taxes).toLocaleString('en-IN');
            modalSeats.textContent = 'Standard Seat Allocation';
            return;
        }

        chipsContainer.innerHTML = '';
        let totalFee = 0;
        let seatNames = [];

        selectedSeats.forEach(s => {
            totalFee += s.fee;
            seatNames.push(s.number);

            const chip = document.createElement('span');
            chip.className = 'badge bg-primary px-3 py-2 rounded-pill d-inline-flex align-items-center gap-1';
            chip.innerHTML = '<i class="bi bi-grid me-1"></i> Seat ' + s.number + 
                (s.fee > 0 ? ' (+\u20B9' + s.fee + ')' : '') +
                ' <span style="cursor:pointer; margin-left: 4px;" onclick="removeSeatByNumber(\'' + s.number + '\')">&times;</span>';
            chipsContainer.appendChild(chip);
        });

        summarySeats.textContent = seatNames.join(', ');
        summaryFee.textContent = '\u20B9' + totalFee.toLocaleString('en-IN');
        const totalWithSeats = baseFare + totalFee;
        const taxes = Math.round(totalWithSeats * 0.12);
        if (summaryTaxes) summaryTaxes.textContent = '\u20B9' + taxes.toLocaleString('en-IN');
        summaryTotal.textContent = '\u20B9' + (totalWithSeats + taxes).toLocaleString('en-IN');
        modalSeats.textContent = seatNames.join(', ');
    }

    function removeSeatByNumber(seatNum) {
        const el = document.querySelector('[data-seat="' + seatNum + '"]');
        if (el) toggleSeatSelection(el);
    }
</script>

<jsp:include page="../common/footer.jsp" />
