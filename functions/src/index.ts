import { onCallGenkit } from 'firebase-functions/https';

// TODO: export your functions
import './flow/customRecipe';
import './flow/retrieveRecipe';
import { customRecipeFlow } from './flow/customRecipe';
export const customRecipe = onCallGenkit(customRecipeFlow);
import { retrieveRecipeFlow } from "./flow/retrieveRecipe";
export const retrieveRecipe = onCallGenkit(retrieveRecipeFlow);