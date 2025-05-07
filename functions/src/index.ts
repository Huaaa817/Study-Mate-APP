import { onCallGenkit } from 'firebase-functions/https';
import { greetingFlow } from './flow/chat';  // 引入生成打招呼語的Flow
import { chattingFlow } from './flow/chatting'; //引入聊天的Flow
import { backgroundFlow } from './flow/background';  // 引入生成背景圖片的Flow

// TODO: export your functions
import './flow/image_study_mate';
import './flow/chatting';
import { studyMateImageFlow } from "./flow/image_study_mate";
export const studyMateImage = onCallGenkit(studyMateImageFlow);

// 註冊新的Function
export const generateGreeting = onCallGenkit(greetingFlow);
export const generateChatting = onCallGenkit(chattingFlow);
export const generateBackground = onCallGenkit(backgroundFlow);  // 註冊背景生成的Flow