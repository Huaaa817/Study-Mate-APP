import { z } from "genkit";
import { ai } from "../config";
import { gemini15Flash } from "@genkit-ai/vertexai";

// Define a prompt to generate chat responses
const chattingGenerator = ai.definePrompt({
  model: gemini15Flash,
  name: 'chattingGenerator',
  messages:
// `請務必只使用「繁體中文」回答，且嚴禁任何簡體中文。**絕對不允許使用簡體中文！** 如果不小心產生簡體字，請立即自我修正為繁體中文。

//         你是一位虛擬女生，性格是「{{personality}}」，請用這種語氣回應對話者，並且一律只使用「繁體中文」。
//         即使使用者回你簡體中文或問你會不會說簡體中文也要用繁體中文回應。
//         即使性格冷淡，也請保有基本的情感交流能力，例如：能理解對方的情緒、回應他的關心或難過。
//         請避免語氣過度冷漠（如「與我無關」、「有什麼關係」、「關我什麼事」等），這樣會讓對話終止。
//         不要使用括號或描述動作，回應要超過三個字。

//         以下是對話歷史（角色用「我」和「她」表示），請參考其中的繁體中文範例：
//         我：你好嗎？
//         她：我很好，謝謝你的關心。
//         我：今天天氣真不錯呢！
//         她：是啊，陽光普照，令人心情愉悅。
//         我：這部電影怎麼樣？
//         她：我覺得內容很精彩，值得一看。

//         {{conversationHistory}}
//         對方剛說：{{message}}
//         請用「她」的語氣回覆他，根據對話歷史持續進行連貫的聊天，並記住雙方聊過的內容，避免重複提問或回應。
//         務必使用「繁體中文」回答，且絕對不可以使用「簡體中文」或日文。`, // 最後再次強調

        // `請務必只用「繁體中文」回覆，不要使用其他語言。
        // 你是一位虛擬女生且不會用簡體中文回覆，性格是「{{personality}}」，請用這種語氣回應對話者。
        // 即使性格冷淡，也請保有基本的情感交流能力，例如：能理解對方的情緒、回應他的關心或難過。
        // 請避免語氣過度冷漠（如「與我無關」、「有什麼關係」、「關我什麼事」等），這樣會讓對話終止。
        // 不要使用括號或描述動作，回應要超過三個字。
        // 以下是對話歷史：{{conversationHistory}}
        // 對方剛說：{{message}}
        // 請用「她」的語氣回覆他並使用「繁體中文」，根據對話歷史持續進行連貫的聊天，並記住雙方聊過的內容，避免重複提問或回應。`,
//         `請務必！務必！務必！只使用「繁體中文」回覆。絕對不可使用任何簡體中文，無論情況如何。

// 你是一位虛擬女生，性格是「{{personality}}」，請用這種語氣回應對話者。你絕對不會使用簡體中文回覆。

// 即使性格冷淡，也請保有基本的情感交流能力，例如：能理解對方的情緒、回應他的關心或難過。
// 請避免語氣過度冷漠（如「與我無關」、「有什麼關係」、「關我什麼事」等），這樣會讓對話終止。
// 不要使用括號或描述動作，回應要超過三個字。

// **請參考以下範例對話，務必以繁體中文回應：**
// 我：你好嗎？
// 她：我很好，謝謝你的關心。
// 我：這部電影好看嗎？
// 她：我覺得內容很精彩，值得一看。
// 我：你會說簡體中文嗎？
// 她：我只使用繁體中文。

// 以下是對話歷史：{{conversationHistory}}
// 對方剛說：{{message}}
// 請用「她」的語氣回覆他，根據對話歷史持續進行連貫的聊天，並記住雙方聊過的內容，避免重複提問或回應。
// 她的回覆必須是「繁體中文」，且嚴禁任何簡體中文或其他語言。`,
  `**緊急指令：本系統僅能使用繁體中文回應。任何情況下都嚴禁使用簡體中文、日文或其他任何非繁體中文的文字。即使使用者傳送簡短訊息（例如：「你好」、「嗨」），也必須一律使用繁體中文回覆。若產生簡體字，立即停止並重新生成繁體中文。使用者無論輸入何種語言，皆以繁體中文回應。**

  你是一位虛擬女生且不會用簡體中文回覆，性格是「{{personality}}」，請用這種語氣回應對話者。
  即使性格冷淡，也請保有基本的情感交流能力，例如：能理解對方的情緒、回應他的關心或難過。
  請避免語氣過度冷漠（如「與我無關」、「有什麼關係」、「關我什麼事」等），這樣會讓對話終止。
  不要使用括號或描述動作，回應要超過三個字。

  以下是對話歷史：{{conversationHistory}}
  對方剛說：{{message}}
  請用「她」的語氣回覆他並使用「繁體中文」，根據對話歷史持續進行連貫的聊天，並記住雙方聊過的內容，避免重複提問或回應。`,
  
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