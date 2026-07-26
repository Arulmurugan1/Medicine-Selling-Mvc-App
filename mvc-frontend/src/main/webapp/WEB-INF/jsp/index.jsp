<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" translate="no">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MediMart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #f8fafc; }
        .navbar-brand { font-weight: 800; font-size: 1.5rem; }
        .hero { background: linear-gradient(135deg, #1e3a5f 0%, #1a56db 50%, #16bdca 100%); min-height: 100vh; }
        .card-hover { transition: transform .3s, box-shadow .3s; }
        .card-hover:hover { transform: translateY(-6px); box-shadow: 0 20px 40px rgba(26,86,219,0.2); }
        .feature-icon { width: 64px; height: 64px; border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg bg-white shadow-sm sticky-top">
    <div class="container">
        <a class="navbar-brand text-primary fw-bold" href="/"><i class="fas fa-clinic-medical me-2"></i>MediMart</a>
        <div class="ms-auto d-flex gap-2">
            <c:choose>
                <c:when test="${loggedIn}">
                    <a href="/medicines" class="btn btn-outline-primary">Browse Medicines</a>
                    <a href="/logout" class="btn btn-secondary">Logout</a>
                </c:when>
                <c:otherwise>
                    <a href="/login" class="btn btn-outline-primary">Login</a>
                    <a href="/register" class="btn btn-primary">Get Started</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>

<!-- Hero Section -->
<section class="hero d-flex align-items-center">
    <div class="container text-white py-5">
        <div class="row align-items-center">
            <div class="col-lg-6">
                <span class="badge bg-light text-primary mb-3 px-3 py-2 fs-6">
                    <i class="fas fa-shield-alt me-1"></i> Trusted & Certified
                </span>
                <h1 class="display-4 fw-bold mb-4">Your Health, <br>Our Priority</h1>
                <p class="lead mb-4 opacity-90">
                    Order genuine medicines online with fast delivery. 
                    Safe, affordable, and delivered to your doorstep.
                </p>
                <div class="d-flex gap-3 flex-wrap">
                    <c:choose>
                        <c:when test="${loggedIn}">
                            <a href="/medicines" class="btn btn-light btn-lg fw-semibold px-5">
                                <i class="fas fa-shopping-cart me-2"></i>Order Now
                            </a>
                            <c:if test="${role == 'GUEST'}">
                                <a href="/orders/my" class="btn btn-outline-light btn-lg px-5">
                                    <i class="fas fa-box me-2"></i>View Orders
                                </a>
                            </c:if>
                            <c:if test="${role == 'ADMIN'}">
                                <a href="/admin/dashboard" class="btn btn-outline-light btn-lg px-5">
                                    <i class="fas fa-tachometer-alt me-2"></i>Dashboard
                                </a>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <a href="/register" class="btn btn-light btn-lg fw-semibold px-5">
                                <i class="fas fa-user-plus me-2"></i>Register Free
                            </a>
                            <a href="/login" class="btn btn-outline-light btn-lg px-5">
                                <i class="fas fa-sign-in-alt me-2"></i>Login
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="col-lg-6 text-center mt-5 mt-lg-0">
                <div style="font-size: 12rem; opacity: 0.25;"><i class="fas fa-pills text-primary"></i></div>
            </div>
        </div>
    </div>
</section>

<!-- Features Section -->
<section class="py-5 bg-white">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="fw-bold text-dark">Why Choose MediMart?</h2>
            <p class="text-muted">Trusted by thousands of customers</p>
        </div>
        <div class="row g-4">
            <div class="col-md-3">
                <div class="card border-0 shadow-sm h-100 card-hover p-4 text-center">
                    <div class="feature-icon bg-blue-100 mx-auto mb-3"><i class="fas fa-hospital text-primary" style="font-size:2rem;"></i></div>
                    <h5 class="fw-bold">Genuine Medicines</h5>
                    <p class="text-muted small">100% authentic, certified and quality-checked medicines</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm h-100 card-hover p-4 text-center">
                    <div class="feature-icon bg-green-100 mx-auto mb-3"><i class="fas fa-truck text-success" style="font-size:2rem;"></i></div>
                    <h5 class="fw-bold">Fast Delivery</h5>
                    <p class="text-muted small">Doorstep delivery with real-time order tracking</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm h-100 card-hover p-4 text-center">
                    <div class="feature-icon bg-purple-100 mx-auto mb-3"><i class="fas fa-tag text-purple" style="font-size:2rem;color:#7c3aed;"></i></div>
                    <h5 class="fw-bold">Best Prices</h5>
                    <p class="text-muted small">Competitive pricing with no hidden charges</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm h-100 card-hover p-4 text-center">
                    <div class="feature-icon bg-yellow-100 mx-auto mb-3"><i class="fas fa-lock text-warning" style="font-size:2rem;"></i></div>
                    <h5 class="fw-bold">Secure & Private</h5>
                    <p class="text-muted small">Your health data is always private and secure</p>
                </div>
            </div>
        </div>
    </div>
</section>

<footer class="bg-dark text-white py-4 mt-auto">
    <div class="container text-center">
        <p class="mb-0">&copy; 2024 MediMart. All rights reserved. &nbsp;|&nbsp;
            <a href="/login" class="text-info text-decoration-none">Login</a> &nbsp;|&nbsp;
            <a href="/register" class="text-info text-decoration-none">Register</a>
        </p>
    </div>
</footer>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
