<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@include file="../layout/header.jsp"%>
<div class="container-fluid p-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold mb-0"><i class="fas fa-pills me-2 text-primary"></i>Medicine Management</h4>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addMedModal">
            <i class="fas fa-plus me-1"></i>Add Medicine
        </button>
    </div>
    <c:if test="${not empty flashScope.success}">
        <div class="alert alert-success rounded-3"><i class="fas fa-check-circle me-2"></i>${flashScope.success}</div>
    </c:if>
    <div class="row g-4">
    <c:forEach var="medicine" items="${medicines}">
        <div class="col-md-4 col-lg-3">
            <div class="card border-0 shadow-sm rounded-4 h-100">
                <div class="card-body p-3">
                    <span class="badge bg-light text-primary border mb-2">${medicine.category}</span>
                    <h6 class="fw-bold">${medicine.name}</h6>
                    <p class="text-muted small">${medicine.description}</p>
                </div>
                <div class="card-footer bg-transparent border-0 pt-0 p-3">
                    <a href="/admin/skus?med=${medicine.id}" class="btn btn-sm btn-outline-primary w-100">
                        <i class="fas fa-tags me-1"></i>Manage SKUs
                    </a>
                </div>
            </div>
        </div>
    </c:forEach>
    </div>
</div>

<div class="modal fade" id="addMedModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0"><h5 class="modal-title fw-bold">Add Medicine</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label fw-semibold">Medicine Name</label>
                    <input type="text" id="medName" class="form-control" placeholder="Paracetamol 500mg"></div>
                <div class="mb-3"><label class="form-label fw-semibold">Category</label>
                    <select id="medCategory" class="form-select">
                        <option>Analgesics</option><option>Antibiotics</option><option>Antacids</option>
                        <option>Vitamins</option><option>Antihistamines</option><option>Antidiabetics</option>
                        <option>Cardiovascular</option><option>Dermatology</option><option>Other</option>
                    </select></div>
                <div class="mb-3"><label class="form-label fw-semibold">Description</label>
                    <textarea id="medDesc" class="form-control" rows="3" placeholder="Medicine description..."></textarea></div>
                <div class="mb-3"><label class="form-label fw-semibold">Image URL (optional)</label>
                    <input type="url" id="medImage" class="form-control" placeholder="https://..."></div>
                <button class="btn btn-primary w-100" onclick="addMedicine()">Save Medicine</button>
            </div>
        </div>
    </div>
</div>
<script>
function addMedicine() {
    const body = {
        name: document.getElementById('medName').value,
        category: document.getElementById('medCategory').value,
        description: document.getElementById('medDesc').value,
        imageUrl: document.getElementById('medImage').value
    };
    fetch('/api-proxy/medicines', { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body) })
        .then(() => { location.reload(); });
}
</script>
<%@include file="../layout/footer.jsp"%>
