// API Service - Thay thế Firebase với Backend API
// API URL cho Vercel deployment
const API_BASE_URL = '/api/nhap-hang';

// Helper function để lấy token từ sessionStorage/localStorage
function getAuthToken() {
    const sessionUser = sessionStorage.getItem('currentUser');
    const localUser = localStorage.getItem('currentUser');

    const user = sessionUser ? JSON.parse(sessionUser) : (localUser ? JSON.parse(localUser) : null);
    return user?.token;
}

// Helper function để call API
async function callAPI(endpoint, options = {}) {
    const token = getAuthToken();

    const headers = {
        'Content-Type': 'application/json',
        ...(options.headers || {})
    };

    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    const config = {
        ...options,
        headers
    };

    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, config);

        // Nếu 401, redirect về login (token hết hạn)
        if (response.status === 401) {
            console.error('401 - Token invalid or expired');

            // Chỉ redirect nếu không phải login page
            if (!window.location.pathname.includes('login.html')) {
                sessionStorage.removeItem('currentUser');
                localStorage.removeItem('currentUser');
                alert('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!');
                window.location.href = 'login.html';
            }
            return null;
        }

        const data = await response.json();

        // Nếu 403, trả về data để xử lý (có thể là lỗi hết thời gian sửa, không phải token)
        if (response.status === 403) {
            console.warn('403 - Forbidden:', data.message || data.code);
            return data; // Trả về để caller xử lý
        }

        if (!response.ok) {
            throw new Error(data.message || 'API call failed');
        }

        return data;
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
}

// ==================== AUTHENTICATION OPERATIONS ====================

export async function login(username, password) {
    try {
        const data = await callAPI('/auth/login', {
            method: 'POST',
            body: JSON.stringify({ username, password })
        });

        return data; // { success: true, token, user }
    } catch (error) {
        console.error('Login error:', error);
        return { success: false, message: error.message };
    }
}

export async function getCurrentUserInfo() {
    try {
        const data = await callAPI('/auth/me', {
            method: 'GET'
        });

        return data.user;
    } catch (error) {
        console.error('Get user info error:', error);
        return null;
    }
}

// ==================== PRODUCTS OPERATIONS ====================

// Get all products
export async function getAllProducts() {
    try {
        const data = await callAPI('/products', {
            method: 'GET'
        });

        return data.products || [];
    } catch (error) {
        console.error('Error getting products:', error);
        return [];
    }
}

// Listen to products (CHỈ LOAD MỘT LẦN - KHÔNG POLLING)
export function listenToProducts(callback) {
    // Chỉ load một lần duy nhất, không poll liên tục
    // Vì polling gây khó khăn khi user đang nhập dữ liệu
    getAllProducts().then(products => {
        callback(products);
    });

    // Return empty unsubscribe function (không có interval để clear)
    return () => {
        // No-op - không có polling interval nào cả
    };
}

// Add a new product
export async function addProduct(productData) {
    try {
        const data = await callAPI('/products', {
            method: 'POST',
            body: JSON.stringify(productData)
        });

        return { success: true, id: data.product?.id || productData.id };
    } catch (error) {
        console.error('Error adding product:', error);
        return { success: false, error: error.message };
    }
}

// Update a product
export async function updateProduct(productId, productData) {
    try {
        const result = await callAPI(`/products/${productId}`, {
            method: 'PUT',
            body: JSON.stringify(productData)
        });

        // Trả về kết quả từ server (bao gồm cả lỗi 403 - hết thời gian sửa giá)
        if (result && result.success === false) {
            return result; // { success: false, message: '...', code: 'EDIT_TIME_EXPIRED' }
        }

        return { success: true, product: result?.product };
    } catch (error) {
        console.error('Error updating product:', error);
        return { success: false, error: error.message };
    }
}

// Delete a product
export async function deleteProduct(productId) {
    try {
        await callAPI(`/products/${productId}`, {
            method: 'DELETE'
        });

        return { success: true };
    } catch (error) {
        console.error('Error deleting product:', error);
        return { success: false, error: error.message };
    }
}

// ==================== USERS OPERATIONS ====================

// Get all users (admin only)
export async function getAllUsers() {
    try {
        const data = await callAPI('/users', {
            method: 'GET'
        });

        return data.users || [];
    } catch (error) {
        console.error('Error getting users:', error);
        return [];
    }
}

// Get user by username
export async function getUserByUsername(username) {
    try {
        const users = await getAllUsers();
        return users.find(u => u.username === username);
    } catch (error) {
        console.error('Error getting user by username:', error);
        return null;
    }
}

// Add a new user (admin only)
export async function addUser(userData) {
    try {
        const data = await callAPI('/users', {
            method: 'POST',
            body: JSON.stringify(userData)
        });

        return { success: true, id: data.user?.id };
    } catch (error) {
        console.error('Error adding user:', error);
        return { success: false, error: error.message };
    }
}

// Update a user (admin only)
export async function updateUser(userId, userData) {
    try {
        await callAPI(`/users/${userId}`, {
            method: 'PUT',
            body: JSON.stringify(userData)
        });

        return { success: true };
    } catch (error) {
        console.error('Error updating user:', error);
        return { success: false, error: error.message };
    }
}

// Delete a user (admin only)
export async function deleteUser(userId) {
    try {
        await callAPI(`/users/${userId}`, {
            method: 'DELETE'
        });

        return { success: true };
    } catch (error) {
        console.error('Error deleting user:', error);
        return { success: false, error: error.message };
    }
}

// ==================== COUNTERS OPERATIONS ====================

// Get counter for a station on a specific date
export async function getCounter(station, dateKey) {
    try {
        // For now, we'll use client-side logic
        // You can implement this on backend later if needed
        const products = await getAllProducts();

        const matchingProducts = products.filter(p => {
            const productStation = p.station || '';
            const productDate = p.sendDate ? p.sendDate.split('T')[0] : '';
            const searchDate = dateKey.split('T')[0];

            return productStation === station && productDate === searchDate;
        });

        return matchingProducts.length;
    } catch (error) {
        console.error('Error getting counter:', error);
        return 0;
    }
}

// Increment counter (generate next ID)
export async function incrementCounter(station, dateKey) {
    try {
        const currentCount = await getCounter(station, dateKey);
        return currentCount + 1;
    } catch (error) {
        console.error('Error incrementing counter:', error);
        return null;
    }
}

// ==================== INITIALIZATION ====================

// Initialize default users if not exists
export async function initializeDefaultUsers() {
    // Tạm thời disable function này vì gây spam requests
    // Users đã được tạo trong database rồi
    console.log('initializeDefaultUsers: Skipped (users already exist in database)');
    return;

    /* COMMENTED OUT TO PREVENT SPAM REQUESTS
    try {
        const users = await getAllUsers();

        if (users.length === 0) {
            console.log('No users found. Please create users through admin panel or SQL Server.');
        }
    } catch (error) {
        console.error('Error initializing default users:', error);
    }
    */
}

// ==================== STATIONS OPERATIONS ====================

// Get all stations
export async function getAllStations() {
    try {
        const data = await callAPI('/stations', {
            method: 'GET'
        });

        return data.stations || [];
    } catch (error) {
        console.error('Error getting stations:', error);
        return [];
    }
}
