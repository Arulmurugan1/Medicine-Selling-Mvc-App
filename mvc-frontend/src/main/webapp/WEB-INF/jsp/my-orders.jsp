<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="loggedIn" value="${true}" />
<%@include file="layout/header.jsp"%>
<div class="container-fluid">
<div class="row">
<div class="col-md-2 p-0 sidebar d-none d-md-block">
    <nav class="nav flex-column pt-3">
        <a class="nav-link" href="/medicines"><i class="fas fa-shopping-cart me-2"></i>Order Now</a>
        <a class="nav-link" href="/cart"><i class="fas fa-cart-shopping me-2"></i>Cart</a>
        <a class="nav-link active" href="/orders/my"><i class="fas fa-box me-2"></i>My Orders</a>
        <hr class="border-white opacity-25 mx-3">
        <a class="nav-link" href="/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
    </nav>
</div>
<div class="col-md-10 p-4">
    <h4 class="fw-bold mb-4"><i class="fas fa-box me-2 text-primary"></i>My Orders</h4>

    <c:if test="${empty orders}">
        <div class="text-center py-5">
            <div style="font-size:5rem;">📦</div>
            <h5 class="text-muted mt-3">No orders yet</h5>
            <a href="/medicines" class="btn btn-primary mt-3">Start Shopping</a>
        </div>
    </c:if>

    <c:forEach var="order" items="${orders}">
    <div class="card border-0 shadow-sm rounded-4 mb-3">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                <div>
                    <h6 class="fw-bold mb-1">Order #${order.id}</h6>
                    <small class="text-muted"><i class="fas fa-calendar me-1"></i>${order.createdAt}</small>
                </div>
                <div class="text-end">
                    <span class="badge rounded-pill px-3 py-2 badge-${order.status}">${order.status}</span>
                    <div class="fw-bold mt-1 text-primary">₹${order.totalAmount}</div>
                </div>
            </div>
            <hr class="my-2">
            <c:forEach var="item" items="${order.items}">
            <div class="d-flex justify-content-between text-sm">
                <span>${item.medicineName} <small class="text-muted">(${item.unitLabel})</small></span>
                <span>x${item.quantity} × ₹${item.unitPrice}</span>
            </div>
            </c:forEach>
            <div class="mt-2">
                <span class="badge bg-light text-dark"><i class="fas fa-truck me-1"></i>Payment: COD</span>
            </div>
        </div>
    </div>
    </c:forEach>
</div>
</div>
</div>
<%@include file="layout/footer.jsp"%>
