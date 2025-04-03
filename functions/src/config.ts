import { genkit } from 'genkit';
import { vertexAI } from '@genkit-ai/vertexai';

const firebaseConfig = {
  // TODO: add your firebase config here
  apiKey: "AIzaSyCoKWgPXpGKhFnbC0adNjrALVs2LtTif0U",
  authDomain: "example-recipe-app-5e590.firebaseapp.com",
  projectId: "example-recipe-app-5e590",
  storageBucket: "example-recipe-app-5e590.firebasestorage.app",
  messagingSenderId: "241594561616",
  appId: "1:241594561616:web:065cf7cd4681b6a787cd55"
};

export const getProjectId = () => firebaseConfig.projectId;

// enableFirebaseTelemetry({ projectId: getProjectId() });

export const ai = genkit({
  plugins: [
    vertexAI({
      projectId: getProjectId(),
      location: 'us-central1',
    }),
  ],
});
