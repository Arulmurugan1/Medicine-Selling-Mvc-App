<%@ page contentType="text/html; charset=UTF-16" pageEncoding="UTF-16" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="loggedIn" value="${true}" />
<%@include file="layout/header.jsp"%>
<div class="container-fluid">
<div class="row">
<div class="col-md-2 p-0 sidebar d-none d-md-block">
    <nav class="nav flex-column pt-3">
        <a class="nav-link" href="/medicines"><i class="fas fa-shopping-cart me-2"></i>Order Now</a>
        <a class="nav-link active" href="/checkout"><i class="fas fa-credit-card me-2"></i>Checkout</a>
        <a class="nav-link" href="/orders/my"><i class="fas fa-box me-2"></i>My Orders</a>
        <hr class="border-white opacity-25 mx-3">
        <a class="nav-link" href="/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
    </nav>
</div>
<div class="col-md-10 p-4">
    <h4 class="fw-bold mb-4"><i class="fas fa-credit-card me-2 text-primary"></i>Checkout</h4>

    <form method="post" action="/checkout/place-order" id="checkoutForm">
        <div class="row g-4">
            <!-- Left -->
            <div class="col-lg-8">
                <!-- Customer Selection -->
                <div class="card border-0 shadow-sm rounded-4 mb-4">
                    <div class="card-body p-4">
                        <h5 class="fw-bold mb-3"><i class="fas fa-user me-2 text-primary"></i>Ordering For</h5>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Select Customer</label>
                            <select name="customerId" class="form-select" required id="customerSelect">
                                <option value="">-- Select Customer --</option>
                                <c:forEach var="customer" items="${customers}">
                                    <option value="${customer.id}">${customer.customerName} (${customer.customerEmail})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <button type="button" class="btn btn-outline-primary btn-sm" data-bs-toggle="modal" data-bs-target="#newCustomerModal">
                            <i class="fas fa-plus me-1"></i>Add New Customer
                        </button>
                    </div>
                </div>

                <!-- Address Selection -->
                <div class="card border-0 shadow-sm rounded-4 mb-4">
                    <div class="card-body p-4">
                        <h5 class="fw-bold mb-3"><i class="fas fa-map-marker-alt me-2 text-primary"></i>Delivery Address</h5>
                        <c:forEach var="addr" items="${addresses}">
                        <div class="form-check border rounded-3 p-3 mb-2">
                            <input class="form-check-input" type="radio" name="addressId"
                                   value="${addr.id}" id="addr${addr.id}" ${addr.isDefault ? 'checked' : ''} required>
                            <label class="form-check-label w-100" for="addr${addr.id}">
                                <strong>${addr.recipientName}</strong> &nbsp;
                                <span class="text-muted">${addr.phone}</span>
                                <c:if test="${addr.isDefault}"><span class="badge bg-success ms-2">Default</span></c:if>
                                <br>
                                <small class="text-muted">${addr.addressLine1}, ${addr.city} - ${addr.pincode}</small>
                            </label>
                        </div>
                        </c:forEach>
                        <button type="button" class="btn btn-outline-primary btn-sm mt-2" data-bs-toggle="modal" data-bs-target="#newAddressModal">
                            <i class="fas fa-plus me-1"></i>Add New Address
                        </button>
                    </div>
                </div>

                <!-- Payment -->
                <div class="card border-0 shadow-sm rounded-4 mb-4">
                    <div class="card-body p-4">
                        <h5 class="fw-bold mb-3"><i class="fas fa-wallet me-2 text-primary"></i>Payment Method</h5>
                        <div class="form-check border rounded-3 p-3">
                            <input class="form-check-input" type="radio" name="payment" value="COD" id="cod" checked>
                            <label class="form-check-label" for="cod">
                                <strong><i class="fas fa-money-bill me-2 text-success"></i>Cash on Delivery (COD)</strong>
                                <br><small class="text-muted">Pay when your order arrives</small>
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right - Summary -->
            <div class="col-lg-4">
                <div class="card border-0 shadow-sm rounded-4 p-4 sticky-top" style="top: 80px;">
                    <h5 class="fw-bold mb-4">Order Summary</h5>
                    <div id="orderSummaryItems"></div>
                    <hr>
                    <div class="d-flex justify-content-between mb-4">
                        <span class="fw-bold fs-5">Total</span>
                        <span class="fw-bold fs-5 text-primary" id="orderTotal">₹0.00</span>
                    </div>
                    <input type="hidden" name="itemsJson" id="itemsJson">
                    <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold">
                        <i class="fas fa-check me-2"></i>Place Order
                    </button>
                </div>
            </div>
        </div>
    </form>
</div>
</div>
</div>

<!-- New Customer Modal -->
<div class="modal fade" id="newCustomerModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0"><h5 class="modal-title fw-bold">Add New Customer</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Customer Name</label>
                    <input type="text" id="newCustName" class="form-control" placeholder="Full Name">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Email</label>
                    <input type="email" id="newCustEmail" class="form-control" placeholder="email@example.com">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Phone</label>
                    <input type="tel" id="newCustPhone" class="form-control" placeholder="+91 XXXXX XXXXX">
                </div>
                <button class="btn btn-primary w-100" onclick="saveCustomer()">Save Customer</button>
            </div>
        </div>
    </div>
</div>

<!-- New Address Modal -->
<div class="modal fade" id="newAddressModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0"><h5 class="modal-title fw-bold">Add Delivery Address</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="row g-2">
                    <div class="col-12"><input type="text" id="addrName" class="form-control" placeholder="Recipient Name"></div>
                    <div class="col-12"><input type="tel" id="addrPhone" class="form-control" placeholder="Phone"></div>
                    <div class="col-12"><input type="text" id="addrLine1" class="form-control" placeholder="Address Line 1"></div>
                    <div class="col-12"><input type="text" id="addrLine2" class="form-control" placeholder="Address Line 2 (optional)"></div>
                    <div class="col-6"><input type="text" id="addrCity" class="form-control" placeholder="City"></div>
                    <div class="col-6"><input type="text" id="addrPincode" class="form-control" placeholder="Pincode"></div>
                    <div class="col-12"><input type="text" id="addrState" class="form-control" placeholder="State"></div>
                </div>
                <button class="btn btn-primary w-100 mt-3" onclick="saveAddress()">Save Address</button>
            </div>
        </div>
    </div>
</div>

<script>
    const cart = JSON.parse(localStorage.getItem('cart') || '[]');
    let total = 0;
    let summaryHtml = '';
    cart.forEach(item => {
        const lt = item.unitPrice * item.quantity;
        total += lt;
        summaryHtml += `<div class="d-flex justify-content-between mb-2">
            <span class="text-muted small">${item.medicineName} x${item.quantity}</span>
            <span class="fw-semibold small">₹${lt.toFixed(2)}</span>
        </div>`;
    });
    document.getElementById('orderSummaryItems').innerHTML = summaryHtml;
    document.getElementById('orderTotal').textContent = '₹' + total.toFixed(2);
    document.getElementById('itemsJson').value = JSON.stringify(cart);

    document.getElementById('checkoutForm').addEventListener('submit', function() {
        localStorage.removeItem('cart');
    });

    function saveCustomer() {
        const body = {
            customerName: document.getElementById('newCustName').value,
            customerEmail: document.getElementById('newCustEmail').value,
            customerPhone: document.getElementById('newCustPhone').value
        };
        fetch('/api-proxy/customers', { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body) })
            .then(r => r.json()).then(c => {
                const opt = new Option(c.customerName + ' (' + c.customerEmail + ')', c.id);
                document.getElementById('customerSelect').add(opt);
                document.getElementById('customerSelect').value = c.id;
                bootstrap.Modal.getInstance(document.getElementById('newCustomerModal')).hide();
            });
    }

    function saveAddress() {
        const body = {
            recipientName: document.getElementById('addrName').value,
            phone: document.getElementById('addrPhone').value,
            addressLine1: document.getElementById('addrLine1').value,
            addressLine2: document.getElementById('addrLine2').value,
            city: document.getElementById('addrCity').value,
            state: document.getElementById('addrState').value,
            pincode: document.getElementById('addrPincode').value
        };
        fetch('/api-proxy/addresses', { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body) })
            .then(r => r.json()).then(a => {
                const div = document.createElement('div');
                div.className = 'form-check border rounded-3 p-3 mb-2';
                div.innerHTML = `<input class="form-check-input" type="radio" name="addressId" value="${a.id}" id="addr${a.id}" checked>
                    <label class="form-check-label w-100" for="addr${a.id}">
                        <strong>${a.recipientName}</strong> <span class="text-muted">${a.phone}</span><br>
                        <small class="text-muted">${a.addressLine1}, ${a.city} - ${a.pincode}</small>
                    </label>`;
                document.querySelector('[data-bs-target="#newAddressModal"]').before(div);
                bootstrap.Modal.getInstance(document.getElementById('newAddressModal')).hide();
            });
    }
</script>
<%@include file="layout/footer.jsp"%>
