/**
 * SkyTech - Shared Application Scripts
 */
document.addEventListener("DOMContentLoaded", function () {
    // Initialize all Bootstrap tooltips if Bootstrap is loaded
    if (typeof bootstrap !== "undefined" && bootstrap.Tooltip) {
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
    }

    // Console ready message
    console.log("SkyTech foundation initialized.");
});
