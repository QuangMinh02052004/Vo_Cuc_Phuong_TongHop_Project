const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

// Serve static files
app.use(express.static(path.join(__dirname)));

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'landing-page' });
});

app.listen(PORT, () => {
    console.log(`Landing page server running on port ${PORT}`);
});
