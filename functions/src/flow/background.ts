import { z } from "genkit";
import { ai } from "../config";
import { imagen3 } from "@genkit-ai/vertexai";

// 定義生成動漫背景圖片的 Flow
const backgroundGenerator = ai.definePrompt({
    model: imagen3,  // 使用適合生成動漫圖像的模型
    name: 'backgroundGenerator',
    messages: `Generate a lively and vibrant anime-style study environment with a cheerful and energetic atmosphere. The scene should include a variety of colorful and dynamic elements such as:
- Bookshelves with books, potted plants with vibrant flowers, and quirky decorations like small figurines or a cute clock.
- A patterned throw blanket or pillow in bright shades like yellow, orange, teal, blue, or green.
- Soft, warm lighting such as a cute desk lamp or fairy lights, creating a cozy and inviting atmosphere.
- A window with a view of a with some greenery or flowers visible outside.
- A rug or carpet with bright, playful patterns like stripes, polka dots, or geometric shapes.
- Walls decorated with colorful artwork, inspirational quotes, or fun posters, adding energy to the space.

Please generate the image with a **random color palette** that includes both **cool tones** (like blue, green, purple) ** and warm tones** (like orange, yellow, red). The color distribution should be varied, ensuring a lively and dynamic feel, with no single color dominating the scene. The overall vibe should feel fresh, youthful, and perfect for an inspiring study app background. The background should be suitable for a mobile screen with a 9:16 aspect ratio and a resolution of 768x1408 pixels.`,
    input: {
        schema: z.object({}),
    },
});

// 定義背景生成的 Flow
export const backgroundFlow = ai.defineFlow({
    name: 'backgroundFlow',
    inputSchema: z.object({}),
}, async () => {
    try {
        // 生成背景圖片
        const response = await backgroundGenerator({});

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
