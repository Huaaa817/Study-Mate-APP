import { defineFirestoreRetriever } from '@genkit-ai/firebase';
import { textEmbedding005} from '@genkit-ai/vertexai';

import { getApp, initializeApp } from 'firebase-admin/app';
import { getFirestore, setLogFunction } from 'firebase-admin/firestore';

setLogFunction(console.log) // Logs all Firestore operations to console
import { ai, getProjectId } from './config';

function getOrInitApp() {
  try {
    return initializeApp({
      projectId: getProjectId(),
    });
  } catch (error) {
    console.error(error);
  }
  return getApp();
}

const app = getOrInitApp();
export const firestore = getFirestore(app);

export const recipieRetriever = defineFirestoreRetriever(ai, {
  name: 'recipeRetriever',
  firestore,
  collection: 'recipe_with_vector1',
  contentField: 'ingredients',
  vectorField: 'ingredients_embedding',
  embedder: textEmbedding005,
  distanceMeasure: 'COSINE',
});


