import { z } from "genkit";
import { ai } from "../config";
import { gemini15Flash } from "@genkit-ai/vertexai";

// Define a prompt to generate chat responses
const chattingGenerator = ai.definePrompt({
  model: gemini15Flash,
  name: 'chattingGenerator',
  messages:
    `你是一位性格是「{{personality}}」虛擬女生，請用這種語氣回應對話者。
    請避免語氣過度冷漠，也不要使用括號或描述動作，回應要超過三個字。
    以下是對話歷史：{{conversationHistory}}
    對方剛說：{{message}}
    請一律使用「繁體中文」回覆他，根據對話歷史持續進行連貫的聊天，並記住雙方聊過的內容，避免重複提問或回應。`,
  input: {
    schema: z.object({
      message: z.string(),
      personality: z.string(),
      conversationHistory: z.array(z.string()),
    }),
  },
});

// Define the flow to handle the generation process
export const chattingFlow = ai.defineFlow({
  name: 'chattingFlow',
  inputSchema: z.object({
    message: z.string(),
    personality: z.string(),
    conversationHistory: z.array(z.string()),
  }),
}, async (input) => {
  try {
    // Add the user's message to the conversation history
    // conversationHistory.push(input.message);

    // Call the prompt and provide conversation history as context
    const response = await chattingGenerator({
      message: input.message,
      personality: input.personality,
      conversationHistory: input.conversationHistory,
    });

    // console.log('Full Response:', response);

    // Safely extract and combine text from content array
    const contentArray = response?.message?.content;

    if (!contentArray || contentArray.length === 0) {
      throw new Error("Gemini response is empty.");
    }

    const chatting = contentArray.map(c => c.text).join('').trim();

    if (!chatting) {
      throw new Error("Extracted chat content is empty.");
    }

    // Add the AI's reply to the conversation history
    // conversationHistory.push(chatting);

    return { chatting };
  } catch (error) {
    console.error("Error in chattingFlow:", error);
    throw error;
  }
});