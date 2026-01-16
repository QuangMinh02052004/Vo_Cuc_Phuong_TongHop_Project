/**
 * Address Matcher Service
 *
 * Extracts delivery address from receiver name by matching with known stations
 */

const { stations } = require('../data/stations');

/**
 * Normalize Vietnamese string for comparison
 * Removes diacritics and converts to lowercase
 *
 * @param {string} str - String to normalize
 * @returns {string} - Normalized string
 */
function normalizeVietnamese(str) {
    if (!str) return '';

    // Remove diacritics
    str = str.normalize('NFD').replace(/[\u0300-\u036f]/g, '');

    // Convert to lowercase
    str = str.toLowerCase();

    // Remove extra spaces
    str = str.replace(/\s+/g, ' ').trim();

    return str;
}

/**
 * Extract address from receiver name
 * Matches receiver name against list of 94 stations
 *
 * Priority:
 * 1. Check full station name (existing logic)
 * 2. Check station aliases (shortcuts/abbreviations)
 *
 * Examples:
 *   Input: "Minh bưu điện trảng bom" → Output: { stationName: "Bưu điện Trảng Bom", matchedText: "bưu điện trảng bom" }
 *   Input: "Minh bd tbom" → Output: { stationName: "Bưu điện Trảng Bom", matchedText: "bd tbom" }
 *   Input: "Minh tbom" → Output: { stationName: "Bưu điện Trảng Bom", matchedText: "tbom" }
 *
 * @param {string} receiverName - Full receiver name (may contain address)
 * @returns {Object|null} - { stationName: string, matchedText: string } or null if no match
 */
function extractAddressFromName(receiverName) {
    if (!receiverName || typeof receiverName !== 'string') {
        return null;
    }

    const normalized = normalizeVietnamese(receiverName);

    // Sort by name length (longest first) to match specific addresses before general ones
    // Example: "Bưu điện Trảng Bom" before "Trảng Bom"
    const sortedStations = [...stations].sort((a, b) => b.name.length - a.name.length);

    // STEP 1: Try to match full station name (existing logic)
    for (const station of sortedStations) {
        const stationNormalized = normalizeVietnamese(station.name);

        // Check if receiver name contains this station name
        if (normalized.includes(stationNormalized)) {
            console.log(`[AddressMatcher] ✅ Full name match: "${station.name}" in "${receiverName}"`);
            return {
                stationName: station.name,
                matchedText: station.name
            };
        }
    }

    // STEP 2: Try to match aliases (NEW LOGIC)
    // Sort aliases by length (longest first) to avoid false positives
    // Example: "bd trang bom" should match before "bd"
    for (const station of sortedStations) {
        // Skip stations without aliases
        if (!station.aliases || !Array.isArray(station.aliases) || station.aliases.length === 0) {
            continue;
        }

        // Sort aliases by length (longest first)
        const sortedAliases = [...station.aliases].sort((a, b) => b.length - a.length);

        for (const alias of sortedAliases) {
            const aliasNormalized = normalizeVietnamese(alias);

            // Check if receiver name contains this alias
            if (normalized.includes(aliasNormalized)) {
                console.log(`[AddressMatcher] ✅ Alias match: "${alias}" → "${station.name}" in "${receiverName}"`);
                return {
                    stationName: station.name,
                    matchedText: alias
                };
            }
        }
    }

    console.log(`[AddressMatcher] ❌ No match found for: "${receiverName}"`);
    return null;
}

/**
 * Extract name only (remove address part)
 *
 * Example:
 *   Input: "Minh bưu điện trảng bom", matchedText: "bưu điện trảng bom"
 *   Output: "Minh"
 *   Input: "Minh tbom", matchedText: "tbom"
 *   Output: "Minh"
 *
 * @param {string} receiverName - Full receiver name
 * @param {string} matchedText - The actual matched text (alias or full name) to remove
 * @returns {string} - Name without address
 */
function extractNameOnly(receiverName, matchedText) {
    if (!receiverName || !matchedText) {
        return receiverName;
    }

    const normalized = normalizeVietnamese(receiverName);
    const matchedNormalized = normalizeVietnamese(matchedText);

    // Find the position of matched text in normalized receiver name
    const index = normalized.indexOf(matchedNormalized);
    if (index !== -1) {
        // Remove the matched text and keep original casing
        const before = receiverName.substring(0, index).trim();
        const after = receiverName.substring(index + matchedText.length).trim();

        // Combine before and after parts
        return (before + ' ' + after).trim();
    }

    return receiverName.trim();
}

module.exports = {
    extractAddressFromName,
    extractNameOnly,
    normalizeVietnamese
};
