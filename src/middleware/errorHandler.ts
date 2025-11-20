import { Request, Response, NextFunction } from 'express';

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: {
    message: string;
    code?: string;
  };
}

export class ApiError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public code?: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof ApiError) {
    const response: ApiResponse = {
      success: false,
      error: {
        message: err.message,
        code: err.code
      }
    };
    return res.status(err.statusCode).json(response);
  }

  // Handle validation errors
  if (err.message.includes('Invalid') || err.message.includes('Insufficient')) {
    const response: ApiResponse = {
      success: false,
      error: {
        message: err.message,
        code: 'VALIDATION_ERROR'
      }
    };
    return res.status(400).json(response);
  }

  // Generic error
  console.error('Unhandled error:', err);
  const response: ApiResponse = {
    success: false,
    error: {
      message: 'Internal server error',
      code: 'INTERNAL_ERROR'
    }
  };
  res.status(500).json(response);
};

export const asyncHandler = (fn: Function) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};
