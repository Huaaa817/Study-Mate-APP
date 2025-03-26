import { genkit } from 'genkit';
import { vertexAI } from '@genkit-ai/vertexai';

const firebaseConfig = {
  // TODO: add your firebase config here
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
