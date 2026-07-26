<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" translate="no">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MediMart - Your Trusted Medicine Store</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        :root { --primary: #1a56db; --accent: #16bdca; }
        body { font-family: 'Segoe UI', sans-serif; background: #f8fafc; }
        .navbar-brand { font-weight: 800; font-size: 1.5rem; color: var(--primary) !important; }
        .nav-link { font-weight: 500; }
        .sidebar { min-height: calc(100vh - 56px); background: linear-gradient(180deg, #1e3a5f 0%, #1a56db 100%); }
        .sidebar .nav-link { color: rgba(255,255,255,0.85); padding: .6rem 1.2rem; border-radius: 8px; margin: 2px 8px; }
        .sidebar .nav-link:hover, .sidebar .nav-link.active { background: rgba(255,255,255,0.15); color: #fff; }
        .sidebar .nav-link i { width: 22px; }
        .card-hover { transition: transform .2s, box-shadow .2s; }
        .card-hover:hover { transform: translateY(-4px); box-shadow: 0 10px 30px rgba(26,86,219,0.15); }
        .badge-PENDING { background: #fbbf24; color: #1f2937; }
        .badge-PROCESSING { background: #60a5fa; color: #1f2937; }
        .badge-OUT_FOR_DELIVERY { background: #f97316; color: #fff; }
        .badge-DELIVERED { background: #34d399; color: #1f2937; }
        .badge-CANCELLED { background: #f87171; color: #fff; }
        .badge-PAID { background: #34d399; color: #1f2937; }
        .flash-success { background: #d1fae5; border: 1px solid #34d399; color: #065f46; }
        .flash-error { background: #fee2e2; border: 1px solid #f87171; color: #991b1b; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm sticky-top">
    <div class="container-fluid px-4">
        <a class="navbar-brand" href="/"><i class="fas fa-clinic-medical me-2 text-blue-600"></i>MediMart</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navMenu">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <c:if test="${loggedIn && (role == 'USER' || role == 'ADMIN')}">
                    <li class="nav-item"><a class="nav-link" href="/medicines"><i class="fas fa-pills me-1"></i>Order Now</a></li>
                    <li class="nav-item"><a class="nav-link" href="/orders/my"><i class="fas fa-box me-1"></i>My Orders</a></li>
                </c:if>
                <c:if test="${loggedIn && role == 'ADMIN'}">
                    <li class="nav-item"><a class="nav-link" href="/admin/dashboard"><i class="fas fa-tachometer-alt me-1"></i>Admin Panel</a></li>
                </c:if>
            </ul>
            <ul class="navbar-nav ms-auto">
                <c:choose>
                    <c:when test="${loggedIn}">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                                <i class="fas fa-user-circle me-1"></i>${userName}
                                <c:if test="${role != 'GUEST'}">
                                    <span class="badge bg-primary ms-1">${role}</span>
                                </c:if>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item"><a class="nav-link" href="/login">Login</a></li>
                        <li class="nav-item"><a class="btn btn-primary ms-2" href="/register">Register</a></li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>
