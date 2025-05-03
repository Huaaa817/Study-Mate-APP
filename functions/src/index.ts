import { onCallGenkit } from 'firebase-functions/https';

// TODO: export your functions
import './flow/customRecipe';
import './flow/retrieveRecipe';
import './flow/image_study_mate';
import { studyMateImageFlow } from "./flow/image_study_mate";
export const studyMateImage = onCallGenkit(studyMateImageFlow);

