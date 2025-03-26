import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
from google.cloud.firestore_v1.vector import Vector

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load CSV
df = pd.read_csv("recipes.csv")

# combine ingredients_embedding vector
embedding_cols = [f"ingredients_embedding/{i}" for i in range(768)]
collection_name = "recipe_with_vector1"

for _, row in df.iterrows():
    embedding_vector = [row[col] for col in embedding_cols]
    recipe_data = {
        "title": str(row["title"]),
        "ingredients": str(row["ingredients"]),
        "directions": str(row["directions"]),
        "ingredients_embedding": Vector(embedding_vector)  # Firestore vector
    }
    db.collection(collection_name).document().set(recipe_data)

print("Upload complete")
