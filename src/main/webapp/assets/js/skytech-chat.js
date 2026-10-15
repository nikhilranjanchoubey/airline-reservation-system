/**
 * SkyTech AI Flight Assistant - Client-side Interactive Controller
 * Connects directly to backend servlet endpoint: POST /api/ai/chat
 */
(function() {
    'use strict';

    // State
    let isOpen = false;
    let isProcessing = false;
    let hasWelcomed = false;
    const conversationHistory = []; // { role: "user" | "model", text: string }

    // Resolve Context Path dynamically
    function getContextPath() {
        const script = document.querySelector('script[src*="skytech-chat.js"]');
        if (script) {
            const src = script.getAttribute('src');
            const idx = src.indexOf('/assets/js/skytech-chat.js');
            if (idx >= 0) {
                return src.substring(0, idx);
            }
        }
        const path = window.location.pathname;
        if (path.startsWith('/airline-reservation-system')) {
            return '/airline-reservation-system';
        }
        return '';
    }

    const CONTEXT_PATH = getContextPath();
    const API_ENDPOINT = CONTEXT_PATH + '/api/ai/chat';

    // DOM Elements
    let triggerBtn = null;
    let panel = null;
    let chatBody = null;
    let chatInput = null;
    let sendBtn = null;
    let subtitle = null;
    let typingIndicator = null;

    function isAuthPage() {
        const path = (window.location.pathname || '').toLowerCase();
        return path.includes('/login') || path.includes('/register') || path.includes('/signup') || path.includes('/checkout');
    }

    function init() {
        // Exclude on login, registration/signup, and checkout pages
        if (isAuthPage()) {
            return;
        }

        // Prevent duplicate initialization
        if (document.getElementById('skytechAiTrigger')) {
            return;
        }

        renderChatbotMarkup();
        bindElements();
        bindEvents();
    }

    // Refined SkyTech Aviation AI Vector Logo (Airliner + Tech Orbit / Contrail)
    const SKYTECH_AI_ICON_SVG = `
        <svg class="skytech-ai-brand-icon" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
            <path d="M4 16.8C2.8 14 3.2 10.7 5.1 8.3C8 4.8 13.2 3.9 17.2 5.9" stroke="#38BDF8" stroke-width="1.6" stroke-linecap="round" stroke-dasharray="2.2 2.2" opacity="0.9"/>
            <circle cx="18" cy="6.6" r="1.3" fill="#38BDF8"/>
            <path d="M21.2 3.6C21.6 3.2 22.2 3.7 21.9 4.2L17.5 12.3L19.5 18.2C19.7 18.7 19.1 19.1 18.7 18.8L14.9 16.5L11.8 18.8C11.5 19 11 18.8 11 18.4L11.2 15.3L7.5 13.2L5.1 13.9C4.7 14 4.4 13.6 4.6 13.3L6.8 10.2L13 9.3L21.2 3.6Z" fill="#FFFFFF"/>
            <path d="M10.2 15.2L5 20.4" stroke="#38BDF8" stroke-width="1.8" stroke-linecap="round"/>
            <circle cx="3.8" cy="21.6" r="1.1" fill="#38BDF8"/>
        </svg>
    `;

    function renderChatbotMarkup() {
        const container = document.createElement('div');
        container.id = 'skytechAiContainer';
        container.innerHTML = `
            <!-- Floating Trigger Button -->
            <button type="button" class="skytech-ai-trigger" id="skytechAiTrigger" 
                    aria-label="Ask SkyTech" title="Ask SkyTech" aria-expanded="false">
                <span class="skytech-ai-trigger-icon" id="skytechAiTriggerIcon">
                    ${SKYTECH_AI_ICON_SVG}
                </span>
                <span class="skytech-ai-tooltip">Ask SkyTech</span>
            </button>

            <!-- Chat Window Panel -->
            <div class="skytech-ai-panel" id="skytechAiPanel" role="dialog" aria-label="SkyTech AI Assistant">
                <!-- Header -->
                <div class="skytech-ai-header">
                    <div class="skytech-ai-header-left">
                        <div class="skytech-ai-avatar">
                            ${SKYTECH_AI_ICON_SVG}
                        </div>
                        <div class="skytech-ai-title-wrap">
                            <div class="skytech-ai-title-row">
                                <h3 class="skytech-ai-title">SkyTech AI</h3>
                                <span class="skytech-ai-title-tag">AI ASSISTANT</span>
                            </div>
                            <p class="skytech-ai-subtitle" id="skytechAiSubtitle">
                                Your flight and booking assistant
                            </p>
                        </div>
                    </div>
                    <div class="skytech-ai-header-actions">
                        <button type="button" class="skytech-ai-btn-ctrl" id="skytechAiMinimize" title="Minimize Chat" aria-label="Minimize Chat">
                            <i class="bi bi-dash-lg"></i>
                        </button>
                        <button type="button" class="skytech-ai-btn-ctrl" id="skytechAiClose" title="Close Chat" aria-label="Close Chat">
                            <i class="bi bi-x-lg"></i>
                        </button>
                    </div>
                </div>

                <!-- Chat Messages Body -->
                <div class="skytech-ai-body" id="skytechAiBody" role="log" aria-live="polite">
                    <!-- Dynamic Messages will be injected here -->
                </div>

                <!-- Chat Input Area -->
                <form class="skytech-ai-input-area" id="skytechAiForm" onsubmit="return false;">
                    <input type="text" class="skytech-ai-input" id="skytechAiInput" 
                           placeholder="Ask about flights or your bookings..." 
                           autocomplete="off" aria-label="Message for SkyTech AI" maxlength="800">
                    <button type="submit" class="skytech-ai-send-btn" id="skytechAiSendBtn" title="Send Message" aria-label="Send Message">
                        <i class="bi bi-send-fill"></i>
                    </button>
                </form>
            </div>
        `;

        document.body.appendChild(container);
    }

    function bindElements() {
        triggerBtn = document.getElementById('skytechAiTrigger');
        panel = document.getElementById('skytechAiPanel');
        chatBody = document.getElementById('skytechAiBody');
        chatInput = document.getElementById('skytechAiInput');
        sendBtn = document.getElementById('skytechAiSendBtn');
        subtitle = document.getElementById('skytechAiSubtitle');
    }

    function bindEvents() {
        // Toggle Panel
        triggerBtn.addEventListener('click', toggleChat);
        document.getElementById('skytechAiMinimize').addEventListener('click', closeChat);
        document.getElementById('skytechAiClose').addEventListener('click', closeChat);

        // Form Submit
        document.getElementById('skytechAiForm').addEventListener('submit', function(e) {
            e.preventDefault();
            handleUserSubmit();
        });

        // Enter sends, Shift+Enter permits newline if ever switched to textarea
        chatInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                handleUserSubmit();
            }
        });
    }

    function toggleChat() {
        if (isOpen) {
            closeChat();
        } else {
            openChat();
        }
    }

    function openChat() {
        isOpen = true;
        panel.classList.add('open');
        triggerBtn.classList.add('open');
        triggerBtn.setAttribute('aria-expanded', 'true');

        // Show welcome greeting on first launch
        if (!hasWelcomed) {
            showWelcomeGreeting();
            hasWelcomed = true;
        }

        setTimeout(() => {
            if (chatInput) chatInput.focus();
            scrollToBottom();
        }, 150);
    }

    function closeChat() {
        isOpen = false;
        panel.classList.remove('open');
        triggerBtn.classList.remove('open');
        triggerBtn.setAttribute('aria-expanded', 'false');
    }

    function showWelcomeGreeting() {
        const welcomeHtml = `
            <div class="skytech-ai-welcome-card">
                <div class="skytech-ai-welcome-text">
                    Hi! 👋 Welcome to SkyTech.<br><br>
                    I can help you find flights, check your bookings, and answer travel questions. What would you like to do?
                </div>
                <div class="skytech-ai-quick-actions">
                    <button type="button" class="skytech-ai-quick-btn" data-action="search">
                        <i class="bi bi-search"></i> Search Flights
                    </button>
                    <button type="button" class="skytech-ai-quick-btn" data-action="cheapest">
                        <i class="bi bi-tag-fill"></i> Cheapest Flights
                    </button>
                    <button type="button" class="skytech-ai-quick-btn" data-action="booking">
                        <i class="bi bi-ticket-perforated-fill"></i> My Bookings
                    </button>
                    <button type="button" class="skytech-ai-quick-btn" data-action="support">
                        <i class="bi bi-headset"></i> Contact Us
                    </button>
                </div>
            </div>
        `;

        const welcomeWrapper = document.createElement('div');
        welcomeWrapper.innerHTML = welcomeHtml;
        chatBody.appendChild(welcomeWrapper);

        // Bind quick action clicks
        welcomeWrapper.querySelectorAll('.skytech-ai-quick-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const action = this.getAttribute('data-action');
                sendAction(action);
            });
        });

        scrollToBottom();
    }

    function sendAction(action) {
        if (isProcessing) return;
        isProcessing = true;
        setFormDisabled(true);

        showTypingIndicator();
        scrollToBottom();

        fetch(API_ENDPOINT, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                action: action
            })
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('HTTP error: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            hideTypingIndicator();
            if (subtitle) {
                subtitle.innerHTML = 'Your flight companion &bull; Available 24/7';
                subtitle.classList.remove('unavailable');
            }
            const replyText = data.reply || "I'm ready to help with your flight inquiries.";
            conversationHistory.push({ role: 'model', text: replyText });

            appendAssistantMessage(replyText, data.flights, data.actionButtons);
        })
        .catch(err => {
            console.error('[SkyTech AI Chat Action Error]', err);
            hideTypingIndicator();
            if (subtitle) {
                subtitle.textContent = 'Temporarily unavailable';
                subtitle.classList.add('unavailable');
            }
            appendAssistantMessage("I'm sorry, I couldn't complete that action right now. Please try again or explore options below.", [], [
                { label: "Search Flights", url: CONTEXT_PATH + "/search-flights" },
                { label: "Manage Booking", url: CONTEXT_PATH + "/manage-booking" }
            ]);
        })
        .finally(() => {
            isProcessing = false;
            setFormDisabled(false);
            if (chatInput) chatInput.focus();
            scrollToBottom();
        });
    }

    function handleUserSubmit() {
        if (isProcessing) return;
        const msg = chatInput.value.trim();
        if (!msg) return;

        chatInput.value = '';
        sendMessage(msg);
    }

    function sendMessage(text) {
        if (isProcessing) return;
        isProcessing = true;
        setFormDisabled(true);

        // 1. Append User Message
        appendUserMessage(text);
        conversationHistory.push({ role: 'user', text: text });

        // 2. Show Typing Indicator
        showTypingIndicator();
        scrollToBottom();

        // 3. API Call to Backend
        fetch(API_ENDPOINT, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: text,
                history: conversationHistory.slice(-6)
            })
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('HTTP error: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            hideTypingIndicator();
            if (subtitle) {
                subtitle.innerHTML = 'Your flight companion &bull; Available 24/7';
                subtitle.classList.remove('unavailable');
            }
            const replyText = data.reply || "I'm ready to help with your flight inquiries.";
            conversationHistory.push({ role: 'model', text: replyText });

            appendAssistantMessage(replyText, data.flights, data.actionButtons);
        })
        .catch(err => {
            console.error('[SkyTech AI Chat Error]', err);
            hideTypingIndicator();
            if (subtitle) {
                subtitle.textContent = 'Temporarily unavailable';
                subtitle.classList.add('unavailable');
            }
            appendAssistantMessage("I'm sorry, I couldn't respond right now. Please try again in a few moments, or explore flights and bookings directly using the links below.", [], [
                { label: "Search Flights", url: CONTEXT_PATH + "/search-flights" },
                { label: "Manage Booking", url: CONTEXT_PATH + "/manage-booking" }
            ]);
        })
        .finally(() => {
            isProcessing = false;
            setFormDisabled(false);
            if (chatInput) chatInput.focus();
            scrollToBottom();
        });
    }

    function appendUserMessage(text) {
        const msgEl = document.createElement('div');
        msgEl.className = 'skytech-ai-msg user';
        msgEl.innerHTML = `
            <div class="skytech-ai-bubble">${escapeHtml(text)}</div>
            <div class="skytech-ai-msg-time">${getCurrentTime()}</div>
        `;
        chatBody.appendChild(msgEl);
    }

    function appendAssistantMessage(replyText, flights, actionButtons) {
        const msgEl = document.createElement('div');
        msgEl.className = 'skytech-ai-msg assistant';

        let contentHtml = `<div class="skytech-ai-bubble">${formatMarkdown(replyText)}</div>`;

        // Render structured flight cards if present
        if (flights && flights.length > 0) {
            contentHtml += `<div class="skytech-ai-flight-cards">`;
            flights.forEach(f => {
                contentHtml += `
                    <div class="skytech-ai-flight-card">
                        <div class="skytech-ai-flight-header">
                            <span class="skytech-ai-airline-badge">
                                <i class="bi bi-airplane-engines-fill"></i> ${escapeHtml(f.airline || 'SkyTech')}
                            </span>
                            <span class="skytech-ai-flight-number">${escapeHtml(f.flightNumber || '')}</span>
                        </div>
                        <div class="skytech-ai-flight-route">
                            <div class="skytech-ai-flight-node">
                                <div class="skytech-ai-flight-time">${escapeHtml(f.departureTime || '--:--')}</div>
                                <div class="skytech-ai-flight-city">${escapeHtml(f.origin || '')}</div>
                            </div>
                            <div class="skytech-ai-flight-path">
                                <span class="skytech-ai-flight-duration">${escapeHtml(f.duration || 'Direct')}</span>
                                <div class="skytech-ai-flight-line"><i class="bi bi-airplane"></i></div>
                            </div>
                            <div class="skytech-ai-flight-node">
                                <div class="skytech-ai-flight-time">${escapeHtml(f.arrivalTime || '--:--')}</div>
                                <div class="skytech-ai-flight-city">${escapeHtml(f.destination || '')}</div>
                            </div>
                        </div>
                        <div class="skytech-ai-flight-footer">
                            <div class="skytech-ai-flight-price">${escapeHtml(f.formattedFare || '')}</div>
                            <a href="${escapeHtml(f.bookUrl || (CONTEXT_PATH + '/search-flights?source=' + encodeURIComponent(f.origin || '') + '&destination=' + encodeURIComponent(f.destination || '') + '&departureDate=' + encodeURIComponent(f.flightDate || '')))}" class="skytech-ai-btn-book">
                                Book Flight <i class="bi bi-arrow-right-short"></i>
                            </a>
                        </div>
                    </div>
                `;
            });
            contentHtml += `</div>`;
        }

        // Render Action Buttons / Navigation Chips
        if (actionButtons && actionButtons.length > 0) {
            contentHtml += `<div class="skytech-ai-actions-wrap">`;
            actionButtons.forEach(btn => {
                const isPrimary = btn.label && (btn.label.includes('View All') || btn.label.includes('Book') || btn.label.includes('Search Flights'));
                const btnClass = isPrimary ? 'skytech-ai-action-chip primary' : 'skytech-ai-action-chip';
                if (btn.url) {
                    contentHtml += `
                        <a href="${escapeHtml(btn.url)}" class="${btnClass}">
                            ${escapeHtml(btn.label)} <i class="bi bi-chevron-right fs-8"></i>
                        </a>
                    `;
                } else if (btn.action === 'retry' || btn.text === 'retry') {
                    contentHtml += `
                        <button type="button" class="${btnClass} skytech-ai-action-btn" data-action="retry">
                            <i class="bi bi-arrow-clockwise fs-8"></i> ${escapeHtml(btn.label)}
                        </button>
                    `;
                } else if (btn.text) {
                    contentHtml += `
                        <button type="button" class="${btnClass} skytech-ai-action-btn" data-query="${escapeHtml(btn.text)}">
                            ${escapeHtml(btn.label)} <i class="bi bi-arrow-up-right fs-8"></i>
                        </button>
                    `;
                }
            });
            contentHtml += `</div>`;
        }

        contentHtml += `<div class="skytech-ai-msg-time">${getCurrentTime()}</div>`;
        msgEl.innerHTML = contentHtml;

        // Bind interactive query & action buttons
        msgEl.querySelectorAll('.skytech-ai-action-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const action = this.getAttribute('data-action');
                const query = this.getAttribute('data-query');
                if (action) {
                    sendAction(action);
                } else if (query) {
                    sendMessage(query);
                }
            });
        });

        chatBody.appendChild(msgEl);
    }

    function showTypingIndicator() {
        if (!typingIndicator) {
            typingIndicator = document.createElement('div');
            typingIndicator.className = 'skytech-ai-typing';
            typingIndicator.innerHTML = `
                <span class="skytech-ai-typing-dot"></span>
                <span class="skytech-ai-typing-dot"></span>
                <span class="skytech-ai-typing-dot"></span>
            `;
        }
        chatBody.appendChild(typingIndicator);
    }

    function hideTypingIndicator() {
        if (typingIndicator && typingIndicator.parentNode) {
            typingIndicator.parentNode.removeChild(typingIndicator);
        }
    }

    function setFormDisabled(disabled) {
        if (chatInput) chatInput.disabled = disabled;
        if (sendBtn) sendBtn.disabled = disabled;
    }

    function scrollToBottom() {
        if (chatBody) {
            chatBody.scrollTop = chatBody.scrollHeight;
        }
    }

    function getCurrentTime() {
        const now = new Date();
        return now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }

    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    /**
     * Safe, lightweight Markdown formatter (bold, lists, code, links).
     */
    function formatMarkdown(text) {
        if (!text) return '';
        let escaped = escapeHtml(text);

        // Bold **text**
        escaped = escaped.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        // Italic *text*
        escaped = escaped.replace(/\*(.*?)\*/g, '<em>$1</em>');
        // Inline code `text`
        escaped = escaped.replace(/`([^`]+)`/g, '<code class="bg-light px-1 py-0.5 rounded text-primary">$1</code>');
        // Bullet points
        escaped = escaped.replace(/^[•\-\*]\s+(.*)$/gm, '&bull; $1');
        // Line breaks
        escaped = escaped.replace(/\n/g, '<br>');

        // Markdown Links [Label](url)
        escaped = escaped.replace(/\[(.*?)\]\((.*?)\)/g, function(match, label, url) {
            const cleanUrl = url.trim();
            // Disallow javascript: schemes
            if (cleanUrl.toLowerCase().startsWith('javascript:')) {
                return label;
            }
            return `<a href="${cleanUrl}">${label}</a>`;
        });

        return escaped;
    }

    // Auto-initialize when document is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
