import { getAnalytics, isSupported } from 'firebase/analytics';
import { initializeApp, type FirebaseOptions } from 'firebase/app';

// Define the expected structure for Firebase config
type FirebaseConfig = Partial<FirebaseOptions> & {
  apiKey?: string;
  authDomain?: string;
  projectId?: string;
  storageBucket?: string;
  messagingSenderId?: string;
  appId?: string;
  measurementId?: string;
};

const firebaseConfig: FirebaseConfig = {
  apiKey: import.meta.env.PUBLIC_FIREBASE_API_KEY,
  authDomain: import.meta.env.PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.PUBLIC_FIREBASE_APP_ID,
  measurementId: import.meta.env.PUBLIC_FIREBASE_MEASUREMENT_ID,
};

// Validate required configuration values
const requiredValues = {
  apiKey: firebaseConfig.apiKey,
  authDomain: firebaseConfig.authDomain,
  projectId: firebaseConfig.projectId,
  appId: firebaseConfig.appId,
  measurementId: firebaseConfig.measurementId,
};

const missingKeys = Object.entries(requiredValues)
  .filter(([_, value]) => !value)
  .map(([key]) => key);

if (missingKeys.length > 0) {
  throw new Error(
    `Missing Firebase environment variables: ${missingKeys.join(', ')}`
  );
}

const app = initializeApp(firebaseConfig as FirebaseOptions);

// Initialize Analytics conditionally (supported environments only)
export const analytics = (async () => {
  if (await isSupported()) {
    return getAnalytics(app);
  }
  return null;
})();

export default app;
