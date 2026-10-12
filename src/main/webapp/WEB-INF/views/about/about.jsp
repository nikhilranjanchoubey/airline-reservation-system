<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="About SkyTech Airlines - Project & Team Overview" />
<c:set var="activePage" value="about" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="about-page-wrapper">
    <!-- =========================================================
         1. ABOUT HERO BANNER
         ========================================================= -->
    <section class="about-hero-section py-5 position-relative overflow-hidden">
        <div class="about-hero-bg-glow"></div>
        <div class="container position-relative z-2 text-center py-4">
            <span class="badge bg-sky-cyan-glow text-dark text-uppercase font-monospace fw-bold px-3 py-2 rounded-pill mb-3">
                <i class="bi bi-mortarboard-fill me-1"></i> Java PBL Project Showcase
            </span>
            <h1 class="display-4 fw-extrabold text-white mb-3 font-heading">
                About <span class="text-sky-cyan">SkyTech Airlines</span>
            </h1>
            <p class="lead text-cloud-white opacity-90 mx-auto" style="max-width: 750px;">
                Engineering a smarter, more connected airline reservation experience.
            </p>
        </div>
    </section>

    <!-- =========================================================
         2. PROJECT OVERVIEW & SCOPE
         ========================================================= -->
    <section class="py-5 bg-midnight-navy border-top border-bottom border-sky-dark">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-6">
                    <div class="pe-lg-4">
                        <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">Project Purpose</span>
                        <h2 class="h1 text-white font-heading fw-bold mt-2 mb-3">
                            Cloud-Native Aviation & PBL Engineering
                        </h2>
                        <p class="text-muted-slate mb-3">
                            <strong>SkyTech Airlines</strong> is a comprehensive Java-based Airline Reservation System developed as a college Project-Based Learning (PBL) initiative. Built to simulate real-world enterprise aviation portals, it bridges modern web aesthetics with robust server-side processing.
                        </p>
                        <p class="text-muted-slate mb-4">
                            The project emphasizes modular software architecture, role-based security, seamless database persistence, and intuitive passenger self-service workflows.
                        </p>
                        <div class="row g-3">
                            <div class="col-sm-6">
                                <div class="p-3 glass-card border-left-cyan rounded-3">
                                    <h6 class="text-white fw-bold mb-1"><i class="bi bi-shield-check text-sky-cyan me-2"></i> Verified Stack</h6>
                                    <p class="small text-muted-slate mb-0">Java 21, Jakarta EE 10 &amp; MySQL 8.3</p>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="p-3 glass-card border-left-cyan rounded-3">
                                    <h6 class="text-white fw-bold mb-1"><i class="bi bi-person-badge-fill text-sky-cyan me-2"></i> Role-Based Access</h6>
                                    <p class="small text-muted-slate mb-0">Passenger &amp; Admin Dashboards</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="glass-card p-4 rounded-4 shadow-cyan-lg">
                        <h4 class="text-white font-heading fw-bold mb-3"><i class="bi bi-list-task text-sky-cyan me-2"></i> System Scope &amp; Implementation</h4>
                        <ul class="list-unstyled d-flex flex-column gap-3 mb-0">
                            <li class="d-flex align-items-start gap-3">
                                <span class="badge bg-success-subtle text-success p-2 rounded-circle"><i class="bi bi-check-lg fs-6"></i></span>
                                <div>
                                    <strong class="text-white d-block">Authentication &amp; Security (Verified)</strong>
                                    <span class="small text-muted-slate">User registration, encrypted password storage, session governance, and Google Sign-In verification.</span>
                                </div>
                            </li>
                            <li class="d-flex align-items-start gap-3">
                                <span class="badge bg-success-subtle text-success p-2 rounded-circle"><i class="bi bi-check-lg fs-6"></i></span>
                                <div>
                                    <strong class="text-white d-block">User Profile &amp; Role Management (Verified)</strong>
                                    <span class="small text-muted-slate">Passenger portal, profile editing, and protected Admin dashboard user status control.</span>
                                </div>
                            </li>
                            <li class="d-flex align-items-start gap-3">
                                <span class="badge bg-info-subtle text-sky-cyan p-2 rounded-circle"><i class="bi bi-airplane fs-6"></i></span>
                                <div>
                                    <strong class="text-white d-block">Flight Search &amp; Route Discovery (Implemented)</strong>
                                    <span class="small text-muted-slate">Interactive flight search panel, origin/destination airport selectors, and popular route fare cards.</span>
                                </div>
                            </li>
                            <li class="d-flex align-items-start gap-3">
                                <span class="badge bg-secondary-subtle text-light p-2 rounded-circle"><i class="bi bi-clock-history fs-6"></i></span>
                                <div>
                                    <strong class="text-white d-block">Booking &amp; Ticket Manifest (In Integration)</strong>
                                    <span class="small text-muted-slate">Seat selection, passenger booking manifests, and ticket management workflows.</span>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         3. PROJECT GOALS (5 Cards)
         ========================================================= -->
    <section class="py-5 bg-deep-aviation position-relative">
        <div class="container">
            <div class="text-center mb-5">
                <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">Engineering Objectives</span>
                <h2 class="display-6 text-white font-heading fw-bold mt-2">Project Core Goals</h2>
            </div>
            
            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift">
                        <div class="goal-icon-box mb-3">
                            <i class="bi bi-lightning-charge-fill"></i>
                        </div>
                        <h5 class="text-white fw-bold mb-2">1. Simplify Passenger Journey</h5>
                        <p class="small text-muted-slate mb-0">Provide an intuitive, frictionless reservation flow from route search to electronic ticketing and check-in.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift">
                        <div class="goal-icon-box mb-3">
                            <i class="bi bi-laptop"></i>
                        </div>
                        <h5 class="text-white fw-bold mb-2">2. Responsive Cinematic UI</h5>
                        <p class="small text-muted-slate mb-0">Design a premium aviation theme with Bootstrap 5, glassmorphism elements, and mobile-first responsiveness.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift">
                        <div class="goal-icon-box mb-3">
                            <i class="bi bi-shield-lock-fill"></i>
                        </div>
                        <h5 class="text-white fw-bold mb-2">3. Role-Based Authorization</h5>
                        <p class="small text-muted-slate mb-0">Enforce enterprise-grade security filters separating passenger account services from administrator operations.</p>
                    </div>
                </div>
                <div class="col-lg-6 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift">
                        <div class="goal-icon-box mb-3">
                            <i class="bi bi-diagram-3-fill"></i>
                        </div>
                        <h5 class="text-white fw-bold mb-2">4. Structured Flight Workflows</h5>
                        <p class="small text-muted-slate mb-0">Organize complex flight availability, passenger booking records, and cancellation rules with transactional precision.</p>
                    </div>
                </div>
                <div class="col-lg-6 col-md-12">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift">
                        <div class="goal-icon-box mb-3">
                            <i class="bi bi-code-square"></i>
                        </div>
                        <h5 class="text-white fw-bold mb-2">5. Academic PBL Mastery</h5>
                        <p class="small text-muted-slate mb-0">Apply modular MVC principles in Java 21, JDBC connection pooling, unit testing, and technical documentation best practices.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         4. VERIFIED TECHNOLOGY STACK
         ========================================================= -->
    <section class="py-5 bg-midnight-navy border-top border-bottom border-sky-dark">
        <div class="container">
            <div class="text-center mb-5">
                <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">Built With Modern Standards</span>
                <h2 class="display-6 text-white font-heading fw-bold mt-2">Verified Technology Stack</h2>
            </div>
            
            <div class="row g-3">
                <div class="col-lg-3 col-md-4 col-6">
                    <div class="tech-card text-center p-3 rounded-3">
                        <i class="bi bi-cup-hot-fill text-sky-cyan fs-2 mb-2 d-block"></i>
                        <h6 class="text-white fw-bold mb-1">Java 21</h6>
                        <span class="fs-8 text-muted-slate">LTS JDK Core Logic</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-4 col-6">
                    <div class="tech-card text-center p-3 rounded-3">
                        <i class="bi bi-layers-fill text-sky-cyan fs-2 mb-2 d-block"></i>
                        <h6 class="text-white fw-bold mb-1">Jakarta Servlets 6.0</h6>
                        <span class="fs-8 text-muted-slate">Controller Architecture</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-4 col-6">
                    <div class="tech-card text-center p-3 rounded-3">
                        <i class="bi bi-filetype-jsp text-sky-cyan fs-2 mb-2 d-block"></i>
                        <h6 class="text-white fw-bold mb-1">JSP 3.1 &amp; JSTL</h6>
                        <span class="fs-8 text-muted-slate">Dynamic View Layer</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-4 col-6">
                    <div class="tech-card text-center p-3 rounded-3">
                        <i class="bi bi-database-fill-gear text-sky-cyan fs-2 mb-2 d-block"></i>
                        <h6 class="text-white fw-bold mb-1">JDBC &amp; MySQL 8.3</h6>
                        <span class="fs-8 text-muted-slate">Persistence &amp; DAO Layer</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-4 col-6">
                    <div class="tech-card text-center p-3 rounded-3">
                        <i class="bi bi-box-seam-fill text-sky-cyan fs-2 mb-2 d-block"></i>
                        <h6 class="text-white fw-bold mb-1">Apache Maven</h6>
                        <span class="fs-8 text-muted-slate">Build &amp; Dependency WAR</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-4 col-6">
                    <div class="tech-card text-center p-3 rounded-3">
                        <i class="bi bi-bootstrap-fill text-sky-cyan fs-2 mb-2 d-block"></i>
                        <h6 class="text-white fw-bold mb-1">Bootstrap 5.3</h6>
                        <span class="fs-8 text-muted-slate">Responsive UI Grid</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-4 col-6">
                    <div class="tech-card text-center p-3 rounded-3">
                        <i class="bi bi-google text-sky-cyan fs-2 mb-2 d-block"></i>
                        <h6 class="text-white fw-bold mb-1">Google Identity</h6>
                        <span class="fs-8 text-muted-slate">GIS OAuth 2.0 Auth</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-4 col-6">
                    <div class="tech-card text-center p-3 rounded-3">
                        <i class="bi bi-server text-sky-cyan fs-2 mb-2 d-block"></i>
                        <h6 class="text-white fw-bold mb-1">Apache Tomcat 10.1</h6>
                        <span class="fs-8 text-muted-slate">Jakarta Servlet Container</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         5. MENTOR PROFILE CARD
         ========================================================= -->
    <section class="py-5 bg-deep-aviation">
        <div class="container">
            <div class="text-center mb-5">
                <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">Academic Guidance</span>
                <h2 class="display-6 text-white font-heading fw-bold mt-2">Project Mentor</h2>
            </div>
            
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="glass-card p-4 p-md-5 rounded-4 shadow-cyan-lg border-sky-cyan-glow">
                        <div class="row align-items-center g-4">
                            <div class="col-md-4 text-center">
                                <div class="mentor-avatar-container mx-auto">
                                    <img src="${pageContext.request.contextPath}/images/team/mentor.jpg" alt="Er. Ram Babu Buri" class="mentor-portrait-img img-fluid rounded-circle border border-3 border-sky-cyan shadow" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/team/mentor.jpg'; this.onerror=function(){this.style.display='none'; this.nextElementSibling.style.display='flex';}">
                                    <div class="avatar-initials-fallback rounded-circle bg-sky-electric text-white font-heading fw-bold display-6 justify-content-center align-items-center" style="display:none; width: 140px; height: 140px; margin: 0 auto;">
                                        RB
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-8 text-center text-md-start">
                                <span class="badge bg-sky-cyan-glow text-dark text-uppercase font-monospace fw-bold mb-2 px-3 py-1">Faculty Mentor</span>
                                <h3 class="text-white font-heading fw-bold mb-1">Er. Ram Babu Buri</h3>
                                <p class="text-sky-cyan fw-semibold mb-3">Department of Computer Science and Engineering (CSE)</p>
                                <p class="text-muted-slate small mb-0">
                                    Providing overall academic direction, architectural oversight, and technical mentorship for the SkyTech Airlines Project-Based Learning (PBL) development team throughout system design, code review, and project implementation.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         6. FEATURED DEVELOPER CARD: MOHAMMED SAHIL
         ========================================================= -->
    <section class="py-5 bg-midnight-navy border-top border-bottom border-sky-dark">
        <div class="container">
            <div class="text-center mb-5">
                <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">Core Module Leader</span>
                <h2 class="display-6 text-white font-heading fw-bold mt-2">Featured Student Developer</h2>
            </div>
            
            <div class="row justify-content-center">
                <div class="col-lg-9">
                    <div class="glass-card p-4 p-md-5 rounded-4 shadow-cyan-lg highlight-developer-card">
                        <div class="row align-items-center g-4">
                            <div class="col-md-4 text-center">
                                <div class="developer-avatar-wrapper mx-auto">
                                    <img src="${pageContext.request.contextPath}/images/team/mohammed-sahil.jpg" alt="Mohammed Sahil" class="dev-portrait-img img-fluid rounded-circle border border-3 border-sky-electric shadow-cyan-glow" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/team/mohammed-sahil.jpg'; this.onerror=function(){this.style.display='none'; this.nextElementSibling.style.display='flex';}">
                                    <div class="avatar-initials-fallback rounded-circle bg-sky-electric text-white font-heading fw-bold display-5 justify-content-center align-items-center shadow-cyan-glow" style="display:none; width: 140px; height: 140px; margin: 0 auto;">
                                        MS
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-8 text-center text-md-start">
                                <span class="badge bg-sky-electric text-white text-uppercase font-monospace fw-bold mb-2 px-3 py-1">
                                    <i class="bi bi-shield-lock-fill me-1"></i> Module Lead
                                </span>
                                <h3 class="text-white font-heading fw-bold mb-1">Mohammed Sahil</h3>
                                <p class="text-sky-cyan fw-bold fs-5 mb-3">Authentication &amp; User Management Developer</p>
                                
                                <p class="text-cloud-white opacity-90 small mb-3">
                                    Engineered the complete security architecture and user lifecycle for SkyTech Airlines, including user registration, login, session governance, role-based authorization filters, password hashing, user profile services, and Google Sign-In integration.
                                </p>

                                <div class="mb-3">
                                    <strong class="text-white fs-7 d-block mb-2 font-heading">Key Module Contributions:</strong>
                                    <div class="d-flex flex-wrap gap-2 justify-content-center justify-content-md-start">
                                        <span class="badge bg-dark border border-secondary text-cloud-white">Registration &amp; Login</span>
                                        <span class="badge bg-dark border border-secondary text-cloud-white">Session Management</span>
                                        <span class="badge bg-dark border border-secondary text-cloud-white">Passenger Profile</span>
                                        <span class="badge bg-dark border border-secondary text-cloud-white">Password Security</span>
                                        <span class="badge bg-dark border border-secondary text-cloud-white">Role Authorization</span>
                                        <span class="badge bg-dark border border-secondary text-cloud-white">Google Sign-In</span>
                                        <span class="badge bg-dark border border-secondary text-cloud-white">Auth Testing &amp; Docs</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         7. FULL TEAM SECTION
         ========================================================= -->
    <section class="py-5 bg-deep-aviation">
        <div class="container">
            <div class="text-center mb-5">
                <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">Student Developers</span>
                <h2 class="display-6 text-white font-heading fw-bold mt-2">Meet the Team Behind SkyTech Airlines</h2>
            </div>
            
            <div class="row g-4">
                <!-- Team Member 1: Mohammed Sahil -->
                <div class="col-lg-4 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 text-center team-card hover-lift">
                        <div class="team-avatar-box mx-auto mb-3">
                            <img src="${pageContext.request.contextPath}/images/team/mohammed-sahil.jpg" alt="Mohammed Sahil" class="team-thumb-img rounded-circle border border-2 border-sky-cyan" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/team/mohammed-sahil.jpg'; this.onerror=function(){this.style.display='none'; this.nextElementSibling.style.display='flex';}">
                            <div class="avatar-initials-fallback rounded-circle bg-primary text-white font-heading fw-bold fs-4 justify-content-center align-items-center" style="display:none; width: 90px; height: 90px; margin: 0 auto;">
                                MS
                            </div>
                        </div>
                        <h5 class="text-white font-heading fw-bold mb-1">Mohammed Sahil</h5>
                        <p class="text-sky-cyan small fw-semibold mb-2">Authentication &amp; User Security</p>
                        <p class="text-muted-slate fs-8 mb-0">Designed user auth servlets, session filters, password security, profile management, and Google OAuth integration.</p>
                    </div>
                </div>

                <!-- Team Member 2: Mukesh Sah -->
                <div class="col-lg-4 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 text-center team-card hover-lift">
                        <div class="team-avatar-box mx-auto mb-3">
                            <img src="${pageContext.request.contextPath}/images/team/mukesh-sah.jpg" alt="Mukesh Sah" class="team-thumb-img rounded-circle border border-2 border-sky-cyan" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/team/mukesh-sah.jpg'; this.onerror=function(){this.style.display='none'; this.nextElementSibling.style.display='flex';}">
                            <div class="avatar-initials-fallback rounded-circle bg-primary text-white font-heading fw-bold fs-4 justify-content-center align-items-center" style="display:none; width: 90px; height: 90px; margin: 0 auto;">
                                MS
                            </div>
                        </div>
                        <h5 class="text-white font-heading fw-bold mb-1">Mukesh Sah</h5>
                        <p class="text-sky-cyan small fw-semibold mb-2">Flight &amp; Route Management</p>
                        <p class="text-muted-slate fs-8 mb-0">Contributed to flight scheduling, destination catalog, airport route mappings, and availability querying logic.</p>
                    </div>
                </div>

                <!-- Team Member 3: Muskan Raj -->
                <div class="col-lg-4 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 text-center team-card hover-lift">
                        <div class="team-avatar-box mx-auto mb-3">
                            <img src="${pageContext.request.contextPath}/images/team/muskan-raj.jpg" alt="Muskan Raj" class="team-thumb-img rounded-circle border border-2 border-sky-cyan" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/team/muskan-raj.jpg'; this.onerror=function(){this.style.display='none'; this.nextElementSibling.style.display='flex';}">
                            <div class="avatar-initials-fallback rounded-circle bg-primary text-white font-heading fw-bold fs-4 justify-content-center align-items-center" style="display:none; width: 90px; height: 90px; margin: 0 auto;">
                                MR
                            </div>
                        </div>
                        <h5 class="text-white font-heading fw-bold mb-1">Muskan Raj</h5>
                        <p class="text-sky-cyan small fw-semibold mb-2">Booking &amp; Passenger Manifest</p>
                        <p class="text-muted-slate fs-8 mb-0">Assisted with booking workflows, passenger input forms, seat selection interfaces, and ticket generation concepts.</p>
                    </div>
                </div>

                <!-- Team Member 4: Nikhil Ranjan Choubey -->
                <div class="col-lg-6 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 text-center team-card hover-lift">
                        <div class="team-avatar-box mx-auto mb-3">
                            <img src="${pageContext.request.contextPath}/images/team/nikhil-ranjan-choubey.jpg" alt="Nikhil Ranjan Choubey" class="team-thumb-img rounded-circle border border-2 border-sky-cyan" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/team/nikhil-ranjan-choubey.jpg'; this.onerror=function(){this.style.display='none'; this.nextElementSibling.style.display='flex';}">
                            <div class="avatar-initials-fallback rounded-circle bg-primary text-white font-heading fw-bold fs-4 justify-content-center align-items-center" style="display:none; width: 90px; height: 90px; margin: 0 auto;">
                                NC
                            </div>
                        </div>
                        <h5 class="text-white font-heading fw-bold mb-1">Nikhil Ranjan Choubey</h5>
                        <p class="text-sky-cyan small fw-semibold mb-2">System Architecture &amp; Database Design</p>
                        <p class="text-muted-slate fs-8 mb-0">Participated in database schema architecture, MySQL relational table design, JDBC connection utilities, and overall project integration.</p>
                    </div>
                </div>

                <!-- Team Member 5: Prashant Chaudhary -->
                <div class="col-lg-6 col-md-12">
                    <div class="glass-card p-4 h-100 rounded-4 text-center team-card hover-lift">
                        <div class="team-avatar-box mx-auto mb-3">
                            <img src="${pageContext.request.contextPath}/images/team/prashant-chaudhary.jpg" alt="Prashant Chaudhary" class="team-thumb-img rounded-circle border border-2 border-sky-cyan" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/team/prashant-chaudhary.jpg'; this.onerror=function(){this.style.display='none'; this.nextElementSibling.style.display='flex';}">
                            <div class="avatar-initials-fallback rounded-circle bg-primary text-white font-heading fw-bold fs-4 justify-content-center align-items-center" style="display:none; width: 90px; height: 90px; margin: 0 auto;">
                                PC
                            </div>
                        </div>
                        <h5 class="text-white font-heading fw-bold mb-1">Prashant Chaudhary</h5>
                        <p class="text-sky-cyan small fw-semibold mb-2">UI/UX Design &amp; Frontend Integration</p>
                        <p class="text-muted-slate fs-8 mb-0">Contributed to responsive Bootstrap layouts, CSS animation effects, header/footer themes, and client-side form validation scripting.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         8. PROJECT TIMELINE (6 July 2026 - 6 October 2026)
         ========================================================= -->
    <section class="py-5 bg-midnight-navy border-top border-bottom border-sky-dark">
        <div class="container">
            <div class="text-center mb-5">
                <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">Development Lifecycle</span>
                <h2 class="display-6 text-white font-heading fw-bold mt-2">Project Milestone Timeline</h2>
                <p class="text-muted-slate small">6 July 2026 &ndash; 6 October 2026</p>
            </div>

            <div class="skytech-timeline-wrapper">
                <div class="row g-4">
                    <div class="col-lg-3 col-md-6">
                        <div class="timeline-phase-card p-4 glass-card rounded-4 border-top-cyan">
                            <div class="phase-number text-sky-cyan font-monospace fw-bold mb-2">PHASE 01</div>
                            <h6 class="text-white fw-bold font-heading mb-1">Requirements &amp; Architecture</h6>
                            <span class="fs-8 text-sky-cyan d-block mb-2">July 2026</span>
                            <p class="small text-muted-slate mb-0">Defined project scope, ER database diagrams, MVC servlet structure, and UI wireframes for SkyTech Airlines.</p>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6">
                        <div class="timeline-phase-card p-4 glass-card rounded-4 border-top-cyan">
                            <div class="phase-number text-sky-cyan font-monospace fw-bold mb-2">PHASE 02</div>
                            <h6 class="text-white fw-bold font-heading mb-1">Module Implementation</h6>
                            <span class="fs-8 text-sky-cyan d-block mb-2">August 2026</span>
                            <p class="small text-muted-slate mb-0">Constructed core DAO data access layer, User/Flight servlets, DB connection pools, and initial JSP views.</p>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6">
                        <div class="timeline-phase-card p-4 glass-card rounded-4 border-top-cyan">
                            <div class="phase-number text-sky-cyan font-monospace fw-bold mb-2">PHASE 03</div>
                            <h6 class="text-white fw-bold font-heading mb-1">UI Refinement &amp; Auth</h6>
                            <span class="fs-8 text-sky-cyan d-block mb-2">September 2026</span>
                            <p class="small text-muted-slate mb-0">Integrated Bootstrap 5 aviation styling, session authorization, password hashing, and Google GIS OAuth 2.0.</p>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6">
                        <div class="timeline-phase-card p-4 glass-card rounded-4 border-top-cyan">
                            <div class="phase-number text-sky-cyan font-monospace fw-bold mb-2">PHASE 04</div>
                            <h6 class="text-white fw-bold font-heading mb-1">Testing &amp; Documentation</h6>
                            <span class="fs-8 text-sky-cyan d-block mb-2">October 2026</span>
                            <p class="small text-muted-slate mb-0">Conducted integration testing, admin authorization audit, visual polish, cinematic footer, and final PBL documentation.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         9. SYSTEM ARCHITECTURE & WORKFLOW (UML / Mermaid)
         ========================================================= -->
    <section class="py-5 bg-deep-aviation">
        <div class="container">
            <div class="text-center mb-5">
                <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">Technical Blueprint</span>
                <h2 class="display-6 text-white font-heading fw-bold mt-2">Architecture &amp; Security Workflow</h2>
            </div>

            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="glass-card p-4 h-100 rounded-4">
                        <h5 class="text-white font-heading fw-bold mb-3"><i class="bi bi-diagram-3 text-sky-cyan me-2"></i> System MVC Architecture</h5>
                        <div class="mermaid-box p-3 bg-midnight-navy rounded-3 border border-sky-dark overflow-auto">
                            <pre class="mermaid text-center">
graph TD
    Client[Passenger / Admin Browser] -->|HTTP / HTTPS| Views[JSP Dynamic Views]
    Views -->|Form / AJAX POST| Controllers[Jakarta Servlets]
    Controllers -->|Authentication & Session| Security[Auth & Role Filters]
    Controllers -->|Business Logic| Services[UserService / FlightService]
    Services -->|JDBC SQL| DAO[Data Access Objects]
    DAO -->|Pooled Connection| DB[(MySQL 8.3 Database)]
                            </pre>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="glass-card p-4 h-100 rounded-4">
                        <h5 class="text-white font-heading fw-bold mb-3"><i class="bi bi-shield-lock text-sky-cyan me-2"></i> Authentication Sequence</h5>
                        <div class="mermaid-box p-3 bg-midnight-navy rounded-3 border border-sky-dark overflow-auto">
                            <pre class="mermaid text-center">
sequenceDiagram
    autonumber
    actor User as Passenger
    participant JSP as Login / Google GIS
    participant Servlet as GoogleAuth / LoginServlet
    participant DB as MySQL DB
    participant Session as HTTP Session
    
    User->>JSP: Enter credentials / Click Google Sign-In
    JSP->>Servlet: POST /google-auth (Credential Token)
    Servlet->>Servlet: Verify Google ID Token & CSRF
    Servlet->>DB: Query user by email / google_id
    DB-->>Servlet: Return User record
    Servlet->>Session: Store currentUser & Role (PASSENGER/ADMIN)
    Servlet-->>JSP: JSON Response (redirectUrl = /profile)
    JSP-->>User: Redirect to Passenger Profile
                            </pre>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>

<!-- Mermaid.js for Rendering UML Diagrams -->
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        mermaid.initialize({
            startOnLoad: true,
            theme: 'dark',
            themeVariables: {
                darkMode: true,
                background: '#071A35',
                primaryColor: '#0B2D52',
                primaryTextColor: '#F4F8FC',
                primaryBorderColor: '#56CCF2',
                lineColor: '#56CCF2',
                secondaryColor: '#168BFF',
                tertiaryColor: '#071A35'
            }
        });
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
