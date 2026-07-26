<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@include file="../layout/header.jsp"%>
<div class="d-flex">
<%@include file="../layout/admin-sidebar.jsp"%>
<div class="flex-grow-1 overflow-auto">
<div class="container-fluid p-4">
    <h4 class="fw-bold mb-4"><i class="fas fa-search me-2 text-primary"></i>Audit Log</h4>
    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="bg-light">
                    <tr><th>#</th><th>Timestamp</th><th>Action</th><th>Entity</th><th>Entity ID</th><th>By</th><th>Remarks</th><th>Details</th></tr>
                </thead>
                <tbody>
                <c:if test="${not empty logs.content}">
                <c:forEach var="log" items="${logs.content}">
                <tr>
                    <td>${log.id}</td>
                    <td><small class="text-muted">${log.createdAt}</small></td>
                    <td>
                        <span class="badge
                            ${log.actionType == 'INACTIVATE_USER' ? 'bg-danger' :
                              log.actionType == 'CANCEL_ORDER' ? 'bg-warning text-dark' :
                              log.actionType == 'INACTIVATE_SKU' ? 'bg-secondary' :
                              log.actionType == 'ORDER_STATUS_UPDATE' ? 'bg-info text-dark' :
                              log.actionType == 'CREATE_ORDER' ? 'bg-success' : 'bg-primary'}">
                            ${log.actionType}
                        </span>
                    </td>
                    <td><span class="badge bg-light text-dark border">${log.entityType}</span></td>
                    <td class="fw-semibold">${log.entityId}</td>
                    <td><small>${log.performedBy}</small></td>
                    <td><small class="text-muted">${log.remarks}</small></td>
                    <td>
                        <button class="btn btn-xs btn-outline-secondary btn-sm" data-bs-toggle="modal"
                                data-bs-target="#logDetailModal"
                                data-old="${log.oldValue}" data-new="${log.newValue}">
                            <i class="fas fa-eye"></i>
                        </button>
                    </td>
                </tr>
                </c:forEach>
                </c:if>
                <c:if test="${empty logs.content}">
                    <tr><td colspan="8" class="text-center text-muted py-4">No audit logs found</td></tr>
                </c:if>
                </tbody>
            </table>
            </div>
        </div>
        <div class="card-footer bg-white border-0 d-flex justify-content-between align-items-center">
            <small class="text-muted">
                <c:if test="${not empty logs}">Page ${page + 1} of ${logs.totalPages} &nbsp;|&nbsp; Total: ${logs.totalElements} records</c:if>
            </small>
            <div class="d-flex gap-2">
                <c:if test="${page > 0}">
                    <a href="/admin/audit-log?page=${page - 1}" class="btn btn-sm btn-outline-secondary">← Prev</a>
                </c:if>
                <c:if test="${not empty logs && page < logs.totalPages - 1}">
                    <a href="/admin/audit-log?page=${page + 1}" class="btn btn-sm btn-outline-primary">Next →</a>
                </c:if>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="logDetailModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0"><h5 class="modal-title fw-bold">Audit Detail</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="fw-semibold text-muted small">OLD VALUE</label>
                        <pre class="bg-light rounded-3 p-3 mt-1" id="oldValuePre" style="font-size:.8rem;max-height:200px;overflow:auto;"></pre>
                    </div>
                    <div class="col-md-6">
                        <label class="fw-semibold text-muted small">NEW VALUE</label>
                        <pre class="bg-light rounded-3 p-3 mt-1" id="newValuePre" style="font-size:.8rem;max-height:200px;overflow:auto;"></pre>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.getElementById('logDetailModal').addEventListener('show.bs.modal', function(e) {
    const btn = e.relatedTarget;
    const fmt = val => { try { return JSON.stringify(JSON.parse(val), null, 2); } catch { return val || '—'; } };
    document.getElementById('oldValuePre').textContent = fmt(btn.dataset.old);
    document.getElementById('newValuePre').textContent = fmt(btn.dataset.new);
});
</script>
</div><!-- container-fluid -->
</div><!-- flex-grow-1 -->
</div><!-- d-flex -->
<%@include file="../layout/footer.jsp"%>
