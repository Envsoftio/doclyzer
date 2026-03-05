import { ArrayNotEmpty, IsArray, IsIn, IsString } from 'class-validator';

export class AcceptPoliciesDto {
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsIn(['terms', 'privacy'], { each: true })
  policyTypes!: string[];
}
