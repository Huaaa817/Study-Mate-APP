import { z } from "zod";
import { Buffer } from "buffer";
import { ai } from "../config";
import { studyMateSchema } from "../type_studymate";
import { imagen3 } from "@genkit-ai/vertexai";


const imageGenerator = ai.definePrompt({
    model: imagen3,
    name: 'imageGenerator',
    messages: `You are a Japanese animation illustrator. Create a medium-long shot portrait of a cheerful anime-style girl. She is dancing, dressed in a uniform, has long black hair.`,
    //messages: `You are a Japanese animation illustrator. Draw a chair.`,
    input: {
        schema: z.object({
            imageSetting: studyMateSchema,
            otherDescription: z.string()
        })
    }
});

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

        // 下載圖片並轉 base64
        const imageResp = await fetch(imageUrl);
        const buffer = Buffer.from(await imageResp.arrayBuffer());
        const base64String = buffer.toString("base64");

        return {
            imageBase64: base64String,
        };
    }
);
