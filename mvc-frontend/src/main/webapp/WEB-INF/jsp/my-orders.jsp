<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="loggedIn" value="${true}" />
<%@include file="layout/header.jsp"%>

<%-- ===== Order Status Popup ===== --%>
<c:if test="${not empty success or not empty error}">
<div id="orderStatusOverlay" style="
    position:fixed;inset:0;background:rgba(0,0,0,.55);z-index:9999;
    display:flex;align-items:center;justify-content:center;">
  <div style="
      background:#fff;border-radius:20px;padding:48px 56px;
      text-align:center;max-width:420px;width:90%;
      box-shadow:0 24px 64px rgba(0,0,0,.25);
      animation:popIn .35s cubic-bezier(.34,1.56,.64,1);">

    <c:choose>
      <c:when test="${not empty success}">
        <%-- Green success tick --%>
        <div style="width:90px;height:90px;border-radius:50%;background:#e8f5e9;
                    display:flex;align-items:center;justify-content:center;margin:0 auto 20px;">
          <svg viewBox="0 0 52 52" width="56" height="56">
            <circle cx="26" cy="26" r="25" fill="none" stroke="#43a047" stroke-width="3"/>
            <path fill="none" stroke="#43a047" stroke-width="4"
                  stroke-linecap="round" stroke-linejoin="round"
                  d="M14 27 l9 9 l16-18" style="stroke-dasharray:40;stroke-dashoffset:0;
                     animation:drawCheck .5s .2s ease forwards;"/>
          </svg>
        </div>
        <h4 style="color:#2e7d32;font-weight:700;margin-bottom:8px;">Order Placed!</h4>
        <p style="color:#555;margin-bottom:6px;">${success}</p>
        <p style="color:#43a047;font-size:.85rem;">
          <i class="fas fa-truck me-1"></i>Your order is being processed.
        </p>
      </c:when>
      <c:otherwise>
        <%-- Red failure mark --%>
        <div style="width:90px;height:90px;border-radius:50%;background:#ffebee;
                    display:flex;align-items:center;justify-content:center;margin:0 auto 20px;">
          <svg viewBox="0 0 52 52" width="56" height="56">
            <circle cx="26" cy="26" r="25" fill="none" stroke="#e53935" stroke-width="3"/>
            <line x1="16" y1="16" x2="36" y2="36" stroke="#e53935" stroke-width="4"
                  stroke-linecap="round"/>
            <line x1="36" y1="16" x2="16" y2="36" stroke="#e53935" stroke-width="4"
                  stroke-linecap="round"/>
          </svg>
        </div>
        <h4 style="color:#c62828;font-weight:700;margin-bottom:8px;">Order Failed</h4>
        <p style="color:#555;margin-bottom:6px;">${error}</p>
        <p style="color:#e53935;font-size:.85rem;">Please try again or contact support.</p>
      </c:otherwise>
    </c:choose>

    <button onclick="closeOrderPopup()"
            style="margin-top:20px;padding:10px 32px;border:none;border-radius:50px;
                   background:#1565c0;color:#fff;font-weight:600;font-size:.95rem;cursor:pointer;">
      OK
    </button>
  </div>
</div>
<style>
@keyframes popIn{from{transform:scale(.6);opacity:0}to{transform:scale(1);opacity:1}}
</style>
<script>
function closeOrderPopup(){document.getElementById('orderStatusOverlay').remove();}
setTimeout(closeOrderPopup, 5000);
</script>
</c:if>
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
<div class="col-md-10 p-4 d-flex flex-column" style="height:calc(100vh - 56px);overflow:hidden;">
    <h4 class="fw-bold mb-4 flex-shrink-0"><i class="fas fa-box me-2 text-primary"></i>My Orders</h4>

    <c:if test="${empty orders}">
        <div class="text-center py-5">
            <div><i class="fas fa-box-open text-muted" style="font-size:5rem;"></i></div>
            <h5 class="text-muted mt-3">No orders yet</h5>
            <a href="/medicines" class="btn btn-primary mt-3">Start Shopping</a>
        </div>
    </c:if>

    <div class="flex-grow-1 overflow-auto pe-1">
    <c:forEach var="order" items="${orders}">
    <div class="card border-0 shadow-sm rounded-4 mb-3" data-order-id="${order.id}">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                <div>
                    <h6 class="fw-bold mb-1">Order #${order.id}</h6>
                    <small class="text-muted"><i class="fas fa-calendar me-1"></i>${fn:replace(fn:substring(order.createdAt, 0, 16), 'T', ' ')}</small>
                </div>
                <div class="text-end">
                    <span class="badge rounded-pill px-3 py-2 order-status-badge badge-${order.status}">${order.status}</span>
                    <div class="fw-bold mt-1 text-primary">&#8377;${order.totalAmount}</div>
                </div>
            </div>
            <hr class="my-2">
            <c:forEach var="item" items="${order.items}">
            <div class="d-flex justify-content-between text-sm">
                <span>${item.medicineName} <small class="text-muted">(${item.unitLabel})</small></span>
                <span>x${item.quantity} &times; &#8377;${item.unitPrice}</span>
            </div>
            </c:forEach>
            <div class="mt-2">
                <span class="badge bg-light text-dark"><i class="fas fa-truck me-1"></i>Payment: COD</span>
            </div>
        </div>
    </div>
    </c:forEach>
    </div><%-- end scrollable orders list --%>
</div>
</div>
</div>
<%@include file="layout/footer.jsp"%>
