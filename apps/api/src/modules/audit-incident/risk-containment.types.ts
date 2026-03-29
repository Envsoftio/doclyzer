import { BadRequestException, NotFoundException } from '@nestjs/common';

export const TARGET_NOT_FOUND = 'RISK_CONTAINMENT_TARGET_NOT_FOUND' as const;
export const INVALID_STATE_TRANSITION =
  'RISK_CONTAINMENT_INVALID_STATE_TRANSITION' as const;

export type RiskContainmentState =
  | 'pending'
  | 'success'
  | 'failure'
  | 'reverted';
export type RiskContainmentTargetType = 'share_link' | 'account';

export interface RiskContainmentResult {
  state: RiskContainmentState;
  targetType: RiskContainmentTargetType;
  targetId: string;
  suspended: boolean;
  changed: boolean;
  actedAt: string;
}

export class RiskContainmentTargetNotFoundException extends NotFoundException {
  constructor(targetType: RiskContainmentTargetType, targetId: string) {
    super({
      code: TARGET_NOT_FOUND,
      message: `${targetType} ${targetId} was not found`,
    });
  }
}

export class RiskContainmentInvalidStateTransitionException extends BadRequestException {
  constructor(message: string) {
    super({
      code: INVALID_STATE_TRANSITION,
      message,
    });
  }
}
