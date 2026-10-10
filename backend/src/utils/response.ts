export interface ApiResponse<T = unknown> {
  success: boolean;
  message: string;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: unknown;
  };
}

export function successResponse<T>(
  message: string,
  data?: T
): ApiResponse<T> {
  return {
    success: true,
    message,
    ...(data !== undefined && { data }),
  };
}

export function errorResponse(
  message: string,
  code: string = 'ERROR',
  details?: unknown
): ApiResponse {
  return {
    success: false,
    message,
    error: {
      code,
      message,
      ...(details !== undefined && { details }),
    },
  };
}
