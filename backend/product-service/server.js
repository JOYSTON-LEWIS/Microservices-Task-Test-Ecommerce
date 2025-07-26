const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();

// Load from environment
const port = process.env.PORT;
const mongoBase = process.env.MONGO_DB_ATLAS_URL;
const dbName = process.env.DB_NAME;

// Validate essential env vars
if (!port || !mongoBase || !dbName) {
  console.error("Missing required environment variables. Please check PORT, MONGO_DB_ATLAS_URL, and DB_NAME.");
  process.exit(1);
}

const mongoURI = `${mongoBase}/${dbName}`;

const PORT = port;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect(mongoURI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Routes
app.use('/api/products', require('./routes/products'));
app.use('/api/categories', require('./routes/categories'));

// Health check
app.get('/health', (req, res) => {
  res.json({ service: 'Product Service', status: 'OK', port: PORT });
});

app.listen(PORT, () => {
  console.log(`Product Service running on port ${PORT}`);
});