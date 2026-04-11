const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3001;

// Serve admin static files
app.use(express.static(path.join(__dirname, 'backend/public')));

// Redirect root ke admin.html
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'backend/public', 'admin.html'));
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'admin-website' });
});

app.listen(PORT, () => {
  console.log(`Admin Website running on port ${PORT}`);
});
