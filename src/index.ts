import express, { Express } from 'express';
import cors from 'cors';
import path from 'path';
import routes from './routes';
import { errorHandler } from './middleware/errorHandler';

const app: Express = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from public directory
app.use(express.static(path.join(__dirname, '../public')));

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Routes
app.use('/api', routes);

// Root endpoint - serve HTML dashboard
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Error handling middleware (must be last)
app.use(errorHandler);

// Start server
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════╗
║   Order Execution Engine                              ║
║   Server running on http://localhost:${PORT}         ║
║   Dashboard: http://localhost:${PORT}                ║
╚═══════════════════════════════════════════════════════╝
  `);
  console.log('Available endpoints:');
  console.log('  GET    /                     - Web Dashboard');
  console.log('  POST   /api/orders           - Create new order');
  console.log('  GET    /api/orders/:id       - Get order by ID');
  console.log('  GET    /api/orders           - Get all orders');
  console.log('  DELETE /api/orders/:id       - Cancel order');
  console.log('  GET    /api/orderbook/:symbol - Get order book');
  console.log('  GET    /api/trades           - Get all trades');
  console.log('  GET    /api/health           - Health check');
  console.log('');
});

export default app;
