import { z } from "zod";

export const RecipeSchema = z.object({
  title: z.string(),
  ingredients: z.string(),
  directions: z.string(),
  ingredient_embedding: z.unknown().optional(),
});

export type Recipe = z.infer<typeof RecipeSchema>;