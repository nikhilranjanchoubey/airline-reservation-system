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

                        <!-- Social OR Divider -->
                        <div class="auth-divider">
                            <span>OR</span>
                        </div>

                        <!-- Social Sign-in Options -->
                        <div class="auth-social-buttons">
                            <button type="button" class="btn-social-auth" onclick="handleSocialAuth('Google')">
                                <svg class="social-icon-svg" viewBox="0 0 24 24">
                                    <path fill="#4285F4" d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.82-2.4 3.68v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.17z"/>
                                    <path fill="#34A853" d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.33 24 12 24z"/>
                                    <path fill="#FBBC05" d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.25C.45 8.18 0 9.99 0 12s.45 3.82 1.25 5.42l4.03-3.15z"/>
                                    <path fill="#EA4335" d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.33 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z"/>
                                </svg>
                                <span>Continue with Google</span>
                            </button>

                            <button type="button" class="btn-social-auth" onclick="handleSocialAuth('Microsoft')">
                                <svg class="social-icon-svg" viewBox="0 0 23 23">
                                    <path fill="#f35325" d="M1 1h10v10H1z"/>
                                    <path fill="#81bc06" d="M12 1h10v10H12z"/>
                                    <path fill="#05a6f0" d="M1 12h10v10H1z"/>
                                    <path fill="#ffba08" d="M12 12h10v10H12z"/>
                                </svg>
                                <span>Continue with Microsoft</span>
                            </button>
                        </div>

                        <!-- Registration Prompt -->
                        <div class="auth-switch-prompt">
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

    // Social auth notice handler
    function handleSocialAuth(provider) {
        alert("Single Sign-On (" + provider + "):\n\nSocial federation is configured for production SkyTech SSO. In this local development build, please use the direct SkyTech credentials or register a local passenger account.");
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
