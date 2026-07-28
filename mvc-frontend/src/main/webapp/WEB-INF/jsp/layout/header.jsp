<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" translate="no">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MediMart - Your Trusted Medicine Store</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        :root { --primary: #1a56db; --accent: #16bdca; }
        body { font-family: 'Segoe UI', sans-serif; background: #f8fafc; }
        .navbar-brand { font-weight: 800; font-size: 1.5rem; color: var(--primary) !important; }
        .nav-link { font-weight: 500; }
        .sidebar { min-height: calc(100vh - 56px); background: linear-gradient(180deg, #1e3a5f 0%, #1a56db 100%); }
        .sidebar .nav-link { color: rgba(255,255,255,0.85); padding: .6rem 1.2rem; border-radius: 8px; margin: 2px 8px; }
        .sidebar .nav-link:hover, .sidebar .nav-link.active { background: rgba(255,255,255,0.15); color: #fff; }
        .sidebar .nav-link i { width: 22px; }
        .card-hover { transition: transform .2s, box-shadow .2s; }
        .card-hover:hover { transform: translateY(-4px); box-shadow: 0 10px 30px rgba(26,86,219,0.15); }
        .badge-PENDING { background: #fbbf24; color: #1f2937; }
        .badge-PROCESSING { background: #60a5fa; color: #1f2937; }
        .badge-OUT_FOR_DELIVERY { background: #f97316; color: #fff; }
        .badge-DELIVERED { background: #34d399; color: #1f2937; }
        .badge-COD_PAYMENT_SUCCESS { background: #a78bfa; color: #fff; }
        .badge-CANCELLED { background: #f87171; color: #fff; }
        .badge-PAID { background: #34d399; color: #1f2937; }
        .flash-success { background: #d1fae5; border: 1px solid #34d399; color: #065f46; }
        .flash-error { background: #fee2e2; border: 1px solid #f87171; color: #991b1b; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm sticky-top">
    <div class="container-fluid px-4">
        <a class="navbar-brand" href="/"><i class="fas fa-clinic-medical me-2 text-blue-600"></i>MediMart</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navMenu">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <c:if test="${loggedIn && (role == 'USER' || role == 'ADMIN')}">
                    <li class="nav-item"><a class="nav-link" href="/medicines"><i class="fas fa-pills me-1"></i>Order Now</a></li>
                    <li class="nav-item"><a class="nav-link" href="/orders/my"><i class="fas fa-box me-1"></i>My Orders</a></li>
                </c:if>
                <c:if test="${loggedIn && role == 'ADMIN'}">
                    <li class="nav-item"><a class="nav-link" href="/admin/dashboard"><i class="fas fa-tachometer-alt me-1"></i>Admin Panel</a></li>
                </c:if>
            </ul>
            <ul class="navbar-nav ms-auto">
                <c:choose>
                    <c:when test="${loggedIn}">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                                <i class="fas fa-user-circle me-1"></i>${userName}
                                <c:if test="${role != 'GUEST'}">
                                    <span class="badge bg-primary ms-1">${role}</span>
                                </c:if>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item"><a class="nav-link" href="/login">Login</a></li>
                        <li class="nav-item"><a class="btn btn-primary ms-2" href="/register">Register</a></li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>

<%-- ===== Global Order Status Toast (shown on every page for logged-in users) ===== --%>
<c:if test="${loggedIn}">
<div id="statusToastContainer" style="
    position:fixed; bottom:28px; right:28px; z-index:99999;
    display:flex; flex-direction:column-reverse; gap:12px; pointer-events:none;">
</div>
<style>
@keyframes orderSlideUp{from{transform:translateY(40px);opacity:0}to{transform:translateY(0);opacity:1}}
@keyframes orderFadeOut{from{opacity:1}to{opacity:0}}
.order-toast{
    background:linear-gradient(135deg,#1565c0,#0d47a1);
    color:#fff; border-radius:16px; padding:16px 22px;
    box-shadow:0 8px 32px rgba(0,0,0,.3);
    min-width:280px; max-width:360px;
    animation:orderSlideUp .4s cubic-bezier(.34,1.56,.64,1) forwards;
    pointer-events:auto; cursor:default;
}
.order-toast.hide{animation:orderFadeOut .4s ease forwards;}
.order-toast .t-title{font-weight:700; font-size:1rem; margin-bottom:4px;}
.order-toast .t-body{font-size:.88rem; opacity:.9;}
</style>
<script>
(function(){
    var STATUS_LABELS = {
        PROCESSING:         {label:'Processing',        icon:'\u2699\ufe0f', color:'#42a5f5'},
        OUT_FOR_DELIVERY:   {label:'Out for Delivery',  icon:'\ud83d\ude9a', color:'#66bb6a'},
        DELIVERED:          {label:'Delivered',         icon:'\ud83d\udce6', color:'#26a69a'},
        COD_PAYMENT_SUCCESS:{label:'Payment Success',   icon:'\ud83d\udcb0', color:'#ffa726'}
    };

    var STORAGE_KEY = 'medimart_order_statuses';
    var known = {};
    try { known = JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}'); } catch(e){}

    function save(){ try{ localStorage.setItem(STORAGE_KEY, JSON.stringify(known)); }catch(e){} }

    function showToast(orderId, statusKey){
        var info = STATUS_LABELS[statusKey];
        if (!info) return;
        var c = document.getElementById('statusToastContainer');
        if (!c) return;
        var t = document.createElement('div');
        t.className = 'order-toast';
        t.innerHTML =
            '<div class="t-title">\ud83c\udf89 HURRAY!</div>' +
            '<div class="t-body">' + info.icon +
            ' Your <strong>Order #' + orderId + '</strong> is now ' +
            '<strong style="color:' + info.color + '">' + info.label + '</strong></div>';
        c.appendChild(t);
        playChime();
        setTimeout(function(){
            t.classList.add('hide');
            setTimeout(function(){ if(t.parentNode) t.parentNode.removeChild(t); }, 450);
        }, 6000);
    }

    function playChime(){
        try {
            var ctx = new (window.AudioContext || window.webkitAudioContext)();
            // Play two ascending tones: a pleasant ding-dong
            [[523.25, 0], [659.25, 0.18], [783.99, 0.36]].forEach(function(note){
                var osc  = ctx.createOscillator();
                var gain = ctx.createGain();
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.type = 'sine';
                osc.frequency.value = note[0];
                gain.gain.setValueAtTime(0, ctx.currentTime + note[1]);
                gain.gain.linearRampToValueAtTime(0.35, ctx.currentTime + note[1] + 0.04);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + note[1] + 0.55);
                osc.start(ctx.currentTime + note[1]);
                osc.stop(ctx.currentTime + note[1] + 0.6);
            });
        } catch(e){}
    }

    function updateBadges(statuses){
        statuses.forEach(function(o){
            var badge = document.querySelector('[data-order-id="' + o.id + '"] .order-status-badge');
            if (badge){
                badge.textContent = o.status;
                badge.className = 'badge rounded-pill px-3 py-2 order-status-badge badge-' + o.status;
            }
        });
    }

    function poll(){
        fetch('/orders/my/statuses', {credentials:'same-origin'})
            .then(function(r){ return r.ok ? r.json() : Promise.reject(); })
            .then(function(statuses){
                var toasts = [];
                statuses.forEach(function(o){
                    var key = String(o.id);
                    var prev = known[key];
                    var curr = o.status;
                    if (prev === undefined){
                        known[key] = curr;        // first time — seed silently
                    } else if (prev !== curr){
                        known[key] = curr;
                        if (STATUS_LABELS[curr]) toasts.push({id: o.id, status: curr});
                    }
                });
                save();
                updateBadges(statuses);
                toasts.forEach(function(t, i){
                    setTimeout(function(){ showToast(t.id, t.status); }, i * 800);
                });
            })
            .catch(function(){});
    }

    // Start polling immediately, then every 10 seconds
    poll();
    setInterval(poll, 10000);
})();
</script>
</c:if>
