<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="loggedIn" value="${true}" />
<%@include file="layout/header.jsp"%>

<div class="container-fluid">
<div class="row">
<!-- Sidebar -->
<div class="col-md-2 p-0 sidebar d-none d-md-block">
    <nav class="nav flex-column pt-3">
        <a class="nav-link" href="/medicines"><i class="fas fa-shopping-cart me-2"></i>Order Now</a>
        <a class="nav-link" href="/cart"><i class="fas fa-cart-shopping me-2"></i>View Cart</a>
        <a class="nav-link" href="/orders/my"><i class="fas fa-box me-2"></i>My Orders</a>
        <hr class="border-white opacity-25 mx-3">
        <a class="nav-link" href="/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
    </nav>
</div>

<!-- Main Content -->
<div class="col-md-10 p-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold mb-0">Medicine Catalog</h4>
            <p class="text-muted small mb-0">Browse and add medicines to your cart</p>
        </div>
        <div class="input-group" style="width: 280px;">
            <input type="text" id="searchInput" class="form-control" placeholder="Search medicines...">
            <span class="input-group-text"><i class="fas fa-search"></i></span>
        </div>
    </div>

    <!-- Category Filter -->
    <div class="mb-4" id="categoryFilterBar">
        <div class="d-flex flex-wrap gap-2 align-items-center" id="categoryBtnContainer">
            <span class="text-muted small fw-semibold me-1">Filter by Category:</span>
            <button class="btn btn-sm btn-primary category-btn active" data-category="all">
                <i class="fas fa-th me-1"></i>All
            </button>
            <%-- Hidden spans used by JS to collect unique categories --%>
            <c:forEach var="medicine" items="${medicines}">
                <span class="d-none medicine-category-source">${fn:trim(medicine.category)}</span>
            </c:forEach>
        </div>
    </div>

    <div class="row g-4" id="medicineGrid" style="overflow-y: auto; max-height: calc(100vh - 220px); padding-right: 4px;">
        <c:forEach var="medicine" items="${medicines}">
        <div class="col-md-4 col-lg-3 medicine-card"
             data-category="${fn:trim(medicine.category)}"
             data-name="${fn:escapeXml(medicine.name)}"
             data-desc="${fn:escapeXml(fn:substring(medicine.description, 0, 100))}">
            <div class="card h-100 border-0 shadow-sm card-hover rounded-3">
                <div class="card-img-top bg-gradient d-flex align-items-center justify-content-center rounded-top-3"
                     style="height: 140px; background: linear-gradient(135deg,#e0f2fe,#bfdbfe);">
                    <c:choose>
                        <c:when test="${not empty medicine.imageUrl}">
                            <img src="${medicine.imageUrl}" alt="${medicine.name}" style="max-height: 120px; object-fit: contain;">
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-pills text-primary" style="font-size:4rem;"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="card-body d-flex flex-column">
                    <span class="badge bg-blue-100 text-blue-800 mb-2 align-self-start" style="background:#dbeafe;color:#1e40af;">${medicine.category}</span>
                    <h6 class="card-title fw-bold">${medicine.name}</h6>
                    <p class="text-muted small flex-grow-1">${fn:substring(medicine.description, 0, 80)}...</p>
                    <button class="btn btn-primary btn-sm mt-2 w-100 select-medicine-btn"
                            data-id="${medicine.id}"
                            data-name="${medicine.name}"
                            data-bs-toggle="modal" data-bs-target="#skuModal">
                        <i class="fas fa-plus me-1"></i>Add to Cart
                    </button>
                </div>
            </div>
        </div>
        </c:forEach>
        <c:if test="${empty medicines}">
            <div class="col-12 text-center py-5">
                <div><i class="fas fa-search text-muted" style="font-size:5rem;"></i></div>
                <h5 class="text-muted mt-3">No medicines available</h5>
            </div>
        </c:if>
    </div>
</div>
</div>
</div>

<!-- SKU Modal -->
<div class="modal fade" id="skuModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold" id="skuModalTitle">Select Variant</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="skuModalBody">
                <div class="text-center py-3"><div class="spinner-border text-primary"></div></div>
            </div>
        </div>
    </div>
</div>

<!-- Cart Sidebar Trigger -->
<a href="/cart" class="btn btn-primary position-fixed bottom-0 end-0 m-4 rounded-pill shadow-lg px-4 py-2" id="cartBtn">
    <i class="fas fa-shopping-cart me-2"></i><span id="cartCount">0</span> items
</a>

<script>
    let cart = JSON.parse(localStorage.getItem('cart') || '[]');
    updateCartCount();

    // Build unique category buttons dynamically
    const seen = new Set();
    const container = document.getElementById('categoryBtnContainer');
    document.querySelectorAll('.medicine-category-source').forEach(span => {
        const cat = span.textContent.trim();
        if (cat && !seen.has(cat)) {
            seen.add(cat);
            const btn = document.createElement('button');
            btn.className = 'btn btn-sm btn-outline-primary category-btn';
            btn.dataset.category = cat;
            btn.innerHTML = '<i class="fas fa-tag me-1"></i>' + cat;
            container.appendChild(btn);
        }
    });

    function updateCartCount() {
        const total = cart.reduce((s, i) => s + i.quantity, 0);
        document.getElementById('cartCount').textContent = total;
    }

    let activeCategory = 'all';

    document.getElementById('categoryBtnContainer').addEventListener('click', function(e) {
        const btn = e.target.closest('.category-btn');
        if (!btn) return;
        document.querySelectorAll('.category-btn').forEach(b => {
            b.classList.remove('active', 'btn-primary');
            b.classList.add('btn-outline-primary');
        });
        btn.classList.remove('btn-outline-primary');
        btn.classList.add('active', 'btn-primary');
        activeCategory = btn.dataset.category;
        filterCards();
    });

    document.getElementById('searchInput').addEventListener('input', filterCards);

    function filterCards() {
        const q = document.getElementById('searchInput').value.toLowerCase().trim();
        document.querySelectorAll('.medicine-card').forEach(card => {
            const name = (card.dataset.name || '').toLowerCase();
            const desc = (card.dataset.desc || '').toLowerCase();
            const cat  = (card.dataset.category || '').toLowerCase().trim();
            const matchSearch = !q || name.includes(q) || cat.includes(q) || desc.includes(q);
            const cardCategory = (card.dataset.category || '').trim();
            const matchCategory = activeCategory === 'all' || cardCategory === activeCategory;
            card.style.display = (matchSearch && matchCategory) ? '' : 'none';
        });
    }

    document.querySelectorAll('.select-medicine-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const id = this.dataset.id;
            const name = this.dataset.name;
            document.getElementById('skuModalTitle').textContent = name;
            document.getElementById('skuModalBody').innerHTML = '<div class="text-center py-3"><div class="spinner-border text-primary"></div></div>';

            fetch('/api-proxy/medicines/' + id + '/skus', {
                headers: { 'X-Proxy': 'true' }
            }).then(r => {
                if (r.status === 204 || r.status === 404) return [];
                if (!r.ok) throw new Error('HTTP ' + r.status);
                return r.json();
            }).then(skus => {
                if (!skus || skus.length === 0) {
                    document.getElementById('skuModalBody').innerHTML = '<p class="text-muted text-center">No variants available</p>';
                    return;
                }
                let html = '<div class="list-group">';
                skus.forEach(sku => {
                    html += `<div class="list-group-item border rounded-3 mb-2 p-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <div class="fw-semibold">\${sku.unitLabel}</div>
                                <small class="text-muted">SKU: \${sku.skuCode}</small>
                            </div>
                            <div class="text-end">
                                <div class="fw-bold text-primary">₹\${sku.unitPrice}</div>
                                <small class="text-success">In stock: \${sku.quantityAvailable}</small>
                            </div>
                        </div>
                        <div class="mt-2 d-flex align-items-center gap-2">
                            <input type="number" min="1" max="\${sku.quantityAvailable}" value="1" class="form-control form-control-sm qty-input" style="width:70px">
                            <button class="btn btn-sm btn-primary flex-grow-1 add-to-cart"
                                data-skuid="\${sku.id}" data-skucode="\${sku.skuCode}"
                                data-medname="${'${name}'}" data-unitlabel="\${sku.unitLabel}"
                                data-price="\${sku.unitPrice}">
                                <i class="fas fa-cart-plus me-1"></i>Add
                            </button>
                        </div>
                    </div>`;
                });
                html += '</div>';
                document.getElementById('skuModalBody').innerHTML = html;

                document.querySelectorAll('.add-to-cart').forEach(btn => {
                    btn.addEventListener('click', function() {
                        const qty = parseInt(this.closest('.list-group-item').querySelector('.qty-input').value);
                        const item = {
                            skuId: parseInt(this.dataset.skuid),
                            skuCode: this.dataset.skucode,
                            medicineName: this.dataset.medname,
                            unitLabel: this.dataset.unitlabel,
                            unitPrice: parseFloat(this.dataset.price),
                            quantity: qty
                        };
                        const existing = cart.findIndex(i => i.skuId === item.skuId);
                        if (existing >= 0) cart[existing].quantity += qty;
                        else cart.push(item);
                        localStorage.setItem('cart', JSON.stringify(cart));
                        updateCartCount();
                        bootstrap.Modal.getInstance(document.getElementById('skuModal')).hide();
                        showToast('Added to cart!');
                    });
                });
            }).catch(() => {
                document.getElementById('skuModalBody').innerHTML = '<p class="text-danger text-center">Failed to load variants</p>';
            });
        });
    });

    function showToast(msg) {
        const t = document.createElement('div');
        t.className = 'position-fixed bottom-0 start-50 translate-middle-x mb-5 alert alert-success rounded-pill px-4 py-2 shadow';
        t.style.zIndex = 9999;
        t.innerHTML = '<i class="fas fa-check-circle me-2"></i>' + msg;
        document.body.appendChild(t);
        setTimeout(() => t.remove(), 2000);
    }
</script>

<%@include file="layout/footer.jsp"%>
