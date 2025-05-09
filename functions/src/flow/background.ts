import { z } from "genkit";
import { ai } from "../config";
import { imagen3 } from "@genkit-ai/vertexai";

// 定義生成動漫背景圖片的 Flow
const backgroundGenerator = ai.definePrompt({
    model: imagen3,  // 使用適合生成動漫圖像的模型
    name: 'backgroundGenerator',
    messages: `You are generating a high-resolution, anime-style background image for a mobile study app.

🎯 Please generate a background scene based exactly on the following description:

"{{description}}"

Do not add characters, close-up objects, or details that are not mentioned above.

The image should be a full, immersive environment with no people.  
Resolution must be 768x1408 pixels (9:16).  
Style: refined, calming, creatively inspiring, suitable as a mobile background.
`,
    input: {
        schema: z.object({ description: z.string() }),
    },
});

// 定義背景生成的 Flow
export const backgroundFlow = ai.defineFlow({
    name: 'backgroundFlow',
    inputSchema: z.object({ description: z.string() }),
}, async (input) => {
    try {
        // 生成背景圖片
        const response = await backgroundGenerator({ description: input.description });

        console.log("Response from background generator:", response);

        // 確保生成的背景圖片存在
        const imageUrl = response?.message?.content?.[0]?.media?.url || "";

        console.log("Generated image URL:", imageUrl);
        // 如果圖片 URL 不存在，則報錯
        if (!imageUrl) {
            throw new Error("Failed to generate background image.");
        }

        // 返回生成的圖片 URL
        return { imageUrl };
    } catch (error) {
        console.error("Error in backgroundFlow:", error);  // 捕獲並打印錯誤
        throw error;
    }
});
