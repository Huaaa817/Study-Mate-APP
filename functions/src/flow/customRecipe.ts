import { z } from "genkit";
import { ai } from "../config";
import { Recipe, RecipeSchema } from "../type";
import { gemini15Flash, imagen3 } from "@genkit-ai/vertexai";
import { recipieRetriever } from "../retriever";

const recipeGenerator = ai.definePrompt({
    model: gemini15Flash,
    name:'recipeGenerator',
    messages: `You are given an original recipe with ingredients and directions. Your task is to modify the recipe to fit the user's available ingredients while keeping the dish as close to the original as possible.

                Original Recipe:

                Title: {{suggestRecipe.title}}
                Ingredients: {{suggestRecipe.ingredients}}
                Directions: {{suggestRecipe.directions}}

                User's Available Ingredients: {{ingredients}}

                Requirements:
                - **Remove** ingredients that the user doesn't have, except for the basic ingredients such as oil or salt.
                - Suggest reasonable substitutions for missing ingredients.
                - Adjust the cooking steps accordingly.
                - Maintain the essence of the dish.

                Output format:
                - title: string, the modified recipe's name
                - ingredients: string, List of new ingredients based on the user's available items
                - directions: string, Modified step-by-step instructions`,
    input: {
        schema: z.object({
            suggestRecipe: z.object({
                title: z.string(),
                ingredients: z.string(),
                directions: z.string()
            }),
            ingredients: z.string()
        })
    }
})         

const imageGenerator = ai.definePrompt({
    model: imagen3,
    name: 'imageGenerator',
    messages: `Create a high-quality, realistic image of a delicious dish named {{title}}. 
            The dish should include the following key ingredients: {{ingredients}}. 
            And it is made by the process: {{directions}}.
            Present the dish in an appealing way, plated beautifully on a well-lit dining table. 
            The colors should be vibrant, and the texture of the ingredients should look fresh and appetizing. 
            Ensure the presentation matches traditional or common ways this dish is served. 
            The background should be simple and elegant, enhancing the focus on the dish itself.`,
    input: {
        schema: z.object({
            title: z.string(),
            ingredients: z.string(),
            directions: z.string()
        })
    }
});


export const customRecipeFlow = ai.defineFlow({
    name: 'customRecipeFlow',
    inputSchema: z.string(),
    /* hint: change to this inputSchema for lab */
    // inputSchema: z.object({
    //     suggestRecipe: RecipeSchema,
    //     ingredients: z.string()
    // }),
},
    async (input) => {

        const recipes: Recipe[] = await ai.run(
            'Retrieve matching ingredients',
            async () => {
                try{
                    const docs = await ai.retrieve({
                        retriever: recipieRetriever,
                        query: input,
                        options: {
                            limit: 1,
                        },
                    });
                    return docs.map((doc) => {
                        const data = doc.toJSON();
                        console.log(data);
                        const recipe : Recipe = {
                            title: '',
                            directions: '',
                            ingredients: '',
                            ...data.metadata,
                        };
                        delete recipe.ingredient_embedding;
                        recipe.ingredients = data.content[0].text!
                        return recipe;
                    });
                }
                catch(error) {
                    console.log(error);
                    return [];
                }
            },
        );

 
        const response = await recipeGenerator(
            
            {
            suggestRecipe: recipes[0],
            ingredients: input
         });

        const customRecipe: Recipe | null = response?.output;

        return customRecipe;
        
        /* hint: change to this return format for lab */
        // return { 
        //     recipe:  ...
        //     customRecipeImage: ...
        //     originRecipeImage: ...
        // };

    }
)