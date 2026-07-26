<div class="sidebar d-flex flex-column" style="width:240px;min-width:240px;min-height:calc(100vh - 56px);">
    <div class="p-3 pb-2 border-bottom border-white border-opacity-25">
        <small class="text-white-50 text-uppercase fw-semibold" style="font-size:.7rem;letter-spacing:.08em;">Admin Dashboard</small>
    </div>
    <nav class="flex-grow-1 py-2">
        <a class="nav-link" href="/admin/dashboard"><i class="fas fa-tachometer-alt"></i> Dashboard</a>
        <a class="nav-link" href="/admin/orders"><i class="fas fa-clipboard-list"></i> Customer Orders</a>
        <a class="nav-link" href="/admin/orders?status=PENDING"><i class="fas fa-hourglass-half"></i> Pending Orders</a>
        <a class="nav-link" href="/admin/orders?status=OUT_FOR_DELIVERY"><i class="fas fa-truck"></i> Pending Delivery</a>
        <a class="nav-link" href="/admin/orders?status=DELIVERED"><i class="fas fa-check-circle"></i> Completed Orders</a>
        <a class="nav-link" href="/admin/medicines"><i class="fas fa-pills"></i> Medicines</a>
        <a class="nav-link" href="/admin/skus"><i class="fas fa-tags"></i> SKU Manager</a>
        <a class="nav-link" href="/admin/payments"><i class="fas fa-credit-card"></i> Payment Info</a>
        <a class="nav-link" href="/admin/customers"><i class="fas fa-users"></i> Customers</a>
        <a class="nav-link" href="/admin/users"><i class="fas fa-user-shield"></i> Users</a>
        <a class="nav-link" href="/admin/audit-log"><i class="fas fa-search"></i> Audit Log</a>
    </nav>
    <div class="p-2 border-top border-white border-opacity-25">
        <a class="nav-link text-danger-emphasis" href="/logout"
           style="background:rgba(255,255,255,0.08);border-radius:8px;">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</div>
