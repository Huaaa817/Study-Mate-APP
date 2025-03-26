import {onCallGenkit} from 'firebase-functions/https';

// TODO: export your functions
import './flow/customRecipe';
import { customRecipeFlow } from './flow/customRecipe';
export const customRecipe = onCallGenkit(customRecipeFlow);

