<template>
  <div>
    <Navbar />
    <!-- App Bar -->
    <nav class="navbar navbar-light bg-light mb-3 appbar">
      <div class="container-fluid d-flex align-items-center justify-content-between">
        <button class="btn btn-link text-dark p-0 me-2" @click="$router.back()" title="Back">
          <i class="fa fa-arrow-left"></i>
        </button>
        <span class="navbar-brand mb-0 h4 flex-grow-1 text-center">{{ storeName || 'Shop' }}</span>
      </div>
    </nav>

    <div style="padding: 2rem;" class="container">
      <div class="row align-items-center mb-4">
        <div class="col d-flex justify-content-between align-items-center">
          <h2>Products</h2>
          <div class="cart-icon position-relative">
            <router-link to="/cart" class="cart-link">
              <i class="fa fa-shopping-cart"></i>
              <span v-if="cartItemCount" class="cart-badge">{{ cartItemCount }}</span>
            </router-link>
          </div>
        </div>
      </div>
      
      <!-- Product Grid -->
      <div class="product-grid">
        <div v-for="product in productsWithFormattedPrice" :key="product.id" class="product-card" @click="goToProductDetail(product.id)">
          <div class="product-image-container">
            <img :src="product.image || product.image_url" :alt="product.name" class="product-image">
            <div class="product-name-overlay">
              <h3 class="product-name">{{ product.name }}</h3>
            </div>
          </div>
          <div class="product-info">
            <div class="price-and-button">
              <div class="product-price">{{ product.formattedPrice }}</div>
              <button class="add-to-cart-btn" @click.stop="addToCart(product)">
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
import Navbar from './Navbar.vue'

export default {
  name: 'ProductList',
  components: {
    Navbar,
  },
  props: {
    storeId: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      store: {},
      storeName: '',
      products: [],
    }
  },
  computed: {
    cartItemCount() {
      return cartStore.itemCount;
    },
    productsWithFormattedPrice() {
      return this.products.map(product => ({
        ...product,
        formattedPrice: this.formatPrice(product.price)
      }));
    }
  },
  async created() {
    this.initializeFirebase();
    
    // Fetch products for the store
    if (this.storeId) {
      await this.fetchStore(); // Wait for store to load first
      this.fetchProducts();
    } else {
      // If no storeId, redirect to shop page to choose a store
      this.$router.push('/shop');
    }
  },
  watch: {
    // Watch for route changes to update content accordingly
    async '$route'(to, from) {
      if (to.params.storeId !== from.params.storeId) {
        if (to.params.storeId) {
          await this.fetchStore(); // Wait for store to load first
          this.fetchProducts();
        }
      }
    }
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
    async fetchStore() {
      try {
        const db = firebase.firestore();
        const storeDoc = await db.collection('stores').doc(this.storeId).get();
        if (storeDoc.exists) {
          this.store = storeDoc.data();
          this.storeName = this.store.name;
          console.log('Store loaded with currency:', this.store.currency); // Debug log
        } else {
          this.storeName = '';
          this.store = {}; // Reset store if not found
        }
      } catch (error) {
        console.error('Error fetching store:', error);
        this.store = {};
      }
    },
    fetchProducts() {
      const db = firebase.firestore();
      db.collection('stores').doc(this.storeId).collection('products').get()
        .then(querySnapshot => {
          this.products = [];
          querySnapshot.forEach(doc => {
            const productData = doc.data();
            productData.id = doc.id;
            productData.storeId = this.storeId; // Add storeId to product for cart
            
            // Ensure compatibility with cart component
            if (productData.image && !productData.image_url) {
              productData.image_url = productData.image;
            }
            
            this.products.push(productData);
          });
        });
    },
    goToProductDetail(productId) {
      this.$router.push({
        name: 'ProductDetail',
        params: {
          storeId: this.storeId,
          productId: productId
        }
      });
    },
    
    addToCart(product) {
      const hadItemsFromDifferentStore = cartStore.currentStoreId && cartStore.currentStoreId !== product.storeId;
      
      cartStore.addItem(product);
      
      if (hadItemsFromDifferentStore) {
        // Show notification about cart being cleared
        this.showStoreChangeNotification(product);
      } else {
        // Show regular add to cart confirmation
        this.showAddToCartFeedback(product);
      }
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
    },
    showStoreChangeNotification(product) {
      const toast = document.createElement('div');
      toast.className = 'toast-notification store-change';
      toast.innerHTML = `
        <div class="d-flex align-items-center">
          <i class="fa fa-info-circle text-warning me-2"></i>
          <div>
            <div><strong>Cart cleared!</strong></div>
            <div style="font-size: 0.9rem;">You can only shop from one store at a time. ${product.name} added to cart.</div>
          </div>
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
        border-left: 4px solid #ff9800;
        z-index: 1000;
        animation: slideInRight 0.3s ease;
        max-width: 300px;
      `;
      
      document.body.appendChild(toast);
      
      setTimeout(() => {
        toast.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
          document.body.removeChild(toast);
        }, 300);
      }, 4000);
    },
    formatPrice(price) {
      const symbol = this.getCurrencySymbol(this.store.currency || 'USD')
      return `${symbol}${parseFloat(price).toFixed(2)}`
    },
    getCurrencySymbol(currency) {
      const symbols = {
        'USD': '$',
        'EUR': '€',
        'GBP': '£',
        'JPY': '¥',
        'CAD': 'C$',
        'AUD': 'A$',
        'CHF': 'CHF',
        'CNY': '¥',
        'SEK': 'kr',
        'NOK': 'kr',
        'MXN': '$',
        'INR': '₹',
        'BRL': 'R$',
        'RUB': '₽',
        'KRW': '₩',
        'SGD': 'S$',
        'HKD': 'HK$',
        'NZD': 'NZ$',
        'TRY': '₺',
        'ZAR': 'R',
        'ILS': '₪'
      }
      return symbols[currency?.toUpperCase()] || '$'
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

/* Header Styling */
.container h2 {
  font-size: 2rem;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 1rem;
  margin: 0;
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
  display: inline-block;
  position: relative;
}

.cart-link {
  font-size: 1.5rem;
  color: #000;
  text-decoration: none;
  transition: all 0.3s ease;
  cursor: pointer;
}

.cart-link:hover {
  color: #333;
  transform: scale(1.1);
}

.cart-badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background-color: #dc3545;
  color: white;
  border-radius: 50%;
  padding: 0.1rem 0.25rem;
  font-size: 0.7rem;
  min-width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  line-height: 1;
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
  
  .row.align-items-center .col {
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
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

/* Add some padding to account for fixed navbar */
.container {
  padding-top: 76px;
}
</style>
