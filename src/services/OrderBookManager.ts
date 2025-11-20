import { v4 as uuidv4 } from 'uuid';
import { Order, OrderSide, OrderStatus, CreateOrderRequest, CreateOrderResponse, OrderBook as OrderBookType } from '../types';
import { MatchingEngine } from '../engine/MatchingEngine';
import { PositionManager } from './PositionManager';

export class OrderBookManager {
  private matchingEngine: MatchingEngine;
  private positionManager: PositionManager;
  private enforcePositions: boolean;

  constructor(enforcePositions: boolean = false) {
    this.matchingEngine = new MatchingEngine();
    this.positionManager = new PositionManager();
    this.enforcePositions = enforcePositions;
    
    // For demo: Give initial positions to default user
    if (enforcePositions) {
      this.positionManager.giveInitialBalance('default', 'AAPL', 1000);
      this.positionManager.giveInitialBalance('default', 'TSLA', 1000);
      this.positionManager.giveInitialBalance('default', 'GOOGL', 1000);
    }
  }

  /**
   * Create and submit a new order
   */
  public createOrder(request: CreateOrderRequest): CreateOrderResponse {
    // Validate order
    this.validateOrder(request);

    const userId = request.userId || 'default';

    // Check position if enforcement is enabled
    if (this.enforcePositions && request.side === OrderSide.SELL) {
      const position = this.positionManager.getPosition(userId, request.symbol.toUpperCase());
      if (position < request.quantity) {
        throw new Error(`Insufficient position. You have ${position} ${request.symbol}, but trying to sell ${request.quantity}`);
      }
    }

    // Create order
    const order: Order = {
      id: uuidv4(),
      symbol: request.symbol.toUpperCase(),
      side: request.side,
      price: request.price,
      quantity: request.quantity,
      filledQuantity: 0,
      status: OrderStatus.PENDING,
      timestamp: Date.now(),
      userId
    };

    // Submit to matching engine
    const trades = this.matchingEngine.submitOrder(order);

    // Update positions if enforcement is enabled
    if (this.enforcePositions) {
      if (order.side === OrderSide.BUY) {
        // For BUY: Increase position by filled amount
        if (order.filledQuantity > 0) {
          this.positionManager.updatePosition(userId, order.symbol, order.filledQuantity, true);
        }
      } else {
        // For SELL: Decrease position immediately (even if pending)
        // This prevents double-selling the same shares
        const quantityToSell = order.quantity; // Reserve the full quantity
        this.positionManager.updatePosition(userId, order.symbol, quantityToSell, false);
        
        // If order was partially filled or cancelled, we'd need to add back unfilled quantity
        // For this demo, we keep it simple
      }
    }

    return {
      order,
      trades
    };
  }

  /**
   * Get order by ID
   */
  public getOrder(orderId: string): Order | undefined {
    return this.matchingEngine.getOrder(orderId);
  }

  /**
   * Get all orders
   */
  public getAllOrders(): Order[] {
    return this.matchingEngine.getAllOrders();
  }

  /**
   * Get all trades
   */
  public getAllTrades() {
    return this.matchingEngine.getAllTrades();
  }

  /**
   * Get order book for a symbol
   */
  public getOrderBook(symbol: string): OrderBookType {
    const orderBook = this.matchingEngine.getOrderBook(symbol.toUpperCase());
    
    return {
      symbol: symbol.toUpperCase(),
      bids: orderBook.bids,
      asks: orderBook.asks,
      timestamp: Date.now()
    };
  }

  /**
   * Cancel an order
   */
  public cancelOrder(orderId: string): boolean {
    return this.matchingEngine.cancelOrder(orderId);
  }

  /**
   * Get user positions (if position tracking is enabled)
   */
  public getUserPositions(userId: string = 'default') {
    if (!this.enforcePositions) {
      return { message: 'Position tracking is disabled', positions: [] };
    }
    return {
      userId,
      positions: this.positionManager.getUserPositions(userId),
      enforcePositions: this.enforcePositions
    };
  }

  /**
   * Validate order request
   */
  private validateOrder(request: CreateOrderRequest): void {
    if (!request.symbol || typeof request.symbol !== 'string') {
      throw new Error('Invalid symbol');
    }

    if (!request.side || (request.side !== OrderSide.BUY && request.side !== OrderSide.SELL)) {
      throw new Error('Invalid order side. Must be BUY or SELL');
    }

    if (typeof request.price !== 'number' || request.price <= 0) {
      throw new Error('Invalid price. Must be a positive number');
    }

    if (typeof request.quantity !== 'number' || request.quantity <= 0) {
      throw new Error('Invalid quantity. Must be a positive number');
    }

    // Check for decimal places (max 2 for price, max 8 for quantity)
    if (!Number.isInteger(request.price * 100)) {
      throw new Error('Price can have maximum 2 decimal places');
    }

    if (!Number.isInteger(request.quantity * 100000000)) {
      throw new Error('Quantity can have maximum 8 decimal places');
    }
  }
}
