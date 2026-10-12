// Interactive Seat Map Controller
document.addEventListener("DOMContentLoaded", function () {
    const seatBoxes = document.querySelectorAll(".seat-box:not(.occupied)");
    const passengerCountInput = document.getElementById("passengerCount");
    const selectedSeatsInputContainer = document.getElementById("selectedSeatsInputContainer");
    const seatPillsContainer = document.getElementById("selectedSeatPills");
    const totalSurchargeEl = document.getElementById("totalSeatSurcharges");
    const confirmBtn = document.getElementById("btnConfirmSeats");

    if (!passengerCountInput || !confirmBtn) return;
    const requiredSeatCount = parseInt(passengerCountInput.value, 10);
    const selectedSeats = [];

    seatBoxes.forEach(seat => {
        seat.addEventListener("click", function () {
            const seatNum = seat.dataset.seat;
            const fee = parseFloat(seat.dataset.fee || "0");

            if (seat.classList.contains("selected")) {
                seat.classList.remove("selected");
                const idx = selectedSeats.findIndex(s => s.number === seatNum);
                if (idx > -1) selectedSeats.splice(idx, 1);
            } else {
                if (selectedSeats.length >= requiredSeatCount) {
                    alert("You have already selected " + requiredSeatCount + " seat(s) for your passengers. Deselect a seat to change.");
                    return;
                }
                seat.classList.add("selected");
                selectedSeats.push({ number: seatNum, fee: fee });
            }
            updateSeatState();
        });
    });

    function updateSeatState() {
        if (selectedSeatsInputContainer) {
            selectedSeatsInputContainer.innerHTML = "";
            selectedSeats.forEach(s => {
                const hidden = document.createElement("input");
                hidden.type = "hidden";
                hidden.name = "selectedSeats[]";
                hidden.value = s.number;
                selectedSeatsInputContainer.appendChild(hidden);
            });
        }

        if (seatPillsContainer) {
            seatPillsContainer.innerHTML = "";
            if (selectedSeats.length === 0) {
                seatPillsContainer.innerHTML = `<span class="text-muted small">No seats chosen yet</span>`;
            } else {
                selectedSeats.forEach(s => {
                    const badge = document.createElement("span");
                    badge.className = "badge bg-primary fs-6 p-2";
                    badge.innerText = s.number + (s.fee > 0 ? " (+₹" + s.fee + ")" : "");
                    seatPillsContainer.appendChild(badge);
                });
            }
        }

        let totalFee = 0;
        selectedSeats.forEach(s => totalFee += s.fee);
        if (totalSurchargeEl) totalSurchargeEl.innerText = "₹" + totalFee.toLocaleString("en-IN", { minimumFractionDigits: 2 });

        if (confirmBtn) {
            confirmBtn.disabled = selectedSeats.length !== requiredSeatCount;
        }
    }
});
