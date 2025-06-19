import firebase from 'firebase/compat/app';
import 'firebase/compat/firestore';
import 'firebase/compat/auth';
import 'firebase/compat/storage';

const firebaseConfig = {
  apiKey: "AIzaSyBtBJvExbuv_bprjk6weIQFZxzyioBdwLc",
  authDomain: "bankapp-9798a.firebaseapp.com",
  projectId: "bankapp-9798a",
  storageBucket: "bankapp-9798a.appspot.com",
  messagingSenderId: "868698601721",
  appId: "1:868698601721:web:5ebe5fabcac75813854a28",
  measurementId: "G-8D7K49379P"
};

if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}

export const db = firebase.firestore();
export const auth = firebase.auth();
export const storage = firebase.storage();
