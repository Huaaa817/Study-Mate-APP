importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");


const firebaseConfig = {
  apiKey: "AIzaSyCoKWgPXpGKhFnbC0adNjrALVs2LtTif0U",
  authDomain: "example-recipe-app-5e590.firebaseapp.com",
  projectId: "example-recipe-app-5e590",
  storageBucket: "example-recipe-app-5e590.firebasestorage.app",
  messagingSenderId: "241594561616",
  appId: "1:241594561616:web:065cf7cd4681b6a787cd55"
};

const messaging = firebase.messaging();

messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});
