import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const FIREBASE_API = process.env.FIREBASE_API;
const FIREBASE_MESSAGE_SENDER_ID = process.env.FIREBASE_MESSAGE_SENDER_ID;
const FIREBASE_APP_ID = process.env.FIREBASE_APP_ID;

// TODO: Replace the following with your app's Firebase project configuration
// See: https://support.google.com/firebase/answer/7015592
const firebaseConfig = {
    apiKey: FIREBASE_API,
    authDomain: "coffee-fetcher-e3938.firebaseapp.com",
    projectId: "coffee-fetcher-e3938",
    storageBucket: "coffee-fetcher-e3938.firebasestorage.app",
    databaseURL: "https://coffee-fetcher-e3938-default-rtdb.firebaseio.com/",
    messagingSenderId: FIREBASE_MESSAGE_SENDER_ID,
    appId: FIREBASE_APP_ID,
    measurementId: "G-Y133TH7Y8Y"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Cloud Firestore and get a reference to the service
const db = getFirestore(app);

export { db };