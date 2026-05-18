import os
import logging
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, firestore
from config.settings import settings

logger = logging.getLogger("ai_seekho.firebase")

db = None

def init_firebase():
    global db
    if not firebase_admin._apps:
        try:
            # Resolve path relative to backend root
            cred_path = settings.FIREBASE_CREDENTIALS_PATH
            if not os.path.isabs(cred_path):
                backend_root = Path(__file__).resolve().parent.parent
                resolved_path = (backend_root / cred_path).resolve()
            else:
                resolved_path = Path(cred_path)

            if resolved_path.exists():
                logger.info(f"Initializing Firebase Admin with Service Account at: {resolved_path}")
                cred = credentials.Certificate(str(resolved_path))
                firebase_admin.initialize_app(cred)
            else:
                logger.warning(f"Firebase credentials JSON not found at: {resolved_path}. Falling back to default app initialization.")
                firebase_admin.initialize_app()
            
            db = firestore.client()
            logger.info("Firebase Admin and Firestore client initialized successfully.")
        except Exception as e:
            logger.error(f"Error initializing Firebase: {e}")
            raise e
    else:
        db = firestore.client()
    return db

# Initialize immediately for module import
try:
    db = init_firebase()
except Exception:
    db = None
