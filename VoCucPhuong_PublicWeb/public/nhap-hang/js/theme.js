// Theme Switcher - Lưu vào localStorage, áp dụng cho tất cả trang NhapHang
(function() {
  const saved = localStorage.getItem('nh-theme') || 'default';
  if (saved !== 'default') {
    document.documentElement.setAttribute('data-theme', saved);
  }

  document.addEventListener('DOMContentLoaded', function() {
    // Highlight saved theme button
    const btns = document.querySelectorAll('.theme-btn');
    btns.forEach(btn => {
      if (btn.dataset.t === saved) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }

      btn.addEventListener('click', function() {
        const theme = this.dataset.t;
        if (theme === 'default') {
          document.documentElement.removeAttribute('data-theme');
        } else {
          document.documentElement.setAttribute('data-theme', theme);
        }
        localStorage.setItem('nh-theme', theme);

        btns.forEach(b => b.classList.remove('active'));
        this.classList.add('active');
      });
    });
  });
})();
