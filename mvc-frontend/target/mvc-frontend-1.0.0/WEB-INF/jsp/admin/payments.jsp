<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@include file="../layout/header.jsp"%>
<div class="container-fluid p-4">
    <h4 class="fw-bold mb-4"><i class="fas fa-credit-card me-2 text-primary"></i>Payment Information</h4>
    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="bg-light">
                    <tr><th>#</th><th>Order ID</th><th>Amount</th><th>Method</th><th>Status</th><th>Created</th></tr>
                </thead>
                <tbody>
                <c:forEach var="payment" items="${payments}">
                <tr>
                    <td>${payment.id}</td>
                    <td class="fw-semibold">#${payment.orderId}</td>
                    <td class="fw-semibold text-primary">₹${payment.amount}</td>
                    <td><span class="badge bg-secondary">${payment.paymentMethod}</span></td>
                    <td><span class="badge rounded-pill px-3 badge-${payment.paymentStatus}">${payment.paymentStatus}</span></td>
                    <td><small class="text-muted">${payment.createdAt}</small></td>
                </tr>
                </c:forEach>
                <c:if test="${empty payments}">
                    <tr><td colspan="6" class="text-center text-muted py-4">No payment records found</td></tr>
                </c:if>
                </tbody>
            </table>
            </div>
        </div>
    </div>
</div>
<%@include file="../layout/footer.jsp"%>
