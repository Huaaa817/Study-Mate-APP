import { z } from "zod";

export const ChatSchema = z.object({
  chat: z.string(),
});

export type Chat = z.infer<typeof ChatSchema>;
