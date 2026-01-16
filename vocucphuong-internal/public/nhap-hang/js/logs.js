// Logs Module - Xem lịch sử chỉnh sửa đơn hàng

// API Configuration - Use Vercel API
const API_BASE_URL = '/api/nhap-hang';

// Helper function để lấy token
function getAuthToken() {
    const sessionUser = sessionStorage.getItem('currentUser');
    const localUser = localStorage.getItem('currentUser');
    const user = sessionUser ? JSON.parse(sessionUser) : (localUser ? JSON.parse(localUser) : null);
    return user?.token;
}

// Helper function để lấy thông tin user hiện tại
function getCurrentUser() {
    const sessionUser = sessionStorage.getItem('currentUser');
    const localUser = localStorage.getItem('currentUser');
    return sessionUser ? JSON.parse(sessionUser) : (localUser ? JSON.parse(localUser) : null);
}

// Call API
async function callAPI(endpoint, options = {}) {
    const token = getAuthToken();

    const headers = {
        'Content-Type': 'application/json',
        ...(options.headers || {})
    };

    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    try {
        console.log('Calling API:', `${API_BASE_URL}${endpoint}`);
        const response = await fetch(`${API_BASE_URL}${endpoint}`, { ...options, headers });

        if (response.status === 401 || response.status === 403) {
            sessionStorage.removeItem('currentUser');
            localStorage.removeItem('currentUser');
            alert('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!');
            window.location.href = 'login.html';
            return null;
        }

        const data = await response.json();
        console.log('API Response:', data);
        return data;
    } catch (error) {
        console.error('API Error:', error);
        return { success: false, error: error.message };
    }
}

// Fetch danh sách trạm từ API
async function fetchStations() {
    return await callAPI('/stations');
}

// Load danh sách trạm vào dropdown
async function loadStations() {
    const result = await fetchStations();
    if (result && result.success && result.stations) {
        const senderStationSelect = document.getElementById('filterSenderStation');
        const stationSelect = document.getElementById('filterStation');

        result.stations.forEach(station => {
            const stationValue = station.code ? `${station.code} - ${station.name}` : station.name;
            const optionText = station.name;

            // Add to sender station dropdown
            const option1 = document.createElement('option');
            option1.value = stationValue;
            option1.textContent = optionText;
            senderStationSelect.appendChild(option1);

            // Add to receiver station dropdown
            const option2 = document.createElement('option');
            option2.value = stationValue;
            option2.textContent = optionText;
            stationSelect.appendChild(option2);
        });
    }
}

// Fetch logs từ API
async function fetchLogs(filters = {}) {
    const params = new URLSearchParams();

    // Chỉ thêm filter nếu có giá trị
    if (filters.dateFrom && filters.dateFrom.trim()) {
        params.append('dateFrom', filters.dateFrom);
    }
    if (filters.dateTo && filters.dateTo.trim()) {
        // Thêm thời gian cuối ngày cho dateTo
        params.append('dateTo', filters.dateTo + 'T23:59:59');
    }
    if (filters.action && filters.action.trim()) {
        params.append('action', filters.action);
    }
    if (filters.changedBy && filters.changedBy.trim()) {
        params.append('changedBy', filters.changedBy);
    }

    // Tìm kiếm tổng hợp (mã, tên, điện thoại)
    if (filters.search && filters.search.trim()) {
        params.append('search', filters.search.trim());
    }

    // Lọc theo trạm gửi
    if (filters.senderStation && filters.senderStation.trim()) {
        params.append('senderStation', filters.senderStation);
    }

    // Lọc theo trạm nhận
    if (filters.station && filters.station.trim()) {
        params.append('station', filters.station);
    }

    // Luôn có limit
    params.append('limit', filters.limit || '200');

    const queryString = params.toString();
    const endpoint = `/products/all-logs${queryString ? '?' + queryString : ''}`;

    return await callAPI(endpoint);
}

// Format ngày giờ
function formatDateTime(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
}

// Format tên trường
function formatFieldName(field) {
    if (!field) return '-';

    // Kiểm tra nếu là "X fields" (nhiều thay đổi)
    if (field.includes(' fields')) {
        return `<span style="color: #7c3aed;">${field.replace(' fields', ' trường')}</span>`;
    }

    const fieldMap = {
        'deliveryStatus': 'Trạng thái giao',
        'paymentStatus': 'Thanh toán',
        'totalAmount': 'Số tiền',
        'notes': 'Ghi chú',
        'receiverName': 'Người nhận',
        'receiverPhone': 'SĐT nhận',
        'senderName': 'Người gửi',
        'senderPhone': 'SĐT gửi',
        'station': 'Trạm đến',
        'senderStation': 'Trạm gửi',
        'productType': 'Loại hàng',
        'vehicle': 'Xe',
        'quantity': 'Số lượng',
        'insurance': 'Bảo hiểm',
        'status': 'Trạng thái',
        'product_info': 'Thông tin đơn'
    };
    return fieldMap[field] || field;
}

// Format giá trị đơn lẻ theo field
function formatSingleValue(value, fieldName) {
    if (value === null || value === undefined || value === '') return '-';

    // Format trạng thái giao hàng
    if (fieldName === 'deliveryStatus') {
        const statusMap = {
            'pending': 'Chờ xử lý',
            'waiting_send': 'Chờ gởi',
            'waiting_receive': 'Chờ nhận',
            'lost': 'Thất lạc',
            'no_contact': 'Không liên lạc',
            'delivered': 'Đã giao'
        };
        return statusMap[value] || value;
    }

    // Format trạng thái thanh toán
    if (fieldName === 'paymentStatus') {
        return value === 'paid' ? 'Đã thu' : 'Chưa thu';
    }

    // Format số tiền
    if (fieldName === 'totalAmount' || fieldName === 'insurance') {
        const num = parseFloat(value);
        if (!isNaN(num)) {
            return new Intl.NumberFormat('vi-VN').format(num) + 'đ';
        }
    }

    return value;
}

// Format giá trị (có thể là JSON array khi có nhiều thay đổi)
function formatValue(value, field) {
    if (value === null || value === undefined || value === '') return '-';

    // Kiểm tra nếu là JSON array (nhiều thay đổi)
    if (value.startsWith('[') && value.endsWith(']')) {
        try {
            const changes = JSON.parse(value);
            if (Array.isArray(changes)) {
                return changes.map(change => {
                    const fieldName = Object.keys(change)[0];
                    const fieldValue = change[fieldName];
                    return `<div><b>${formatFieldName(fieldName)}:</b> ${formatSingleValue(fieldValue, fieldName)}</div>`;
                }).join('');
            }
        } catch {
            // Không phải JSON, xử lý bình thường
        }
    }

    // Format product_info (JSON)
    if (field === 'product_info') {
        try {
            const info = JSON.parse(value);
            return `${info.receiverName} - ${info.receiverPhone} (${new Intl.NumberFormat('vi-VN').format(info.totalAmount)}đ)`;
        } catch {
            return value;
        }
    }

    // Format đơn lẻ theo field
    return formatSingleValue(value, field);
}

// Format hành động
function formatAction(action) {
    const actionMap = {
        'create': { text: 'Tạo mới', class: 'action-create' },
        'update': { text: 'Cập nhật', class: 'action-update' },
        'delete': { text: 'Xóa', class: 'action-delete' }
    };
    const info = actionMap[action] || { text: action, class: '' };
    return `<span class="action-badge ${info.class}">${info.text}</span>`;
}

// Format số tiền
function formatCurrency(amount) {
    if (!amount && amount !== 0) return '-';
    return new Intl.NumberFormat('vi-VN').format(amount) + 'đ';
}

// Format tên trạm (bỏ số đầu)
function formatStationName(station) {
    if (!station || station === '-') return '-';
    return station.includes(' - ') ? station.split(' - ')[1] : station;
}

// Render bảng logs
function renderLogsTable(logs) {
    const tbody = document.getElementById('logsTableBody');
    const summary = document.getElementById('logsSummary');

    if (!logs || logs.length === 0) {
        tbody.innerHTML = '<tr><td colspan="13" class="no-logs">Không có dữ liệu lịch sử.</td></tr>';
        summary.textContent = 'Không tìm thấy lịch sử nào.';
        return;
    }

    // Count by action
    const createCount = logs.filter(l => l.action === 'create').length;
    const updateCount = logs.filter(l => l.action === 'update').length;
    const deleteCount = logs.filter(l => l.action === 'delete').length;

    summary.innerHTML = `
        Tổng cộng <strong>${logs.length}</strong> bản ghi |
        <span style="color: #065f46;">Tạo mới: ${createCount}</span> |
        <span style="color: #92400e;">Cập nhật: ${updateCount}</span> |
        <span style="color: #991b1b;">Xóa: ${deleteCount}</span>
    `;

    tbody.innerHTML = logs.map((log, index) => {
        const oldValue = formatValue(log.oldValue, log.field);
        const newValue = formatValue(log.newValue, log.field);

        // Thông tin người gửi
        const senderInfo = log.senderName
            ? `${log.senderName}<br><small>${log.senderPhone || ''}</small>`
            : '-';

        // Thông tin người nhận
        const receiverInfo = log.receiverName
            ? `${log.receiverName}<br><small>${log.receiverPhone || ''}</small>`
            : '-';

        return `
            <tr>
                <td>${index + 1}</td>
                <td class="time-cell">${formatDateTime(log.changedAt)}</td>
                <td><a href="#" class="product-link" onclick="viewProduct('${log.productId}')">${log.productId}</a></td>
                <td>${formatAction(log.action)}</td>
                <td>${senderInfo}</td>
                <td>${receiverInfo}</td>
                <td>${formatStationName(log.station)}</td>
                <td><strong>${formatCurrency(log.totalAmount)}</strong></td>
                <td><span class="field-name">${formatFieldName(log.field)}</span></td>
                <td class="value-old">${oldValue}</td>
                <td class="value-new">${newValue}</td>
                <td>${log.changedBy || '-'}</td>
                <td class="ip-address">${log.ipAddress || '-'}</td>
            </tr>
        `;
    }).join('');
}

// Xem chi tiết sản phẩm
function viewProduct(productId) {
    // Có thể mở popup hoặc chuyển trang
    alert(`Mã đơn hàng: ${productId}\n\nChức năng xem chi tiết sẽ được phát triển thêm.`);
}

// Load logs
async function loadLogs() {
    const tbody = document.getElementById('logsTableBody');
    const summary = document.getElementById('logsSummary');

    // Hiển thị loading
    tbody.innerHTML = '<tr><td colspan="13" class="no-logs">Đang tải dữ liệu...</td></tr>';
    summary.textContent = 'Đang tải...';

    const filters = {
        search: document.getElementById('filterSearch').value,
        senderStation: document.getElementById('filterSenderStation').value,
        station: document.getElementById('filterStation').value,
        dateFrom: document.getElementById('filterDateFrom').value,
        dateTo: document.getElementById('filterDateTo').value,
        action: document.getElementById('filterAction').value,
        changedBy: document.getElementById('filterChangedBy').value,
        limit: document.getElementById('filterLimit').value
    };

    const result = await fetchLogs(filters);

    if (result && result.success) {
        if (result.logs && result.logs.length > 0) {
            renderLogsTable(result.logs);
        } else {
            tbody.innerHTML = '<tr><td colspan="13" class="no-logs">Chưa có lịch sử chỉnh sửa nào. Hãy thử tạo hoặc cập nhật một đơn hàng.</td></tr>';
            summary.textContent = 'Không có dữ liệu lịch sử.';
        }
    } else {
        const errorMsg = result?.error || 'Không xác định';
        tbody.innerHTML = `<tr><td colspan="13" class="no-logs">Lỗi: ${errorMsg}<br><br>Có thể bảng ProductLogs chưa được tạo. Hãy khởi động lại server để tự động tạo bảng.</td></tr>`;
        summary.textContent = 'Lỗi khi tải dữ liệu.';
        console.error('Load logs error:', result);
    }
}

// Reset filter
function resetFilter() {
    document.getElementById('filterForm').reset();
    loadLogs();
}

// Khởi tạo
document.addEventListener('DOMContentLoaded', async function() {
    // Kiểm tra đăng nhập
    const currentUser = getCurrentUser();
    if (!currentUser) {
        window.location.href = 'login.html';
        return;
    }

    // Hiển thị thông tin user
    document.getElementById('currentUser').textContent = currentUser.fullName;

    // Hiển thị tên trạm
    const station = currentUser.station || '';
    if (station) {
        const stationName = station.includes(' - ') ? station.split(' - ')[1] : station;
        document.getElementById('currentStationName').textContent = stationName;
    }

    // Kiểm tra quyền admin - chỉ admin mới được xem
    if (currentUser.role !== 'admin') {
        document.getElementById('adminWarning').style.display = 'block';
        document.querySelector('.management-section').innerHTML = `
            <div style="text-align: center; padding: 50px; color: #dc2626;">
                <h2>Không có quyền truy cập</h2>
                <p>Chỉ quản trị viên mới có thể xem trang này.</p>
                <a href="index.html" class="btn btn-primary" style="margin-top: 20px;">Quay lại trang chủ</a>
            </div>
        `;
        return;
    }

    // Load danh sách trạm cho dropdown
    await loadStations();

    // Không set filter ngày mặc định - hiển thị tất cả
    // Load logs
    await loadLogs();

    // Xử lý form filter
    document.getElementById('filterForm').addEventListener('submit', function(e) {
        e.preventDefault();
        loadLogs();
    });
});

// Export functions
window.resetFilter = resetFilter;
window.viewProduct = viewProduct;
