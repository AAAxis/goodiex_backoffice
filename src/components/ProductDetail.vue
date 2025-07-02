<template>
  <div>
    <Navbar :storeName="storeName" />


    <div class="container" style="padding: 2rem;">
      <div class="row align-items-center mb-4">
        <div class="col d-flex justify-content-between align-items-center">
          <h2>Product Details</h2>
          <div class="cart-icon position-relative">
            <router-link to="/cart" class="cart-link">
              <i class="fa fa-shopping-cart"></i>
              <span v-if="cartItemCount" class="cart-badge">{{ cartItemCount }}</span>
            </router-link>
          </div>
        </div>
      </div>
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
              <div v-if="galleryImages.length > 0" class="gallery-wrapper">
                <img :src="galleryImages[selectedImageIndex]" :alt="product.name" class="main-product-image" />
                <div v-if="galleryImages.length > 1" class="gallery-thumbnails">
                  <img
                    v-for="(img, idx) in galleryImages"
                    :key="img"
                    :src="img"
                    :alt="`Thumbnail ${idx+1}`"
                    class="gallery-thumb"
                    :class="{ selected: idx === selectedImageIndex }"
                    @click="selectedImageIndex = idx"
                  />
                </div>
              </div>
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

        <!-- Contact Us Section -->
        <div v-if="store && (store.phone || store.email || store.address)" class="contact-section mt-5">
          <h3>Contact Us</h3>
          <div class="contact-items">
            <div v-if="store.phone" class="contact-item">
              <i class="fa fa-phone"></i>
              <a :href="`tel:${store.phone}`">{{ store.phone }}</a>
            </div>
            <div v-if="store.email" class="contact-item">
              <i class="fa fa-envelope"></i>
              <a :href="`mailto:${store.email}`">{{ store.email }}</a>
            </div>
            <div v-if="store.address" class="contact-item">
              <i class="fa fa-map-marker-alt"></i>
              <span>{{ store.address }}</span>
            </div>
          </div>
        </div>

        <!-- Similar Products Section -->
        <div v-if="similarProducts.length > 0" class="similar-products-section mt-5">
          <h3>Similar Products</h3>
          <div class="similar-products-row">
            <div v-for="item in similarProducts" :key="item.id" class="similar-product-card">
              <router-link :to="`/shop/store/${storeId}/product/${item.id}`" class="similar-product-link">
                <img :src="(item.images && item.images[0]) || item.image || ''" :alt="item.name" class="similar-product-image" />
                <div class="similar-product-info">
                  <div class="similar-product-name">{{ item.name }}</div>
                  <div class="similar-product-price">{{ formatPrice(item.price) }}</div>
                </div>
              </router-link>
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
      quantity: 1,
      selectedImageIndex: 0,
      similarProducts: []
    }
  },
  computed: {
    galleryImages() {
      if (Array.isArray(this.product.images) && this.product.images.length > 0) {
        return this.product.images
      } else if (this.product.image) {
        return [this.product.image]
      } else {
        return []
      }
    },
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
    this.fetchSimilarProducts();
  },
  watch: {
    async '$route'(to, from) {
      if (to.params.productId !== from.params.productId || to.params.storeId !== from.params.storeId) {
        await this.fetchStore(); // Load store first to get currency
        this.fetchProduct();
        this.selectedImageIndex = 0;
        this.fetchSimilarProducts();
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
          this.selectedImageIndex = 0;
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
        bottom: 40px;
        left: 50%;
        right: auto;
        top: auto;
        transform: translateX(-50%);
        background: white;
        padding: 12px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 1000;
        animation: slideInUp 0.3s ease;
      `;
      document.body.appendChild(toast);
      setTimeout(() => {
        toast.style.animation = 'slideOutDown 0.3s ease';
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
        bottom: 40px;
        left: 50%;
        right: auto;
        top: auto;
        transform: translateX(-50%);
        background: white;
        padding: 12px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        border-left: 4px solid #ff9800;
        z-index: 1000;
        animation: slideInUp 0.3s ease;
        max-width: 300px;
      `;
      document.body.appendChild(toast);
      setTimeout(() => {
        toast.style.animation = 'slideOutDown 0.3s ease';
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
    },

    async fetchSimilarProducts() {
      if (!this.storeId || !this.productId) return;
      try {
        const db = firebase.firestore();
        const productsSnap = await db.collection('stores').doc(this.storeId).collection('products').limit(20).get();
        const all = [];
        productsSnap.forEach(doc => {
          if (doc.id !== this.productId) {
            all.push({ id: doc.id, ...doc.data() });
          }
        });
        // Shuffle and pick up to 4
        for (let i = all.length - 1; i > 0; i--) {
          const j = Math.floor(Math.random() * (i + 1));
          [all[i], all[j]] = [all[j], all[i]];
        }
        this.similarProducts = all.slice(0, 4);
      } catch (e) {
        this.similarProducts = [];
      }
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

/* Header Styling */
.container h2 {
  font-size: 2rem;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 1rem;
  margin: 0;
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
@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(100%) translateX(-50%);
  }
  to {
    opacity: 1;
    transform: translateY(0) translateX(-50%);
  }
}

@keyframes slideOutDown {
  from {
    opacity: 1;
    transform: translateY(0) translateX(-50%);
  }
  to {
    opacity: 0;
    transform: translateY(100%) translateX(-50%);
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

/* Gallery styles */
.gallery-wrapper {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.gallery-thumbnails {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
  justify-content: center;
}

.gallery-thumb {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 8px;
  border: 2px solid #eee;
  cursor: pointer;
  transition: border 0.2s, transform 0.2s;
}

.gallery-thumb.selected {
  border: 2px solid #2196f3;
  transform: scale(1.08);
}

/* Contact Us Section */
.contact-section {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 2rem;
  margin-top: 2rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
.contact-section h3 {
  margin-bottom: 1rem;
  color: #2d3748;
}
.contact-items {
  display: flex;
  gap: 2rem;
  flex-wrap: wrap;
}
.contact-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.1rem;
  color: #333;
}
.contact-item a {
  color: #222;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s;
}
.contact-item a:hover {
  color: #000;
  text-decoration: none;
}
.contact-item i {
  color: #222;
  font-size: 1.2rem;
}

/* Similar Products Section */
.similar-products-section {
  margin-top: 2rem;
}
.similar-products-row {
  display: flex;
  gap: 1.5rem;
  flex-wrap: wrap;
  margin-top: 1rem;
}
.similar-product-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  width: 200px;
  overflow: hidden;
  transition: box-shadow 0.2s, transform 0.2s;
}
.similar-product-card:hover {
  box-shadow: 0 4px 16px rgba(33,150,243,0.12);
  transform: translateY(-2px) scale(1.03);
}
.similar-product-link {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-decoration: none;
  color: inherit;
  padding: 1rem;
}
.similar-product-image {
  width: 100%;
  height: 120px;
  object-fit: cover;
  border-radius: 6px;
  margin-bottom: 0.75rem;
  background: #f8f9fa;
}
.similar-product-info {
  text-align: center;
}
.similar-product-name {
  font-weight: 600;
  color: #2d3748;
  margin-bottom: 0.25rem;
}
.similar-product-price {
  color: #2196f3;
  font-weight: 500;
  font-size: 1.1rem;
}
</style> 