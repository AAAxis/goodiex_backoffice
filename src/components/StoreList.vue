<template>
  <div>
    <Navbar />
    <!-- App Bar -->
 

    <div class="container" style="padding: 2rem;">
      <div class="row align-items-center mb-4">
        <div class="col-auto">
          <h2>Available Stores</h2>
          <p class="text-muted">Choose a store to start shopping</p>
        </div>
      </div>

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
        <p class="mt-2">Loading stores...</p>
      </div>

      <div v-else-if="stores.length === 0" class="text-center py-5">
        <i class="fa fa-store fa-4x text-muted mb-3"></i>
        <h3 class="text-muted">No stores available</h3>
        <p class="text-muted">Check back later for new stores!</p>
      </div>

      <div v-else class="store-grid">
        <div v-for="store in stores" :key="store.id" class="store-card" @click="visitStore(store.id)">
          <div class="store-image-container">
            <img v-if="store.image" :src="store.image" :alt="store.name" class="store-image">
            <div v-else class="store-image-placeholder">
              <i class="fa fa-store fa-3x"></i>
            </div>
                         <div class="store-name-overlay">
               <h3 class="store-name">{{ store.name }}</h3>
             </div>
          </div>
          <div class="store-info">
            <p class="store-description">{{ store.description || 'Welcome to our store' }}</p>
            <div class="store-details">
              <span class="store-detail">
                <i class="fa fa-box"></i>
                {{ store.totalProducts || 0 }} Products
              </span>
              <div class="contact-icons">
                <i v-if="store.phone" class="fa fa-phone contact-icon" @click.stop="callPhone(store.phone)" title="Call Store"></i>
                <i v-if="store.email" class="fa fa-envelope contact-icon" @click.stop="copyEmail(store.email)" title="Copy Email"></i>
                <i v-if="store.address" class="fa fa-map-marker-alt contact-icon" @click.stop="openMap(store.address)" title="Open in Maps"></i>
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
  name: 'StoreList',
  components: {
    Navbar,
  },
  data() {
    return {
      stores: [],
      loading: false
    }
  },
  computed: {
    cartItemCount() {
      return cartStore.itemCount;
    }
  },
  created() {
    this.initializeFirebase();
    this.fetchStores();
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
    
    async fetchStores() {
      this.loading = true;
      try {
        const db = firebase.firestore();
        const querySnapshot = await db.collection('stores')
          .where('isActive', '==', true)
          .get();
        
        this.stores = [];
        
        for (const doc of querySnapshot.docs) {
          const storeData = { id: doc.id, ...doc.data() };
          
          // Count products for each store
          const productsSnapshot = await db.collection('stores')
            .doc(doc.id)
            .collection('products')
            .get();
          storeData.totalProducts = productsSnapshot.size;
          
          this.stores.push(storeData);
        }
        
      } catch (error) {
        console.error('Error fetching stores:', error);
      } finally {
        this.loading = false;
      }
    },
    
    visitStore(storeId) {
      this.$router.push({ name: 'ShopStore', params: { storeId } });
    },

    callPhone(phone) {
      if (phone) {
        // Clean phone number for tel: link
        const cleanPhone = phone.replace(/[^\d+]/g, '');
        window.open(`tel:${cleanPhone}`, '_self');
      }
    },

    async copyEmail(email) {
      if (email) {
        try {
          await navigator.clipboard.writeText(email);
          this.showToast(`Email copied: ${email}`, 'success');
        } catch (error) {
          // Fallback for older browsers
          this.fallbackCopyEmail(email);
        }
      }
    },

    fallbackCopyEmail(email) {
      const textArea = document.createElement('textarea');
      textArea.value = email;
      document.body.appendChild(textArea);
      textArea.select();
      try {
        document.execCommand('copy');
        this.showToast(`Email copied: ${email}`, 'success');
      } catch (error) {
        console.error('Failed to copy email:', error);
        this.showToast('Failed to copy email', 'error');
      }
      document.body.removeChild(textArea);
    },

    openMap(address) {
      if (address) {
        // Encode address for URL
        const encodedAddress = encodeURIComponent(address);
        
        // Detect device and open appropriate maps app
        const isMobile = /Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
        
        if (isMobile) {
          // Try to open native maps app first, fallback to Google Maps web
          const mapsUrl = `https://maps.google.com/maps?q=${encodedAddress}`;
          window.open(mapsUrl, '_blank');
        } else {
          // Desktop - open Google Maps in new tab
          const mapsUrl = `https://www.google.com/maps/search/?api=1&query=${encodedAddress}`;
          window.open(mapsUrl, '_blank');
        }
      }
    },

    showToast(message, type = 'info') {
      const toast = document.createElement('div');
      toast.className = `toast-notification ${type}`;
      toast.innerHTML = `
        <div class="toast-content">
          <i class="fa ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle'}"></i>
          <span>${message}</span>
        </div>
      `;
      
      // Toast styles
      toast.style.cssText = `
        position: fixed;
        top: 80px;
        right: 20px;
        background: ${type === 'success' ? '#d4edda' : type === 'error' ? '#f8d7da' : '#d1ecf1'};
        color: ${type === 'success' ? '#155724' : type === 'error' ? '#721c24' : '#0c5460'};
        border: 1px solid ${type === 'success' ? '#c3e6cb' : type === 'error' ? '#f5c6cb' : '#bee5eb'};
        padding: 12px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 1000;
        animation: slideInRight 0.3s ease;
        max-width: 300px;
      `;
      
      document.body.appendChild(toast);
      
      // Remove toast after 3 seconds
      setTimeout(() => {
        toast.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
          if (document.body.contains(toast)) {
            document.body.removeChild(toast);
          }
        }, 300);
      }, 3000);
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

.store-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 2rem;
  padding: 1rem 0;
}

.store-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  cursor: pointer;
}

.store-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

.store-image-container {
  position: relative;
  width: 100%;
  height: 240px;
  overflow: hidden;
  background: #f8f9fa;
}

.store-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.store-image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.store-card:hover .store-image {
  transform: scale(1.05);
}

.store-name-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.8));
  padding: 2rem 1rem 1rem 1rem;
}

.store-name {
  font-size: 1.3rem;
  font-weight: 600;
  color: white;
  margin: 0 0 0.5rem 0;
  line-height: 1.4;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
}



.store-info {
  padding: 1.5rem;
}

.store-description {
  color: #666;
  margin-bottom: 1rem;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.store-details {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.9rem;
}

.store-detail {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #000;
  font-weight: 500;
}

.store-detail i {
  color: #000;
}

.contact-icons {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.contact-icon {
  font-size: 1.1rem;
  color: #6c757d;
  cursor: pointer;
  transition: all 0.2s ease;
  padding: 0.25rem;
  border-radius: 50%;
}

.contact-icon:hover {
  transform: scale(1.2);
}

/* Phone contact styling */
.contact-icon.fa-phone:hover {
  color: #28a745;
  background: rgba(40, 167, 69, 0.1);
}

/* Email contact styling */
.contact-icon.fa-envelope:hover {
  color: #17a2b8;
  background: rgba(23, 162, 184, 0.1);
}

/* Address contact styling */
.contact-icon.fa-map-marker-alt:hover {
  color: #ffc107;
  background: rgba(255, 193, 7, 0.1);
}

h2 {
  font-size: 2rem;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 0.5rem;
}

@media (max-width: 768px) {
  .store-grid {
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 1.5rem;
  }
  
  .store-image-container {
    height: 200px;
  }
  
  .store-name {
    font-size: 1.1rem;
  }
  
  h2 {
    font-size: 1.5rem;
  }
  
  .contact-icons {
    gap: 0.5rem;
  }
  
  .contact-icon {
    font-size: 1rem;
  }
}

@media (max-width: 480px) {
  .store-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
}

.container {
  padding-top: 76px;
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

.toast-content {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.toast-content i {
  font-size: 1rem;
}
</style> 