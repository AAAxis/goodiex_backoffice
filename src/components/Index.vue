<template>
  <div>
    <!-- Hero Section -->
    <div class="hero-image">
      <div class="image-container">
        <img src="/hero.jpg" alt="Hero Image">
        <div class="centered-hero-title">
          <h1>Foodiex - Smart Meals Delivery</h1>
          <p class="hero-subtitle">Fresh ingredients delivered to your door</p>
          <router-link to="/shop" class="btn btn-primary btn-lg mt-3">Start Shopping</router-link>
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
       <p class="text-muted"> Looking to share Foodiex with their audience. As an ambassador, you'll receive a personalized code to share, and you'll earn a reward for every box ordered!
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
</div>

</template>

<script>
export default {
  data() {
    return {};
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
