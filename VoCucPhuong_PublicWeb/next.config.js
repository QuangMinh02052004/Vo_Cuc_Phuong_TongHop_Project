/** @type {import('next').NextConfig} */
const nextConfig = {
  // Allow serving static files from public folder
  async rewrites() {
    return [
      // Nhap Hang static files
      {
        source: '/nhap-hang/:path*',
        destination: '/nhap-hang/:path*',
      },
      // Tong Hop static files
      {
        source: '/tong-hop/:path*',
        destination: '/tong-hop/:path*',
      },
    ];
  },
  // Headers for CORS
  async headers() {
    return [
      {
        source: '/api/:path*',
        headers: [
          { key: 'Access-Control-Allow-Origin', value: '*' },
          { key: 'Access-Control-Allow-Methods', value: 'GET,POST,PUT,PATCH,DELETE,OPTIONS' },
          { key: 'Access-Control-Allow-Headers', value: 'Content-Type, Authorization' },
        ],
      },
    ];
  },
};

module.exports = nextConfig;
