import { onCallGenkit } from 'firebase-functions/https';
import { greetingFlow } from './flow/chat';  // 引入生成打招呼語的Flow
import { chattingFlow } from './flow/chatting'; //引入聊天的Flow
import { backgroundFlow } from './flow/background';  // 引入生成背景圖片的Flow
import { studyMateImageFlow } from './flow/image_study_mate'; // 引入生成背景圖片的Flow

import * as admin from 'firebase-admin';
import { https } from 'firebase-functions/v2';
import { onSchedule } from 'firebase-functions/v2/scheduler';

// 初始化 Firebase Admin SDK
if (admin.apps.length === 0) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
} else {
  console.log("Firebase app already initialized");
}

const db = admin.firestore();

// 註冊 Functions
export const studyMateImage = onCallGenkit(studyMateImageFlow);
export const generateGreeting = onCallGenkit(greetingFlow);
export const generateChatting = onCallGenkit(chattingFlow);
export const generateBackground = onCallGenkit(backgroundFlow);

// 推播訂閱
export const studyMateAppSubscribeToTopic = https.onCall(async (request) => {
  const { token, topic } = request.data;
  const uid = request.auth?.uid;

  if (!uid) {
    console.error("studyMateAppSubscribeToTopic: Error: Client must log in first.");
    throw new https.HttpsError("failed-precondition", "Please log in first.");
  }

  try {
    await admin.messaging().subscribeToTopic(token, topic);
    console.log(`studyMateAppSubscribeToTopic: Successfully subscribed device with token: ${token} to topic: ${topic}`);
    return { message: `Subscribed to ${topic}` };
  } catch (error) {
    console.error("studyMateAppSubscribeToTopic: Error processing HTTP request", error);
    throw new https.HttpsError("internal", "Internal server error.");
  }
});

// 推播退訂
export const studyMateAppUnsubscribeFromTopic = https.onCall(async (request) => {
  const { token, topic } = request.data;
  const uid = request.auth?.uid;

  if (!uid) {
    console.error("studyMateAppUnsubscribeFromTopic: Error: Client must log in first.");
    throw new https.HttpsError("failed-precondition", "Please log in first.");
  }

  try {
    await admin.messaging().unsubscribeFromTopic(token, topic);
    console.log(`studyMateAppUnsubscribeFromTopic: Successfully unsubscribed device with token: ${token} from topic: ${topic}`);
    return { message: `Unsubscribed from ${topic}` };
  } catch (error) {
    console.error("studyMateAppUnsubscribeFromTopic: Error processing HTTP request", error);
    throw new https.HttpsError("internal", "Internal server error.");
  }
});

// 定時檢查並發送通知的功能
export const notifyLowMoodUsers = onSchedule("every 1 minutes", async (event) => {
  try {
    // 從 Firestore 取得所有用戶資料
    const usersSnapshot = await db.collection('apps/study_mate/users').get();
    const lowMoodUsers: { userId: string; moodValue: number }[] = [];

    // 遍歷所有用戶，找出 mood 值低於 3 的用戶
    usersSnapshot.forEach((userDoc) => {
      const moodStatus = userDoc.data().moodStatus;
      // 檢查 moodStatus 中的 value 是否存在且小於 3
      if (moodStatus && typeof moodStatus.value === "number" && moodStatus.value < 3) {
        lowMoodUsers.push({
          userId: userDoc.id,
          moodValue: moodStatus.value, // 這裡是取 value 作為心情值
        });
      }
    });

    // 如果沒有低 mood 的用戶，結束
    if (lowMoodUsers.length === 0) {
      console.log("No users with low mood found.");
      return;
    }

    // 為每個 mood 值低於 3 的用戶發送推播通知
    const promises = lowMoodUsers.map(async ({ userId, moodValue }) => {
      const userDoc = await db.doc(`apps/study_mate/users/${userId}`).get();
      const fcmToken = userDoc.data()?.fcmToken;

      // 檢查用戶是否有 FCM token
      if (!fcmToken) {
        console.log(`User ${userId} has no FCM token.`);
        return;
      }

      // 構建推播通知消息
      const message = {
        token: fcmToken,
        notification: {
          title: "心情提醒",
          body: `您的心情值目前為 ${moodValue}，建議您稍作休息或調整心情喔！`,
        },
        data: {
          function: "notifyLowMoodUsers",
          moodValue: String(moodValue), // 傳遞 mood 值到推播資料
        },
      };

      // 發送通知
      try {
        await admin.messaging().send(message);
        console.log(`Notification sent to user ${userId}`);
      } catch (error) {
        console.error(`Failed to send notification to user ${userId}:`, error);
      }
    });

    // 等待所有通知發送完畢
    await Promise.all(promises);

  } catch (error) {
    console.error("Error running notifyLowMoodUsers:", error);
  }
});
