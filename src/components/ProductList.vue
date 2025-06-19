<template>
  <div>
    <!-- App Bar -->
    <nav class="navbar navbar-light bg-light mb-3 appbar">
      <div class="container-fluid d-flex align-items-center justify-content-between">
        <button class="btn btn-link text-dark p-0 me-2" @click="$router.back()" title="Back">
          <i class="fa fa-arrow-left"></i>
        </button>
        <span class="navbar-brand mb-0 h4 flex-grow-1 text-center">{{ storeName || 'Shop' }}</span>
        <div class="cart-icon ms-2 position-relative" style="display: inline-block;">
          <router-link to="/cart" style="cursor:pointer; text-decoration: none; color: #111; font-size: 1.5rem;">
            <i class="fa fa-shopping-cart"></i>
          </router-link>
          <span v-if="cartItemCount" class="position-absolute badge rounded-pill bg-danger" style="font-size:0.7rem; top: -3px; right: -8px; min-width: 16px; height: 16px; display: flex; align-items: center; justify-content: center; z-index: 10;">
            {{ cartItemCount }}
          </span>
        </div>
      </div>
    </nav>

    <!-- Category Chips Block -->
    <div style="padding: 2rem;" class="container">
      <div class="row align-items-center mb-1">
        <div class="col-auto">
          <h2>Products</h2>
        </div>
      </div>
      <div class="row mb-3">
        <div class="col">
          <div class="category-chips">
            <span
              v-for="cat in categories"
              :key="cat.id"
              class="chip"
              :class="{ selected: cat.id === selectedCategoryId }"
              @click="switchCategory(cat.id)"
            >
              {{ cat.name }}
            </span>
          </div>
        </div>
      </div>
      <!-- Product Grid -->
      <div class="product-grid">
        <div v-for="product in products" :key="product.id" class="product-card">
          <div class="product-image-container">
            <img :src="product.image_url" :alt="product.name" class="product-image">
            <div class="product-name-overlay">
              <h3 class="product-name">{{ product.name }}</h3>
            </div>
          </div>
          <div class="product-info">
            <div class="price-and-button">
              <div class="product-price">${{ product.price }}.00</div>
              <button class="add-to-cart-btn" @click="addToCart(product)">
                <i class="fa fa-plus"></i>
                Add to Cart
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import firebase from 'firebase/compat/app';
import 'firebase/compat/firestore';
import cartStore from '../cart.js';

export default {
  name: 'ProductList',
  props: {
    categoryId: {
      type: String,
      default: null
    },
    productId: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      storeName: '',
      products: [],
      categories: [],
      selectedCategoryId: null,
    }
  },
  computed: {
    cartItemCount() {
      return cartStore.itemCount;
    }
  },
  created() {
    this.initializeFirebase();
    this.fetchCategories().then(() => {
      // If categoryId is provided in URL, use it
      if (this.categoryId) {
        this.selectedCategoryId = this.categoryId;
        this.fetchProducts(this.categoryId);
      }
      // Otherwise use first category
      else if (this.categories.length > 0) {
        this.selectedCategoryId = this.categories[0].id;
        this.fetchProducts(this.selectedCategoryId);
      }
    });
  },
  methods: {
    initializeFirebase() {
      const firebaseConfig = {
        apiKey: "AIzaSyASwq11lvLT6YfaGwp7W_dCBICDzVsBbSM",
        authDomain: "bankapp-9798a.firebaseapp.com",
        projectId: "bankapp-9798a",
        storageBucket: "bankapp-9798a.appspot.com",
        messagingSenderId: "868698601721",
        appId: "1:868698601721:web:e061dcefcb437f53854a28",
        measurementId: "G-WY7R44DDM4"
      };
      
      if (!firebase.apps.length) {
        firebase.initializeApp(firebaseConfig);
      }
    },
    fetchCategories() {
      const db = firebase.firestore();
      return db.collection('categories').get().then(querySnapshot => {
        this.categories = [];
        querySnapshot.forEach(doc => {
          const data = doc.data();
          // Only add categories that are receiving orders
          if (data.receivingOrders === true) {
            data.id = doc.id;
            this.categories.push(data);
          }
        });
      });
    },
    fetchProducts(categoryId) {
      const db = firebase.firestore();
      db.collection('categories').doc(categoryId).collection('products').get()
        .then(querySnapshot => {
          this.products = [];
          querySnapshot.forEach(doc => {
            const productData = doc.data();
            productData.id = doc.id;
            this.products.push(productData);
          });
          
          // Get category name for the store name
          db.collection('categories').doc(categoryId).get()
            .then(categoryDoc => {
              if (categoryDoc.exists) {
                this.storeName = categoryDoc.data().name;
              } else {
                this.storeName = '';
              }
            });
        });
    },
    switchCategory(categoryId) {
      this.selectedCategoryId = categoryId;
      this.fetchProducts(categoryId);
      // Update URL when switching categories
      this.$router.push({ name: 'ShopCategory', params: { categoryId } });
    },
    addToCart(product) {
      cartStore.addItem(product);
      
      // Show a brief confirmation
      this.showAddToCartFeedback(product);
    },
    showAddToCartFeedback(product) {
      // Create a simple toast notification
      const toast = document.createElement('div');
      toast.className = 'toast-notification';
      toast.innerHTML = `
        <div class="d-flex align-items-center">
          <i class="fa fa-check-circle text-success me-2"></i>
          <span>${product.name} added to cart!</span>
        </div>
      `;
      toast.style.cssText = `
        position: fixed;
        top: 80px;
        right: 20px;
        background: white;
        padding: 12px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 1000;
        animation: slideInRight 0.3s ease;
      `;
      
      document.body.appendChild(toast);
      
      // Remove toast after 3 seconds
      setTimeout(() => {
        toast.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
          document.body.removeChild(toast);
        }, 300);
      }, 2500);
    }
  }
};
</script>

<style scoped>
/* Modern Product Grid Layout */
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 2rem;
  padding: 1rem 0;
}

/* Product Card */
.product-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  cursor: pointer;
}

.product-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

/* Product Image Container */
.product-image-container {
  position: relative;
  width: 100%;
  height: 240px;
  overflow: hidden;
  background: #f8f9fa;
}

.product-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.product-card:hover .product-image {
  transform: scale(1.05);
}

/* Product Name Overlay */
.product-name-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.8));
  padding: 2rem 1rem 1rem 1rem;
}

.product-name {
  font-size: 1.1rem;
  font-weight: 600;
  color: white;
  margin: 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
}

/* Add to Cart Button */
.add-to-cart-btn {
  background: #343a40;
  color: white;
  border: none;
  padding: 10px 16px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 11px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(52, 58, 64, 0.3);
  white-space: nowrap;
  min-width: 100px;
  height: 38px;
}

.add-to-cart-btn:hover {
  background: #23272b;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(52, 58, 64, 0.4);
}

.add-to-cart-btn i {
  font-size: 10px;
}

/* Price and Button Row */
.price-and-button {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 0.5rem;
}

/* Product Info */
.product-info {
  padding: 1.5rem;
  text-align: center;
}

.product-price {
  font-size: 1.25rem;
  font-weight: 700;
  color: #2d3748;
  margin: 0;
}

/* Category Chips Redesign */
.category-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  margin-bottom: 2rem;
  justify-content: center;
}

.chip {
  display: inline-flex;
  align-items: center;
  padding: 0.75rem 1.5rem;
  border-radius: 50px;
  background: #f8f9fa;
  color: #6c757d;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  border: 2px solid transparent;
  transition: all 0.3s ease;
  text-decoration: none;
}

.chip:hover {
  background: #e9ecef;
  color: #495057;
  transform: translateY(-2px);
}

.chip.selected {
  background: #4CAF50;
  color: white;
  border-color: #4CAF50;
  box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
}

/* Header Styling */
.container h2 {
  font-size: 2rem;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 1rem;
  text-align: center;
}

/* App Bar */
.appbar {
  position: sticky;
  top: 0;
  z-index: 100;
  background: white !important;
  box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
}

.cart-icon {
  font-size: 1.5rem;
  color: #4CAF50;
  transition: all 0.3s ease;
}

.cart-icon:hover {
  color: #45a049;
  transform: scale(1.1);
}

.cart-icon .badge {
  font-size: 0.7rem;
  min-width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Responsive Design */
@media (max-width: 768px) {
  .product-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 1.5rem;
    padding: 0.5rem 0;
  }
  
  .product-image-container {
    height: 200px;
  }
  
  .product-info {
    padding: 1rem;
  }
  
  .product-name {
    font-size: 1rem;
  }
  
  .product-name-overlay {
    padding: 1.5rem 0.75rem 0.75rem 0.75rem;
  }
  
  .product-price {
    font-size: 1.1rem;
  }
  
  .add-to-cart-btn {
    padding: 6px 12px;
    font-size: 11px;
  }
  
  .price-and-button {
    margin-top: 0.5rem;
  }
  
  .container h2 {
    font-size: 1.5rem;
    text-align: left;
  }
  
  .category-chips {
    justify-content: flex-start;
    margin-bottom: 1.5rem;
  }
  
  .chip {
    padding: 0.5rem 1rem;
    font-size: 0.85rem;
  }
}

@media (max-width: 480px) {
  .product-grid {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 1rem;
  }
  
  .product-image-container {
    height: 180px;
  }
}

/* Large Desktop */
@media (min-width: 1200px) {
  .product-grid {
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 2.5rem;
  }
  
  .product-image-container {
    height: 280px;
  }
}

/* Toast Animation Styles */
@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(100%);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideOutRight {
  from {
    opacity: 1;
    transform: translateX(0);
  }
  to {
    opacity: 0;
    transform: translateX(100%);
  }
}

/* Loading States */
.product-card.loading {
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0% {
    opacity: 1;
  }
  50% {
    opacity: 0.7;
  }
  100% {
    opacity: 1;
  }
}
</style>
