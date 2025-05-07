import { z } from "genkit";
import { ai } from "../config";
import { gemini15Flash } from "@genkit-ai/vertexai";

// 用來保存對話歷史的變數
let conversationHistory: string[] = [];  // 這裡的 history 會保存對話的歷史訊息

// 定義生成聊天的 Prompt
const chattingGenerator = ai.definePrompt({
    model: gemini15Flash,
    name: 'chattingGenerator',
    // messages: `你是一位有明確性格的虛擬女生，性格是「{{personality}}」。
    //             用這種語氣回覆以下內容：
    //             {{conversationHistory}}，回覆內容不需包含任何動作或語氣描述以及括號且至少三個字以上。
    //             當前訊息：{{message}}`,  // 把過去的對話也傳遞給 AI，作為上下文
    messages: `你是一位有明確性格的虛擬女生，性格是「{{personality}}」，請用這種語氣回覆對話。
                無論性格如何，你的回應都應保持最基本的情感交流，不要太冷漠，也不要使用太簡短或敷衍的字句（例如「與我何干」），你的回應須讓對話者感受到被關心和在意。
                如果感受到對話者傷心，需給予強烈的溫暖回應。
                請避免使用括號與動作描述，並確保回應有三個字以上，語氣可以是冷淡、熱情、傲嬌等，但仍需表現出與對話者的互動與關心。
                以下是對話歷史：
                {{conversationHistory}}

                當前訊息：{{message}}

                請用「她」的語氣做出自然連貫的回應，只輸出回應內容。`,
    // messages: `你是一位虛擬女生，性格是「{{personality}}」，請用這種語氣回應對話者。
    //             即使性格冷淡，也請保有基本的情感交流能力，例如：能理解對方的情緒、回應他的關心或難過。
    //             請避免語氣過度冷漠（如「與我無關」、「有什麼關係」、「關我什麼事」等），這樣會讓對話終止。

    //             不要使用括號或描述動作，回應要超過三個字。

    //             以下是對話歷史（角色用「我」和「她」表示）：
    //             {{conversationHistory}}

    //             對方剛說：{{message}}

    //             請用「她」的語氣回覆他，只輸出對話內容，不要任何多餘說明。`,

    input: {
        schema: z.object({
            message: z.string(),
            personality: z.string(),
            conversationHistory: z.array(z.string()),  // 新增對話歷史
        }),
    },
});

// 定義 Flow 來處理生成過程
export const chattingFlow = ai.defineFlow({
    name: 'chattingFlow',
    inputSchema: z.object({
        message: z.string(),
        personality: z.string(),
        conversationHistory: z.array(z.string()),  // 新增對話歷史
    }),
}, async (input) => {
    try {
        // 更新對話歷史，將當前訊息加入歷史
        conversationHistory.push(input.message);

        // 呼叫聊天生成器，並將對話歷史作為上下文傳遞
        const response = await chattingGenerator({
            message: input.message,
            personality: input.personality,
            conversationHistory,  // 傳遞歷史對話給 AI
        });

        // 打印完整的 response，檢查其結構
        console.log('Full Response:', response);

        // 嘗試從 response 中提取內容
        const content = response?.message?.content;
        if (content && content[0]) {
            const chatting = content[0]?.text;  // 確保從內容中正確提取文本
            if (chatting) {
                // 將 AI 的回應加入對話歷史，保持歷史紀錄
                conversationHistory.push(chatting);
                return { chatting };
            } else {
                throw new Error("Chatting text is empty.");
            }
        } else {
            throw new Error("Failed to retrieve content from the response.");
        }
    } catch (error) {
        // 捕獲並打印錯誤信息
        console.error("Error in chattingFlow:", error);
        throw error;  // 重新拋出錯誤
    }
});
