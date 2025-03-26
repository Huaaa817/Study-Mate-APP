import {onCallGenkit} from 'firebase-functions/https';

import './flow/customRecipe';
import { customRecipeFlow } from './flow/customRecipe';
export const customRecipe = onCallGenkit(customRecipeFlow);

