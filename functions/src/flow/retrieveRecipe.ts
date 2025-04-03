// hint: complete your retrieveRecipeFlow here
import { z } from "genkit";
import { ai } from "../config";
//import { Recipe } from "../type";
//import { gemini15Flash } from "@genkit-ai/vertexai";
import { recipieRetriever } from "../retriever";

import { Recipe, RecipeSchema } from "../type";


export const retrieveRecipeFlow = ai.defineFlow({
    name: 'retrieveRecipeFlow',
    inputSchema: z.string(),
    outputSchema: z.array(RecipeSchema)
},

    async (input) => {
        // 1. 檢索與使用者食材匹配的五道食譜
        console.log("User input ingredients:", input);
        console.log("I'm Here!");

        const recipes: Recipe[] = await ai.run(
            'Retrieve matching ingredients',
            async () => {
                try {
                    const docs = await ai.retrieve({
                        retriever: recipieRetriever,
                        query: input,
                        options: {
                            limit: 5,
                        },
                    });
                    console.log("Retrieved docs:", docs);
                    return docs.map((doc) => {
                        const data = doc.toJSON();
                        const metadata = data.metadata || {};
                        const recipe: Recipe = {
                            title: typeof metadata.title === 'string' ? metadata.title : '',
                            directions: typeof metadata.directions === 'string' ? metadata.directions : '',
                            ingredients: data.content?.[0]?.text ?? '',
                        };
                        return recipe;
                    });
                } catch (error) {
                    console.error("Hi, Error retrieving recipes:", error);
                    return [];
                }
            },
        );

        // 2. 若找不到任何食譜，回傳空陣列
        if (recipes.length === 0) {
            return [];
        }
        console.log("Final recipes:", recipes);
        return JSON.parse(JSON.stringify(recipes));;
    }
);
