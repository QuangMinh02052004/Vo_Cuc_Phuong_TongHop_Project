// Statistics page - Show ALL products from ALL stations
import { getAllProducts } from './api.js';
import { populateSelect, OPTIONS } from '../data/options.js';

let allProducts = [];
let searchFilters = {};

const PAGE_SIZE = 20;
let currentPage = 1;

function renderPagination(totalItems, containerId = 'paginationContainer') {
    const totalPages = Math.ceil(totalItems / PAGE_SIZE);
    let container = document.getElementById(containerId);
    if (!container) return;
    if (totalPages <= 1) { container.innerHTML = ''; return; }
    const start = (currentPage - 1) * PAGE_SIZE + 1;
    const end = Math.min(currentPage * PAGE_SIZE, totalItems);
    let html = `<div style="display:flex;align-items:center;justify-content:space-between;padding:10px 4px;font-size:14px;color:#6b7280;">
        <span>${start}–${end} / <strong>${totalItems}</strong> đơn</span>
        <div style="display:flex;gap:4px;align-items:center;">`;
    html += `<button onclick="goToPage(1)" ${currentPage===1?'disabled':''} style="padding:5px 9px;border:1px solid #d1d5db;border-radius:6px;background:${currentPage===1?'#f3f4f6':'white'};cursor:${currentPage===1?'default':'pointer'};font-size:13px;">«</button>`;
    html += `<button onclick="goToPage(${currentPage-1})" ${currentPage===1?'disabled':''} style="padding:5px 9px;border:1px solid #d1d5db;border-radius:6px;background:${currentPage===1?'#f3f4f6':'white'};cursor:${currentPage===1?'default':'pointer'};font-size:13px;">‹</button>`;
    const range = [];
    for (let i = Math.max(1, currentPage-2); i <= Math.min(totalPages, currentPage+2); i++) range.push(i);
    range.forEach(p => {
        const active = p === currentPage;
        html += `<button onclick="goToPage(${p})" style="padding:5px 10px;border:1px solid ${active?'#0ea5e9':'#d1d5db'};border-radius:6px;background:${active?'#0ea5e9':'white'};color:${active?'white':'#374151'};font-weight:${active?'600':'400'};cursor:pointer;font-size:13px;">${p}</button>`;
    });
    html += `<button onclick="goToPage(${currentPage+1})" ${currentPage===totalPages?'disabled':''} style="padding:5px 9px;border:1px solid #d1d5db;border-radius:6px;background:${currentPage===totalPages?'#f3f4f6':'white'};cursor:${currentPage===totalPages?'default':'pointer'};font-size:13px;">›</button>`;
    html += `<button onclick="goToPage(${totalPages})" ${currentPage===totalPages?'disabled':''} style="padding:5px 9px;border:1px solid #d1d5db;border-radius:6px;background:${currentPage===totalPages?'#f3f4f6':'white'};cursor:${currentPage===totalPages?'default':'pointer'};font-size:13px;">»</button>`;
    html += `</div></div>`;
    container.innerHTML = html;
}

function goToPage(page) {
    const totalPages = Math.ceil(window._lastFilteredCount / PAGE_SIZE);
    currentPage = Math.max(1, Math.min(page, totalPages || 1));
    renderStatisticsTable();
    window.scrollTo({ top: 0, behavior: 'smooth' });
}
window.goToPage = goToPage;

// Initialize
document.addEventListener('DOMContentLoaded', async function () {
    // Load all products
    await loadAllProducts();

    // Load search options
    populateSelect('searchStation', OPTIONS.stations);
    populateSelect('searchDestStation', OPTIONS.stations);

    // Set default date filter to today
    const today = new Date();
    const yyyy = today.getFullYear();
    const mm = String(today.getMonth() + 1).padStart(2, '0');
    const dd = String(today.getDate()).padStart(2, '0');
    const todayStart = `${yyyy}-${mm}-${dd}T00:00`;
    const todayEnd = `${yyyy}-${mm}-${dd}T23:59`;

    document.getElementById('searchDateFrom').value = todayStart;
    document.getElementById('searchDateTo').value = todayEnd;
    searchFilters = { dateFrom: todayStart, dateTo: todayEnd };

    // Render table and statistics
    renderStatisticsTable();
    renderStatistics();

    // Setup event listeners
    document.getElementById('searchForm').addEventListener('submit', handleSearch);
    document.getElementById('resetSearchBtn').addEventListener('click', resetSearch);
});

// Load ALL products from Firestore (no filters)
async function loadAllProducts() {
    allProducts = await getAllProducts();
    console.log('Loaded all products:', allProducts.length);
}

// Handle search form submit
function handleSearch(e) {
    e.preventDefault();

    const keyword = document.getElementById('searchKeyword').value.trim().toLowerCase();
    const dateFrom = document.getElementById('searchDateFrom').value;
    const dateTo = document.getElementById('searchDateTo').value;
    const station = document.getElementById('searchStation').value;
    const destStation = document.getElementById('searchDestStation').value;
    const deliveryStatus = document.getElementById('searchDeliveryStatus').value;

    searchFilters = {
        keyword,
        dateFrom,
        dateTo,
        station,
        destStation,
        deliveryStatus
    };

    currentPage = 1;
    renderStatisticsTable();
    renderStatistics();
}

// Reset search filters
function resetSearch() {
    document.getElementById('searchForm').reset();
    searchFilters = {};
    currentPage = 1;
    renderStatisticsTable();
    renderStatistics();
}

// Render statistics table - Show ALL products from ALL stations
function renderStatisticsTable() {
    const tbody = document.getElementById('statisticsTableBody');

    console.log('=== STATISTICS DEBUG ===');
    console.log('Total products:', allProducts.length);

    // NO station filter - show all products
    let filteredProducts = allProducts;

    // Apply search filters
    if (searchFilters.keyword) {
        filteredProducts = filteredProducts.filter(product =>
            product.id.toLowerCase().includes(searchFilters.keyword) ||
            (product.senderName || '').toLowerCase().includes(searchFilters.keyword) ||
            (product.senderPhone || '').includes(searchFilters.keyword) ||
            (product.receiverName || '').toLowerCase().includes(searchFilters.keyword) ||
            (product.receiverPhone || '').includes(searchFilters.keyword)
        );
    }

    if (searchFilters.dateFrom) {
        filteredProducts = filteredProducts.filter(product => {
            const productDate = product.sendDate || product.createdAt;
            return productDate >= searchFilters.dateFrom;
        });
    }

    if (searchFilters.dateTo) {
        filteredProducts = filteredProducts.filter(product => {
            const productDate = product.sendDate || product.createdAt;
            return productDate <= searchFilters.dateTo;
        });
    }

    if (searchFilters.station) {
        filteredProducts = filteredProducts.filter(product =>
            (product.senderStation || '') === searchFilters.station
        );
    }

    if (searchFilters.destStation) {
        filteredProducts = filteredProducts.filter(product =>
            (product.station || '') === searchFilters.destStation
        );
    }

    if (searchFilters.deliveryStatus) {
        filteredProducts = filteredProducts.filter(product =>
            (product.deliveryStatus || 'pending') === searchFilters.deliveryStatus
        );
    }

    console.log('Products after filter:', filteredProducts.length);

    // Sort by date (newest first)
    filteredProducts.sort((a, b) => {
        const dateA = new Date(a.sendDate || a.createdAt);
        const dateB = new Date(b.sendDate || b.createdAt);
        return dateB - dateA;
    });

    // Render table rows
    if (filteredProducts.length === 0) {
        tbody.innerHTML = '<tr><td colspan="12" style="text-align: center;">Không có dữ liệu</td></tr>';
        renderPagination(0);
        return;
    }

    // Pagination
    window._lastFilteredCount = filteredProducts.length;
    const totalPages = Math.ceil(filteredProducts.length / PAGE_SIZE);
    if (currentPage > totalPages) currentPage = totalPages;
    const pageOffset = (currentPage - 1) * PAGE_SIZE;
    const pageProducts = filteredProducts.slice(pageOffset, pageOffset + PAGE_SIZE);

    tbody.innerHTML = pageProducts.map((product, index) => {
        const index_real = pageOffset + index;
        const deliveryStatus = product.deliveryStatus || 'pending';
        const deliveryStatusText = deliveryStatus === 'delivered' ? 'Đã giao' : 'Chưa giao';
        const deliveryStatusClass = deliveryStatus === 'delivered' ? 'status-delivered' : 'status-pending';

        return `
            <tr>
                <td>${index_real + 1}</td>
                <td>${product.id || ''}</td>
                <td>${product.senderName || ''}</td>
                <td>${product.senderPhone || ''}</td>
                <td>${product.receiverName || ''}</td>
                <td>${product.receiverPhone || ''}</td>
                <td>${formatStationName(product.senderStation || '')}</td>
                <td>${formatStationName(product.station || '')}</td>
                <td>${product.productType || ''}</td>
                <td>${formatCurrency(product.totalAmount || 0)}</td>
                <td><span class="delivery-status ${deliveryStatusClass}">${deliveryStatusText}</span></td>
                <td>${formatDateTime(product.sendDate || product.createdAt)}</td>
            </tr>
        `;
    }).join('');

    renderPagination(filteredProducts.length);
}

// Format station name (remove number prefix)
function formatStationName(station) {
    if (!station) return '';
    return station.includes(' - ') ? station.split(' - ')[1] : station;
}

// Format currency
function formatCurrency(amount) {
    const num = parseFloat(amount) || 0;
    return new Intl.NumberFormat('vi-VN').format(num);
}

// Format date time
function formatDateTime(dateString) {
    if (!dateString) return '';
    const date = new Date(dateString);
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes} - ${day}/${month}/${year}`;
}

// Render statistics summary
function renderStatistics() {
    const statsElement = document.getElementById('statistics');

    // Apply same filters as table
    let filteredProducts = allProducts;

    if (searchFilters.keyword) {
        filteredProducts = filteredProducts.filter(product =>
            product.id.toLowerCase().includes(searchFilters.keyword) ||
            (product.senderName || '').toLowerCase().includes(searchFilters.keyword) ||
            (product.senderPhone || '').includes(searchFilters.keyword) ||
            (product.receiverName || '').toLowerCase().includes(searchFilters.keyword) ||
            (product.receiverPhone || '').includes(searchFilters.keyword)
        );
    }

    if (searchFilters.dateFrom) {
        filteredProducts = filteredProducts.filter(product => {
            const productDate = product.sendDate || product.createdAt;
            return productDate >= searchFilters.dateFrom;
        });
    }

    if (searchFilters.dateTo) {
        filteredProducts = filteredProducts.filter(product => {
            const productDate = product.sendDate || product.createdAt;
            return productDate <= searchFilters.dateTo;
        });
    }

    if (searchFilters.station) {
        filteredProducts = filteredProducts.filter(product =>
            (product.senderStation || '') === searchFilters.station
        );
    }

    if (searchFilters.destStation) {
        filteredProducts = filteredProducts.filter(product =>
            (product.station || '') === searchFilters.destStation
        );
    }

    if (searchFilters.deliveryStatus) {
        filteredProducts = filteredProducts.filter(product =>
            (product.deliveryStatus || 'pending') === searchFilters.deliveryStatus
        );
    }

    const totalShipments = filteredProducts.length;
    const deliveredProducts = filteredProducts.filter(p => p.deliveryStatus === 'delivered');
    const pendingProducts = filteredProducts.filter(p => !p.deliveryStatus || p.deliveryStatus === 'pending');

    const totalAmount = filteredProducts.reduce((sum, p) => sum + (parseFloat(p.totalAmount) || 0), 0);
    const deliveredAmount = deliveredProducts.reduce((sum, p) => sum + (parseFloat(p.totalAmount) || 0), 0);
    const pendingAmount = pendingProducts.reduce((sum, p) => sum + (parseFloat(p.totalAmount) || 0), 0);

    statsElement.innerHTML = `
        <div class="stats-summary">
            <div class="stats-header">Thống kê tổng hợp</div>
            <div class="stats-line">
                <span class="stats-text">${totalShipments} đơn hàng (Đã giao: ${deliveredProducts.length} | Chưa giao: ${pendingProducts.length})</span>
            </div>
            <div class="stats-line stats-paid">
                Đã giao: <strong>${formatCurrency(deliveredAmount)}đ</strong> / ${formatCurrency(totalAmount)}đ
            </div>
            <div class="stats-line">
                Chưa giao: <strong>${formatCurrency(pendingAmount)}đ</strong>
            </div>
            <div class="stats-line stats-total">
                Tổng giá trị: <strong>${formatCurrency(totalAmount)}đ</strong>
            </div>
        </div>
    `;
}
