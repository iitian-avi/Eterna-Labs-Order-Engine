// Order types and interfaces

export enum OrderSide {
  BUY = 'BUY',
  SELL = 'SELL'
}

export enum OrderStatus {
  PENDING = 'PENDING',
  PARTIALLY_FILLED = 'PARTIALLY_FILLED',
  FILLED = 'FILLED',
  CANCELLED = 'CANCELLED'
}

export interface Order {
  id: string;
  symbol: string;
  side: OrderSide;
  price: number;
  quantity: number;
  filledQuantity: number;
  status: OrderStatus;
  timestamp: number;
  userId?: string; // Optional: for position tracking
}

export interface Trade {
  id: string;
  symbol: string;
  buyOrderId: string;
  sellOrderId: string;
  price: number;
  quantity: number;
  timestamp: number;
}

export interface OrderBookEntry {
  price: number;
  quantity: number;
  orderCount: number;
}

export interface OrderBook {
  symbol: string;
  bids: OrderBookEntry[];  // Buy orders, sorted by price descending
  asks: OrderBookEntry[];  // Sell orders, sorted by price ascending
  timestamp: number;
}

export interface CreateOrderRequest {
  symbol: string;
  side: OrderSide;
  price: number;
  quantity: number;
  userId?: string; // Optional: for position tracking
}

export interface CreateOrderResponse {
  order: Order;
  trades: Trade[];
}
