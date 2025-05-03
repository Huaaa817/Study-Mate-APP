import { z } from "zod";

export const studyMateSchema = z.object({
    hairLength: z.string(),
    hairColor: z.string(),
    hairStyled: z.string(),
    decoration: z.string(),
    skinTone: z.string(),
    smileFeelings: z.string(),
    eyeFeeling: z.string(),
    personality1: z.string(),
    personality2: z.string(),
});

export type studyMate = z.infer<typeof studyMateSchema>;