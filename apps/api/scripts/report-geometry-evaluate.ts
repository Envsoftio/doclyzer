import { readFileSync } from 'node:fs';
import {
  evaluate,
  type EvaluationCase,
} from '../src/modules/reports/geometry/evaluation';

const path = process.argv[2];
if (!path)
  throw new Error(
    'Usage: ts-node scripts/report-geometry-evaluate.ts reviewed-cases.json',
  );
const cases = JSON.parse(readFileSync(path, 'utf8')) as EvaluationCase[];
if (!Array.isArray(cases))
  throw new Error('Expected an array of reviewed cases');
console.log(JSON.stringify(evaluate(cases), null, 2));
