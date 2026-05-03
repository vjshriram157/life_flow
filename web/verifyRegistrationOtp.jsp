<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Verify Email | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <style>
        body {
            background: url('<%=request.getContextPath()%>/assets/images/hero-bg.jpg') no-repeat center center/cover;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }
        .overlay {
            position: absolute;
            top: 0; left: 0; width: 100%; height: 100%;
            background: linear-gradient(135deg, rgba(15, 23, 42, 0.95) 0%, rgba(225, 29, 72, 0.8) 100%);
            z-index: 1;
        }
        .login-container {
            z-index: 2;
            width: 100%;
            max-width: 450px;
            padding: 15px;
        }
        .logo-icon {
            font-size: 3rem;
            color: var(--primary-crimson);
            margin-bottom: 1rem;
        }
        .otp-input {
            letter-spacing: 5px;
            font-weight: bold;
            text-align: center;
            font-size: 1.25rem;
        }
        @media (max-width: 576px) {
            .login-container {
                padding: 1.5rem;
            }
            .card {
                border-radius: 1rem !important;
            }
            .logo-icon {
                font-size: 2.5rem;
            }
            h3.fw-bold {
                font-size: 1.5rem;
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
                <i class="fa-solid fa-envelope-circle-check logo-icon"></i>
                <h3 class="fw-bold">Verify Email</h3>
                <p class="text-white-50 small">Enter the 6-digit OTP sent to <strong><%= request.getParameter("email") != null ? request.getParameter("email") : "your email" %></strong> to complete your registration.</p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger bg-danger text-white border-0 py-2"><i class="fa-solid fa-circle-exclamation me-2"></i> <%= request.getAttribute("error") %></div>
            <% } %>

            <form action="<%=request.getContextPath()%>/VerifyRegistrationServlet" method="post">
                <input type="hidden" name="email" value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
                
                <div class="mb-5 mt-2">
                    <label class="form-label text-white-50 small fw-bold tracking-wide">6-DIGIT OTP</label>
                    <div class="input-group">
                        <span class="input-group-text bg-transparent border-secondary text-white-50"><i class="fa-solid fa-hashtag"></i></span>
                        <input type="text" name="otp" class="form-control bg-transparent border-secondary text-white otp-input" maxlength="6" required autocomplete="off">
                    </div>
                </div>

                <button type="submit" class="btn btn-premium w-100 py-3 mb-2 rounded-3 fw-bold">Verify & Complete Registration</button>
            </form>
            
        </div>
    </div>
</div>
</body>
</html>
