<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Support Center | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .contact-header {
            padding: 10rem 0 5rem;
            background: linear-gradient(180deg, #020617 0%, var(--bg-dark) 100%);
            text-align: center;
        }
        .accent-pill {
            background: rgba(225, 29, 72, 0.15);
            color: var(--primary-crimson);
            border-radius: var(--radius-pill);
            padding: 0.5rem 1.2rem;
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        .support-card {
            background: var(--surface-dark);
            border: var(--border-glass);
            border-radius: var(--radius-lg);
            padding: 2.5rem;
            height: 100%;
            transition: var(--transition-premium);
        }
        .support-card:hover {
            transform: translateY(-5px);
            border-color: rgba(225, 29, 72, 0.3);
        }
        .contact-form-card {
            background: var(--surface-dark);
            border: var(--border-glass);
            border-radius: var(--radius-lg);
            padding: 3rem;
            height: 100%;
        }
        .form-label-premium {
            color: var(--text-secondary);
            font-weight: 600;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 0.75rem;
            display: block;
        }
        .form-control-premium {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 1rem 1.25rem;
            color: white;
            transition: var(--transition-premium);
            width: 100%;
        }
        .form-control-premium:focus {
            background: rgba(255, 255, 255, 0.05);
            border-color: var(--primary-crimson);
            box-shadow: 0 0 0 4px rgba(225, 29, 72, 0.1);
            outline: none;
        }
        .success-banner {
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.2);
            color: #10b981;
            padding: 1rem 1.5rem;
            border-radius: 12px;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 2rem;
            font-weight: 600;
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/fragments/header.jspf" %>

<div class="contact-header">
    <div class="container fade-in-up">
        <div class="accent-pill mb-4">
            <i class="fa-solid fa-headset"></i> <fmt:message key="nav.contact_tag" />
        </div>
        <h1 class="display-3 fw-bold text-white mb-4" style="font-family: 'Poppins';"><fmt:message key="nav.contact_title" /></h1>
        <p class="text-secondary fs-5 mx-auto" style="max-width: 650px;"><fmt:message key="nav.contact_subtitle" /></p>
    </div>
</div>

<main class="container mb-5 pb-5">
    <div class="row g-4 fade-in-up delay-100">
        
        <div class="col-lg-4">
            <div class="row g-4">
                <div class="col-12">
                    <div class="support-card">
                        <div class="icon-circle mb-4">
                            <i class="fa-solid fa-envelope"></i>
                        </div>
                        <h4 class="text-white fw-bold mb-2"><fmt:message key="nav.email_us" /></h4>
                        <p class="text-danger fw-bold mb-2">lifeflowad@gmail.com</p>
                        <p class="text-secondary small mb-0"><fmt:message key="nav.email_text" /></p>
                    </div>
                </div>
                <div class="col-12">
                    <div class="support-card">
                        <div class="icon-circle mb-4">
                            <i class="fa-solid fa-phone"></i>
                        </div>
                        <h4 class="text-white fw-bold mb-2"><fmt:message key="nav.hotline" /></h4>
                        <p class="text-danger fw-bold mb-2">1800-LIFE-FLOW</p>
                        <p class="text-secondary small mb-0"><fmt:message key="nav.hotline_text" /></p>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="contact-form-card">
                <c:if test="${not empty param.success}">
                    <div class="success-banner">
                        <i class="fa-solid fa-circle-check"></i>
                        <fmt:message key="nav.success_msg" />
                    </div>
                </c:if>

                <form action="SupportServlet" method="post">
                    <div class="row g-4">
                        <div class="col-md-6">
                            <label class="form-label-premium"><fmt:message key="nav.form.name" /></label>
                            <input type="text" name="name" class="form-control-premium" placeholder="John Doe" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-premium"><fmt:message key="nav.form.email" /></label>
                            <input type="email" name="email" class="form-control-premium" placeholder="john@example.com" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label-premium"><fmt:message key="nav.form.help" /></label>
                            <textarea name="message" class="form-control-premium" rows="5" placeholder="Describe your request or issue..." required></textarea>
                        </div>
                        <div class="col-12 mt-4">
                            <button type="submit" class="btn btn-join py-3 w-100 fs-5">
                                <fmt:message key="nav.form.btn" />
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

    </div>
</main>

<%@ include file="/WEB-INF/fragments/footer.jspf" %>

</body>
</html>
