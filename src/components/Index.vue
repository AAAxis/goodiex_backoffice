<template>
  <div>
    <Navbar />
    <router-view />
  </div>



  <div class="hero-image">
    <div class="image-container">
      <img src="/hero.jpg" alt="Hero Image">
      <div class="centered-hero-title">
        <h1>Foodiex - Smart Meals Delivery</h1>
      </div>
    </div>
  </div>

<div style="padding: 1rem;" class="container">
    <!-- START THE FEATURETTES -->
<br>
  <h2 style="text-align:center; margin:1rem;">Over 60 dinner recipes to choose from every week</h2>



  <div class="row">
  <div class="col-12">
<button class="open-chat-button" onclick="window.open('https://t.me/polskoydm')"><i class="fas fa-comments"></i></button>

  </div>
  <div class="col-12">
    <!-- Mobile slider -->
    <div class="mobile-slider">
      <div class="slider-track">
        <div class="slider-card" v-for="(category, index) in categories" :key="category.id">
          <div class="card">
            <a v-if="category.id" :href="`/${category.id}/shop`"><img :src="category.link" :alt="category.title" class="card-img-top"></a>
            <div class="card-body">
              <h5 class="card-title">{{ category.name }}</h5>
              <p>0$ Free Delivery</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Desktop grid -->
    <div class="desktop-grid">
      <div class="row">
        <div class="col-md-2 col-sm-4 col-xs-6 mb-4" v-for="(category, index) in categories" :key="category.id">
          <div class="card">
            <a v-if="category.id" :href="`/${category.id}/shop`"><img :src="category.link" :alt="category.title" class="card-img-top"></a>
            <div class="card-body">
              <h5 class="card-title">{{ category.name }}</h5>
              <p>0$ Free Delivery</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>


 <hr class="featurette-divider">
 <h2 style="text-align:center; margin:2rem; color:black;">How it works</h2>
<br>
    <div class="row featurette">
      <div class="col-md-7">
        <h2 class="featurette-heading fw-normal lh-1">QUICK ONLINE SUPERMARKET<span class="text-muted"> Groceries delivered every week </span></h2>
        <p class="lead">cheeses, fruit, vegetables, snacks, nuts, and other products</p>
      </div>
      <div class="col-md-5">
         <img style="height:25rem;   object-position: center;  object-fit: cover;
  background-repeat: no-repeat;" class="d-block w-100" src="/post2.png" alt="First Photo">

      </div>
    </div>
<br>
    <hr class="featurette-divider">
<br>
    <div class="row featurette">
      <div class="col-md-7 order-md-2">
        <h2 class="featurette-heading fw-normal lh-1">Get Free Products <span class="text-muted">Enjoy a free Foodiex box.</span></h2>
        <p class="lead"> and share experience with your family or friends.</p>
      </div>
      <div class="col-md-5 order-md-1">
          <img style="height:25rem;   object-position: center;  object-fit: cover;
  background-repeat: no-repeat;" class="d-block w-100" src="/post1.png" alt="Second Photo">

      </div>
    </div>
<br>
    <hr class="featurette-divider">
<br>

    <div class="row featurette">
       <div class="col-md-7">
        <h2 class="featurette-heading fw-normal lh-1">Ambassador Program<span class="text-muted">is designed for passionate creators
</span></h2>
       <p class="text-muted"> Looking to share Foodiex with their audience. As an ambassador, you’ll receive a personalized code to share, and you’ll earn a reward for every box ordered!
 </p>
      </div>
       <div class="col-md-5">
              <img style="height:25rem;   object-position: center;  object-fit: cover;
  background-repeat: no-repeat;" class="d-block w-100" src="/post3.png" alt="Third photo">

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
      categories: [] // Initialize an empty array to hold the categories data
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

      // Fetch categories collection
    db.collection('categories').get().then(querySnapshot => {
      querySnapshot.forEach(doc => {
        const categoryData = doc.data();
        // Only add categories that are receiving orders
        if (categoryData.receivingOrders === true) {
          categoryData.id = doc.id;
          this.categories.push(categoryData);
        }
      });
    }).catch(error => {
      console.error('Error fetching categories: ', error);
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

.centered-hero-title {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  width: 100%;
  z-index: 2;
}
.centered-hero-title h1 {
  color: #fff;
  font-size: 2.5rem;
  text-shadow: 0 2px 8px rgba(0,0,0,0.5);
  font-weight: bold;
  margin: 0;
}

.mobile-slider {
  display: none;
}
.desktop-grid {
  display: block;
}
@media (min-width: 769px) {
  .desktop-grid > .row {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
  }
}
@media (max-width: 768px) {
  .mobile-slider {
    display: block;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    margin-bottom: 1.5rem;
  }
  .slider-track {
    display: flex;
    flex-direction: row;
    gap: 1rem;
    width: max-content;
    padding-bottom: 0.5rem;
  }
  .slider-card {
    min-width: 220px;
    flex: 0 0 auto;
  }
  .desktop-grid {
    display: none;
  }
}
</style>
