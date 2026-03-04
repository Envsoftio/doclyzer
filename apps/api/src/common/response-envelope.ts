export interface ApiSuccessResponse<TData> {
  success: true;
  data: TData;
  correlationId: string;
}

export interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
  };
  correlationId: string;
}

export function successResponse<TData>(
  data: TData,
  correlationId: string,
): ApiSuccessResponse<TData> {
  return {
    success: true,
    data,
    correlationId,
  };
}
