<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="loggedIn" value="${true}" />
<%@include file="layout/header.jsp"%>
<div class="container-fluid">
<div class="row">
<div class="col-md-2 p-0 sidebar d-none d-md-block">
    <nav class="nav flex-column pt-3">
        <a class="nav-link" href="/medicines"><i class="fas fa-shopping-cart me-2"></i>Order Now</a>
        <a class="nav-link active" href="/cart"><i class="fas fa-cart-shopping me-2"></i>View Cart</a>
        <a class="nav-link" href="/orders/my"><i class="fas fa-box me-2"></i>My Orders</a>
        <hr class="border-white opacity-25 mx-3">
        <a class="nav-link" href="/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
    </nav>
</div>
<div class="col-md-10 p-4">
    <h4 class="fw-bold mb-4"><i class="fas fa-shopping-cart me-2 text-primary"></i>My Cart</h4>

    <div id="cartEmpty" class="text-center py-5 d-none">
        <div><i class="fas fa-shopping-cart text-muted" style="font-size:5rem;"></i></div>
        <h5 class="text-muted mt-3">Your cart is empty</h5>
        <a href="/medicines" class="btn btn-primary mt-3">Browse Medicines</a>
    </div>

    <div id="cartContent">
        <div class="row">
            <div class="col-lg-8">
                <div class="card border-0 shadow-sm rounded-4">
                    <div class="card-body p-0">
                        <table class="table mb-0">
                            <thead class="bg-light">
                                <tr><th>Medicine</th><th>Unit</th><th>Price</th><th>Qty</th><th>Total</th><th></th></tr>
                            </thead>
                            <tbody id="cartTableBody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="card border-0 shadow-sm rounded-4 p-4 sticky-top" style="top: 80px;">
                    <h5 class="fw-bold mb-4">Order Summary</h5>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">Subtotal</span><span id="subtotal" class="fw-semibold">₹0.00</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">Delivery</span><span class="text-success fw-semibold">FREE</span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between mb-4">
                        <span class="fw-bold fs-5">Total</span><span class="fw-bold fs-5 text-primary" id="total">₹0.00</span>
                    </div>
                    <button class="btn btn-primary w-100 py-2 fw-semibold" onclick="window.location='/checkout'">
                        <i class="fas fa-arrow-right me-2"></i>Proceed to Checkout
                    </button>
                    <a href="/medicines" class="btn btn-outline-secondary w-100 mt-2">Continue Shopping</a>
                </div>
            </div>
        </div>
    </div>
</div>
</div>
</div>
<script>
    let cart = JSON.parse(localStorage.getItem('cart') || '[]');
    renderCart();
    function renderCart() {
        const tbody = document.getElementById('cartTableBody');
        if (cart.length === 0) {
            document.getElementById('cartEmpty').classList.remove('d-none');
            document.getElementById('cartContent').classList.add('d-none');
            return;
        }
        let total = 0;
        tbody.innerHTML = cart.map((item, idx) => {
            const lineTotal = item.unitPrice * item.quantity;
            total += lineTotal;
            return `<tr>
                <td class="fw-semibold">\${item.medicineName}</td>
                <td><small class="text-muted">\${item.unitLabel}</small></td>
                <td>₹\${item.unitPrice.toFixed(2)}</td>
                <td><input type="number" class="form-control form-control-sm" style="width:70px" value="\${item.quantity}" min="1" onchange="updateQty(\${idx}, this.value)"></td>
                <td class="fw-semibold text-primary">₹\${lineTotal.toFixed(2)}</td>
                <td><button class="btn btn-sm btn-outline-danger" onclick="removeItem(\${idx})"><i class="fas fa-trash"></i></button></td>
            </tr>`;
        }).join('');
        document.getElementById('subtotal').textContent = '₹' + total.toFixed(2);
        document.getElementById('total').textContent = '₹' + total.toFixed(2);
    }
    function updateQty(idx, qty) {
        cart[idx].quantity = parseInt(qty);
        localStorage.setItem('cart', JSON.stringify(cart));
        renderCart();
    }
    function removeItem(idx) {
        cart.splice(idx, 1);
        localStorage.setItem('cart', JSON.stringify(cart));
        renderCart();
    }
</script>
<%@include file="layout/footer.jsp"%>
