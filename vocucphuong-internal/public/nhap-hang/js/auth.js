// Authentication Module with Backend API
import {
    login,
    initializeDefaultUsers
} from './api.js';

// Kiểm tra xem đã đăng nhập chưa khi load trang
document.addEventListener('DOMContentLoaded', async function () {
    // Nếu đang ở trang login và đã đăng nhập, redirect về trang chính
    if (window.location.pathname.includes('login.html')) {
        const currentUser = getCurrentUser();
        if (currentUser) {
            window.location.href = 'index.html';
            return;
        }

        // Khởi tạo default users nếu chưa có
        await initializeDefaultUsers();

        // Setup form login
        const loginForm = document.getElementById('loginForm');
        if (loginForm) {
            loginForm.addEventListener('submit', handleLogin);
        }
    } else {
        // Nếu không phải trang login, check authentication
        checkAuthentication();
    }
});

// Xử lý đăng nhập
async function handleLogin(e) {
    e.preventDefault();

    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    const rememberMe = document.getElementById('rememberMe').checked;

    // Call API login
    const result = await login(username, password);

    if (result.success) {
        // Đăng nhập thành công
        const user = result.user;

        // Lưu thông tin đăng nhập (BẮT BUỘC phải lưu station và token!)
        const sessionData = {
            userId: user.id,
            username: user.username,
            fullName: user.fullName || user.full_name,
            role: user.role,
            station: user.station || '', // Trạm của user
            permissions: Array.isArray(user.permissions) ? user.permissions : [],
            scope: user.scope || (user.role === 'admin' ? 'all_stations' : 'own_station'),
            token: result.token, // JWT token
            loginTime: new Date().toISOString()
        };

        if (rememberMe) {
            localStorage.setItem('currentUser', JSON.stringify(sessionData));
        } else {
            sessionStorage.setItem('currentUser', JSON.stringify(sessionData));
        }

        // Redirect về trang chính
        window.location.href = 'index.html';
    } else {
        showError(result.message || 'Tên đăng nhập hoặc mật khẩu không đúng!');
    }
}

// Hiển thị lỗi
function showError(message) {
    const errorDiv = document.getElementById('errorMessage');
    if (errorDiv) {
        errorDiv.textContent = message;
        errorDiv.style.display = 'block';

        setTimeout(() => {
            errorDiv.style.display = 'none';
        }, 5000);
    }
}

// Lấy thông tin user hiện tại
function getCurrentUser() {
    const sessionUser = sessionStorage.getItem('currentUser');
    const localUser = localStorage.getItem('currentUser');

    if (sessionUser) {
        return JSON.parse(sessionUser);
    } else if (localUser) {
        return JSON.parse(localUser);
    }
    return null;
}

// Kiểm tra authentication
function checkAuthentication() {
    const currentUser = getCurrentUser();

    if (!currentUser) {
        // Chưa đăng nhập, redirect về trang login
        window.location.href = 'login.html';
        return false;
    }

    // Đã đăng nhập, hiển thị thông tin user
    updateUIWithUser(currentUser);
    return true;
}

// Cập nhật UI với thông tin user
function updateUIWithUser(user) {
    const userElement = document.getElementById('currentUser');
    if (userElement) {
        userElement.textContent = user.fullName;
    }

    // Cập nhật tên trạm trong header
    const stationNameElement = document.querySelector('.station-name');
    if (stationNameElement && user.station) {
        // Bỏ số và dấu gạch ngang, chỉ lấy tên trạm
        // Ví dụ: "01 - AN ĐỒNG" -> "AN ĐỒNG"
        const stationName = user.station.includes(' - ')
            ? user.station.split(' - ')[1]
            : user.station;
        stationNameElement.textContent = stationName;
    }

    // Nếu là admin, hiển thị menu quản lý tài khoản
    if (user.role === 'admin' || hasPerm('users.manage')) {
        addAdminMenu();
    }

    // Ẩn các mục nav user không có quyền
    applyNavPermissions();
}

// Mapping nav -> permission
const NAV_PERM_MAP = [
    { href: 'index.html', perm: 'phongve.view' },
    { href: 'warehouse.html', perm: 'kho.view' },
    { href: 'statistics.html', perm: 'thongke.view' },
    { href: 'logs.html', perm: 'logs.view' },
    { href: 'admin.html', perm: 'users.manage' },
];

function applyNavPermissions() {
    const navItems = document.querySelectorAll('.navbar .nav-item');
    navItems.forEach(item => {
        const href = item.getAttribute('href') || '';
        const match = NAV_PERM_MAP.find(m => href.endsWith(m.href));
        if (!match) return;
        if (!hasPerm(match.perm)) {
            item.style.display = 'none';
        }
    });
}

// Quyền: admin có tất cả; ngược lại check trong mảng permissions
function hasPerm(perm) {
    const u = getCurrentUser();
    if (!u) return false;
    if (u.role === 'admin') return true;
    return Array.isArray(u.permissions) && u.permissions.includes(perm);
}

// scope: admin = all_stations; ngược lại theo cài đặt
function getUserScope() {
    const u = getCurrentUser();
    if (!u) return 'own_station';
    if (u.role === 'admin') return 'all_stations';
    return u.scope === 'all_stations' ? 'all_stations' : 'own_station';
}

// Truy cập tất cả trạm (admin OR scope=all_stations)
function hasGlobalStationAccess() {
    return getUserScope() === 'all_stations';
}

// Thêm menu quản lý cho admin
function addAdminMenu() {
    const navbar = document.querySelector('.navbar');
    if (navbar && !document.querySelector('.nav-item-admin')) {
        const adminLink = document.createElement('a');
        adminLink.href = 'admin.html';
        adminLink.className = 'nav-item nav-item-admin';
        adminLink.textContent = 'Quản lý tài khoản';
        navbar.appendChild(adminLink);
    }
}

// Đăng xuất
function logout() {
    sessionStorage.removeItem('currentUser');
    localStorage.removeItem('currentUser');
    window.location.href = 'login.html';
}

// Export functions for use in other files
window.getCurrentUser = getCurrentUser;
window.logout = logout;
window.checkAuthentication = checkAuthentication;
window.hasPerm = hasPerm;
window.getUserScope = getUserScope;
window.hasGlobalStationAccess = hasGlobalStationAccess;
