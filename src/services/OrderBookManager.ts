import { v4 as uuidv4 } from 'uuid';
import { Order, OrderSide, OrderStatus, CreateOrderRequest, CreateOrderResponse, OrderBook as OrderBookType } from '../types';
import { MatchingEngine } from '../engine/MatchingEngine';

export class OrderBookManager {
  private matchingEngine: MatchingEngine;

  constructor() {
    this.matchingEngine = new MatchingEngine();
  }

  /**
   * Create and submit a new order
   */
  public createOrder(request: CreateOrderRequest): CreateOrderResponse {
    // Validate order
    this.validateOrder(request);

    // Create order
    const order: Order = {
      id: uuidv4(),
      symbol: request.symbol.toUpperCase(),
      side: request.side,
      price: request.price,
      quantity: request.quantity,
      filledQuantity: 0,
      status: OrderStatus.PENDING,
      timestamp: Date.now()
    };

    // Submit to matching engine
    const trades = this.matchingEngine.submitOrder(order);

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
