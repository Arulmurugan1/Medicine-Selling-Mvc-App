<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@include file="../layout/header.jsp"%>
<div class="d-flex">
<%@include file="../layout/admin-sidebar.jsp"%>
<div class="flex-grow-1 overflow-auto">
<div class="container-fluid p-4">
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h4 class="fw-bold mb-0"><i class="fas fa-list me-2 text-primary"></i>
                <c:choose>
                    <c:when test="${activeStatus == 'PENDING'}">Pending Orders</c:when>
                    <c:when test="${activeStatus == 'OUT_FOR_DELIVERY'}">Orders Out for Delivery</c:when>
                    <c:when test="${activeStatus == 'DELIVERED'}">Completed Orders</c:when>
                    <c:otherwise>All Customer Orders</c:otherwise>
                </c:choose>
            </h4>
        </div>
        <div class="d-flex gap-2 flex-wrap">
            <a href="/admin/orders" class="btn btn-sm ${empty activeStatus ? 'btn-primary' : 'btn-outline-secondary'}">All</a>
            <a href="/admin/orders?status=PENDING" class="btn btn-sm ${activeStatus == 'PENDING' ? 'btn-warning' : 'btn-outline-warning'}">Pending</a>
            <a href="/admin/orders?status=PROCESSING" class="btn btn-sm ${activeStatus == 'PROCESSING' ? 'btn-info' : 'btn-outline-info'}">Processing</a>
            <a href="/admin/orders?status=OUT_FOR_DELIVERY" class="btn btn-sm ${activeStatus == 'OUT_FOR_DELIVERY' ? 'btn-warning text-white' : 'btn-outline-warning'}">Delivery</a>
            <a href="/admin/orders?status=DELIVERED" class="btn btn-sm ${activeStatus == 'DELIVERED' ? 'btn-success' : 'btn-outline-success'}">Completed</a>
        </div>
    </div>

    <c:if test="${not empty success}">
        <div class="alert alert-success rounded-3"><i class="fas fa-check-circle me-2"></i>${success}</div>
    </c:if>

    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="bg-light">
                    <tr>
                        <th>#</th><th>Date</th><th>Customer</th><th>User</th>
                        <th>Total</th><th>Status</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="order" items="${orders}">
                    <tr>
                        <td class="fw-semibold">${order.id}</td>
                        <td><small class="text-muted">${order.createdAt}</small></td>
                        <td>${order.customerId}</td>
                        <td><small>${order.userEmail}</small></td>
                        <td class="fw-semibold text-primary">₹${order.totalAmount}</td>
                        <td><span class="badge rounded-pill px-3 py-2 badge-${order.status}">${order.status}</span></td>
                        <td>
                            <div class="d-flex gap-1">
                                <c:if test="${order.status != 'CANCELLED' and order.status != 'DELIVERED'}">
                                    <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal"
                                            data-bs-target="#statusModal" data-orderid="${order.id}" data-status="${order.status}">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger" data-bs-toggle="modal"
                                            data-bs-target="#cancelModal" data-orderid="${order.id}">
                                        <i class="fas fa-ban"></i>
                                    </button>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty orders}">
                    <tr><td colspan="7" class="text-center text-muted py-4">No orders found</td></tr>
                </c:if>
                </tbody>
            </table>
            </div>
        </div>
    </div>
</div>

<!-- Status Modal -->
<div class="modal fade" id="statusModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0"><h5 class="modal-title fw-bold">Update Order Status</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="statusForm" method="post">
                <div class="modal-body">
                    <select name="status" class="form-select mb-3">
                        <option value="PENDING">Pending</option>
                        <option value="PROCESSING">Processing</option>
                        <option value="OUT_FOR_DELIVERY">Out for Delivery</option>
                        <option value="DELIVERED">Delivered</option>
                    </select>
                    <input type="text" name="remarks" class="form-control" placeholder="Remarks (optional)">
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update Status</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Cancel Modal -->
<div class="modal fade" id="cancelModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0"><h5 class="modal-title fw-bold text-danger">Cancel Order</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="cancelForm" method="post">
                <div class="modal-body">
                    <p class="text-muted">Are you sure you want to cancel this order? This action is audited.</p>
                    <input type="text" name="remarks" class="form-control" placeholder="Reason for cancellation" required>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">No, Keep It</button>
                    <button type="submit" class="btn btn-danger">Yes, Cancel Order</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
document.getElementById('statusModal').addEventListener('show.bs.modal', function(e) {
    const btn = e.relatedTarget;
    document.getElementById('statusForm').action = '/admin/orders/' + btn.dataset.orderid + '/status';
    const sel = document.querySelector('#statusModal select[name=status]');
    sel.value = btn.dataset.status;
});
document.getElementById('cancelModal').addEventListener('show.bs.modal', function(e) {
    const btn = e.relatedTarget;
    document.getElementById('cancelForm').action = '/admin/orders/' + btn.dataset.orderid + '/cancel';
});
</script>
</div><!-- container-fluid -->
</div><!-- flex-grow-1 -->
</div><!-- d-flex -->
<%@include file="../layout/footer.jsp"%>
