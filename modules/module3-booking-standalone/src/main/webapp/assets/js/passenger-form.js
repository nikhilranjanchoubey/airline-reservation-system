// Dynamic Passenger Form Manager
document.addEventListener("DOMContentLoaded", function () {
    const container = document.getElementById("passengerListContainer");
    const addBtn = document.getElementById("btnAddPassenger");
    if (!container || !addBtn) return;

    let passengerCount = container.querySelectorAll(".passenger-card").length;
    const maxPassengers = 9;

    addBtn.addEventListener("click", function () {
        if (passengerCount >= maxPassengers) {
            alert("Maximum limit of " + maxPassengers + " passengers reached.");
            return;
        }

        passengerCount++;
        const card = document.createElement("div");
        card.className = "skytech-card passenger-card mb-3";
        card.innerHTML = `
            <div class="skytech-card-header bg-light">
                <div><i class="bi bi-person-fill text-primary me-2"></i> Passenger #` + passengerCount + `</div>
                <button type="button" class="btn btn-sm btn-outline-danger btn-remove-pax">
                    <i class="bi bi-trash"></i> Remove
                </button>
            </div>
            <div class="skytech-card-body">
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label small fw-semibold">First Name *</label>
                        <input type="text" name="firstName[]" class="form-control" placeholder="First Name" required minlength="2" maxlength="50">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small fw-semibold">Last Name *</label>
                        <input type="text" name="lastName[]" class="form-control" placeholder="Last Name" required minlength="2" maxlength="50">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small fw-semibold">Date of Birth *</label>
                        <input type="date" name="dateOfBirth[]" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small fw-semibold">Gender *</label>
                        <select name="gender[]" class="form-select" required>
                            <option value="MALE">Male</option>
                            <option value="FEMALE">Female</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small fw-semibold">Category *</label>
                        <select name="passengerType[]" class="form-select" required>
                            <option value="ADULT">Adult (12+ yrs)</option>
                            <option value="CHILD">Child (2-11 yrs)</option>
                            <option value="INFANT">Infant (&lt;2 yrs)</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small fw-semibold">Passport / Govt ID</label>
                        <input type="text" name="passportOrId[]" class="form-control" placeholder="Optional for domestic">
                    </div>
                </div>
            </div>
        `;
        container.appendChild(card);
        bindRemoveButtons();
    });

    function bindRemoveButtons() {
        const removeBtns = container.querySelectorAll(".btn-remove-pax");
        removeBtns.forEach(btn => {
            btn.onclick = function () {
                if (container.querySelectorAll(".passenger-card").length <= 1) {
                    alert("At least one passenger is required.");
                    return;
                }
                btn.closest(".passenger-card").remove();
                renumberCards();
            };
        });
    }

    function renumberCards() {
        const cards = container.querySelectorAll(".passenger-card");
        passengerCount = cards.length;
        cards.forEach((c, idx) => {
            const h = c.querySelector(".skytech-card-header div");
            if (h) h.innerHTML = `<i class="bi bi-person-fill text-primary me-2"></i> Passenger #` + (idx + 1);
        });
    }

    bindRemoveButtons();
});
