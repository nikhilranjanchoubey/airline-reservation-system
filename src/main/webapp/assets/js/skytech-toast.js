/**
 * SkyTech Reusable Toast Notification System
 * Position: Top-Right (Desktop) / Full Width Margin (Mobile)
 * Types: SUCCESS (3000ms), INFO (3500ms), WARNING (4000ms), ERROR (5000ms)
 */
(function(window) {
    'use strict';

    const DEFAULT_DURATIONS = {
        success: 3000,
        info: 3500,
        warning: 4000,
        error: 5000
    };

    const ICONS = {
        success: 'bi-check-circle-fill text-success',
        info: 'bi-info-circle-fill text-primary',
        warning: 'bi-exclamation-triangle-fill text-warning',
        error: 'bi-x-circle-fill text-danger'
    };

    const BORDER_COLORS = {
        success: '#16a34a',
        info: '#1976d2',
        warning: '#f59e0b',
        error: '#dc2626'
    };

    function ensureContainer() {
        let container = document.getElementById('skytech-toast-container') || document.getElementById('skyTechToastContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'skytech-toast-container';
            container.className = 'skytech-toast-container';
            document.body.appendChild(container);
        }
        return container;
    }

    const SkyTechToast = {
        show: function(options) {
            if (typeof options === 'string') {
                options = { message: options };
            }
            const type = (options.type || 'info').toLowerCase();
            const title = options.title || (type.charAt(0).toUpperCase() + type.slice(1));
            const message = options.message || '';
            const duration = options.duration || DEFAULT_DURATIONS[type] || 3500;

            const container = ensureContainer();

            const toastEl = document.createElement('div');
            toastEl.className = 'skytech-toast skytech-toast-' + type;
            toastEl.setAttribute('role', 'alert');
            toastEl.setAttribute('aria-live', 'assertive');
            toastEl.setAttribute('aria-atomic', 'true');
            toastEl.style.borderLeftColor = BORDER_COLORS[type] || '#1976d2';

            toastEl.innerHTML = 
                '<div class="skytech-toast-icon">' +
                    '<i class="bi ' + (ICONS[type] || ICONS.info) + '"></i>' +
                '</div>' +
                '<div class="skytech-toast-content">' +
                    '<div class="skytech-toast-title">' + title + '</div>' +
                    (message ? '<div class="skytech-toast-message">' + message + '</div>' : '') +
                '</div>' +
                '<button type="button" class="skytech-toast-close" aria-label="Close">&times;</button>' +
                '<div class="skytech-toast-progress"><div class="skytech-toast-progress-bar" style="background-color:' + (BORDER_COLORS[type] || '#1976d2') + '; animation-duration:' + duration + 'ms;"></div></div>';

            container.appendChild(toastEl);

            // Animate in
            requestAnimationFrame(function() {
                toastEl.classList.add('show');
            });

            // Dismiss helper
            let timer = null;
            function dismiss() {
                if (timer) clearTimeout(timer);
                toastEl.classList.remove('show');
                toastEl.classList.add('hide');
                setTimeout(function() {
                    if (toastEl.parentNode) {
                        toastEl.parentNode.removeChild(toastEl);
                    }
                }, 300);
            }

            // Close button
            const closeBtn = toastEl.querySelector('.skytech-toast-close');
            if (closeBtn) {
                closeBtn.addEventListener('click', dismiss);
            }

            // Auto dismiss
            if (duration > 0) {
                timer = setTimeout(dismiss, duration);
            }

            // Pause on hover
            toastEl.addEventListener('mouseenter', function() {
                if (timer) clearTimeout(timer);
                const bar = toastEl.querySelector('.skytech-toast-progress-bar');
                if (bar) bar.style.animationPlayState = 'paused';
            });

            toastEl.addEventListener('mouseleave', function() {
                const bar = toastEl.querySelector('.skytech-toast-progress-bar');
                if (bar) bar.style.animationPlayState = 'running';
                if (duration > 0) {
                    timer = setTimeout(dismiss, 1500);
                }
            });

            return toastEl;
        },

        success: function(title, message, duration) {
            return this.show({ type: 'success', title: title, message: message, duration: duration });
        },

        info: function(title, message, duration) {
            return this.show({ type: 'info', title: title, message: message, duration: duration });
        },

        warning: function(title, message, duration) {
            return this.show({ type: 'warning', title: title, message: message, duration: duration });
        },

        error: function(title, message, duration) {
            return this.show({ type: 'error', title: title, message: message, duration: duration });
        }
    };

    window.SkyTechToast = SkyTechToast;

    // Centralized global showToast helper as required by Issue 18
    window.showToast = function(message, type, title) {
        type = (type || 'info').toLowerCase();
        if (!title) {
            if (type === 'success') title = 'Success';
            else if (type === 'warning') title = 'Notice';
            else if (type === 'error') title = 'Error';
            else title = 'Information';
        }
        return SkyTechToast.show({
            type: type,
            title: title,
            message: message
        });
    };

})(window);
