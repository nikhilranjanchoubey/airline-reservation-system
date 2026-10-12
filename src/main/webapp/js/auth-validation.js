/**
 * Airline Reservation System - Client-side Authentication Validation
 */

document.addEventListener("DOMContentLoaded", function () {
    // Bootstrap form validation
    const forms = document.querySelectorAll(".needs-validation");
    Array.from(forms).forEach(function (form) {
        form.addEventListener("submit", function (event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add("was-validated");
        }, false);
    });

    // Password strength meter
    const passwordInput = document.getElementById("password");
    const strengthFill = document.getElementById("strengthFill");
    const strengthText = document.getElementById("strengthText");

    if (passwordInput && strengthFill) {
        passwordInput.addEventListener("input", function () {
            const pwd = passwordInput.value;
            let score = 0;

            if (pwd.length >= 8) score++;
            if (/[A-Z]/.test(pwd)) score++;
            if (/[a-z]/.test(pwd)) score++;
            if (/[0-9]/.test(pwd)) score++;
            if (/[@$!%*?&_#^~]/.test(pwd)) score++;

            let width = 0;
            let color = "#e2e8f0";
            let label = "Enter password";

            switch (score) {
                case 1:
                case 2:
                    width = 25;
                    color = "#ef4444"; // Red
                    label = "Weak (needs upper, lower, number, special char)";
                    break;
                case 3:
                    width = 50;
                    color = "#f59e0b"; // Orange
                    label = "Moderate";
                    break;
                case 4:
                    width = 75;
                    color = "#3b82f6"; // Blue
                    label = "Strong";
                    break;
                case 5:
                    width = 100;
                    color = "#10b981"; // Green
                    label = "Very Strong";
                    break;
                default:
                    width = 0;
                    label = "Min. 8 characters";
            }

            strengthFill.style.width = width + "%";
            strengthFill.style.backgroundColor = color;
            if (strengthText) {
                strengthText.textContent = label;
                strengthText.style.color = color;
            }
        });
    }

    // Confirm password match check
    const confirmPasswordInput = document.getElementById("confirmPassword");
    if (confirmPasswordInput && passwordInput) {
        const checkMatch = function () {
            if (confirmPasswordInput.value && passwordInput.value !== confirmPasswordInput.value) {
                confirmPasswordInput.setCustomValidity("Passwords do not match");
            } else {
                confirmPasswordInput.setCustomValidity("");
            }
        };
        confirmPasswordInput.addEventListener("input", checkMatch);
        passwordInput.addEventListener("input", checkMatch);
    }
});
