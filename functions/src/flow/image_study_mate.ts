// import { z } from "zod";
// import { Buffer } from "buffer";
// import { ai } from "../config";
// import { studyMateSchema } from "../type_studymate";
// import { imagen3 } from "@genkit-ai/vertexai";


// const imageGenerator = ai.definePrompt({
//     model: imagen3,
//     name: 'imageGenerator',
//     //messages: `You are a Japanese animation illustrator. Create a medium-long shot portrait of a cheerful anime-style girl. She is dancing, dressed in a uniform, has long black hair.`,
//     //messages: `You are a Japanese animation illustrator. Draw a chair.`,
//     messages: `You are a Japanese animation illustrator. Create a four-panel sequence (四宮格) of a cheerful anime-style girl with consistent head position in each frame. She is dancing (打招呼) in medium-long shot, wearing a uniform, with long black hair. Each panel should depict a different stage of the greeting movement to form a smooth animation.`,
//     input: {
//         schema: z.object({
//             imageSetting: studyMateSchema,
//             otherDescription: z.string()
//         })
//     }
// });

// export const studyMateImageFlow = ai.defineFlow({
//     name: 'studyMateImageFlow',
//     inputSchema: z.object({
//         imageSetting: studyMateSchema,
//         otherDescription: z.string()
//     }),
//     outputSchema: z.object({
//         imageBase64: z.string()
//     })
// },
//     async (input) => {
//         let response;
//         try {
//             response = await imageGenerator({
//                 imageSetting: input.imageSetting,
//                 otherDescription: input.otherDescription
//             });
//         } catch (error: any) {
//             const errorMessage = error?.message || "";
//             if (errorMessage.includes("Model returned no predictions")) {
//                 console.warn("Retrying due to content filter...");
//                 response = await imageGenerator({
//                     imageSetting: input.imageSetting,
//                     otherDescription: input.otherDescription
//                 });
//             } else {
//                 throw error;
//             }
//         }

//         const imageUrl = response?.media?.url;
//         if (!imageUrl) throw new Error("No image URL returned");

//         // 下載圖片並轉 base64
//         const imageResp = await fetch(imageUrl);
//         const buffer = Buffer.from(await imageResp.arrayBuffer());
//         const base64String = buffer.toString("base64");

//         return {
//             imageBase64: base64String,
//         };
//     }
// );

import { z } from "zod";
import { Buffer } from "buffer";
import { ai } from "../config";
import { studyMateSchema } from "../type_studymate";
import { imagen3 } from "@genkit-ai/vertexai";

/**
 * 將使用者輸入轉成 prompt 文字
 */
function buildPrompt(input: {
    imageSetting: z.infer<typeof studyMateSchema>;
    otherDescription: string;
}): string {
    const {
        hairColor,
        skinTone,
        hairStyled,
        hairLength,
        personality1,
    } = input.imageSetting;

    return `
    You are a Japanese anime illustrator. Create a ${personality1} anime-style girl in a four-panel (四宮格) sequence. She has a ${skinTone} skin tone and wears her hair in a ${hairLength.toLowerCase()}, ${hairStyled.toLowerCase()} style. Follow the detailed instructions below:

    Global requirements for all four panels:
    - No borders or frames between the panels.
    - Each panel must be the same size and have equal visual weight.
    - The girl should always face forward (frontal face).
    - Each panel is a medium-long shot.
    - The girl's body stays centered in every frame.
    - Keep head position and framing consistent.
    - The girl must align with the bottom edge of each panel, so she is drawn starting from the bottom of the panel upwards.

    Panel 1 (top-left):
    - The girl is sitting and reading a book.
    - She wears a school uniform and has long ${hairColor} hair.
    - She has a ${skinTone} skin tone.
    - The mood is calm and focused.


    panel 2, 3, 4 should depict a different stage of the dancing movement to form a smooth animation, and ensure Each panel is a medium-long shot.
    Panel 2 (top-right):
    - A new action begins (not related to panel 1).
    - The girl is now dancing in a medium-long shot.
    - She has a ${skinTone} skin tone.
    - Medium-long shot, same framing and position.

    Panel 3 (bottom-left):
    - Continue the dance motion from panel 2.
    - The girl is dancing with her right hand beside her face, in a medium-long shot.
    - She has a ${skinTone} skin tone.
    - Her fingers are spread in a lively greeting.

    Panel 4 (bottom-right):
    - Continue smoothly from panel 3.
    - The girl is dancing in a final dynamic pose in a medium-long shot.
    - She has a ${skinTone} skin tone.
    - Same style and consistent framing.

    Remember: all four panels must follow the global requirements above.
    `;
    // return `You are a Japanese animation illustrator. Create a four-panel sequence (四宮格) of a cheerful anime-style girl with consistent head position in each frame. She is dancing (打招呼) in medium-long shot, wearing a uniform, with long ${hairColor} hair. Each panel should depict a different stage of the greeting movement to form a smooth animation.`
    //     ;
}

/**
 * 定義 AI Prompt
 */
const imageGenerator = ai.definePrompt({
    model: imagen3,
    name: "imageGenerator",
    messages: (input) => [
        {
            role: "user",
            content: [{ text: buildPrompt(input) }],
        },
    ],
    input: {
        schema: z.object({
            imageSetting: studyMateSchema,
            otherDescription: z.string(),
        }),
    },
});

/**
 * Flow 主體：呼叫 image model 並轉為 base64 字串，Dev UI 顯示圖片
 */
export const studyMateImageFlow = ai.defineFlow(
    {
        name: "studyMateImageFlow",
        inputSchema: z.object({
            imageSetting: studyMateSchema,
            otherDescription: z.string(),
        }),
        outputSchema: z.object({
            imageBase64: z.string(),
            imageBase64Preview: z.string().optional(), // Dev UI 用來預覽圖片
        }),
    },
    async (input) => {
        let response;
        try {
            response = await imageGenerator({
                imageSetting: input.imageSetting,
                otherDescription: input.otherDescription,
            });
        } catch (error: any) {
            const errorMessage = error?.message || "";
            if (errorMessage.includes("Model returned no predictions")) {
                console.warn("Retrying due to content filter...");
                response = await imageGenerator({
                    imageSetting: input.imageSetting,
                    otherDescription: input.otherDescription,
                });
            } else {
                throw error;
            }
        }

        const imageUrl = response?.media?.url;
        if (!imageUrl) throw new Error("No image URL returned");

        const imageResp = await fetch(imageUrl);
        const buffer = Buffer.from(await imageResp.arrayBuffer());
        const base64String = buffer.toString("base64");

        return {
            imageBase64: base64String,
            imageBase64Preview: imageUrl, // Dev UI 預覽用
        };
    }
);
