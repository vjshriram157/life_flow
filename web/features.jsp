<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Features | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        /* Smooth Premium Animation Tokens */
        .fade-in-up { 
            opacity: 0; 
            transform: translateY(40px); 
            transition: all 0.8s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .fade-in-up.scroll-active { 
            opacity: 1; 
            transform: translateY(0); 
        }

        .features-header {
            padding: 12rem 0 6rem;
            background: radial-gradient(circle at top right, rgba(225, 29, 72, 0.1), transparent),
                        radial-gradient(circle at bottom left, rgba(15, 23, 42, 1), #020617);
            text-align: center;
        }
        
        .section-tag {
            color: var(--primary-crimson);
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
            font-size: 0.85rem;
            margin-bottom: 1rem;
            display: block;
        }

        .showcase-grid {
            padding: 5rem 0;
            background: var(--bg-darker);
        }

        .card-premium {
            background: var(--surface-dark);
            border: var(--border-glass);
            border-radius: var(--radius-lg);
            padding: 3.5rem;
            height: 100%;
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            text-align: left;
        }

        .card-premium:hover {
            transform: translateY(-10px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4), 0 0 30px rgba(225, 29, 72, 0.3);
            border-color: rgba(225, 29, 72, 0.5);
        }

        .icon-box-lg {
            width: 80px;
            height: 80px;
            background: rgba(225, 29, 72, 0.1);
            color: var(--primary-crimson);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            margin-bottom: 2.5rem;
            transition: all 0.3s ease;
        }

        .card-premium:hover .icon-box-lg {
            background: var(--primary-crimson);
            color: white;
            transform: rotate(-5deg);
        }

        .feature-title {
            font-family: 'Poppins', sans-serif;
            color: white;
            font-weight: 700;
            margin-bottom: 1.25rem;
        }

        .feature-desc {
            color: var(--text-secondary);
            font-size: 1rem;
            line-height: 1.7;
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/fragments/header.jspf" %>

<div class="features-header">
    <div class="container fade-in-up">
        <span class="section-tag">Enterprise-Grade Infrastructure</span>
        <h1 class="display-3 fw-bold text-white mb-4" style="font-family: 'Poppins';">Modular Security <span class="text-danger">Grid</span></h1>
        <p class="text-secondary fs-5 mx-auto" style="max-width: 700px;">The autonomous infrastructure designed to eliminate blood shortages through data-driven intelligence.</p>
    </div>
</div>

<main class="showcase-grid">
    <div class="container mb-5 pb-5">
        <div class="row g-4 overflow-hidden">
            
            <!-- Feature 1 -->
            <div class="col-lg-4 col-md-6 fade-in-up delay-100">
                <div class="card-premium">
                    <div class="icon-box-lg">
                        <i class="fa-solid fa-tower-broadcast"></i>
                    </div>
                    <h3 class="feature-title">Emergency Grid</h3>
                    <p class="feature-desc">Hyper-local broadcast system that alerts donors within a 5km radius of a critical patient request, ensuring sub-10 minute response times.</p>
                </div>
            </div>

            <!-- Feature 2 -->
            <div class="col-lg-4 col-md-6 fade-in-up delay-200">
                <div class="card-premium">
                    <div class="icon-box-lg">
                        <i class="fa-solid fa-dna"></i>
                    </div>
                    <h3 class="feature-title">Smart Matching</h3>
                    <p class="feature-desc">Intelligent cross-matching algorithms for rare blood types and high-priority trauma surgeries using AI-driven HLA compatibility checks.</p>
                </div>
            </div>

            <!-- Feature 3 -->
            <div class="col-lg-4 col-md-6 fade-in-up delay-300">
                <div class="card-premium">
                    <div class="icon-box-lg">
                        <i class="fa-solid fa-file-contract"></i>
                    </div>
                    <h3 class="feature-title">Ethical Sourcing</h3>
                    <p class="feature-desc">Strict verification audits to ensure every donation is voluntary and transparently coordinated, preventing any commercialization of human tissue.</p>
                </div>
            </div>

            <!-- Feature 4 -->
            <div class="col-lg-6 col-md-6 fade-in-up delay-100">
                <div class="card-premium">
                    <div class="icon-box-lg">
                        <i class="fa-solid fa-certificate"></i>
                    </div>
                    <h3 class="feature-title">Verified Certificates</h3>
                    <p class="feature-desc">Instant, cryptographic digital certificates for every successful donation. These can be shared with employers or for public record.</p>
                </div>
            </div>

            <!-- Feature 5 -->
            <div class="col-lg-6 col-md-6 fade-in-up delay-200">
                <div class="card-premium">
                    <div class="icon-box-lg">
                        <i class="fa-solid fa-hospital"></i>
                    </div>
                    <h3 class="feature-title">Live Integration</h3>
                    <p class="feature-desc">Direct API connection with hospital management systems (HMS) for real-time stock availability updates and critical shortage alerts.</p>
                </div>
            </div>

        </div>
    </div>
</main>

<%@ include file="/WEB-INF/fragments/footer.jspf" %>

</body>
</html>
