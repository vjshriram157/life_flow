<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign In | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: url('https://images.unsplash.com/photo-1615461066841-6116e61058f4?auto=format&fit=crop&q=80&w=2000') no-repeat center center;
            background-size: cover;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }
        .overlay {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.85);
            z-index: 1;
        }
        .login-container {
            position: relative;
            z-index: 2;
            width: 100%;
            max-width: 480px;
            padding: 1rem;
        }
        .brand-text span {
            color: var(--primary-crimson);
            font-weight: 800;
        }
        .logo-icon {
            color: var(--primary-crimson);
            font-size: 2.5rem;
            margin-bottom: 1rem;
            filter: drop-shadow(0 0 10px rgba(225,29,72,0.4));
        }
        .custom-input-group .input-group-text, 
        .custom-input-group .form-control {
            background: rgba(255, 255, 255, 0.05);
            border-color: rgba(255, 255, 255, 0.1);
            color: white;
        }
        .custom-input-group .form-control:focus {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--primary-crimson);
            box-shadow: 0 0 0 4px rgba(225, 29, 72, 0.1);
        }
        .custom-input-group .form-control::placeholder {
            color: rgba(255, 255, 255, 0.4);
        }
        @media (max-width: 576px) {
            .login-container {
                padding: 1.5rem;
            }
            .card {
                border-radius: 1rem !important;
            }
            .brand-text {
                font-size: 1.5rem !important;
            }
            .logo-icon {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
<div class="overlay"></div>
<div class="login-container fade-in-up">
    <div class="card text-white p-2 p-md-4" style="background-color: rgba(15, 23, 42, 0.95); border: 1px solid rgba(255,255,255,0.1); border-radius: 1.5rem; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);">
        <div class="card-body">
            <div class="text-center mb-4">
                <i class="fa-solid fa-truck-medical logo-icon"></i>
                <div class="brand-text h3 mb-2">Welcome to <span>LifeFlow</span></div>
                <p class="text-white-50" style="font-size: 0.95rem;">
                    Securely access your Admin, Donor, or Bank dashboard.
                </p>
            </div>

            <%
                String error = (String) request.getAttribute("error");
                String registered = request.getParameter("registered");
                if (registered != null) {
            %>
            <div class="alert alert-success bg-transparent border-success text-success d-flex align-items-center mb-4">
                <i class="fa-solid fa-circle-check me-2"></i> Registration successful. Pending approval.
            </div>
            <%
                }
                if (error != null) {
            %>
            <div class="alert alert-danger bg-transparent border-danger text-danger d-flex align-items-center mb-4">
                <i class="fa-solid fa-triangle-exclamation me-2"></i> <%= error %>
            </div>
            <%
                }
            %>

            <form method="post" action="<%= request.getContextPath() %>/LoginServlet" novalidate>
                <div class="mb-4">
                    <label for="email" class="form-label text-white-50">Email Address</label>
                    <div class="input-group custom-input-group">
                        <span class="input-group-text border-end-0">
                            <i class="fa-solid fa-envelope text-white-50"></i>
                        </span>
                        <input type="email" class="form-control border-start-0" 
                               id="email" name="email" required autofocus placeholder="name@example.com">
                    </div>
                </div>
                
                <div class="mb-2">
                    <label class="form-label text-white-50 small fw-bold tracking-wide">PASSWORD</label>
                    <div class="input-group custom-input-group">
                        <span class="input-group-text border-end-0"><i class="fa-solid fa-lock"></i></span>
                        <input type="password" id="passwordField" name="password" class="form-control border-start-0 border-end-0 ps-0" placeholder="••••••••" required>
                        <span class="input-group-text border-start-0" id="togglePassword" style="cursor: pointer;">
                            <i class="fa-regular fa-eye text-white-50" id="toggleIcon"></i>
                        </span>
                    </div>
                </div>
                
                <div class="text-end mb-4">
                    <a href="forgotPassword.jsp" class="text-danger text-decoration-none small fw-bold hover-white" style="transition: color 0.3s ease;">Forgot Password?</a>
                </div>

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="form-check">
                        <input class="form-check-input bg-transparent border-secondary" type="checkbox" id="rememberMe">
                        <label class="form-check-label text-white-50" for="rememberMe" style="font-size: 0.9rem;">Remember me</label>
                    </div>
                    <a href="<%= request.getContextPath() %>/register.jsp" class="text-decoration-none fw-bold" style="color: var(--primary-light); font-size: 0.9rem;">Create account</a>
                </div>
                
                <div class="d-grid mt-2">
                    <button type="submit" id="loginBtn" class="btn btn-premium py-3 fs-6">
                        <i class="fa-solid fa-arrow-right-to-bracket me-2"></i> 
                        <span class="btn-text">Sign In to Dashboard</span>
                        <span class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // --- Password Toggle Logic ---
        const togglePassword = document.getElementById('togglePassword');
        const passwordField = document.getElementById('passwordField');
        const toggleIcon = togglePassword ? togglePassword.querySelector('i') : null;

        if (togglePassword && passwordField) {
            togglePassword.addEventListener('click', function() {
                if (passwordField.type === 'password') {
                    passwordField.type = 'text';
                    toggleIcon.classList.remove('fa-eye');
                    toggleIcon.classList.add('fa-eye-slash');
                } else {
                    passwordField.type = 'password';
                    toggleIcon.classList.remove('fa-eye-slash');
                    toggleIcon.classList.add('fa-eye');
                }
            });
        }

        // --- Premium Scroll Reveal ---
        const observerOptions = { threshold: 0.1 };
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('scroll-active');
                }
            });
        }, observerOptions);

        document.querySelectorAll('.fade-in-up').forEach(el => observer.observe(el));

        // --- Login Loading State ---
        const loginForm = document.querySelector('form');
        const loginBtn = document.getElementById('loginBtn');
        if (loginForm && loginBtn) {
            loginForm.addEventListener('submit', function() {
                const btnText = loginBtn.querySelector('.btn-text');
                const spinner = loginBtn.querySelector('.spinner-border');
                const icon = loginBtn.querySelector('.fa-arrow-right-to-bracket');
                
                if (btnText && spinner) {
                    btnText.textContent = 'Authenticating...';
                    spinner.classList.remove('d-none');
                    if (icon) icon.classList.add('d-none');
                    loginBtn.disabled = true;
                }
            });
        }
    });
</script>
</body>
</html>
