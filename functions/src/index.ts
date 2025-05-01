import { onCallGenkit } from 'firebase-functions/https';
import { greetingFlow } from './flow/chat';  // 引入生成打招呼語的Flow

// 註冊新的Function
export const generateGreeting = onCallGenkit(greetingFlow);
