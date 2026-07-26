<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@include file="../layout/header.jsp"%>
<div class="d-flex">
<%@include file="../layout/admin-sidebar.jsp"%>
<div class="flex-grow-1 overflow-auto">
<div class="container-fluid p-4">
    <h4 class="fw-bold mb-4"><i class="fas fa-tags me-2 text-primary"></i>SKU Manager</h4>
    <div class="row g-4">
        <!-- Left: Medicine List -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-4 p-3">
                <h6 class="fw-bold mb-3">Medicines</h6>
                <input type="text" id="medSearch" class="form-control mb-3" placeholder="Search medicines...">
                <div id="medList" class="list-group">
                <c:forEach var="medicine" items="${medicines}">
                    <button type="button" class="list-group-item list-group-item-action med-item rounded-3 mb-1"
                            data-medid="${medicine.id}" data-medname="${medicine.name}">
                        <strong>${medicine.name}</strong>
                        <br><small class="text-muted">${medicine.category}</small>
                    </button>
                </c:forEach>
                </div>
                <!-- Pagination -->
                <div class="d-flex justify-content-between align-items-center mt-3" id="medPagination">
                    <button class="btn btn-sm btn-outline-secondary" id="pagePrev" onclick="changePage(-1)">&laquo; Prev</button>
                    <small class="text-muted" id="pageInfo"></small>
                    <button class="btn btn-sm btn-outline-secondary" id="pageNext" onclick="changePage(1)">Next &raquo;</button>
                </div>
            </div>
        </div>

        <!-- Right: SKU Table -->
        <div class="col-md-8">
            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-header bg-white border-0 d-flex justify-content-between align-items-center p-4">
                    <h6 class="fw-bold mb-0" id="skuPanelTitle">Select a medicine</h6>
                    <button class="btn btn-primary btn-sm d-none" id="addSkuBtn" data-bs-toggle="modal" data-bs-target="#addSkuModal">
                        <i class="fas fa-plus me-1"></i>Add SKU
                    </button>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                    <table class="table mb-0">
                        <thead class="bg-light">
                            <tr><th>SKU Code</th><th>Unit</th><th>Price</th><th>Stock</th><th>Status</th><th>Actions</th></tr>
                        </thead>
                        <tbody id="skuTableBody">
                            <tr><td colspan="6" class="text-center text-muted py-4">Select a medicine to view SKUs</td></tr>
                        </tbody>
                    </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add SKU Modal -->
<div class="modal fade" id="addSkuModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0"><h5 class="modal-title fw-bold">Add New SKU</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="addSkuMedId">
                <div class="mb-3"><label class="form-label fw-semibold">SKU Code</label>
                    <input type="text" id="addSkuCode" class="form-control" placeholder="e.g. MED-001-10T"></div>
                <div class="mb-3"><label class="form-label fw-semibold">Unit Label</label>
                    <input type="text" id="addSkuLabel" class="form-control" placeholder="e.g. Strip of 10 Tablets"></div>
                <div class="mb-3"><label class="form-label fw-semibold">Unit Price (₹)</label>
                    <input type="number" id="addSkuPrice" class="form-control" step="0.01" placeholder="99.00"></div>
                <div class="mb-3"><label class="form-label fw-semibold">Initial Stock</label>
                    <input type="number" id="addSkuStock" class="form-control" placeholder="100"></div>
                <button class="btn btn-primary w-100" onclick="addSku()">Save SKU</button>
            </div>
        </div>
    </div>
</div>

<!-- Edit SKU Modal -->
<div class="modal fade" id="editSkuModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0"><h5 class="modal-title fw-bold">Edit SKU</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="editSkuId">
                <div class="mb-3"><label class="form-label fw-semibold">Unit Label</label>
                    <input type="text" id="editSkuLabel" class="form-control"></div>
                <div class="mb-3"><label class="form-label fw-semibold">Unit Price (₹)</label>
                    <input type="number" id="editSkuPrice" class="form-control" step="0.01"></div>
                <div class="mb-3"><label class="form-label fw-semibold">Stock Quantity</label>
                    <input type="number" id="editSkuStock" class="form-control"></div>
                <button class="btn btn-primary w-100" onclick="updateSku()">Save Changes</button>
            </div>
        </div>
    </div>
</div>

<script>
let currentMedId = null;
const PAGE_SIZE = 8;
let currentPage = 0;
let filteredItems = [];

// Decode HTML entities from server-rendered text (e.g. &amp; &lt; accented chars)
function decode(str) {
    const txt = document.createElement('textarea');
    txt.innerHTML = str || '';
    return txt.value;
}

function getAllItems() {
    return Array.from(document.querySelectorAll('.med-item'));
}

function applyFilter(q) {
    const all = getAllItems();
    filteredItems = q ? all.filter(btn => btn.textContent.toLowerCase().includes(q)) : all;
    currentPage = 0;
    renderPage();
}

function renderPage() {
    const total = filteredItems.length;
    const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
    const start = currentPage * PAGE_SIZE;
    const end = start + PAGE_SIZE;

    getAllItems().forEach(btn => btn.style.display = 'none');
    filteredItems.slice(start, end).forEach(btn => btn.style.display = '');

    document.getElementById('pageInfo').textContent = 'Page ' + (currentPage + 1) + ' / ' + totalPages + ' (' + total + ' total)';
    document.getElementById('pagePrev').disabled = currentPage === 0;
    document.getElementById('pageNext').disabled = currentPage >= totalPages - 1;
    document.getElementById('medPagination').style.display = total === 0 ? 'none' : '';
}

function changePage(delta) {
    const totalPages = Math.ceil(filteredItems.length / PAGE_SIZE);
    currentPage = Math.max(0, Math.min(currentPage + delta, totalPages - 1));
    renderPage();
}

document.getElementById('medSearch').addEventListener('input', function() {
    applyFilter(this.value.toLowerCase());
});

document.querySelectorAll('.med-item').forEach(btn => {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.med-item').forEach(b => b.classList.remove('active'));
        this.classList.add('active');
        currentMedId = this.dataset.medid;
        document.getElementById('skuPanelTitle').textContent = decode(this.dataset.medname) + ' — SKUs';
        document.getElementById('addSkuBtn').classList.remove('d-none');
        document.getElementById('addSkuMedId').value = currentMedId;
        loadSkus(currentMedId);
    });
});

// Init pagination on load
filteredItems = getAllItems();
renderPage();

function loadSkus(medId) {
    fetch('/api-proxy/medicines/' + medId + '/skus/all')
        .then(function(r) { return r.status === 204 ? [] : r.json(); })
        .then(function(skus) {
            const tbody = document.getElementById('skuTableBody');
            if (!skus || skus.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">No SKUs found for this medicine</td></tr>';
                return;
            }
            tbody.innerHTML = skus.map(function(s) {
                const label = decode(s.unitLabel);
                const code  = decode(s.skuCode);
                const safeLabel = label.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
                return '<tr>' +
                    '<td><code>' + code + '</code></td>' +
                    '<td>' + label + '</td>' +
                    '<td class="fw-semibold">&#8377;' + Number(s.unitPrice).toFixed(2) + '</td>' +
                    '<td>' + s.quantityAvailable + '</td>' +
                    '<td><span class="badge ' + (s.isActive ? 'bg-success' : 'bg-danger') + '">' + (s.isActive ? 'Active' : 'Inactive') + '</span></td>' +
                    '<td><div class="d-flex gap-1">' +
                        '<button class="btn btn-sm btn-outline-primary" onclick="openEdit(' + s.id + ',\'' + safeLabel + '\',' + s.unitPrice + ',' + s.quantityAvailable + ')">' +
                            '<i class="fas fa-edit"></i></button>' +
                        (s.isActive ? '<button class="btn btn-sm btn-outline-danger" onclick="inactivateSku(' + s.id + ')"><i class="fas fa-ban"></i></button>' : '') +
                    '</div></td>' +
                '</tr>';
            }).join('');
        });
}

function addSku() {
    const body = {
        skuCode: document.getElementById('addSkuCode').value,
        unitLabel: document.getElementById('addSkuLabel').value,
        unitPrice: parseFloat(document.getElementById('addSkuPrice').value),
        quantityAvailable: parseInt(document.getElementById('addSkuStock').value)
    };
    fetch('/api-proxy/skus/medicine/' + currentMedId, {
        method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body)
    }).then(() => { bootstrap.Modal.getInstance(document.getElementById('addSkuModal')).hide(); loadSkus(currentMedId); });
}

function openEdit(id, label, price, stock) {
    document.getElementById('editSkuId').value = id;
    document.getElementById('editSkuLabel').value = label;
    document.getElementById('editSkuPrice').value = price;
    document.getElementById('editSkuStock').value = stock;
    new bootstrap.Modal(document.getElementById('editSkuModal')).show();
}

function updateSku() {
    const id = document.getElementById('editSkuId').value;
    const body = {
        unitLabel: document.getElementById('editSkuLabel').value,
        unitPrice: parseFloat(document.getElementById('editSkuPrice').value),
        quantityAvailable: parseInt(document.getElementById('editSkuStock').value)
    };
    fetch('/api-proxy/skus/' + id, {
        method: 'PUT', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body)
    }).then(() => { bootstrap.Modal.getInstance(document.getElementById('editSkuModal')).hide(); loadSkus(currentMedId); });
}

function inactivateSku(id) {
    const remarks = prompt('Reason for inactivating this SKU (optional):');
    if (remarks === null) return;
    fetch('/api-proxy/skus/' + id + '/inactivate', {
        method: 'PUT', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({ remarks })
    }).then(() => loadSkus(currentMedId));
}
</script>
</div><!-- container-fluid -->
</div><!-- flex-grow-1 -->
</div><!-- d-flex -->
<%@include file="../layout/footer.jsp"%>
