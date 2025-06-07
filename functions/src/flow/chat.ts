import { z } from "genkit";
import { ai } from "../config";
import { gemini15Flash } from "@genkit-ai/vertexai";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

initializeApp();
const db = getFirestore();

// Define Prompt
const greetingGenerator = ai.definePrompt({
    model: gemini15Flash,
    name: "greetingGenerator",
    messages: `
你是一位女生，性格是「{{personality}}」。請用這種語氣對很好的男性朋友說一句自然又超過 15 字的打招呼語，不要叫他的名字。
{{todoReminder}}
不要解釋，不要講太多背景，直接說話。`,
    input: {
        schema: z.object({
            personality: z.string(),
            todoReminder: z.string(),
        }),
    },
});

// Flow：取得打招呼語句
export const greetingFlow = ai.defineFlow(
    {
        name: "greetingFlow",
        inputSchema: z.object({
            userId: z.string(), // ✅ 只需傳入 userId
        }),
    },
    async (input) => {
        try {
            const { userId } = input;

            // ✅ 讀取使用者 personality 文件（固定為 profile）
            const profileDoc = await db
                .collection("apps")
                .doc("study_mate")
                .collection("users")
                .doc(userId)
                .collection("personality")
                .doc("profile")
                .get();

            const personality =
                profileDoc.exists && profileDoc.data()?.type
                    ? profileDoc.data()!.type
                    : "可愛";

            // ✅ 查詢今天的 todos（以台灣 UTC+8 時區切割）
            const now = new Date();

            // 取得當前系統與 UTC 的時間差（台灣為 -480 分鐘）
            const offset = -now.getTimezoneOffset(); // 例如 -480

            // 偏移後的本地時間（轉為台灣時區）
            const localTime = new Date(now.getTime() + offset * 60 * 1000);

            // 台灣時間的今天 00:00
            const today = new Date(localTime);
            today.setHours(0, 0, 0, 0);

            // 台灣時間的明天 00:00
            const tomorrow = new Date(today);
            tomorrow.setDate(today.getDate() + 1);


            const todosSnapshot = await db
                .collection("apps")
                .doc("study_mate")
                .collection("users")
                .doc(userId)
                .collection("todo-items")
                .where("dueDate", ">=", today)
                .where("dueDate", "<", tomorrow)
                .get();

            const todos = todosSnapshot.docs.map((doc) => doc.data());
            const count = todos.length;

            let reminder = "";
            if (count > 0) {
                reminder = `並創意地告訴他，他今天有 ${count} 項代辦事項，一起開始！不需告訴他具體有哪些事項`;
            }

            // ✅ 呼叫 Gemini 生成 greeting
            const response = await greetingGenerator({
                personality,
                todoReminder: reminder,
            });

            const content = response?.message?.content;
            if (content && content[0]?.text) {
                return { greeting: content[0].text };
            } else {
                throw new Error("Failed to retrieve greeting from response.");
            }
        } catch (err) {
            console.error("Error in greetingFlow:", err);
            throw err;
        }
    }
);
