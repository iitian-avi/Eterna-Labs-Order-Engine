import { MatchingEngine } from '../engine/MatchingEngine';
import { Order, OrderSide, OrderStatus } from '../types';

describe('MatchingEngine', () => {
  let engine: MatchingEngine;

  beforeEach(() => {
    engine = new MatchingEngine();
  });

  describe('Order Submission', () => {
    it('should accept a buy order', () => {
      const order: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      const trades = engine.submitOrder(order);
      expect(trades).toHaveLength(0);
      expect(engine.getOrder('1')).toBeDefined();
    });

    it('should accept a sell order', () => {
      const order: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.SELL,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      const trades = engine.submitOrder(order);
      expect(trades).toHaveLength(0);
      expect(engine.getOrder('1')).toBeDefined();
    });
  });

  describe('Order Matching', () => {
    it('should match a buy order with an existing sell order at same price', () => {
      const sellOrder: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.SELL,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      const buyOrder: Order = {
        id: '2',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now() + 1
      };

      engine.submitOrder(sellOrder);
      const trades = engine.submitOrder(buyOrder);

      expect(trades).toHaveLength(1);
      expect(trades[0].quantity).toBe(100);
      expect(trades[0].price).toBe(150);
      expect(sellOrder.status).toBe(OrderStatus.FILLED);
      expect(buyOrder.status).toBe(OrderStatus.FILLED);
    });

    it('should match when buy price is higher than sell price', () => {
      const sellOrder: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.SELL,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      const buyOrder: Order = {
        id: '2',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 155,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now() + 1
      };

      engine.submitOrder(sellOrder);
      const trades = engine.submitOrder(buyOrder);

      expect(trades).toHaveLength(1);
      expect(trades[0].quantity).toBe(100);
    });

    it('should not match when buy price is lower than sell price', () => {
      const sellOrder: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.SELL,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      const buyOrder: Order = {
        id: '2',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 145,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now() + 1
      };

      engine.submitOrder(sellOrder);
      const trades = engine.submitOrder(buyOrder);

      expect(trades).toHaveLength(0);
    });

    it('should handle partial fills', () => {
      const sellOrder: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.SELL,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      const buyOrder: Order = {
        id: '2',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 150,
        quantity: 50,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now() + 1
      };

      engine.submitOrder(sellOrder);
      const trades = engine.submitOrder(buyOrder);

      expect(trades).toHaveLength(1);
      expect(trades[0].quantity).toBe(50);
      expect(sellOrder.status).toBe(OrderStatus.PARTIALLY_FILLED);
      expect(sellOrder.filledQuantity).toBe(50);
      expect(buyOrder.status).toBe(OrderStatus.FILLED);
      expect(buyOrder.filledQuantity).toBe(50);
    });

    it('should match multiple orders', () => {
      const sellOrder1: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.SELL,
        price: 150,
        quantity: 50,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      const sellOrder2: Order = {
        id: '2',
        symbol: 'AAPL',
        side: OrderSide.SELL,
        price: 150,
        quantity: 50,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now() + 1
      };

      const buyOrder: Order = {
        id: '3',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now() + 2
      };

      engine.submitOrder(sellOrder1);
      engine.submitOrder(sellOrder2);
      const trades = engine.submitOrder(buyOrder);

      expect(trades).toHaveLength(2);
      expect(buyOrder.status).toBe(OrderStatus.FILLED);
      expect(sellOrder1.status).toBe(OrderStatus.FILLED);
      expect(sellOrder2.status).toBe(OrderStatus.FILLED);
    });
  });

  describe('Order Book', () => {
    it('should return correct order book structure', () => {
      const buyOrder: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      const sellOrder: Order = {
        id: '2',
        symbol: 'AAPL',
        side: OrderSide.SELL,
        price: 155,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      engine.submitOrder(buyOrder);
      engine.submitOrder(sellOrder);

      const orderBook = engine.getOrderBook('AAPL');

      expect(orderBook.bids).toHaveLength(1);
      expect(orderBook.asks).toHaveLength(1);
      expect(orderBook.bids[0].price).toBe(150);
      expect(orderBook.asks[0].price).toBe(155);
    });

    it('should aggregate orders at same price level', () => {
      const buyOrder1: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      const buyOrder2: Order = {
        id: '2',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 150,
        quantity: 50,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now() + 1
      };

      engine.submitOrder(buyOrder1);
      engine.submitOrder(buyOrder2);

      const orderBook = engine.getOrderBook('AAPL');

      expect(orderBook.bids).toHaveLength(1);
      expect(orderBook.bids[0].quantity).toBe(150);
      expect(orderBook.bids[0].orderCount).toBe(2);
    });
  });

  describe('Order Cancellation', () => {
    it('should cancel a pending order', () => {
      const order: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      engine.submitOrder(order);
      const cancelled = engine.cancelOrder('1');

      expect(cancelled).toBe(true);
      expect(order.status).toBe(OrderStatus.CANCELLED);
    });

    it('should not cancel a filled order', () => {
      const sellOrder: Order = {
        id: '1',
        symbol: 'AAPL',
        side: OrderSide.SELL,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now()
      };

      const buyOrder: Order = {
        id: '2',
        symbol: 'AAPL',
        side: OrderSide.BUY,
        price: 150,
        quantity: 100,
        filledQuantity: 0,
        status: OrderStatus.PENDING,
        timestamp: Date.now() + 1
      };

      engine.submitOrder(sellOrder);
      engine.submitOrder(buyOrder);

      const cancelled = engine.cancelOrder('1');
      expect(cancelled).toBe(false);
    });
  });
});
