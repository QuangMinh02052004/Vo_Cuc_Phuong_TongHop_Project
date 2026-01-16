export const metadata = {
  title: 'Võ Cực Phương - Quản Lý Nội Bộ',
  description: 'Hệ thống quản lý nội bộ công ty TNHH Võ Cực Phương',
};

export default function RootLayout({ children }) {
  return (
    <html lang="vi">
      <body style={{ margin: 0, padding: 0 }}>{children}</body>
    </html>
  );
}
