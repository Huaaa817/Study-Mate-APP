import { onCallGenkit } from 'firebase-functions/https';
import { greetingFlow } from './flow/chat';  // 引入生成打招呼語的Flow


// TODO: export your functions
import './flow/customRecipe';
import './flow/retrieveRecipe';
import './flow/image_study_mate';
import { studyMateImageFlow } from "./flow/image_study_mate";
export const studyMateImage = onCallGenkit(studyMateImageFlow);


// 註冊新的Function
export const generateGreeting = onCallGenkit(greetingFlow);

