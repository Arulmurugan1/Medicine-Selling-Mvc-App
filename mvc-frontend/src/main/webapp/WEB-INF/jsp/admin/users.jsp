<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@include file="../layout/header.jsp"%>
<div class="d-flex">
<%@include file="../layout/admin-sidebar.jsp"%>
<div class="flex-grow-1 overflow-auto">
<div class="container-fluid p-4">
    <h4 class="fw-bold mb-4"><i class="fas fa-users me-2 text-primary"></i>User Management</h4>
    <c:if test="${not empty success}">
        <div class="alert alert-success rounded-3"><i class="fas fa-check-circle me-2"></i>${success}</div>
    </c:if>
    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="bg-light">
                    <tr><th>#</th><th>Name</th><th>Email</th><th>Role</th><th>Joined</th><th>Status</th><th>Action</th></tr>
                </thead>
                <tbody>
                <c:forEach var="user" items="${users}">
                <tr>
                    <td>${user.id}</td>
                    <td class="fw-semibold">${user.name}</td>
                    <td>${user.email}</td>
                    <td><span class="badge ${user.role == 'ADMIN' ? 'bg-danger' : 'bg-primary'}">${user.role}</span></td>
                    <td><small class="text-muted">${user.createdAt}</small></td>
                    <td>
                        <c:choose>
                            <c:when test="${user.isActive}">
                                <span class="badge bg-success rounded-pill">Active</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-danger rounded-pill">Inactive</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <div class="d-flex gap-2">
                        <c:if test="${user.isActive && user.role != 'ADMIN'}">
                            <button class="btn btn-sm btn-outline-success promote-btn"
                                    data-bs-toggle="modal" data-bs-target="#promoteModal"
                                    data-userid="${user.id}" data-username="${user.name}">
                                <i class="fas fa-user-shield me-1"></i>Make Admin
                            </button>
                            <button class="btn btn-sm btn-outline-danger" data-bs-toggle="modal"
                                    data-bs-target="#inactivateModal" data-userid="${user.id}" data-username="${user.name}">
                                <i class="fas fa-user-slash me-1"></i>Inactivate
                            </button>
                        </c:if>
                        </div>
                    </td>
                </tr>
                </c:forEach>
                </tbody>
            </table>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="promoteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold text-success"><i class="fas fa-user-shield me-2"></i>Promote to Admin</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="promoteForm" method="post">
                <div class="modal-body">
                    <div class="alert alert-warning rounded-3">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        You are about to grant full admin privileges to <strong id="promoteUserName"></strong>.
                        This action cannot be undone from the UI.
                    </div>
                    <p class="text-muted small">The user will have access to all admin features including user management, order management, and inventory control.</p>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success"><i class="fas fa-user-shield me-1"></i>Confirm Promote</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="inactivateModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">
            <div class="modal-header border-0"><h5 class="modal-title fw-bold text-danger">Inactivate User</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="inactivateForm" method="post">
                <div class="modal-body">
                    <p>Inactivate user <strong id="inactivateUserName"></strong>? They will no longer be able to login.</p>
                    <input type="text" name="remarks" class="form-control" placeholder="Reason (optional)">
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">Confirm Inactivate</button>
                </div>
            </form>
        </div>
    </div>
</div>
<script>
document.getElementById('promoteModal').addEventListener('show.bs.modal', function(e) {
    const btn = e.relatedTarget;
    document.getElementById('promoteForm').action = '/admin/users/' + btn.dataset.userid + '/promote';
    document.getElementById('promoteUserName').textContent = btn.dataset.username;
});
document.getElementById('inactivateModal').addEventListener('show.bs.modal', function(e) {
    const btn = e.relatedTarget;
    document.getElementById('inactivateForm').action = '/admin/users/' + btn.dataset.userid + '/inactivate';
    document.getElementById('inactivateUserName').textContent = btn.dataset.username;
});
</script>
</div><!-- container-fluid -->
</div><!-- flex-grow-1 -->
</div><!-- d-flex -->
<%@include file="../layout/footer.jsp"%>
