import { v4 as uuidv4 } from 'uuid';
import { Order, OrderSide, OrderStatus, Trade } from '../types';

export class MatchingEngine {
  private buyOrders: Map<string, Order[]> = new Map(); // symbol -> sorted buy orders
  private sellOrders: Map<string, Order[]> = new Map(); // symbol -> sorted sell orders
  private orders: Map<string, Order> = new Map(); // orderId -> order
  private trades: Trade[] = [];

  /**
   * Submit a new order and attempt to match it
   */
  public submitOrder(order: Order): Trade[] {
    this.orders.set(order.id, order);
    
    const trades: Trade[] = [];
    
    if (order.side === OrderSide.BUY) {
      // Match buy order against sell orders
      const matchedTrades = this.matchBuyOrder(order);
      trades.push(...matchedTrades);
      
      // If order is not fully filled, add to buy order book
      if (order.filledQuantity < order.quantity) {
        this.addBuyOrder(order);
      }
    } else {
      // Match sell order against buy orders
      const matchedTrades = this.matchSellOrder(order);
      trades.push(...matchedTrades);
      
      // If order is not fully filled, add to sell order book
      if (order.filledQuantity < order.quantity) {
        this.addSellOrder(order);
      }
    }
    
    // Store all trades
    this.trades.push(...trades);
    
    return trades;
  }

  /**
   * Match a buy order against existing sell orders
   */
  private matchBuyOrder(buyOrder: Order): Trade[] {
    const trades: Trade[] = [];
    const sellOrders = this.sellOrders.get(buyOrder.symbol) || [];
    
    let i = 0;
    while (i < sellOrders.length && buyOrder.filledQuantity < buyOrder.quantity) {
      const sellOrder = sellOrders[i];
      
      // Check if prices match (buy price >= sell price)
      if (buyOrder.price >= sellOrder.price) {
        const trade = this.executeTrade(buyOrder, sellOrder);
        if (trade) {
          trades.push(trade);
        }
        
        // Remove fully filled sell orders
        if (sellOrder.status === OrderStatus.FILLED) {
          sellOrders.splice(i, 1);
        } else {
          i++;
        }
      } else {
        // No more matching possible (sell orders are sorted by price ascending)
        break;
      }
    }
    
    return trades;
  }

  /**
   * Match a sell order against existing buy orders
   */
  private matchSellOrder(sellOrder: Order): Trade[] {
    const trades: Trade[] = [];
    const buyOrders = this.buyOrders.get(sellOrder.symbol) || [];
    
    let i = 0;
    while (i < buyOrders.length && sellOrder.filledQuantity < sellOrder.quantity) {
      const buyOrder = buyOrders[i];
      
      // Check if prices match (buy price >= sell price)
      if (buyOrder.price >= sellOrder.price) {
        const trade = this.executeTrade(buyOrder, sellOrder);
        if (trade) {
          trades.push(trade);
        }
        
        // Remove fully filled buy orders
        if (buyOrder.status === OrderStatus.FILLED) {
          buyOrders.splice(i, 1);
        } else {
          i++;
        }
      } else {
        // No more matching possible (buy orders are sorted by price descending)
        break;
      }
    }
    
    return trades;
  }

  /**
   * Execute a trade between buy and sell orders
   */
  private executeTrade(buyOrder: Order, sellOrder: Order): Trade | null {
    const remainingBuyQty = buyOrder.quantity - buyOrder.filledQuantity;
    const remainingSellQty = sellOrder.quantity - sellOrder.filledQuantity;
    
    if (remainingBuyQty <= 0 || remainingSellQty <= 0) {
      return null;
    }
    
    // Determine trade quantity
    const tradeQuantity = Math.min(remainingBuyQty, remainingSellQty);
    
    // Trade price is the price of the order that was placed first (price-time priority)
    const tradePrice = buyOrder.timestamp < sellOrder.timestamp 
      ? buyOrder.price 
      : sellOrder.price;
    
    // Update orders
    buyOrder.filledQuantity += tradeQuantity;
    sellOrder.filledQuantity += tradeQuantity;
    
    // Update order status
    if (buyOrder.filledQuantity === buyOrder.quantity) {
      buyOrder.status = OrderStatus.FILLED;
    } else {
      buyOrder.status = OrderStatus.PARTIALLY_FILLED;
    }
    
    if (sellOrder.filledQuantity === sellOrder.quantity) {
      sellOrder.status = OrderStatus.FILLED;
    } else {
      sellOrder.status = OrderStatus.PARTIALLY_FILLED;
    }
    
    // Create trade
    const trade: Trade = {
      id: uuidv4(),
      symbol: buyOrder.symbol,
      buyOrderId: buyOrder.id,
      sellOrderId: sellOrder.id,
      price: tradePrice,
      quantity: tradeQuantity,
      timestamp: Date.now()
    };
    
    return trade;
  }

  /**
   * Add buy order to order book (sorted by price descending, then by time)
   */
  private addBuyOrder(order: Order): void {
    const orders = this.buyOrders.get(order.symbol) || [];
    
    // Insert order in sorted position (price descending, time ascending)
    let inserted = false;
    for (let i = 0; i < orders.length; i++) {
      if (order.price > orders[i].price || 
          (order.price === orders[i].price && order.timestamp < orders[i].timestamp)) {
        orders.splice(i, 0, order);
        inserted = true;
        break;
      }
    }
    
    if (!inserted) {
      orders.push(order);
    }
    
    this.buyOrders.set(order.symbol, orders);
  }

  /**
   * Add sell order to order book (sorted by price ascending, then by time)
   */
  private addSellOrder(order: Order): void {
    const orders = this.sellOrders.get(order.symbol) || [];
    
    // Insert order in sorted position (price ascending, time ascending)
    let inserted = false;
    for (let i = 0; i < orders.length; i++) {
      if (order.price < orders[i].price || 
          (order.price === orders[i].price && order.timestamp < orders[i].timestamp)) {
        orders.splice(i, 0, order);
        inserted = true;
        break;
      }
    }
    
    if (!inserted) {
      orders.push(order);
    }
    
    this.sellOrders.set(order.symbol, orders);
  }

  /**
   * Get order by ID
   */
  public getOrder(orderId: string): Order | undefined {
    return this.orders.get(orderId);
  }

  /**
   * Get all orders
   */
  public getAllOrders(): Order[] {
    return Array.from(this.orders.values());
  }

  /**
   * Get all trades
   */
  public getAllTrades(): Trade[] {
    return [...this.trades];
  }

  /**
   * Get order book for a symbol
   */
  public getOrderBook(symbol: string) {
    const buyOrders = this.buyOrders.get(symbol) || [];
    const sellOrders = this.sellOrders.get(symbol) || [];
    
    return {
      bids: this.aggregateOrders(buyOrders),
      asks: this.aggregateOrders(sellOrders)
    };
  }

  /**
   * Aggregate orders by price level
   */
  private aggregateOrders(orders: Order[]) {
    const priceMap = new Map<number, { quantity: number; count: number }>();
    
    for (const order of orders) {
      const remainingQty = order.quantity - order.filledQuantity;
      if (remainingQty > 0) {
        const existing = priceMap.get(order.price);
        if (existing) {
          existing.quantity += remainingQty;
          existing.count += 1;
        } else {
          priceMap.set(order.price, { quantity: remainingQty, count: 1 });
        }
      }
    }
    
    return Array.from(priceMap.entries()).map(([price, { quantity, count }]) => ({
      price,
      quantity,
      orderCount: count
    }));
  }

  /**
   * Cancel an order
   */
  public cancelOrder(orderId: string): boolean {
    const order = this.orders.get(orderId);
    if (!order || order.status === OrderStatus.FILLED || order.status === OrderStatus.CANCELLED) {
      return false;
    }
    
    // Remove from order book
    if (order.side === OrderSide.BUY) {
      const orders = this.buyOrders.get(order.symbol) || [];
      const index = orders.findIndex(o => o.id === orderId);
      if (index !== -1) {
        orders.splice(index, 1);
      }
    } else {
      const orders = this.sellOrders.get(order.symbol) || [];
      const index = orders.findIndex(o => o.id === orderId);
      if (index !== -1) {
        orders.splice(index, 1);
      }
    }
    
    order.status = OrderStatus.CANCELLED;
    return true;
  }
}
