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
        //hairLength,
        hairColor,
        // hairStyled,
        // decoration,
        // skinTone,
        // smileFeelings,
        // eyeFeeling,
        // personality1,
        // personality2,
    } = input.imageSetting;

    //     return `You are a Japanese animation illustrator. Create a medium-long shot portrait of an anime-style girl.
    // Her hairstyle is ${hairLength}, ${hairColor}, and ${hairStyled}. She is wearing ${decoration}.
    // Her skin tone is ${skinTone}. She has a ${smileFeelings} smile and ${eyeFeeling} eyes.
    // Her personality is ${personality1} and ${personality2}.
    // ${input.otherDescription}`;
    return `You are a Japanese animation illustrator. Create a four-panel sequence (四宮格) of a cheerful anime-style girl with consistent head position in each frame. She is dancing (打招呼) in medium-long shot, wearing a uniform, with long ${hairColor} hair. Each panel should depict a different stage of the greeting movement to form a smooth animation.`;
    //     
}

/**
 * 定義 AI Prompt，傳入 messages 是一個 resolver function
 */
const imageGenerator = ai.definePrompt({
    model: imagen3,
    name: 'imageGenerator',
    messages: (input) => [
        {
            role: 'user',
            content: [
                {
                    text: buildPrompt(input)
                }
            ]
        }
    ],
    input: {
        schema: z.object({
            imageSetting: studyMateSchema,
            otherDescription: z.string()
        })
    }
});

/**
 * Flow 註冊，會由 onCallGenkit 呼叫
 */
export const studyMateImageFlow = ai.defineFlow({
    name: 'studyMateImageFlow',
    inputSchema: z.object({
        imageSetting: studyMateSchema,
        otherDescription: z.string()
    }),
    outputSchema: z.object({
        imageBase64: z.string()
    })
},
    async (input) => {
        let response;
        try {
            response = await imageGenerator({
                imageSetting: input.imageSetting,
                otherDescription: input.otherDescription
            });
        } catch (error: any) {
            const errorMessage = error?.message || "";
            if (errorMessage.includes("Model returned no predictions")) {
                console.warn("Retrying due to content filter...");
                response = await imageGenerator({
                    imageSetting: input.imageSetting,
                    otherDescription: input.otherDescription
                });
            } else {
                throw error;
            }
        }

        const imageUrl = response?.media?.url;
        if (!imageUrl) throw new Error("No image URL returned");

        // 下載圖片並轉為 base64 傳回前端
        const imageResp = await fetch(imageUrl);
        const buffer = Buffer.from(await imageResp.arrayBuffer());
        const base64String = buffer.toString("base64");

        return {
            imageBase64: base64String,
        };
    }
);
