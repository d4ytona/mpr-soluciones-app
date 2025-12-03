const express = require('express');
const cors = require('cors');
require('dotenv').config();

const cronRoutes = require('./routes/cron');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    message: 'MPR Soluciones API Server',
    version: '1.0.0'
  });
});

// Cron routes
app.use('/api/cron', cronRoutes);

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
