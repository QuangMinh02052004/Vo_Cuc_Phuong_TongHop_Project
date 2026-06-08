// ===== AUTO-FORMAT TIỀN VND =====
// 1000 → "1.000", 1500000 → "1.500.000"
window.formatVNDCurrency = function(value) {
    var digits = String(value).replace(/\D/g, '');
    if (!digits) return '';
    // Thêm dấu chấm phân cách hàng nghìn bằng regex
    return digits.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
};

window.parseVNDCurrency = function(formatted) {
    return parseInt(String(formatted).replace(/\./g, ''), 10) || 0;
};

window.setupVNDCurrencyInput = function(inputEl) {
    if (!inputEl) return;
    inputEl.addEventListener('input', function() {
        var raw = this.value.replace(/\D/g, '');
        var cursorPos = this.selectionStart;
        var oldLen = this.value.length;
        this.value = raw ? window.formatVNDCurrency(raw) : '';
        var newLen = this.value.length;
        var newPos = Math.max(0, cursorPos + (newLen - oldLen));
        this.setSelectionRange(newPos, newPos);
    });
};

// Auto-attach vào ô totalAmount khi DOM sẵn sàng
document.addEventListener('DOMContentLoaded', function() {
    var totalAmountInput = document.getElementById('totalAmount');
    if (totalAmountInput) {
        window.setupVNDCurrencyInput(totalAmountInput);
    }
    var deliveredAmountInput = document.getElementById('deliveredAmount');
    if (deliveredAmountInput) {
        window.setupVNDCurrencyInput(deliveredAmountInput);
    }
});

// ===== CUSTOM MODAL - Thay thế alert() / confirm() =====

/**
 * Hiển thị popup xác nhận (thay confirm())
 * @param {string} message - Nội dung hiển thị
 * @param {object} options - { title, type: 'warning'|'danger'|'info', confirmText, cancelText }
 * @returns {Promise<boolean>}
 */
window.showConfirmModal = function(message, options = {}) {
    return new Promise((resolve) => {
        const {
            title = 'Xác nhận',
            type = 'warning',
            confirmText = 'Đồng ý',
            cancelText = 'Hủy',
            danger = false
        } = options;

        const icons = {
            warning: '⚠️',
            danger: '🗑️',
            info: 'ℹ️',
            success: '✓'
        };

        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.innerHTML = `
            <div class="modal-box">
                <div class="modal-icon ${type}">${icons[type] || '⚠️'}</div>
                <div class="modal-title">${title}</div>
                <div class="modal-message">${message}</div>
                <div class="modal-actions">
                    <button class="modal-btn cancel" id="modalCancel">${cancelText}</button>
                    <button class="modal-btn ${danger ? 'danger' : 'confirm'}" id="modalConfirm">${confirmText}</button>
                </div>
            </div>
        `;

        document.body.appendChild(overlay);

        // Focus confirm button
        overlay.querySelector('#modalConfirm').focus();

        const close = (result) => {
            overlay.style.animation = 'modalFadeIn 0.15s ease reverse';
            setTimeout(() => {
                overlay.remove();
                resolve(result);
            }, 150);
        };

        overlay.querySelector('#modalCancel').addEventListener('click', () => close(false));
        overlay.querySelector('#modalConfirm').addEventListener('click', () => close(true));
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) close(false);
        });

        // ESC to cancel
        const handleKey = (e) => {
            if (e.key === 'Escape') { close(false); document.removeEventListener('keydown', handleKey); }
            if (e.key === 'Enter') { close(true); document.removeEventListener('keydown', handleKey); }
        };
        document.addEventListener('keydown', handleKey);
    });
};

/**
 * Hiển thị popup thông báo (thay alert())
 * @param {string} message - Nội dung hiển thị
 * @param {object} options - { title, type: 'info'|'success'|'warning'|'danger' }
 * @returns {Promise<void>}
 */
window.showAlertModal = function(message, options = {}) {
    return new Promise((resolve) => {
        const {
            title = 'Thông báo',
            type = 'info',
            buttonText = 'Đã hiểu'
        } = options;

        const icons = {
            warning: '⚠️',
            danger: '❌',
            info: 'ℹ️',
            success: '✅'
        };

        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.innerHTML = `
            <div class="modal-box">
                <div class="modal-icon ${type}">${icons[type] || 'ℹ️'}</div>
                <div class="modal-title">${title}</div>
                <div class="modal-message">${message}</div>
                <div class="modal-actions">
                    <button class="modal-btn confirm" id="modalOk">${buttonText}</button>
                </div>
            </div>
        `;

        document.body.appendChild(overlay);
        overlay.querySelector('#modalOk').focus();

        const close = () => {
            overlay.style.animation = 'modalFadeIn 0.15s ease reverse';
            setTimeout(() => {
                overlay.remove();
                resolve();
            }, 150);
        };

        overlay.querySelector('#modalOk').addEventListener('click', close);
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) close();
        });
        document.addEventListener('keydown', function handler(e) {
            if (e.key === 'Escape' || e.key === 'Enter') { close(); document.removeEventListener('keydown', handler); }
        });
    });
};
