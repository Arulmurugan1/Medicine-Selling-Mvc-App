<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" translate="no">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - MediMart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { background: linear-gradient(135deg, #1e3a5f 0%, #1a56db 100%); min-height: 100vh; display: flex; align-items: center; }
        .card { border: none; border-radius: 20px; }
        .btn-primary { background: linear-gradient(135deg, #1a56db, #16bdca); border: none; }
        .form-control:focus { border-color: #1a56db; box-shadow: 0 0 0 3px rgba(26,86,219,0.15); }
    </style>
</head>
<body>
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="text-center mb-4">
                <h2 class="text-white fw-bold"><i class="fas fa-clinic-medical me-2"></i>MediMart</h2>
                <p class="text-white-50">Your trusted medicine store</p>
            </div>
            <div class="card shadow-lg p-4">
                <h4 class="fw-bold mb-1">Welcome back!</h4>
                <p class="text-muted small mb-4">Sign in to your account</p>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger rounded-3"><i class="fas fa-exclamation-circle me-2"></i>${error}</div>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="alert alert-success rounded-3"><i class="fas fa-check-circle me-2"></i>${success}</div>
                </c:if>

                <form method="post" action="/login">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fas fa-envelope text-muted"></i></span>
                            <input type="email" name="email" class="form-control" placeholder="you@example.com" autocomplete="off" required>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-semibold">Password</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fas fa-lock text-muted"></i></span>
                            <input type="password" name="password" class="form-control" placeholder="Enter the Password" autocomplete="new-password" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold">
                        <i class="fas fa-sign-in-alt me-2"></i>Sign In
                    </button>
                </form>

                <hr class="my-4">
                <p class="text-center text-muted mb-0">
                    Don't have an account? <a href="/register" class="text-primary fw-semibold">Register now</a>
                </p>
            </div>
        </div>
    </div>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
