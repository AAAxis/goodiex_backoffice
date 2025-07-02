<template>
  <div>
    <Navbar />
    <!-- App Bar -->
    <nav class="navbar navbar-light bg-light mb-3 appbar">
      <div class="container-fluid d-flex align-items-center justify-content-between">
        <button class="btn btn-link text-dark p-0 me-2" @click="$router.back()" title="Back">
          <i class="fa fa-arrow-left"></i>
        </button>
        <span class="navbar-brand mb-0 h4 flex-grow-1 text-center">Shopping Cart</span>
        <div style="width: 40px;"></div> <!-- Spacer for centering -->
      </div>
    </nav>

    <div class="container" style="padding: 2rem;">
      <div v-if="cartItems.length">
        <div v-for="(item, index) in cartItems" :key="index" class="cart-item d-flex justify-content-between align-items-stretch p-3 mb-3 border rounded">
          <div class="cart-item-info d-flex align-items-stretch">
            <img class="cart-item-image" :src="item.product.image_url" alt="">
            <div class="ms-3 d-flex flex-column justify-content-center">
              <h5 class="mb-1">{{ item.product.name }}</h5>
              <p class="mb-0 text-muted">Quantity: {{ item.quantity }}</p>
              <p class="mb-0 text-success fw-bold">{{ formatPrice(item.product.price, item.product.storeId) }}</p>
            </div>
          </div>
          <div class="d-flex align-items-center">
            <div class="quantity-controls me-3">
              <button class="btn btn-outline-secondary btn-sm" @click="decreaseQuantity(index)">
                <i class="fa fa-minus"></i>
              </button>
              <span class="mx-2">{{ item.quantity }}</span>
              <button class="btn btn-outline-secondary btn-sm" @click="increaseQuantity(index)">
                <i class="fa fa-plus"></i>
              </button>
            </div>
            <button class="btn btn-danger btn-sm" @click="removeFromCart(index)">
              <i class="fa fa-trash"></i>
            </button>
          </div>
        </div>
        
        <div class="cart-summary mt-4 p-3 bg-light rounded">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="mb-0">Total: {{ formatPrice(cartTotal, store.currency) }}</h4>
          </div>
          <button class="btn btn-success btn-lg w-100" @click="proceedToCheckout">
            Proceed to Checkout
          </button>
        </div>
      </div>
      
      <div v-else class="text-center py-5">
        <i class="fa fa-shopping-cart fa-4x text-muted mb-3"></i>
        <h3 class="text-muted">Your cart is empty</h3>
        <p class="text-muted">Add some products to get started!</p>
        <router-link to="/" class="btn btn-primary">Continue Shopping</router-link>
      </div>
    </div>

    <!-- Checkout Modal -->
    <div class="modal fade" id="checkoutModal" tabindex="-1" aria-labelledby="checkoutModalLabel" aria-hidden="true" ref="checkoutModal">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="checkoutModalLabel">Checkout Details</h5>
            <button type="button" class="btn-close" @click="closeCheckoutModal"></button>
          </div>
          <div class="modal-body">
            <div class="form-group mb-3">
              <label for="email" class="form-label">Email *</label>
              <input type="email" id="email" v-model="email" required class="form-control">
            </div>
            <div class="form-group mb-3">
              <label for="name" class="form-label">Full Name *</label>
              <input type="text" id="name" v-model="name" required class="form-control">
            </div>
            <div class="form-group mb-3">
              <label for="address" class="form-label">Delivery Instructions *</label>
              <textarea id="address" v-model="address" required class="form-control" rows="3"></textarea>
            </div>
            <div class="cart-summary p-3 bg-light rounded">
              <h6>Order Summary:</h6>
              <div v-for="item in cartItems" :key="item.product.id" class="d-flex justify-content-between">
                <span>{{ item.product.name }} x{{ item.quantity }}</span>
                <span>{{ formatPrice(item.product.price * item.quantity, store.currency) }}</span>
              </div>
              <hr>
              <div class="d-flex justify-content-between fw-bold">
                <span>Total:</span>
                <span>{{ formatPrice(cartTotal, store.currency) }}</span>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeCheckoutModal">Cancel</button>
            <button type="button" class="btn btn-success" @click="submitPayment" :disabled="!isFormValid">
              Proceed to Payment
            </button>
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
  name: 'Cart',
  components: {
    Navbar,
  },
  data() {
    return {
      email: '',
      name: '',
      address: '',
      currentOrderID: null,
      store: {}, // Single store information
      cartStore // Add reference to cartStore for template access
    }
  },
  computed: {
    cartItems() {
      return cartStore.items;
    },
    cartTotal() {
      return cartStore.total;
    },
    isFormValid() {
      return this.email && this.name && this.address;
    }
  },
  watch: {
    'cartStore.currentStoreId': {
      handler(newStoreId) {
        if (newStoreId) {
          this.fetchStore(newStoreId);
        }
      },
      immediate: true
    }
  },
  methods: {
    async fetchStore(storeId) {
      if (!storeId) return;
      
      try {
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

        const db = firebase.firestore();
        const storeDoc = await db.collection('stores').doc(storeId).get();
        if (storeDoc.exists) {
          this.store = storeDoc.data();
        }
      } catch (error) {
        console.error('Error fetching store:', error);
      }
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

    formatPrice(price, currency) {
      const symbol = this.getCurrencySymbol(currency);
      return `${symbol}${parseFloat(price).toFixed(2)}`;
    },

    increaseQuantity(index) {
      cartStore.updateQuantity(index, this.cartItems[index].quantity + 1);
    },
    decreaseQuantity(index) {
      const newQuantity = this.cartItems[index].quantity - 1;
      cartStore.updateQuantity(index, newQuantity);
    },
    removeFromCart(index) {
      cartStore.removeItem(index);
    },
    proceedToCheckout() {
      const modal = new window.bootstrap.Modal(this.$refs.checkoutModal);
      modal.show();
    },
    closeCheckoutModal() {
      const modal = window.bootstrap.Modal.getInstance(this.$refs.checkoutModal);
      if (modal) {
        modal.hide();
      }
    },
    async submitPayment() {
      if (!this.isFormValid) {
        alert('Please fill in all required fields.');
        return;
      }

      try {
        // Initialize Firebase if not already done
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

        const db = firebase.firestore();
        
        // Create new order with 'pending' status initially
        const orderDoc = await db.collection('web-orders').add({
          status: 'pending', // Changed from 'ordering' to 'pending'
          total: this.cartTotal,
          timestamp: firebase.firestore.FieldValue.serverTimestamp(),
          email: this.email,
          name: this.name,
          address: this.address,
          storeId: cartStore.currentStoreId // Add store ID to link order to specific store
        });
        
        const orderID = orderDoc.id;
        this.currentOrderID = orderID;
        
        // Add cart items to order
        const cartRef = db.collection('web-orders').doc(orderID).collection('cart');
        for (const item of this.cartItems) {
          await cartRef.add({
            product_image_url: item.product.image_url,
            product_name: item.product.name,
            price: item.product.price,
            quantity: item.quantity,
          });
        }

        // Create checkout session with Stripe
        const response = await fetch('https://pay.theholylabs.com/create-payment-order', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            order: orderID,
            email: this.email,
            total: this.cartTotal,
            name: this.name,
            currency: this.store.currency || 'USD'
          }),
        });
        
        const responseData = await response.json();
        
        if (!response.ok) {
          throw new Error(responseData.error || 'Payment request failed');
        }
        
        // Close the modal
        this.closeCheckoutModal();
        
        // Clear cart before redirecting (since payment is pending)
        cartStore.clearCart();
        
        // Redirect to Stripe checkout
        window.location.href = responseData.sessionUrl;
        
      } catch (error) {
        console.error('Error creating checkout session:', error);
        alert('There was an error processing your order. Please try again.');
      }
    },
  }
};
</script>

<style scoped>
.appbar {
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}

.cart-item {
  transition: all 0.2s ease;
}

.cart-item:hover {
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.cart-item-image {
  width: 80px;
  height: 100%;
  min-height: 80px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #eee;
  align-self: stretch;
}

.cart-item-info {
  min-height: 80px;
}

.quantity-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.cart-summary {
  border: 2px solid #e9ecef;
}

@media (max-width: 768px) {
  .cart-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .cart-item-info {
    width: 100%;
    margin-bottom: 1rem;
  }
  
  .cart-item .d-flex:last-child {
    width: 100%;
    justify-content: space-between;
  }
}

/* Add some padding to account for fixed navbar */
.container {
  padding-top: 76px;
}
</style>
