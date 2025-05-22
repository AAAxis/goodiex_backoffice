<template>
  <div>
    <Navbar />
    <router-view />
  </div>



  <div class="hero-image">
    <div class="image-container">
      <img src="https://polskoydm.pythonanywhere.com/static/images/designer.png" alt="Hero Image">
  
   
      <div class="top-right">
        <button class="join-button" @click="scrollToBottom">Sign Up</button>
      </div>
    </div>
  </div>

<div style="padding: 1rem;" class="container">
    <!-- START THE FEATURETTES -->
<br>
  <h2 style="text-align:center; margin:1rem;">Favourites Near You</h2>



  <div class="row">
  <div class="col-12">
<button class="open-chat-button" onclick="window.open('https://t.me/polskoydm')"><i class="fas fa-comments"></i></button>

  </div>
  <div class="col-12">
    <div class="row">
      <div class="col-md-2 col-sm-4 col-xs-6 mb-4" v-for="(branch, index) in branches" :key="branch.id">
        <div class="card">
     <a v-if="branch.id" :href="`/${branch.id}/shop`"><img :src="branch.link" :alt="branch.title" class="card-img-top"></a>

          <div class="card-body">
            <h5 class="card-title">{{ branch.name }}</h5>
            <p>20 min - $0 Delivery</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>


 <hr class="featurette-divider">
 <h2 style="text-align:center; margin:2rem; color:black;">Products For Bussiness</h2>
<br>
    <div class="row featurette">
      <div class="col-md-7">
        <h2 class="featurette-heading fw-normal lh-1">QUICK ONLINE SUPERMARKET<span class="text-muted"> Groceries delivered in 20 minutes </span></h2>
        <p class="lead">cheeses, fruit, vegetables, snacks, nuts, and other products</p>
      </div>
      <div class="col-md-5">
         <img style="height:25rem;   object-position: center;  object-fit: none;
  background-repeat: no-repeat;" class="d-block w-100" src="https://polskoydm.pythonanywhere.com/static/images/post1.jpg" alt="First Photo">

      </div>
    </div>
<br>
    <hr class="featurette-divider">
<br>
    <div class="row featurette">
      <div class="col-md-7 order-md-2">
        <h2 class="featurette-heading fw-normal lh-1">Billa makes it incredibly easy for you to discover   <span class="text-muted">and get what you want.</span></h2>
        <p class="lead">Delivered to you – quickly, reliably and affordably.</p>
      </div>
      <div class="col-md-5 order-md-1">
          <img style="height:25rem;   object-position: center;  object-fit: none;
  background-repeat: no-repeat;" class="d-block w-100" src="https://polskoydm.pythonanywhere.com/static/images/post2.jpg" alt="Second Photo">

      </div>
    </div>
<br>
    <hr class="featurette-divider">
<br>

    <div class="row featurette">
       <div class="col-md-7">
        <h2 class="featurette-heading fw-normal lh-1">When you order with Billa<span class="text-muted"> you help thousands of hard-working restaurant and store owners</span></h2>
       <p class="text-muted">Getting home-delivered goods is more than your life made easy.  </p>
      </div>
       <div class="col-md-5">
              <img style="height:25rem;   object-position: center;  object-fit: none;
  background-repeat: no-repeat;" class="d-block w-100" src="https://polskoydm.pythonanywhere.com/static/images/post3.jpg" alt="Third photo">

          </div>
    </div>
<br>
    <hr class="featurette-divider">
    <!-- /END THE FEATURETTES -->
<br>
 
  </div>

</template>

<script>
// Import the necessary Firebase modules
import firebase from 'firebase/compat/app';
import 'firebase/compat/firestore';

export default {
  data() {
    return {
      branches: [] // Initialize an empty array to hold the branches data
    };
  },
  mounted() {
    // Initialize Firebase with your Firebase config
    const firebaseConfig = {
          apiKey: "AIzaSyASwq11lvLT6YfaGwp7W_dCBICDzVsBbSM",
          authDomain: "bankapp-9798a.firebaseapp.com",
          projectId: "bankapp-9798a",
          storageBucket: "bankapp-9798a.appspot.com",
          messagingSenderId: "868698601721",
          appId: "1:868698601721:web:e061dcefcb437f53854a28",
          measurementId: "G-WY7R44DDM4"
    };

    // Check if Firebase is already initialized to avoid reinitialization
    if (!firebase.apps.length) {
      firebase.initializeApp(firebaseConfig);
    }

    // Access the Firestore database
    const db = firebase.firestore();

      // Fetch branches collection
    db.collection('merchants').get().then(querySnapshot => {
      querySnapshot.forEach(doc => {
        const branchData = doc.data();
        // Assign the document ID to the branch data
        branchData.id = doc.id;
        // Push each branch document into the branches array
        this.branches.push(branchData);
      });
    }).catch(error => {
      console.error('Error fetching branches: ', error);
    });
  }
};

</script>



<style>
.hero-image {
  height: 50vh;
}

.image-container {
  position: relative;
  height: 100%;
}

.image-container img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.centered {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
}

h1 {
  font-size: 3rem;
  color: white;
}

.top-right {
  position: absolute;
  top: 10px;
  right: 10px;
  display: flex;
  flex-direction: row;
  align-items: center;
}



.card-img-top {
  width: 100%;
  height: 200px;
   /* 4:3 aspect ratio (change as needed) */
  object-fit: cover; /* This ensures the image fills the container without distortion */
}


.join-button {
  background-color: #4CAF50;
  color: white;
  padding: 8px 15px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.sign-in {
  color: aliceblue;
  margin-left: 10px;
  font-weight: bold;
  text-decoration: none;
  cursor: pointer;
}


.open-chat-button {
  z-index: 1;
  position: fixed;
  bottom: 20px;
  right: 20px;
  border: none;
  border-radius: 50%;
  background-color: #4caf50;
  color: white;
  font-size: 24px;
  padding: 16px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  cursor: pointer;
}

.open-chat-button i {
  margin-right: 0.5rem;
}

.top-right-text {
  position: absolute;
  top: 10px;
  left: 10px;
  color: white;
  font-size: 3rem;
}
</style>
