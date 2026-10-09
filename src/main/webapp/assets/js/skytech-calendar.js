/**
 * SkyTech Custom Airline Date Calendar Popover
 * 
 * Features:
 * - Dynamic IST date anchor (Asia/Kolkata)
 * - Visually disabled past dates (greyed out, unclickable, cursor: not-allowed)
 * - Click on past dates does NOTHING (no error toast, no selection)
 * - Today highlighted with airline blue styling and fully selectable
 * - Future dates hoverable and selectable
 * - Previous month button disabled when viewing the current minimum month
 * - Forward/backward month navigation with dynamic boundary checks
 * - "Today" and "Clear" quick action buttons
 * - Accessible keyboard navigation and outside click / ESC dismissal
 * - Native hidden input synchronization (yyyy-MM-dd)
 */
(function(window) {
    'use strict';

    const MONTH_NAMES = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
    ];

    const MONTH_NAMES_SHORT = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    const DAY_NAMES_FULL = [
        'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    ];

    // Helper: pad integer to 2 digits
    function pad(n) {
        return n < 10 ? '0' + n : String(n);
    }

    // Helper: parse "YYYY-MM-DD" into year, month (1-12), day (1-31)
    function parseDateString(str) {
        if (!str || typeof str !== 'string') return null;
        const parts = str.trim().split('-');
        if (parts.length !== 3) return null;
        const y = parseInt(parts[0], 10);
        const m = parseInt(parts[1], 10);
        const d = parseInt(parts[2], 10);
        if (isNaN(y) || isNaN(m) || isNaN(d)) return null;
        return { year: y, month: m, day: d };
    }

    // Helper: convert components to "YYYY-MM-DD"
    function toDateString(year, month, day) {
        return year + '-' + pad(month) + '-' + pad(day);
    }

    // Helper: get client's today in YYYY-MM-DD
    function getLocalTodayIso() {
        const now = new Date();
        return toDateString(now.getFullYear(), now.getMonth() + 1, now.getDate());
    }

    // Calendar state
    let serverTodayIso = getLocalTodayIso();
    let currentTrigger = null;
    let currentOptions = null;
    let viewYear = 0;
    let viewMonth = 1; // 1-12
    let popoverEl = null;

    function setServerToday(isoStr) {
        if (isoStr && /^\d{4}-\d{2}-\d{2}$/.test(isoStr.trim())) {
            serverTodayIso = isoStr.trim();
        }
    }

    function createPopoverElement() {
        if (popoverEl) return popoverEl;

        popoverEl = document.createElement('div');
        popoverEl.id = 'skytechCalendarPopover';
        popoverEl.className = 'skytech-calendar-popover d-none';
        popoverEl.setAttribute('role', 'dialog');
        popoverEl.setAttribute('aria-modal', 'true');
        popoverEl.setAttribute('aria-label', 'Flight Date Picker');

        popoverEl.innerHTML = 
            '<div class="skytech-calendar-header">' +
                '<button type="button" class="skytech-cal-nav-btn" id="skytechCalPrevBtn" aria-label="Previous month">' +
                    '<i class="bi bi-chevron-left"></i>' +
                '</button>' +
                '<span class="skytech-calendar-title" id="skytechCalTitle">Month Year</span>' +
                '<button type="button" class="skytech-cal-nav-btn" id="skytechCalNextBtn" aria-label="Next month">' +
                    '<i class="bi bi-chevron-right"></i>' +
                '</button>' +
            '</div>' +
            '<div class="skytech-calendar-weekdays">' +
                '<span>Su</span><span>Mo</span><span>Tu</span><span>We</span><span>Th</span><span>Fr</span><span>Sa</span>' +
            '</div>' +
            '<div class="skytech-calendar-grid" id="skytechCalDaysGrid"></div>' +
            '<div class="skytech-calendar-footer">' +
                '<button type="button" class="btn btn-sm btn-link text-muted p-0 text-decoration-none" id="skytechCalClearBtn">Clear</button>' +
                '<button type="button" class="btn btn-sm btn-primary rounded-pill px-3" id="skytechCalTodayBtn">Today</button>' +
            '</div>';

        document.body.appendChild(popoverEl);

        // Bind popover persistent controls
        const prevBtn = popoverEl.querySelector('#skytechCalPrevBtn');
        const nextBtn = popoverEl.querySelector('#skytechCalNextBtn');
        const clearBtn = popoverEl.querySelector('#skytechCalClearBtn');
        const todayBtn = popoverEl.querySelector('#skytechCalTodayBtn');

        prevBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            if (prevBtn.disabled) return;
            navigateMonth(-1);
        });

        nextBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            navigateMonth(1);
        });

        clearBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            handleClear();
        });

        todayBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            handleSelectDate(serverTodayIso);
        });

        popoverEl.addEventListener('click', function(e) {
            e.stopPropagation();
        });

        // Global dismissers
        document.addEventListener('click', function(e) {
            if (popoverEl && !popoverEl.classList.contains('d-none')) {
                if (!popoverEl.contains(e.target) && (!currentTrigger || !currentTrigger.contains(e.target))) {
                    closeCalendar();
                }
            }
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && popoverEl && !popoverEl.classList.contains('d-none')) {
                closeCalendar();
            }
        });

        return popoverEl;
    }

    function navigateMonth(direction) {
        viewMonth += direction;
        if (viewMonth < 1) {
            viewMonth = 12;
            viewYear--;
        } else if (viewMonth > 12) {
            viewMonth = 1;
            viewYear++;
        }
        renderCalendar();
    }

    function renderCalendar() {
        if (!popoverEl || !currentOptions) return;

        const titleEl = popoverEl.querySelector('#skytechCalTitle');
        const gridEl = popoverEl.querySelector('#skytechCalDaysGrid');
        const prevBtn = popoverEl.querySelector('#skytechCalPrevBtn');

        titleEl.textContent = MONTH_NAMES[viewMonth - 1] + ' ' + viewYear;

        // Determine minimum allowed date and year/month
        const minDateIso = currentOptions.minDateIso || serverTodayIso;
        const minParsed = parseDateString(minDateIso) || parseDateString(serverTodayIso);
        const minYear = minParsed.year;
        const minMonth = minParsed.month;

        // Issue 5: Disable previous month button when viewing current/min month
        const isMinMonth = (viewYear < minYear) || (viewYear === minYear && viewMonth <= minMonth);
        if (isMinMonth) {
            prevBtn.disabled = true;
            prevBtn.classList.add('disabled');
        } else {
            prevBtn.disabled = false;
            prevBtn.classList.remove('disabled');
        }

        // Selected date
        const selectedIso = currentOptions.selectedIso || '';

        // Generate grid
        gridEl.innerHTML = '';

        // Day of week for first day of current view month (0=Su, 1=Mo, ..., 6=Sa)
        const firstDayOfWeek = new Date(viewYear, viewMonth - 1, 1).getDay();

        // Days in current view month
        const daysInMonth = new Date(viewYear, viewMonth, 0).getDate();

        // Days in previous view month (for leading padding)
        const daysInPrevMonth = new Date(viewYear, viewMonth - 1, 0).getDate();

        // 1. Render preceding days from previous month (muted, disabled, unclickable)
        for (let i = 0; i < firstDayOfWeek; i++) {
            const dayNum = daysInPrevMonth - firstDayOfWeek + 1 + i;
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'calendar-day is-padding is-past';
            btn.textContent = dayNum;
            btn.disabled = true;
            btn.setAttribute('tabindex', '-1');
            btn.setAttribute('aria-hidden', 'true');
            gridEl.appendChild(btn);
        }

        // 2. Render actual days of the current month
        for (let d = 1; d <= daysInMonth; d++) {
            const dateStr = toDateString(viewYear, viewMonth, d);
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.textContent = d;
            btn.setAttribute('data-date', dateStr);

            const isPast = dateStr < minDateIso;
            const isToday = (dateStr === serverTodayIso);
            const isSelected = (dateStr === selectedIso);

            if (isPast) {
                // Issue 1 & 2: Visually muted/greyed out, cursor: not-allowed, unclickable
                btn.className = 'calendar-day is-past';
                btn.disabled = true;
                btn.setAttribute('aria-disabled', 'true');
                btn.setAttribute('tabindex', '-1');
                // Explicitly ignore click events (Issue 2)
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    return false;
                });
            } else {
                // Selectable date
                let classList = 'calendar-day is-selectable';
                if (isToday) classList += ' is-today';
                if (isSelected) classList += ' is-selected';
                btn.className = classList;
                btn.setAttribute('aria-label', d + ' ' + MONTH_NAMES[viewMonth - 1] + ' ' + viewYear + (isToday ? ' (Today)' : ''));

                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    handleSelectDate(dateStr);
                });
            }

            gridEl.appendChild(btn);
        }
    }

    function handleSelectDate(dateStr) {
        if (!dateStr || !currentOptions) return;

        // Double check minimum date limit
        const minDateIso = currentOptions.minDateIso || serverTodayIso;
        if (dateStr < minDateIso) {
            // Strictly reject past dates without action
            return;
        }

        // Update target input
        if (currentOptions.inputEl) {
            currentOptions.inputEl.value = dateStr;
        }

        // Update formatted display
        updateDisplayForDate(dateStr, currentOptions.primaryDisplayEl, currentOptions.subtextDisplayEl);

        // Fire onSelect callback
        if (typeof currentOptions.onSelect === 'function') {
            currentOptions.onSelect(dateStr);
        }

        closeCalendar();
    }

    function handleClear() {
        if (!currentOptions) return;

        if (currentOptions.inputEl) {
            currentOptions.inputEl.value = '';
        }

        if (currentOptions.primaryDisplayEl) {
            currentOptions.primaryDisplayEl.textContent = currentOptions.placeholderText || 'Select Date';
        }
        if (currentOptions.subtextDisplayEl) {
            currentOptions.subtextDisplayEl.textContent = '';
        }

        if (typeof currentOptions.onClear === 'function') {
            currentOptions.onClear();
        }

        closeCalendar();
    }

    function updateDisplayForDate(isoStr, primaryEl, subtextEl) {
        if (!primaryEl) return;
        if (!isoStr) {
            primaryEl.textContent = 'Select Date';
            if (subtextEl) subtextEl.textContent = '';
            return;
        }

        const parsed = parseDateString(isoStr);
        if (!parsed) {
            primaryEl.textContent = isoStr;
            if (subtextEl) subtextEl.textContent = '';
            return;
        }

        const dt = new Date(parsed.year, parsed.month - 1, parsed.day);
        const dayStr = pad(parsed.day);
        const monthShort = MONTH_NAMES_SHORT[parsed.month - 1];
        const dayOfWeek = DAY_NAMES_FULL[dt.getDay()];

        primaryEl.textContent = dayStr + ' ' + monthShort + ' ' + parsed.year;
        if (subtextEl) {
            subtextEl.textContent = '\u2022 ' + dayOfWeek;
        }
    }

    function positionPopover(triggerEl) {
        if (!popoverEl || !triggerEl) return;

        const rect = triggerEl.getBoundingClientRect();
        const popoverWidth = 320;
        const popoverHeight = 350;
        const margin = 8;

        // Default: directly below trigger
        let top = rect.bottom + window.scrollY + margin;
        let left = rect.left + window.scrollX;

        // Ensure does not overflow right edge of viewport
        const maxLeft = window.scrollX + document.documentElement.clientWidth - popoverWidth - 16;
        if (left > maxLeft) {
            left = Math.max(window.scrollX + 16, maxLeft);
        }

        // Mobile responsiveness: center popover if viewport is narrow
        if (document.documentElement.clientWidth < 400) {
            left = window.scrollX + (document.documentElement.clientWidth - popoverWidth) / 2;
        }

        popoverEl.style.top = top + 'px';
        popoverEl.style.left = left + 'px';
    }

    function openCalendar(triggerEl, options) {
        createPopoverElement();
        currentTrigger = triggerEl;
        currentOptions = options || {};

        // Anchor date for initial month view
        const targetValue = (currentOptions.inputEl ? currentOptions.inputEl.value : '') || '';
        const minIso = currentOptions.minDateIso || serverTodayIso;
        const activeIso = (targetValue && targetValue >= minIso) ? targetValue : (minIso || serverTodayIso);

        const activeParsed = parseDateString(activeIso) || parseDateString(serverTodayIso);
        viewYear = activeParsed.year;
        viewMonth = activeParsed.month;
        currentOptions.selectedIso = targetValue;

        positionPopover(triggerEl);
        popoverEl.classList.remove('d-none');
        renderCalendar();
    }

    function closeCalendar() {
        if (popoverEl) {
            popoverEl.classList.add('d-none');
        }
        currentTrigger = null;
        currentOptions = null;
    }

    // Public API
    window.SkyTechCalendar = {
        init: function(config) {
            if (config && config.todayIso) {
                setServerToday(config.todayIso);
            }
        },
        open: openCalendar,
        close: closeCalendar,
        formatDisplay: updateDisplayForDate,
        getTodayIso: function() {
            return serverTodayIso;
        }
    };

})(window);
