import { z } from "genkit";
import { ai } from "../config";
import { gemini15Flash } from "@genkit-ai/vertexai";

// 定義生成打招呼語的 Prompt
const greetingGenerator = ai.definePrompt({
    model: gemini15Flash,
    name: 'greetingGenerator',
    messages: `你是一位女生，性格是「{{personality}}」。請用這種語氣對很好的男性朋友說一句自然又超過 10 字的打招呼語。不要解釋，不要講太多背景，直接說話。`,
    input: {
        schema: z.object({
            personality: z.string(),
        }),
    },
});

// 定義 Flow 來處理生成過程
export const greetingFlow = ai.defineFlow({
    name: 'greetingFlow',
    inputSchema: z.object({
        personality: z.string(),
    }),
}, async (input) => {
    try {
        const response = await greetingGenerator({
            personality: input.personality,
        });

        // 打印完整的 response，檢查其結構
        console.log('Full Response:', response);

        // 嘗試從 response 中提取內容
        const content = response?.message?.content;
        if (content && content[0]) {
            const greeting = content[0]?.text;  // 確保從內容中正確提取文本
            if (greeting) {
                return { greeting };
            } else {
                throw new Error("Greeting text is empty.");
            }
        } else {
            throw new Error("Failed to retrieve content from the response.");
        }
    } catch (error) {
        // 捕獲並打印錯誤信息
        console.error("Error in greetingFlow:", error);
        throw error;  // 重新拋出錯誤
    }
});
