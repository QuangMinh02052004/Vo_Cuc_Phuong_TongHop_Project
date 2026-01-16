/**
 * TongHop Integration Service
 *
 * Main service for integrating with TongHop (Bus Booking) system
 * Orchestrates timeslot matching and booking creation
 */

const httpClient = require('../utils/http-client');
const tonghopConfig = require('../config/tonghop');
const { findNearestTimeslot } = require('./timeslot-matcher');
const { transformProductToBooking, validateBookingData } = require('./booking-transformer');

/**
 * Fetch all timeslots from TongHop API
 *
 * @returns {Promise<Array>} - Array of timeslot objects
 * @throws {Error} - If API call fails
 */
async function fetchTimeslots() {
    const url = `${tonghopConfig.apiUrl}${tonghopConfig.endpoints.timeslots}`;

    try {
        const response = await httpClient.get(url, {
            timeout: tonghopConfig.timeout
        });

        // TongHop can return either array directly or {success: true, timeslots: [...]}
        if (Array.isArray(response)) {
            return response;
        }
        return response.timeslots || [];
    } catch (error) {
        console.error('Failed to fetch timeslots from TongHop:', error.message);
        throw new Error(`Không thể lấy danh sách khung giờ xe: ${error.message}`);
    }
}

/**
 * Fetch bookings for a specific timeslot
 *
 * @param {number} timeslotId - Timeslot ID
 * @returns {Promise<Array>} - Array of booking objects
 * @throws {Error} - If API call fails
 */
async function fetchBookingsByTimeslot(timeslotId) {
    // Use the correct route that filters by timeslotId
    const url = `${tonghopConfig.apiUrl}/api/bookings/timeslot/${timeslotId}`;

    try {
        const response = await httpClient.get(url, {
            timeout: tonghopConfig.timeout
        });

        // This route returns array directly
        if (Array.isArray(response)) {
            console.log(`[FetchBookings] Got ${response.length} bookings for timeslot ${timeslotId}`);
            return response;
        }
        return response.bookings || [];
    } catch (error) {
        console.error('Failed to fetch bookings from TongHop:', error.message);
        // Don't throw - return empty array to continue with seat assignment
        return [];
    }
}

/**
 * Find first available seat number (1-28)
 *
 * @param {Array} bookings - Array of existing bookings
 * @returns {number} - First available seat number (1-28)
 */
function findAvailableSeat(bookings) {
    const occupiedSeats = new Set(
        bookings
            .map(b => b.seatNumber)
            .filter(num => num >= 1 && num <= 28)
    );

    // DEBUG: Log occupied seats
    console.log(`[FindSeat] Total bookings: ${bookings.length}`);
    console.log(`[FindSeat] Occupied seats: ${Array.from(occupiedSeats).sort((a, b) => a - b).join(', ')}`);

    for (let seat = 1; seat <= 28; seat++) {
        if (!occupiedSeats.has(seat)) {
            console.log(`[FindSeat] Found available seat: ${seat}`);
            return seat;
        }
    }

    // All seats occupied - default to seat 28 (will overwrite)
    console.log(`[FindSeat] All seats occupied, defaulting to seat 28`);
    return 28;
}

/**
 * Create booking in TongHop system
 *
 * @param {Object} bookingData - Booking data
 * @returns {Promise<Object>} - Created booking object
 * @throws {Error} - If API call fails or validation fails
 */
async function createBooking(bookingData) {
    // Validate data first
    const errors = validateBookingData(bookingData);
    if (errors.length > 0) {
        throw new Error(`Dữ liệu booking không hợp lệ: ${errors.join(', ')}`);
    }

    const url = `${tonghopConfig.apiUrl}${tonghopConfig.endpoints.bookings}`;

    try {
        const response = await httpClient.post(url, bookingData, {
            timeout: tonghopConfig.timeout
        });

        // TongHop returns { success: true, booking: {...} }
        return response.booking || response;
    } catch (error) {
        console.error('Failed to create booking in TongHop:', error.message);
        throw new Error(`Không thể tạo booking: ${error.message}`);
    }
}

/**
 * Determine route based on sender's station
 *
 * Logic:
 * - STT 1-25 (Sài Gòn area) → "Sài Gòn - Long Khánh"
 * - STT 26-94 (Long Khánh area) → "Long Khánh - Sài Gòn"
 *
 * @param {string} senderStation - Sender's station (format: "01 - An Đông" hoặc "An Đông")
 * @returns {string} - Route name ("Sài Gòn - Long Khánh" or "Long Khánh - Sài Gòn")
 */
function determineRouteFromStation(senderStation) {
    if (!senderStation) {
        // Default to SG-LK if no station info
        console.log('[RouteMapper] No senderStation, defaulting to "Sài Gòn- Long Khánh"');
        return 'Sài Gòn- Long Khánh';
    }

    // Check station name ONLY (STT không liên quan!)
    const stationName = senderStation.toLowerCase();

    // Các trạm ở khu vực Long Khánh (GỬI TỪ Long Khánh ĐI Sài Gòn)
    const longKhanhStations = [
        'trảng bom', 'trang bom',
        'dầu giây', 'dau giay',
        'long khánh', 'long khanh',
        'bưu điện trảng bom', 'bu dien trang bom',
        'thu phí bầu cá', 'thu phi bau ca', 'bau ca',
        'hưng lộc', 'hung loc',
        'tam hiệp', 'tam hiep',
        'hố nai', 'ho nai',
        'bến xe hố nai', 'ben xe ho nai',
        'cầu sập', 'cau sap',
        'chợ sặt', 'cho sat',
        'ngã 4 621', 'nga 4 621',
        'tân vạn', 'tan van',
        'amata'
    ];

    const isLongKhanhStation = longKhanhStations.some(name => stationName.includes(name));

    if (isLongKhanhStation) {
        console.log(`[RouteMapper] "${senderStation}" → "Long Khánh - Sài Gòn" (station in LK area)`);
        return 'Long Khánh - Sài Gòn';
    }

    // Các trạm ở khu vực Sài Gòn (GỬI TỪ Sài Gòn ĐI Long Khánh)
    const saigonStations = [
        'an đông', 'an dong',
        'metro',
        'cantavil',
        'suối tiên', 'suoi tien',
        'cầu đen', 'cau den',
        'cầu trắng', 'cau trang',
        'thủ đức', 'thu duc',
        'bình thái', 'binh thai',
        'nguyễn thị minh khai', 'nguyen thi minh khai',
        'trần phú', 'tran phu',
        'pasteur', 'pastuer'
    ];

    const isSaigonStation = saigonStations.some(name => stationName.includes(name));

    if (isSaigonStation) {
        console.log(`[RouteMapper] "${senderStation}" → "Sài Gòn- Long Khánh" (station in SG area)`);
        return 'Sài Gòn- Long Khánh';
    }

    // Default: Nếu không match → mặc định Sài Gòn
    console.log(`[RouteMapper] "${senderStation}" → "Sài Gòn- Long Khánh" (default - không match được tên trạm)`);
    return 'Sài Gòn- Long Khánh';
}

/**
 * Create booking for product (Main orchestration function)
 *
 * Steps:
 * 1. Determine route based on sender's station
 * 2. Fetch available timeslots from TongHop
 * 3. Filter timeslots by route
 * 4. Find nearest upcoming timeslot
 * 5. Transform product data to booking format
 * 6. Create booking via TongHop API
 *
 * @param {Object} product - Product object from NhapHang
 * @returns {Promise<Object>} - Created booking object
 * @throws {Error} - If any step fails
 */
async function createBookingForProduct(product) {
    const startTime = Date.now();

    try {
        // Step 1: Determine route from sender's station
        const route = determineRouteFromStation(product.senderStation);
        console.log(`[TongHop] Determined route: "${route}" for product ${product.id} (station: ${product.senderStation})`);

        // Step 2: Fetch timeslots
        console.log(`[TongHop] Fetching timeslots for product ${product.id}...`);
        const allTimeslots = await fetchTimeslots();

        if (!allTimeslots || allTimeslots.length === 0) {
            throw new Error('Không có khung giờ xe nào. Vui lòng kiểm tra lại TongHop system.');
        }

        console.log(`[TongHop] Found ${allTimeslots.length} total timeslots`);

        // Step 3: Filter timeslots by route
        const timeslots = allTimeslots.filter(slot => slot.route === route);

        if (timeslots.length === 0) {
            throw new Error(`Không có khung giờ xe nào cho tuyến "${route}". Vui lòng tạo booking thủ công.`);
        }

        console.log(`[TongHop] Filtered to ${timeslots.length} timeslots for route "${route}"`);

        // Step 4: Find nearest timeslot
        const timeslot = findNearestTimeslot(timeslots, new Date());

        if (!timeslot) {
            throw new Error('Không tìm thấy khung giờ xe phù hợp. Vui lòng tạo booking thủ công.');
        }

        console.log(`[TongHop] Matched timeslot: ${timeslot.time} on ${timeslot.date} (ID: ${timeslot.id})`);

        // Step 3: Find available seat
        const existingBookings = await fetchBookingsByTimeslot(timeslot.id);
        const availableSeat = findAvailableSeat(existingBookings);
        console.log(`[TongHop] Found ${existingBookings.length} existing bookings, assigned seat ${availableSeat}`);

        // Step 4: Transform data
        const bookingData = transformProductToBooking(product, timeslot, availableSeat);

        // Step 5: Create booking
        console.log(`[TongHop] Creating booking for product ${product.id}...`);
        const booking = await createBooking(bookingData);

        const duration = Date.now() - startTime;
        console.log(`[TongHop] ✅ Booking created successfully (ID: ${booking.id}, Seat: ${availableSeat}) in ${duration}ms`);

        return booking;
    } catch (error) {
        const duration = Date.now() - startTime;
        console.error(`[TongHop] ❌ Failed to create booking for product ${product.id} after ${duration}ms:`, error.message);
        throw error;
    }
}

/**
 * Check if TongHop integration is enabled and configured
 *
 * @returns {boolean}
 */
function isEnabled() {
    return tonghopConfig.enabled;
}

/**
 * Check if a product should trigger auto-booking
 *
 * @param {Object} product - Product object
 * @returns {boolean}
 */
function shouldCreateBooking(product) {
    if (!product || !product.station) {
        return false;
    }

    return tonghopConfig.shouldTriggerBooking(product.station);
}

/**
 * Health check - test connection to TongHop API
 *
 * @returns {Promise<Object>} - Health status
 */
async function healthCheck() {
    try {
        const timeslots = await fetchTimeslots();
        return {
            status: 'healthy',
            api_url: tonghopConfig.apiUrl,
            timeslots_count: timeslots.length,
            timestamp: new Date().toISOString()
        };
    } catch (error) {
        return {
            status: 'unhealthy',
            api_url: tonghopConfig.apiUrl,
            error: error.message,
            timestamp: new Date().toISOString()
        };
    }
}

module.exports = {
    createBookingForProduct,
    fetchTimeslots,
    createBooking,
    isEnabled,
    shouldCreateBooking,
    healthCheck
};
