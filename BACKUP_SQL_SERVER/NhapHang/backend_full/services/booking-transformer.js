/**
 * Booking Transformer Service
 *
 * Transforms NhapHang Product data to TongHop Booking format
 */

const { extractAddressFromName, extractNameOnly } = require('./address-matcher');

/**
 * Format note string for booking
 *
 * Formula: "giao {name} {quantity}"
 * Example: "giao Trần Văn A 2 thùng + 2 bao"
 *
 * @param {string} receiverName - Receiver name (cleaned, without address)
 * @param {string} productType - Product type
 * @param {string} quantity - Quantity string
 * @returns {string} - Formatted note
 */
function formatBookingNote(receiverName, productType, quantity) {
    const name = receiverName || '';
    const type = productType || '';

    // Priority 1: Use 'quantity' field if provided
    if (quantity && quantity.trim()) {
        return `giao ${name} ${quantity}`;
    }

    // Priority 2: No quantity - extract type name from productType and use default "1"
    // If productType = "06 - Kiện" → extract "Kiện", return "1 Kiện"
    // If productType = "Kiện" → return "1 Kiện"
    const match = type.match(/^(\d+)\s*-\s*(.+)$/);

    if (match) {
        const typeName = match[2].trim(); // Extract type name only (e.g., "Kiện")
        return `giao ${name} 1 ${typeName}`;
    }

    // If productType doesn't have number format, use as-is with "1"
    if (type.trim()) {
        return `giao ${name} 1 ${type.trim()}`;
    }

    // Final fallback
    return `giao ${name} 1`;
}

/**
 * Transform Product to Booking
 *
 * Maps NhapHang product fields to TongHop booking fields
 *
 * @param {Object} product - Product from NhapHang
 * @param {Object} timeslot - Matched timeslot from TongHop
 * @param {number} seatNumber - Assigned seat number (1-28)
 * @returns {Object} - Booking data ready for TongHop API
 */
function transformProductToBooking(product, timeslot, seatNumber = 28) {
    // Try to extract address from receiver name
    // Returns { stationName, matchedText } or null
    const matchResult = extractAddressFromName(product.receiverName);

    // Determine dropoff address (priority: matched address > station > "Dọc đường")
    let dropoffAddress = 'Dọc đường';
    if (matchResult) {
        dropoffAddress = matchResult.stationName;
    } else if (product.station && product.station !== '00 - DỌC ĐƯỜNG') {
        dropoffAddress = product.station;
    }

    // Clean receiver name (remove matched text if found)
    const cleanName = matchResult
        ? extractNameOnly(product.receiverName, matchResult.matchedText)
        : product.receiverName;

    return {
        // From product - direct mapping
        phone: product.receiverPhone || '',
        name: cleanName || '',
        amount: parseFloat(product.totalAmount) || 0,
        paid: parseFloat(product.totalAmount) || 0, // Already paid in freight

        // Pickup at station
        pickupMethod: 'Tại bến',
        pickupAddress: 'tại bến',

        // Dropoff address - auto-detected or default
        dropoffMethod: 'Dọc đường',
        dropoffAddress: dropoffAddress,

        // From timeslot - denormalized
        timeSlotId: timeslot.id,
        timeSlot: timeslot.time,
        date: timeslot.date,
        route: timeslot.route || '',

        // Computed - use cleanName (without address) in note
        note: formatBookingNote(cleanName, product.productType, product.quantity),

        // Auto-assigned seat number (first available from 1-28)
        seatNumber: seatNumber,
        gender: '',
        nationality: ''
    };
}

/**
 * Validate booking data before sending to API
 *
 * @param {Object} bookingData - Booking data to validate
 * @returns {Array<string>} - Array of error messages (empty if valid)
 */
function validateBookingData(bookingData) {
    const errors = [];

    if (!bookingData.phone) {
        errors.push('Thiếu số điện thoại người nhận');
    }

    if (!bookingData.name) {
        errors.push('Thiếu tên người nhận');
    }

    if (!bookingData.timeSlotId) {
        errors.push('Không tìm thấy khung giờ xe');
    }

    if (typeof bookingData.amount !== 'number' || bookingData.amount <= 0) {
        errors.push('Số tiền không hợp lệ');
    }

    if (!bookingData.timeSlot || !bookingData.date) {
        errors.push('Thiếu thông tin thời gian');
    }

    return errors;
}

module.exports = {
    transformProductToBooking,
    formatBookingNote,
    validateBookingData
};
