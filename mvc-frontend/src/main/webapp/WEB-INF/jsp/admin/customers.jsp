<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@include file="../layout/header.jsp"%>
<div class="d-flex">
<%@include file="../layout/admin-sidebar.jsp"%>
<div class="flex-grow-1 overflow-auto">
<div class="container-fluid p-4">
    <h4 class="fw-bold mb-4"><i class="fas fa-user-friends me-2 text-primary"></i>Customer Master</h4>
    <c:if test="${not empty success}">
        <div class="alert alert-success rounded-3"><i class="fas fa-check-circle me-2"></i>${success}</div>
    </c:if>
    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="bg-light">
                    <tr><th>#</th><th>Name</th><th>Email</th><th>Phone</th><th>Status</th><th>Action</th></tr>
                </thead>
                <tbody>
                <c:forEach var="customer" items="${customers}">
                <tr class="${!customer.isActive ? 'text-muted' : ''}">
                    <td>${customer.id}</td>
                    <td class="fw-semibold ${!customer.isActive ? 'text-decoration-line-through' : ''}">${customer.customerName}</td>
                    <td>${customer.customerEmail}</td>
                    <td>${customer.customerPhone}</td>
                    <td>
                        <c:choose>
                            <c:when test="${customer.isActive}"><span class="badge bg-success rounded-pill">Active</span></c:when>
                            <c:otherwise><span class="badge bg-danger rounded-pill">Inactive</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:if test="${customer.isActive}">
                            <button class="btn btn-sm btn-outline-danger" data-bs-toggle="modal"
                                    data-bs-target="#custModal" data-custid="${customer.id}" data-custname="${customer.customerName}">
                                <i class="fas fa-ban me-1"></i>Inactivate
                            </button>
                        </c:if>
                    </td>
                </tr>
                </c:forEach>
                </tbody>
            </table>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="custModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0"><h5 class="modal-title fw-bold text-danger">Inactivate Customer</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="custForm" method="post">
                <div class="modal-body">
                    <p>Inactivate customer <strong id="custName"></strong>?</p>
                    <input type="text" name="remarks" class="form-control" placeholder="Reason (optional)">
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">Confirm</button>
                </div>
            </form>
        </div>
    </div>
</div>
<script>
document.getElementById('custModal').addEventListener('show.bs.modal', function(e) {
    const btn = e.relatedTarget;
    document.getElementById('custForm').action = '/admin/customers/' + btn.dataset.custid + '/inactivate';
    document.getElementById('custName').textContent = btn.dataset.custname;
});
</script>
</div><!-- container-fluid -->
</div><!-- flex-grow-1 -->
</div><!-- d-flex -->
<%@include file="../layout/footer.jsp"%>
