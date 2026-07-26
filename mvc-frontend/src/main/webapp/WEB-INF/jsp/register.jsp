<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" translate="no">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - MediMart</title>
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
<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="text-center mb-4">
                <h2 class="text-white fw-bold"><i class="fas fa-clinic-medical me-2"></i>MediMart</h2>
                <p class="text-white-50">Create your account in seconds</p>
            </div>
            <div class="card shadow-lg p-4">
                <h4 class="fw-bold mb-1">Create Account</h4>
                <p class="text-muted small mb-4">Join thousands of customers</p>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger rounded-3"><i class="fas fa-exclamation-circle me-2"></i>${error}</div>
                </c:if>

                <form method="post" action="/register">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Full Name</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fas fa-user text-muted"></i></span>
                            <input type="text" name="name" class="form-control" placeholder="John Doe" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fas fa-envelope text-muted"></i></span>
                            <input type="email" name="email" class="form-control" placeholder="you@example.com" required>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-semibold">Password <small class="text-muted">(min. 6 chars)</small></label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fas fa-lock text-muted"></i></span>
                            <input type="password" name="password" class="form-control" placeholder="••••••••" required minlength="6">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold">
                        <i class="fas fa-user-plus me-2"></i>Create Account
                    </button>
                </form>

                <hr class="my-4">
                <p class="text-center text-muted mb-0">
                    Already have an account? <a href="/login" class="text-primary fw-semibold">Sign in</a>
                </p>
            </div>
        </div>
    </div>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
