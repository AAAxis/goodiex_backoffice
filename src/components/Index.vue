<template>
  <div>
    <Navbar />
    <!-- Hero Section -->
    <div class="hero-image">
      <div class="image-container">
        <img src="/hero.png" alt="E-commerce Hero" class="hero-bg-image">
        <div class="centered-hero-title">
          <h1>Create Your Online Store Today</h1>
          <p class="hero-subtitle">Start, grow, and scale your business with our e-commerce platform</p>
          <router-link to="/store-owner/register" class="btn btn-primary btn-lg mt-3">Start Free Trial</router-link>
        </div>
      </div>
    </div>

<div style="padding: 1rem;" class="container">
    <!-- START THE FEATURETTES -->
<br>

  <div class="row">
    <div class="col-12">
      <button class="open-chat-button" onclick="window.open('https://t.me/theholylabs')"><i class="fas fa-comments"></i></button>
    </div>
  </div>

 <h2 style="text-align:center; margin:2rem; color:black;">Why Choose Our Platform</h2>
<br>
    <div class="row featurette">
      <div class="col-md-7">
        <h2 class="featurette-heading fw-normal lh-1">POWERFUL E-COMMERCE TOOLS<span class="text-muted"> Everything you need to succeed</span></h2>
        <p class="lead">Create your online store with powerful tools that help you find customers, drive sales, and manage your business.</p>
      </div>
      <div class="col-md-5">
         <img style="height:25rem; object-position: center; object-fit: cover;
  background-repeat: no-repeat;" class="d-block w-100" src="/post2.png" alt="E-commerce Dashboard">
      </div>
    </div>
<br>
    <hr class="featurette-divider">
<br>
    <div class="row featurette">
      <div class="col-md-7 order-md-2">
        <h2 class="featurette-heading fw-normal lh-1">Seamless Delivery & Logistics <span class="text-muted">We handle everything for you</span></h2>
        <p class="lead">Focus on your business while we take care of all your delivery needs. Our partnerships with trusted logistics companies ensure your products reach customers safely and on time, anywhere in the world.</p>
      </div>
      <div class="col-md-5 order-md-1">
          <img style="height:25rem; object-position: center; object-fit: cover;
  background-repeat: no-repeat;" class="d-block w-100" src="/post1.png" alt="Delivery and Logistics">
      </div>
    </div>
<br>
    <hr class="featurette-divider">
<br>

    <div class="row featurette">
       <div class="col-md-7">
        <h2 class="featurette-heading fw-normal lh-1">24/7 Support<span class="text-muted"> We're here to help</span></h2>
       <p class="text-muted">Get the help you need, when you need it. Our support team is available 24/7 to ensure your success.</p>
      </div>
       <div class="col-md-5">
              <img style="height:25rem; object-position: center; object-fit: cover;
  background-repeat: no-repeat;" class="d-block w-100" src="/post3.png" alt="Support Team">
          </div>
    </div>
<br>
    <hr class="featurette-divider">
    <!-- /END THE FEATURETTES -->
<br>
  </div>
</div>

</template>

<script>
import Navbar from './Navbar.vue'

export default {
  components: {
    Navbar
  },
  data() {
    return {};
  }
};
</script>



<style>
.hero-image {
  height: 100vh;
  margin-top: -76px; /* Adjust this value based on your navbar height */
  padding-top: 76px; /* Add padding to prevent content from going under navbar */
}

.image-container {
  position: relative;
  height: 100%;
}

.hero-bg-image {
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

.hero-subtitle {
  color: #fff;
  font-size: 1.2rem;
  text-shadow: 0 2px 8px rgba(0,0,0,0.5);
  margin: 1rem 0;
}

.btn-primary {
  background-color: #4CAF50;
  border-color: #4CAF50;
  padding: 12px 30px;
  font-size: 1.1rem;
  font-weight: 600;
  border-radius: 25px;
  text-decoration: none;
  transition: all 0.3s ease;
}

.btn-primary:hover {
  background-color: #388e3c;
  border-color: #388e3c;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.2);
}

.mobile-slider {
  display: none;
}

@media (max-width: 768px) {
  .mobile-slider {
    display: none;
  }
  .centered-hero-title h1 {
    font-size: 2rem;
  }
  .hero-subtitle {
    font-size: 1rem;
  }
  .btn-primary {
    font-size: 1rem;
    padding: 10px 25px;
  }
}
</style>
