import { Router, Request, Response } from 'express';
import { OrderBookManager } from '../services/OrderBookManager';
import { asyncHandler, ApiResponse, ApiError } from '../middleware/errorHandler';
import { CreateOrderRequest, OrderSide } from '../types';

const router = Router();
const orderBookManager = new OrderBookManager();

/**
 * POST /api/orders
 * Create a new order
 */
router.post('/orders', asyncHandler(async (req: Request, res: Response) => {
  const { symbol, side, price, quantity } = req.body;

  // Validate required fields
  if (!symbol || !side || price === undefined || quantity === undefined) {
    throw new ApiError(400, 'Missing required fields: symbol, side, price, quantity', 'MISSING_FIELDS');
  }

  // Validate side
  if (side !== OrderSide.BUY && side !== OrderSide.SELL) {
    throw new ApiError(400, 'Invalid order side. Must be BUY or SELL', 'INVALID_SIDE');
  }

  const request: CreateOrderRequest = {
    symbol,
    side,
    price: Number(price),
    quantity: Number(quantity)
  };

  const result = orderBookManager.createOrder(request);

  const response: ApiResponse = {
    success: true,
    data: result
  };

  res.status(201).json(response);
}));

/**
 * GET /api/orders/:id
 * Get order by ID
 */
router.get('/orders/:id', asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;

  const order = orderBookManager.getOrder(id);

  if (!order) {
    throw new ApiError(404, 'Order not found', 'ORDER_NOT_FOUND');
  }

  const response: ApiResponse = {
    success: true,
    data: order
  };

  res.json(response);
}));

/**
 * GET /api/orders
 * Get all orders
 */
router.get('/orders', asyncHandler(async (req: Request, res: Response) => {
  const orders = orderBookManager.getAllOrders();

  const response: ApiResponse = {
    success: true,
    data: {
      orders,
      count: orders.length
    }
  };

  res.json(response);
}));

/**
 * DELETE /api/orders/:id
 * Cancel an order
 */
router.delete('/orders/:id', asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;

  const cancelled = orderBookManager.cancelOrder(id);

  if (!cancelled) {
    throw new ApiError(400, 'Order cannot be cancelled or not found', 'CANCEL_FAILED');
  }

  const response: ApiResponse = {
    success: true,
    data: {
      message: 'Order cancelled successfully',
      orderId: id
    }
  };

  res.json(response);
}));

/**
 * GET /api/orderbook/:symbol
 * Get order book for a symbol
 */
router.get('/orderbook/:symbol', asyncHandler(async (req: Request, res: Response) => {
  const { symbol } = req.params;

  const orderBook = orderBookManager.getOrderBook(symbol);

  const response: ApiResponse = {
    success: true,
    data: orderBook
  };

  res.json(response);
}));

/**
 * GET /api/trades
 * Get all trades
 */
router.get('/trades', asyncHandler(async (req: Request, res: Response) => {
  const trades = orderBookManager.getAllTrades();

  const response: ApiResponse = {
    success: true,
    data: {
      trades,
      count: trades.length
    }
  };

  res.json(response);
}));

/**
 * GET /api/health
 * Health check endpoint
 */
router.get('/health', (req: Request, res: Response) => {
  res.json({
    success: true,
    data: {
      status: 'healthy',
      timestamp: new Date().toISOString()
    }
  });
});

export default router;
