<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@include file="../layout/header.jsp"%>
<style>
    .admin-card { border: none; border-radius: 20px; transition: transform .2s, box-shadow .2s; cursor: pointer; }
    .admin-card:hover { transform: translateY(-5px); box-shadow: 0 15px 35px rgba(26,86,219,.18); }
    .admin-card .icon { font-size: 2.5rem; margin-bottom: .75rem; }
</style>
<div class="container-fluid p-4">
    <div class="mb-4">
        <h4 class="fw-bold mb-0"><i class="fas fa-tachometer-alt me-2 text-primary"></i>Admin Dashboard</h4>
        <p class="text-muted">Welcome back, <strong>${userName}</strong> — here's your control panel</p>
    </div>

    <div class="row g-4">
        <div class="col-md-3 col-sm-6">
            <a href="/medicines" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#dbeafe,#eff6ff);">
                <div class="icon">🛒</div>
                <h6 class="fw-bold text-blue-800">Order Now</h6>
                <p class="text-muted small mb-0">Browse & place new orders</p>
            </div></a>
        </div>
        <div class="col-md-3 col-sm-6">
            <a href="/admin/orders" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#fef3c7,#fffbeb);">
                <div class="icon">📋</div>
                <h6 class="fw-bold text-yellow-800">Customer Orders</h6>
                <p class="text-muted small mb-0">View all customer orders</p>
            </div></a>
        </div>
        <div class="col-md-3 col-sm-6">
            <a href="/admin/orders?status=PENDING" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#fce7f3,#fdf2f8);">
                <div class="icon">⏳</div>
                <h6 class="fw-bold text-pink-800">Pending Orders</h6>
                <p class="text-muted small mb-0">Orders awaiting processing</p>
            </div></a>
        </div>
        <div class="col-md-3 col-sm-6">
            <a href="/admin/orders?status=OUT_FOR_DELIVERY" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#fed7aa,#fff7ed);">
                <div class="icon">🚚</div>
                <h6 class="fw-bold text-orange-800">Pending Delivery</h6>
                <p class="text-muted small mb-0">Orders out for delivery</p>
            </div></a>
        </div>
        <div class="col-md-3 col-sm-6">
            <a href="/admin/orders?status=DELIVERED" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#d1fae5,#ecfdf5);">
                <div class="icon">✅</div>
                <h6 class="fw-bold text-green-800">Completed Orders</h6>
                <p class="text-muted small mb-0">Successfully delivered</p>
            </div></a>
        </div>
        <div class="col-md-3 col-sm-6">
            <a href="/admin/payments" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#ede9fe,#f5f3ff);">
                <div class="icon">💳</div>
                <h6 class="fw-bold text-purple-800">Payment Info</h6>
                <p class="text-muted small mb-0">COD payment records</p>
            </div></a>
        </div>
        <div class="col-md-3 col-sm-6">
            <a href="/admin/customers" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#e0f2fe,#f0f9ff);">
                <div class="icon">👥</div>
                <h6 class="fw-bold text-sky-800">Customers</h6>
                <p class="text-muted small mb-0">Manage customer records</p>
            </div></a>
        </div>
        <div class="col-md-3 col-sm-6">
            <a href="/admin/users" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#fef2f2,#fff5f5);">
                <div class="icon">🔑</div>
                <h6 class="fw-bold text-red-800">Users</h6>
                <p class="text-muted small mb-0">Manage registered users</p>
            </div></a>
        </div>
        <div class="col-md-3 col-sm-6">
            <a href="/admin/medicines" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#f0fdf4,#dcfce7);">
                <div class="icon">💊</div>
                <h6 class="fw-bold text-green-800">Medicines</h6>
                <p class="text-muted small mb-0">Add & manage medicine catalog</p>
            </div></a>
        </div>
        <div class="col-md-3 col-sm-6">
            <a href="/admin/skus" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#f0f9ff,#e0f2fe);">
                <div class="icon">🏷️</div>
                <h6 class="fw-bold text-blue-800">SKU Manager</h6>
                <p class="text-muted small mb-0">Manage SKUs & stock</p>
            </div></a>
        </div>
        <div class="col-md-3 col-sm-6">
            <a href="/admin/audit-log" class="text-decoration-none">
            <div class="card admin-card p-4 text-center" style="background:linear-gradient(135deg,#f9fafb,#f3f4f6);">
                <div class="icon">🔍</div>
                <h6 class="fw-bold text-gray-800">Audit Log</h6>
                <p class="text-muted small mb-0">Track all admin actions</p>
            </div></a>
        </div>
    </div>
</div>
<%@include file="../layout/footer.jsp"%>
