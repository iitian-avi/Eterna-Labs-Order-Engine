/**
 * Position Manager
 * Tracks user positions and ensures users cannot sell more than they own
 */

export interface Position {
  symbol: string;
  quantity: number;
}

export class PositionManager {
  // Map of userId -> symbol -> quantity
  private positions: Map<string, Map<string, number>>;

  constructor() {
    this.positions = new Map();
  }

  /**
   * Initialize a user if not exists
   */
  private ensureUser(userId: string): void {
    if (!this.positions.has(userId)) {
      this.positions.set(userId, new Map());
    }
  }

  /**
   * Get user's position for a symbol
   */
  public getPosition(userId: string, symbol: string): number {
    this.ensureUser(userId);
    return this.positions.get(userId)?.get(symbol) || 0;
  }

  /**
   * Get all positions for a user
   */
  public getUserPositions(userId: string): Position[] {
    this.ensureUser(userId);
    const userPositions = this.positions.get(userId)!;
    const positions: Position[] = [];

    userPositions.forEach((quantity, symbol) => {
      if (quantity > 0) {
        positions.push({ symbol, quantity });
      }
    });

    return positions;
  }

  /**
   * Check if user has sufficient quantity to sell
   */
  public canSell(userId: string, symbol: string, quantity: number): boolean {
    const currentPosition = this.getPosition(userId, symbol);
    return currentPosition >= quantity;
  }

  /**
   * Update position after a trade
   * For BUY: Add to position
   * For SELL: Subtract from position
   */
  public updatePosition(userId: string, symbol: string, quantity: number, isBuy: boolean): void {
    this.ensureUser(userId);
    const userPositions = this.positions.get(userId)!;
    const currentPosition = userPositions.get(symbol) || 0;

    const newPosition = isBuy 
      ? currentPosition + quantity 
      : currentPosition - quantity;

    if (newPosition < 0) {
      throw new Error('Position cannot be negative');
    }

    userPositions.set(symbol, newPosition);
  }

  /**
   * Give initial balance to user for testing
   */
  public giveInitialBalance(userId: string, symbol: string, quantity: number): void {
    this.ensureUser(userId);
    const userPositions = this.positions.get(userId)!;
    userPositions.set(symbol, quantity);
  }

  /**
   * Reset all positions (for testing)
   */
  public reset(): void {
    this.positions.clear();
  }
}
