<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register | LifeFlow</title>
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
        .register-container {
            position: relative;
            z-index: 2;
            width: 100%;
            max-width: 650px;
            padding: 2rem 1rem;
        }
        .brand-text span {
            color: var(--primary-crimson);
            font-weight: 800;
        }
        .logo-icon {
            color: var(--primary-crimson);
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
            filter: drop-shadow(0 0 10px rgba(225,29,72,0.4));
        }
        .custom-input-group .input-group-text, 
        .custom-input-group .form-control,
        .custom-input-group .form-select {
            background: rgba(255, 255, 255, 0.05);
            border-color: rgba(255, 255, 255, 0.1);
            color: white;
        }
        .custom-input-group .form-control:focus,
        .custom-input-group .form-select:focus {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--primary-crimson);
            box-shadow: 0 0 0 4px rgba(225, 29, 72, 0.1);
        }
        .custom-input-group .form-control::placeholder {
            color: rgba(255, 255, 255, 0.4);
        }
        .custom-input-group .form-select option {
            background: #0f172a;
            color: white;
        }
        @media (max-width: 576px) {
            .register-container {
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
<div class="register-container fade-in-up">
    <div class="card text-white p-2 p-md-4" style="background-color: rgba(15, 23, 42, 0.95); border: 1px solid rgba(255,255,255,0.1); border-radius: 1.5rem; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);">
        <div class="card-body">
            <div class="text-center mb-4">
                <i class="fa-solid fa-heart-pulse logo-icon"></i>
                <div class="brand-text h3 mb-2">Join <span>LifeFlow</span></div>
                <p class="text-white-50" style="font-size: 0.95rem;">
                    Create your profile to start saving lives today.
                </p>
            </div>

            <% String error=(String) request.getAttribute("error"); if (error !=null) { %>
            <div class="alert alert-danger bg-transparent border-danger text-danger d-flex align-items-center mb-4">
                <i class="fa-solid fa-triangle-exclamation me-2"></i> <%= error %>
            </div>
            <% } %>

            <form method="post" action="<%= request.getContextPath() %>/RegisterServlet" novalidate>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="fullName" class="form-label text-white-50">Full Name</label>
                        <div class="input-group custom-input-group">
                            <span class="input-group-text border-end-0"><i class="fa-solid fa-user text-white-50"></i></span>
                            <input type="text" class="form-control border-start-0" id="fullName" name="fullName" required placeholder="John Doe">
                        </div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="email" class="form-label text-white-50">Email</label>
                        <div class="input-group custom-input-group">
                            <span class="input-group-text border-end-0"><i class="fa-solid fa-envelope text-white-50"></i></span>
                            <input type="email" class="form-control border-start-0" id="email" name="email" required placeholder="name@example.com">
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="phone" class="form-label text-white-50">Phone</label>
                        <div class="input-group custom-input-group">
                            <span class="input-group-text border-end-0"><i class="fa-solid fa-phone text-white-50"></i></span>
                            <input type="text" class="form-control border-start-0" id="phone" name="phone" placeholder="+1 234 567 8900">
                        </div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="city" class="form-label text-white-50">City</label>
                        <div class="input-group custom-input-group">
                            <span class="input-group-text border-end-0"><i class="fa-solid fa-map-location-dot text-white-50"></i></span>
                            <input type="text" class="form-control border-start-0" id="city" name="city" placeholder="New York">
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="password" class="form-label text-white-50">Password</label>
                        <div class="input-group custom-input-group">
                            <span class="input-group-text border-end-0"><i class="fa-solid fa-lock text-white-50"></i></span>
                            <input type="password" class="form-control border-start-0" id="password" name="password" required minlength="6" placeholder="••••••••">
                        </div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="confirmPassword" class="form-label text-white-50">Confirm Password</label>
                        <div class="input-group custom-input-group">
                            <span class="input-group-text border-end-0"><i class="fa-solid fa-check-double text-white-50"></i></span>
                            <input type="password" class="form-control border-start-0" id="confirmPassword" name="confirmPassword" required minlength="6" placeholder="••••••••">
                        </div>
                    </div>
                </div>

                <div class="row mb-4">
                    <div class="col-md-6 mb-3 mb-md-0">
                        <label for="bloodGroup" class="form-label text-white-50">Blood Group</label>
                        <div class="input-group custom-input-group">
                            <span class="input-group-text border-end-0"><i class="fa-solid fa-droplet text-white-50"></i></span>
                            <select class="form-select border-start-0" id="bloodGroup" name="bloodGroup">
                                <option value="">Select Group</option>
                                <option value="A+">A+</option>
                                <option value="A-">A-</option>
                                <option value="B+">B+</option>
                                <option value="B-">B-</option>
                                <option value="O+">O+</option>
                                <option value="O-">O-</option>
                                <option value="AB+">AB+</option>
                                <option value="AB-">AB-</option>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label for="role" class="form-label text-white-50">Account Type</label>
                        <div class="input-group custom-input-group">
                            <span class="input-group-text border-end-0"><i class="fa-solid fa-user-tag text-white-50"></i></span>
                            <select class="form-select border-start-0" id="role" name="role" required>
                                <option value="DONOR">Donor</option>
                                <option value="BANK">Blood Bank (Requires Approval)</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="d-grid mt-2">
                    <button type="submit" class="btn btn-premium py-3 fs-6">
                        <i class="fa-solid fa-user-plus me-2"></i> Create Account
                    </button>
                </div>
            </form>

            <div class="text-center mt-4">
                <span class="text-white-50">Already registered?</span>
                <a href="<%= request.getContextPath() %>/login.jsp" class="text-decoration-none fw-bold ms-1" style="color: var(--primary-light);">Sign in here</a>
            </div>
        </div>
    </div>
</div>
<script>
    document.addEventListener("DOMContentLoaded", function() {
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
    });
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>