<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Sign In - SkyTech Airlines" />
<c:set var="activePage" value="login" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="auth-page-body">
    <div class="auth-cinematic-wrapper login-bg">
        <div class="auth-cinematic-overlay"></div>

        <!-- Minimalist Cinematic Top Navigation -->
        <header class="auth-top-bar">
            <a href="${pageContext.request.contextPath}/" class="auth-brand" aria-label="SkyTech Airlines Homepage">
                <div class="auth-brand-icon">
                    <i class="bi bi-airplane-fill" style="transform: rotate(-35deg); display: inline-block;"></i>
                </div>
                <div class="auth-brand-text">
                    <span class="auth-brand-name">SkyTech</span>
                    <span class="auth-brand-sub">AIRLINES</span>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/" class="auth-back-link">
                <i class="bi bi-arrow-left"></i>
                <span>Back to Home</span>
            </a>
        </header>

        <!-- Main Split Screen Content -->
        <main class="auth-main-container">
            <div class="auth-split-grid">
                
                <!-- Left Visual & Storytelling Panel -->
                <div class="auth-visual-pane">
                    <h1 class="auth-hero-title">
                        Welcome Back,<br>
                        <span class="auth-highlight-text">Traveler.</span>
                    </h1>
                    <p class="auth-hero-desc">
                        Your next journey is just a sign-in away. Access your bookings and manage your journeys with SkyTech Airlines.
                    </p>

                    <!-- 3 Benefit Indicators -->
                    <div class="auth-benefits-list">
                        <div class="auth-benefit-item">
                            <div class="auth-benefit-icon">
                                <i class="bi bi-airplane-fill" style="transform: rotate(-25deg); display: inline-block;"></i>
                            </div>
                            <div class="auth-benefit-text">
                                <h4>Easy Booking</h4>
                                <p>Book flights in just a few clicks.</p>
                            </div>
                        </div>

                        <div class="auth-benefit-item">
                            <div class="auth-benefit-icon">
                                <i class="bi bi-shield-lock-fill"></i>
                            </div>
                            <div class="auth-benefit-text">
                                <h4>Secure Account</h4>
                                <p>Your data and payments are protected.</p>
                            </div>
                        </div>

                        <div class="auth-benefit-item">
                            <div class="auth-benefit-icon">
                                <i class="bi bi-briefcase-fill"></i>
                            </div>
                            <div class="auth-benefit-text">
                                <h4>Your Trips in One Place</h4>
                                <p>View, manage and access boarding passes anytime, anywhere.</p>
                            </div>
                        </div>
                    </div>

                    <!-- Ambient Quote Card -->
                    <div class="auth-quote-card">
                        <div class="auth-quote-icon">“</div>
                        <div class="auth-quote-text">Connecting people, places and possibilities.</div>
                        <div class="auth-quote-author">— SkyTech Airlines</div>
                    </div>
                </div>

                <!-- Right Authentication Card -->
                <div class="auth-card-panel">
                    <div class="auth-card-header">
                        <h2 class="auth-card-title">Sign in to SkyTech</h2>
                        <p class="auth-card-subtitle">Access your bookings and manage your journeys.</p>
                    </div>

                    <!-- Server Alert Messages -->
                    <c:if test="${not empty flashSuccess}">
                        <div class="auth-alert auth-alert-success" role="alert">
                            <i class="bi bi-check-circle-fill fs-5"></i>
                            <div><c:out value="${flashSuccess}" /></div>
                        </div>
                    </c:if>

                    <c:if test="${not empty flashError}">
                        <div class="auth-alert auth-alert-warning" role="alert">
                            <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                            <div><c:out value="${flashError}" /></div>
                        </div>
                    </c:if>

                    <c:if test="${not empty errorMessage}">
                        <div class="auth-alert auth-alert-danger" role="alert">
                            <i class="bi bi-x-circle-fill fs-5"></i>
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
                        <div id="googleSignInBtnContainer" class="g_id_signin"
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
                        <span>OR CONTINUE WITH EMAIL</span>
                    </div>

                    <!-- Login Form -->
                    <form action="${pageContext.request.contextPath}/login" method="post" id="loginForm" novalidate>
                        <!-- Email Field -->
                        <div class="auth-field-group">
                            <label for="email" class="auth-field-label">Email Address <span class="required-mark">*</span></label>
                            <div class="auth-input-wrapper">
                                <i class="bi bi-envelope auth-field-icon"></i>
                                <input type="email" class="auth-input-control" id="email" name="email"
                                       value="<c:out value='${loginEmail}' />"
                                       placeholder="Enter your email address" required autocomplete="email">
                            </div>
                        </div>

                        <!-- Password Field -->
                        <div class="auth-field-group">
                            <label for="password" class="auth-field-label">Password <span class="required-mark">*</span></label>
                            <div class="auth-input-wrapper">
                                <i class="bi bi-lock auth-field-icon"></i>
                                <input type="password" class="auth-input-control" id="password" name="password"
                                       placeholder="Enter your password" required autocomplete="current-password">
                                <button type="button" class="btn-toggle-eye" id="togglePasswordBtn" aria-label="Toggle password visibility">
                                    <i class="bi bi-eye" id="toggleIcon"></i>
                                </button>
                            </div>
                        </div>

                        <!-- Remember Me & Forgot Password -->
                        <div class="auth-options-row">
                            <label class="auth-remember-check">
                                <input type="checkbox" id="rememberMe" name="rememberMe" checked>
                                <span>Remember me</span>
                            </label>
                            <a href="javascript:void(0)" onclick="handleForgotPassword()" class="auth-forgot-link">Forgot Password?</a>
                        </div>

                        <!-- Primary Sign In Action -->
                        <button type="submit" class="btn-auth-submit" id="submitLoginBtn">
                            <i class="bi bi-box-arrow-in-right"></i>
                            <span>Sign In</span>
                        </button>

                        <!-- Registration Prompt -->
                        <div class="auth-switch-prompt" style="margin-top: 1.5rem;">
                            Don't have an account yet? 
                            <a href="${pageContext.request.contextPath}/register" class="auth-switch-link">Create Passenger Account</a>
                        </div>
                    </form>

                    <!-- Pre-seeded Demo Credentials Box -->
                    <div class="auth-demo-badge">
                        <div class="auth-demo-title">
                            <i class="bi bi-info-circle-fill"></i>
                            <span>Demo Credentials (Development only)</span>
                        </div>
                        <div class="auth-demo-grid">
                            <div class="auth-demo-row">
                                <span><strong>Admin:</strong> <code class="auth-demo-code">admin@airline.com</code> / <code class="auth-demo-code">Admin@12345</code></span>
                                <button type="button" class="btn-demo-fill" onclick="fillCredentials('admin@airline.com', 'Admin@12345')">Use Admin</button>
                            </div>
                            <div class="auth-demo-row">
                                <span><strong>Passenger:</strong> <code class="auth-demo-code">passenger@airline.com</code> / <code class="auth-demo-code">Passenger@12345</code></span>
                                <button type="button" class="btn-demo-fill" onclick="fillCredentials('passenger@airline.com', 'Passenger@12345')">Use Passenger</button>
                            </div>
                        </div>
                    </div>
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
                    // Fallback to standard Google Sign-In prompt/render
                    console.log('Google One-tap prompt skipped/not displayed:', notification.getNotDisplayedReason());
                }
            });
        } else {
            alert("Google Identity Services is loading or blocked by a browser extension. Please refresh the page and try again.");
        }
    }

    // Password visibility toggle
    const toggleBtn = document.getElementById('togglePasswordBtn');
    const passwordInput = document.getElementById('password');
    const toggleIcon = document.getElementById('toggleIcon');

    if (toggleBtn && passwordInput) {
        toggleBtn.addEventListener('click', function() {
            const isPassword = passwordInput.getAttribute('type') === 'password';
            passwordInput.setAttribute('type', isPassword ? 'text' : 'password');
            toggleIcon.className = isPassword ? 'bi bi-eye-slash' : 'bi bi-eye';
        });
    }

    // Quick fill demo credentials
    function fillCredentials(email, pwd) {
        document.getElementById('email').value = email;
        document.getElementById('password').value = pwd;
        document.getElementById('password').focus();
    }

    // Forgot password info handler
    function handleForgotPassword() {
        alert("Password Recovery Notice:\n\nFor security and PBL environment testing, please log in using the pre-seeded credentials (Passenger or Admin), or contact system admin at admin@airline.com.");
    }

    // Form submission animation feedback
    const loginForm = document.getElementById('loginForm');
    const submitLoginBtn = document.getElementById('submitLoginBtn');
    if (loginForm && submitLoginBtn) {
        loginForm.addEventListener('submit', function() {
            submitLoginBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Authenticating...';
            submitLoginBtn.style.opacity = '0.85';
            submitLoginBtn.style.pointerEvents = 'none';
        });
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
