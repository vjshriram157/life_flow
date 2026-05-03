<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Terms & Conditions | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .legal-content {
            line-height: 1.8;
            color: var(--text-secondary);
        }
        .legal-content h3 {
            color: var(--text-primary);
            font-weight: 700;
            margin-top: 2.5rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .legal-content h3 i {
            color: var(--primary-crimson);
            font-size: 1.25rem;
        }
        .hero-legal {
            padding: 8rem 0 4rem;
            background: radial-gradient(circle at top left, rgba(225, 29, 72, 0.05), transparent),
                        radial-gradient(circle at bottom right, rgba(30, 41, 59, 0.5), transparent);
        }
    </style>
</head>
<body>

    <%@ include file="/WEB-INF/fragments/header.jspf" %>

    <section class="hero-legal text-center">
        <div class="container fade-in-up">
            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25 px-3 py-2 rounded-pill mb-3">Service Agreement</span>
            <h1 class="display-3 fw-bold text-white mb-3" style="font-family: 'Poppins';">Terms of Service</h1>
            <p class="lead text-secondary mx-auto" style="max-width: 650px;">
                User responsibilities, service scope, and legal limitations of the LifeFlow platform.
            </p>
        </div>
    </section>

    <main class="container pb-5 mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-9">
                <div class="card-premium p-4 p-md-5 fade-in-up delay-100">
                    <div class="legal-content">
                        <p class="mb-5 italic text-white-50">Last Updated: April 21, 2026</p>

                        <h3><i class="fa-solid fa-hospital"></i> 1. Scope of Service</h3>
                        <p>
                            LifeFlow is a digital aggregator and logistics management platform for blood donors and blood banks. We facilitate the discovery of stock levels and donor matches. <strong>LifeFlow is not a medical facility</strong> and does not perform blood extractions or medical procedures directly.
                        </p>

                        <h3><i class="fa-solid fa-user-check"></i> 2. Donor Eligibility</h3>
                        <p>
                            By registering as a donor, you affirm that you satisfy all local health regulations for blood donation, including being of legal age and free from disqualifying medical conditions. You are responsible for ensuring that all medical history snapshots provided to the platform are accurate and truthful.
                        </p>

                        <h3><i class="fa-solid fa-triangle-exclamation"></i> 3. User Conduct</h3>
                        <p>
                            Falsification of blood stock levels, medical history, or emergency broadcast requests is strictly prohibited. Such actions will result in immediate permanent suspension of the account and, where applicable, reporting to local health authorities for endangering public safety.
                        </p>

                        <h3><i class="fa-solid fa-scale-balanced"></i> 4. Limitation of Liability</h3>
                        <p>
                            LifeFlow makes no guarantees regarding the clinical safety or quality of blood stock at individual listed blood banks. Interactions between donors and banks are governed by their respective local laws. LifeFlow is not liable for outcomes resulting from independent clinic practices.
                        </p>

                        <h3><i class="fa-solid fa-link-slash"></i> 5. Termination</h3>
                        <p>
                            We reserve the right to suspend or terminate access to the platform for any user who violates these terms or engages in behavior that compromises the integrity of the donation network.
                        </p>

                        <div class="mt-5 p-4 rounded-4 text-center" style="background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.08);">
                            <p class="mb-0 small text-secondary">
                                Continued use of the platform constitutes acceptance of these terms. For corporate inquiries, contact <a href="mailto:lifeflowad@gmail.com" class="text-danger">lifeflowad@gmail.com</a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="/WEB-INF/fragments/footer.jspf" %>

</body>
</html>
