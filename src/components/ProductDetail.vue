<template>
  <div>
    <Navbar />
    <!-- App Bar -->
    <nav class="navbar navbar-light bg-light mb-3 appbar">
      <div class="container-fluid d-flex align-items-center justify-content-between">
        <button class="btn btn-link text-dark p-0 me-2" @click="$router.back()" title="Back">
          <i class="fa fa-arrow-left"></i>
        </button>
        <span class="navbar-brand mb-0 h4 flex-grow-1 text-center">Product Details</span>
        <div class="cart-icon ms-2 position-relative" style="display: inline-block;">
          <router-link to="/cart" style="cursor:pointer; text-decoration: none; color: #000; font-size: 1.5rem;">
            <i class="fa fa-shopping-cart"></i>
          </router-link>
          <span v-if="cartItemCount" class="position-absolute badge rounded-pill bg-danger" style="font-size:0.7rem; top: -3px; right: -8px; min-width: 16px; height: 16px; display: flex; align-items: center; justify-content: center; z-index: 10;">
            {{ cartItemCount }}
          </span>
        </div>
      </div>
    </nav>

    <div class="container" style="padding: 2rem;">
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
        <p class="mt-2">Loading product...</p>
      </div>

      <div v-else-if="!product.id" class="text-center py-5">
        <i class="fa fa-exclamation-triangle fa-4x text-muted mb-3"></i>
        <h3 class="text-muted">Product not found</h3>
        <p class="text-muted">The product you're looking for doesn't exist.</p>
        <button class="btn btn-primary" @click="$router.back()">Go Back</button>
      </div>

      <div v-else class="product-detail">
        <div class="row">
          <div class="col-md-6">
            <div class="product-image-section">
              <img v-if="product.image" :src="product.image" :alt="product.name" class="main-product-image">
              <div v-else class="no-image-placeholder">
                <i class="fa fa-image fa-4x text-muted"></i>
                <p class="text-muted mt-2">No image available</p>
              </div>
            </div>
          </div>
          
          <div class="col-md-6">
            <div class="product-info-section">
              <div class="store-link">
                <router-link :to="`/shop/store/${storeId}`" class="text-muted">
                  <i class="fa fa-store me-1"></i>{{ storeName }}
                </router-link>
              </div>
              
              <h1 class="product-title">{{ product.name }}</h1>
              
              <div class="product-price-section">
                <span class="current-price">{{ formattedPrice }}</span>
              </div>
              
              <div class="product-availability">
                <span v-if="product.stock > 0" class="availability-badge available">
                  <i class="fa fa-check-circle me-1"></i>
                  {{ product.stock }} in stock
                </span>
                <span v-else class="availability-badge unavailable">
                  <i class="fa fa-times-circle me-1"></i>
                  Out of stock
                </span>
              </div>
              
              <div v-if="product.description" class="product-description">
                <h3>Description</h3>
                <p>{{ product.description }}</p>
              </div>
              
              <div class="product-actions">
                <div class="quantity-selector">
                  <label>Quantity:</label>
                  <div class="quantity-controls">
                    <button class="qty-btn" @click="decreaseQuantity" :disabled="quantity <= 1">-</button>
                    <span class="quantity-display">{{ quantity }}</span>
                    <button class="qty-btn" @click="increaseQuantity" :disabled="quantity >= product.stock">+</button>
                  </div>
                </div>
                
                <button 
                  class="add-to-cart-btn-large" 
                  @click="addToCart" 
                  :disabled="product.stock === 0"
                >
                  <i class="fa fa-shopping-cart me-2"></i>
                  {{ product.stock === 0 ? 'Out of Stock' : 'Add to Cart' }}
                </button>
              </div>
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
  name: 'ProductDetail',
  components: {
    Navbar,
  },
  props: {
    storeId: {
      type: String,
      required: true
    },
    productId: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      product: {},
      store: {},
      storeName: '',
      loading: true,
      quantity: 1
    }
  },
  computed: {
    cartItemCount() {
      return cartStore.itemCount;
    },
    formattedPrice() {
      if (!this.product.price) return '$0.00';
      return this.formatPrice(this.product.price);
    }
  },
  async created() {
    this.initializeFirebase();
    await this.fetchStore(); // Load store first to get currency
    this.fetchProduct();
  },
  watch: {
    async '$route'(to, from) {
      if (to.params.productId !== from.params.productId || to.params.storeId !== from.params.storeId) {
        await this.fetchStore(); // Load store first to get currency
        this.fetchProduct();
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
    
    async fetchProduct() {
      this.loading = true;
      try {
        const db = firebase.firestore();
        const productDoc = await db.collection('stores')
          .doc(this.storeId)
          .collection('products')
          .doc(this.productId)
          .get();
        
        if (productDoc.exists) {
          this.product = { id: productDoc.id, ...productDoc.data() };
          this.product.storeId = this.storeId;
          
          // Ensure compatibility with cart component
          if (this.product.image && !this.product.image_url) {
            this.product.image_url = this.product.image;
          }
        } else {
          this.product = {};
        }
      } catch (error) {
        console.error('Error fetching product:', error);
        this.product = {};
      } finally {
        this.loading = false;
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
          this.store = {};
        }
      } catch (error) {
        console.error('Error fetching store:', error);
        this.store = {};
      }
    },
    
    increaseQuantity() {
      if (this.quantity < this.product.stock) {
        this.quantity++;
      }
    },
    
    decreaseQuantity() {
      if (this.quantity > 1) {
        this.quantity--;
      }
    },
    
    addToCart() {
      if (this.product.stock === 0) return;
      
      const hadItemsFromDifferentStore = cartStore.currentStoreId && cartStore.currentStoreId !== this.product.storeId;
      
      for (let i = 0; i < this.quantity; i++) {
        cartStore.addItem(this.product);
      }
      
      if (hadItemsFromDifferentStore) {
        this.showStoreChangeNotification();
      } else {
        this.showAddToCartFeedback();
      }
    },
    
    showAddToCartFeedback() {
      const toast = document.createElement('div');
      toast.className = 'toast-notification';
      toast.innerHTML = `
        <div class="d-flex align-items-center">
          <i class="fa fa-check-circle text-success me-2"></i>
          <span>${this.quantity} × ${this.product.name} added to cart!</span>
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
      
      setTimeout(() => {
        toast.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
          document.body.removeChild(toast);
        }, 300);
      }, 2500);
    },

    showStoreChangeNotification() {
      const toast = document.createElement('div');
      toast.className = 'toast-notification store-change';
      toast.innerHTML = `
        <div class="d-flex align-items-center">
          <i class="fa fa-info-circle text-warning me-2"></i>
          <div>
            <div><strong>Cart cleared!</strong></div>
            <div style="font-size: 0.9rem;">You can only shop from one store at a time. ${this.quantity} × ${this.product.name} added to cart.</div>
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
  color: #000;
  transition: all 0.3s ease;
}

.cart-icon:hover {
  color: #333;
  transform: scale(1.1);
}

.container {
  padding-top: 76px;
}

.product-detail {
  max-width: 1200px;
  margin: 0 auto;
}

.product-image-section {
  position: sticky;
  top: 100px;
}

.main-product-image {
  width: 100%;
  height: 500px;
  object-fit: cover;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}

.no-image-placeholder {
  width: 100%;
  height: 500px;
  background: #f8f9fa;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border: 2px dashed #dee2e6;
}

.product-info-section {
  padding-left: 2rem;
}

.store-link {
  margin-bottom: 1rem;
}

.store-link a {
  text-decoration: none;
  font-size: 0.9rem;
}

.store-link a:hover {
  color: #000 !important;
}

.product-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 1rem;
  line-height: 1.2;
}

.product-price-section {
  margin-bottom: 1.5rem;
}

.current-price {
  font-size: 2rem;
  font-weight: 700;
  color: #000;
}

.product-availability {
  margin-bottom: 2rem;
}

.availability-badge {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
}

.availability-badge.available {
  background: #e8f5e8;
  color: #2e7d32;
}

.availability-badge.unavailable {
  background: #ffebee;
  color: #c62828;
}

.product-description {
  margin-bottom: 2rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid #e9ecef;
}

.product-description h3 {
  font-size: 1.2rem;
  font-weight: 600;
  margin-bottom: 1rem;
  color: #2d3748;
}

.product-description p {
  color: #666;
  line-height: 1.6;
  font-size: 1rem;
}

.product-actions {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.quantity-selector {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.quantity-selector label {
  font-weight: 500;
  color: #2d3748;
}

.quantity-controls {
  display: flex;
  align-items: center;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  overflow: hidden;
}

.qty-btn {
  background: #f8f9fa;
  border: none;
  padding: 0.5rem 1rem;
  cursor: pointer;
  font-size: 1.2rem;
  font-weight: 600;
  color: #495057;
  transition: background 0.2s;
}

.qty-btn:hover:not(:disabled) {
  background: #e9ecef;
}

.qty-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.quantity-display {
  padding: 0.5rem 1rem;
  font-weight: 600;
  min-width: 50px;
  text-align: center;
  background: white;
}

.add-to-cart-btn-large {
  background: #000;
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 8px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 60px;
}

.add-to-cart-btn-large:hover:not(:disabled) {
  background: #333;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.2);
}

.add-to-cart-btn-large:disabled {
  background: #ccc;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
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

/* Responsive Design */
@media (max-width: 768px) {
  .product-info-section {
    padding-left: 0;
    margin-top: 2rem;
  }
  
  .product-title {
    font-size: 2rem;
  }
  
  .current-price {
    font-size: 1.5rem;
  }
  
  .main-product-image {
    height: 400px;
  }
  
  .no-image-placeholder {
    height: 400px;
  }
  
  .product-image-section {
    position: static;
  }
  
  .quantity-selector {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
}

@media (max-width: 480px) {
  .main-product-image {
    height: 300px;
  }
  
  .no-image-placeholder {
    height: 300px;
  }
  
  .product-title {
    font-size: 1.5rem;
  }
}
</style> 