<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Create Account - SkyTech" />
<c:set var="activePage" value="register" scope="request" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="auth-page-body">
    <div class="auth-cinematic-wrapper register-bg" style="background-image: url('${pageContext.request.contextPath}/images/auth-register-bg.jpg');">
        <div class="auth-cinematic-overlay"></div>

        <!-- Minimalist Cinematic Top Navigation -->
        <header class="auth-top-bar">
            <a href="${pageContext.request.contextPath}/" class="auth-brand skytech-brand" aria-label="SkyTech Home">
                <span class="skytech-brand__icon">
                    <i class="bi bi-airplane-engines-fill"></i>
                </span>
                <span class="skytech-brand__text">SkyTech</span>
            </a>
            <a href="${pageContext.request.contextPath}/" class="auth-back-link">
                <i class="bi bi-arrow-left"></i>
                <span>Back to Home</span>
            </a>
        </header>

        <!-- Main Split Screen Content -->
        <main class="auth-main-container">
            <div class="auth-split-grid register-grid">
                
                <!-- Left Visual & Storytelling Panel -->
                <div class="auth-visual-pane">
                    <h1 class="auth-hero-title">
                        Begin Your<br>
                        <span class="auth-highlight-text">Journey.</span>
                    </h1>
                    <p class="auth-hero-desc">
                        Create your SkyTech account and make every trip simpler, faster and more comfortable.
                    </p>

                    <!-- 3 Benefit Indicators -->
                    <div class="auth-benefits-list">
                        <div class="auth-benefit-item">
                            <div class="auth-benefit-icon">
                                <i class="bi bi-person-check-fill"></i>
                            </div>
                            <div class="auth-benefit-text">
                                <h4>Faster Booking</h4>
                                <p>Book flights in seconds.</p>
                            </div>
                        </div>

                        <div class="auth-benefit-item">
                            <div class="auth-benefit-icon">
                                <i class="bi bi-calendar2-week-fill"></i>
                            </div>
                            <div class="auth-benefit-text">
                                <h4>Manage Your Trips</h4>
                                <p>View and update your bookings.</p>
                            </div>
                        </div>

                        <div class="auth-benefit-item">
                            <div class="auth-benefit-icon">
                                <i class="bi bi-ticket-perforated-fill"></i>
                            </div>
                            <div class="auth-benefit-text">
                                <h4>Digital Travel Records</h4>
                                <p>Access your boarding passes anytime.</p>
                            </div>
                        </div>
                    </div>

                    <!-- Ambient Quote Card -->
                    <div class="auth-quote-card">
                        <div class="auth-quote-text">A safer, smarter and more connected way to fly.</div>
                        <div class="auth-quote-author">— SkyTech</div>
                    </div>
                </div>

                <!-- Right Registration Card -->
                <div class="auth-card-panel">
                    <div class="auth-card-header">
                        <h2 class="auth-card-title">Create Passenger Account</h2>
                        <p class="auth-card-subtitle">Join SkyTech for seamless flight booking, seat selection, and digital boarding passes.</p>
                    </div>

                    <!-- Server Error Message -->
                    <c:if test="${not empty errorMessage}">
                        <div class="auth-alert auth-alert-danger" role="alert">
                            <i class="bi bi-exclamation-octagon-fill fs-5"></i>
                            <div><c:out value="${errorMessage}" /></div>
                        </div>
                    </c:if>

                    <c:set var="gClientId" value="${not empty googleClientId ? googleClientId : com.airline.util.ConfigUtil.getGoogleClientId()}" />

                    <!-- Google Identity Services Web Authentication -->
                    <script src="https://accounts.google.com/gsi/client" async defer></script>
                    
                    <div class="google-auth-wrapper text-center my-3">
                        <div id="g_id_onload"
                             data-client_id="<c:out value='${gClientId}' />"
                             data-login_uri="${pageContext.request.contextPath}/auth/google"
                             data-auto_prompt="false">
                        </div>

                        <!-- Render Container for Google Identity Services Button -->
                        <div id="googleSignInBtnContainerReg" class="g_id_signin"
                             data-type="standard"
                             data-shape="rectangular"
                             data-theme="outline"
                             data-text="continue_with"
                             data-size="large"
                             data-logo_alignment="left"
                             data-width="360">
                        </div>
                    </div>

                    <div class="auth-divider">
                        <span>OR REGISTER WITH EMAIL</span>
                    </div>

                    <!-- Registration Form -->
                    <form action="${pageContext.request.contextPath}/register" method="post" id="registerForm" novalidate>
                        
                        <!-- Row 1: First Name & Last Name -->
                        <div class="auth-fields-row">
                            <div class="auth-field-group">
                                <label for="firstName" class="auth-field-label">First Name <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-person auth-field-icon"></i>
                                    <input type="text" class="auth-input-control" id="firstName" name="firstName"
                                           value="<c:out value='${regFirstName}' />"
                                           placeholder="e.g. John" required autocomplete="given-name">
                                </div>
                            </div>
                            <div class="auth-field-group">
                                <label for="lastName" class="auth-field-label">Last Name <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-person auth-field-icon"></i>
                                    <input type="text" class="auth-input-control" id="lastName" name="lastName"
                                           value="<c:out value='${regLastName}' />"
                                           placeholder="e.g. Doe" required autocomplete="family-name">
                                </div>
                            </div>
                        </div>

                        <!-- Row 2: Email & Phone -->
                        <div class="auth-fields-row">
                            <div class="auth-field-group">
                                <label for="email" class="auth-field-label">Email Address <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-envelope auth-field-icon"></i>
                                    <input type="email" class="auth-input-control" id="email" name="email"
                                           value="<c:out value='${regEmail}' />"
                                           placeholder="john.doe@example.com" required autocomplete="email">
                                </div>
                            </div>
                            <div class="auth-field-group">
                                <label for="phone" class="auth-field-label">Phone Number <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-telephone auth-field-icon"></i>
                                    <input type="tel" class="auth-input-control" id="phone" name="phone"
                                           value="<c:out value='${regPhone}' />"
                                           placeholder="+1555-0123" required autocomplete="tel">
                                </div>
                            </div>
                        </div>

                        <!-- Row 3: Passport & Date of Birth -->
                        <div class="auth-fields-row">
                            <div class="auth-field-group">
                                <label for="passportNumber" class="auth-field-label">Passport Number <span class="text-muted fw-normal">(Optional)</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-credit-card-2-front auth-field-icon"></i>
                                    <input type="text" class="auth-input-control" id="passportNumber" name="passportNumber"
                                           value="<c:out value='${regPassport}' />"
                                           placeholder="e.g. A12345678">
                                </div>
                            </div>
                            <div class="auth-field-group">
                                <label for="dateOfBirth" class="auth-field-label">Date of Birth <span class="text-muted fw-normal">(Optional)</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-calendar auth-field-icon"></i>
                                    <input type="date" class="auth-input-control" id="dateOfBirth" name="dateOfBirth"
                                           value="<c:out value='${regDob}' />">
                                </div>
                            </div>
                        </div>

                        <!-- Row 4: Password & Confirm Password -->
                        <div class="auth-fields-row">
                            <div class="auth-field-group">
                                <label for="password" class="auth-field-label">Password <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-lock auth-field-icon"></i>
                                    <input type="password" class="auth-input-control" id="password" name="password"
                                           placeholder="Min. 8 characters" required autocomplete="new-password">
                                    <button type="button" class="btn-toggle-eye" id="togglePasswordBtn" aria-label="Toggle password visibility">
                                        <i class="bi bi-eye" id="togglePassIcon"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="auth-field-group">
                                <label for="confirmPassword" class="auth-field-label">Confirm Password <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-lock auth-field-icon"></i>
                                    <input type="password" class="auth-input-control" id="confirmPassword" name="confirmPassword"
                                           placeholder="Re-enter password" required autocomplete="new-password">
                                    <button type="button" class="btn-toggle-eye" id="toggleConfirmBtn" aria-label="Toggle confirm password visibility">
                                        <i class="bi bi-eye" id="toggleConfirmIcon"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Password Strength Meter & Interactive Criteria Checklist -->
                        <div class="strength-meter-wrap">
                            <div class="strength-bars">
                                <div class="strength-bar" id="bar1"></div>
                                <div class="strength-bar" id="bar2"></div>
                                <div class="strength-bar" id="bar3"></div>
                                <div class="strength-bar" id="bar4"></div>
                            </div>
                            <div class="strength-criteria-list">
                                <div class="criteria-item" id="critLength">
                                    <span class="criteria-dot"></span>
                                    <span>At least 8 characters</span>
                                </div>
                                <div class="criteria-item" id="critNumber">
                                    <span class="criteria-dot"></span>
                                    <span>Include a number</span>
                                </div>
                                <div class="criteria-item" id="critUpper">
                                    <span class="criteria-dot"></span>
                                    <span>Include an uppercase letter</span>
                                </div>
                                <div class="criteria-item" id="critSpecial">
                                    <span class="criteria-dot"></span>
                                    <span>Include a special character (@$!%*?&amp;_#^~)</span>
                                </div>
                            </div>
                        </div>

                        <!-- Terms of Carriage Consent Checkbox -->
                        <div class="auth-terms-wrap">
                            <input type="checkbox" id="termsConsent" name="termsConsent" required checked>
                            <label for="termsConsent">
                                I agree to SkyTech <a href="javascript:void(0)" onclick="viewTerms()" class="auth-switch-link">Terms of Carriage</a> and <a href="javascript:void(0)" onclick="viewPrivacy()" class="auth-switch-link">Privacy Policy</a>.
                            </label>
                        </div>

                        <!-- Primary Create Account Action -->
                        <button type="submit" class="btn-auth-submit" id="btnRegisterSubmit">
                            <i class="bi bi-person-plus-fill"></i>
                            <span>Create Account</span>
                        </button>

                        <!-- Switch to Sign In -->
                        <div class="auth-switch-prompt" style="margin-top: 1.25rem;">
                            Already have an account? 
                            <a href="${pageContext.request.contextPath}/login" class="auth-switch-link">Sign In</a>
                        </div>
                    </form>
                </div>

            </div>
        </main>
    </div>
</div>

<script>
    // Google Identity Services trigger
    function triggerGooglePrompt() {
        if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
            google.accounts.id.prompt((notification) => {
                if (notification.isNotDisplayed() || notification.isSkippedMoment()) {
                    console.log('Google One-tap prompt skipped/not displayed:', notification.getNotDisplayedReason());
                }
            });
        } else {
            alert("Google Identity Services is loading or blocked by a browser extension. Please refresh the page and try again.");
        }
    }

    // Password toggles
    const passInput = document.getElementById('password');
    const togglePassBtn = document.getElementById('togglePasswordBtn');
    const togglePassIcon = document.getElementById('togglePassIcon');

    if (togglePassBtn && passInput) {
        togglePassBtn.addEventListener('click', function() {
            const isPass = passInput.getAttribute('type') === 'password';
            passInput.setAttribute('type', isPass ? 'text' : 'password');
            togglePassIcon.className = isPass ? 'bi bi-eye-slash' : 'bi bi-eye';
        });
    }

    const confInput = document.getElementById('confirmPassword');
    const toggleConfBtn = document.getElementById('toggleConfirmBtn');
    const toggleConfirmIcon = document.getElementById('toggleConfirmIcon');

    if (toggleConfBtn && confInput) {
        toggleConfBtn.addEventListener('click', function() {
            const isPass = confInput.getAttribute('type') === 'password';
            confInput.setAttribute('type', isPass ? 'text' : 'password');
            toggleConfirmIcon.className = isPass ? 'bi bi-eye-slash' : 'bi bi-eye';
        });
    }

    // Real-time password criteria & strength meter
    const bar1 = document.getElementById('bar1');
    const bar2 = document.getElementById('bar2');
    const bar3 = document.getElementById('bar3');
    const bar4 = document.getElementById('bar4');
    const bars = [bar1, bar2, bar3, bar4];

    const critLength = document.getElementById('critLength');
    const critNumber = document.getElementById('critNumber');
    const critUpper = document.getElementById('critUpper');
    const critSpecial = document.getElementById('critSpecial');

    if (passInput) {
        passInput.addEventListener('input', function() {
            const val = passInput.value;
            const hasLen = val.length >= 8;
            const hasNum = /\d/.test(val);
            const hasUp = /[A-Z]/.test(val);
            const hasSpec = /[@$!%*?&_#^~]/.test(val);

            // Update criteria items
            critLength.className = hasLen ? 'criteria-item valid' : 'criteria-item';
            critNumber.className = hasNum ? 'criteria-item valid' : 'criteria-item';
            critUpper.className = hasUp ? 'criteria-item valid' : 'criteria-item';
            critSpecial.className = hasSpec ? 'criteria-item valid' : 'criteria-item';

            const score = (hasLen ? 1 : 0) + (hasNum ? 1 : 0) + (hasUp ? 1 : 0) + (hasSpec ? 1 : 0);

            // Colors
            const colors = ['#EF4444', '#F59E0B', '#3B82F6', '#10B981'];
            const activeColor = score > 0 ? colors[score - 1] : '#E2E8F0';

            bars.forEach((bar, idx) => {
                if (idx < score) {
                    bar.style.backgroundColor = activeColor;
                } else {
                    bar.style.backgroundColor = '#E2E8F0';
                }
            });
        });
    }

    // Client-side validation before submission
    const regForm = document.getElementById('registerForm');
    const btnRegister = document.getElementById('btnRegisterSubmit');

    if (regForm && btnRegister) {
        regForm.addEventListener('submit', function(e) {
            const pwd = passInput.value;
            const conf = confInput.value;

            if (pwd !== conf) {
                e.preventDefault();
                alert("Passwords do not match. Please verify your passwords and re-try.");
                confInput.focus();
                return;
            }

            const terms = document.getElementById('termsConsent');
            if (terms && !terms.checked) {
                e.preventDefault();
                alert("Please agree to the SkyTech Terms of Carriage to register.");
                terms.focus();
                return;
            }

            btnRegister.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Creating Account...';
            btnRegister.style.opacity = '0.85';
            btnRegister.style.pointerEvents = 'none';
        });
    }

    function viewTerms() {
        alert("SkyTech Terms of Carriage:\n\nPassengers are entitled to standard baggage allowance, transparent fares, and 24-hour advance check-in. Standard flight safety guidelines apply.");
    }

    function viewPrivacy() {
        alert("SkyTech Privacy Policy:\n\nYour personal passenger details, contact numbers, and travel itineraries are securely stored and encrypted according to airline data privacy standards.");
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
