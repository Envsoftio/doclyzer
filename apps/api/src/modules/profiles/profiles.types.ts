export interface Profile {
  id: string;
  userId: string;
  name: string;
  dateOfBirth: string | null;
  relation: string | null;
  createdAt: string;
}

export interface ProfileWithActive extends Profile {
  isActive: boolean;
}

export const PROFILE_NOT_FOUND = 'PROFILE_NOT_FOUND';
export const PROFILE_LIMIT_EXCEEDED = 'PROFILE_LIMIT_EXCEEDED';
