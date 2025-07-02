<template>
  <div class="success-container">
    <div class="success-card">
      <div class="success-icon">
        <i class="fa fa-check-circle"></i>
      </div>
      <h1 class="success-title">Payment Successful!</h1>
      <p class="success-message">
        Thank you {{ customerName }} for your order!
      </p>
      <div class="order-details">
        <h3>Order Details</h3>
        <p><strong>Order ID:</strong> {{ orderId }}</p>
        <p><strong>Total:</strong> {{ formatPrice(total, currency) }}</p>
        <p><strong>Email:</strong> {{ email }}</p>
        <div v-if="orderUpdated" class="order-status">
          <i class="fa fa-check-circle text-success"></i>
          <span class="text-success">Order processed successfully</span>
        </div>
        <div v-if="orderItems.length > 0" class="order-items-list mt-3">
          <h4 class="mb-2">Items Ordered</h4>
          <ul class="order-items-ul">
            <li v-for="(item, idx) in orderItems" :key="idx" class="order-item-li">
              <span>{{ item.product_name }} <span v-if="item.quantity">x{{ item.quantity }}</span></span>
              <span>{{ formatPrice(item.price * (item.quantity || 1), currency) }}</span>
            </li>
          </ul>
          <div v-if="deliveryFee && deliveryFee > 0" class="d-flex justify-content-between mt-2">
            <span>Delivery Fee</span>
            <span>{{ formatPrice(deliveryFee, currency) }}</span>
          </div>
          <div class="order-total-row mt-2">
            <strong>Total:</strong>
            <span>{{ formatPrice(total, currency) }}</span>
          </div>
        </div>
      </div>
      <div class="success-actions">
        <router-link to="/" class="btn btn-dark btn-lg">
          Back to Home
        </router-link>
        <button class="btn btn-primary btn-lg" @click="sendReceipt" :disabled="sendingReceipt">
          <span v-if="sendingReceipt"><i class="fa fa-spinner fa-spin"></i> Sending...</span>
          <span v-else>Send Receipt</span>
        </button>
        <div v-if="receiptSent" class="alert alert-success mt-2">Receipt sent to {{ email }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import firebase from 'firebase/compat/app';
import 'firebase/compat/firestore';

export default {
  name: 'PaymentSuccess',
  data() {
    return {
      orderId: '',
      email: '',
      total: '',
      customerName: '',
      currency: '',
      orderUpdated: false,
      orderItems: [],
      deliveryFee: 0,
      sendingReceipt: false,
      receiptSent: false
    }
  },
  async created() {
    // Get data from URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    this.orderId = urlParams.get('order') || '';
    this.email = urlParams.get('email') || '';
    this.total = urlParams.get('total') || '';
    this.customerName = decodeURIComponent(urlParams.get('name') || '');
    this.currency = urlParams.get('currency') || 'USD';

    console.log('PaymentSuccess created with params:', {
      orderId: this.orderId,
      email: this.email,
      total: this.total,
      customerName: this.customerName,
      currency: this.currency
    });

    // Update order status to 'completed' if we have an order ID
    if (this.orderId) {
      await this.updateOrderStatus();
      await this.fetchOrderItems();
    }
  },
  methods: {
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

    formatPrice(total, currency) {
      const symbol = this.getCurrencySymbol(currency);
      return `${symbol}${parseFloat(total).toFixed(2)}`;
    },

    async updateOrderStatus() {
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
        
        // Update the order status to 'completed'
        await db.collection('web-orders').doc(this.orderId).update({
          status: 'completed',
          completedAt: firebase.firestore.FieldValue.serverTimestamp(),
          paymentStatus: 'paid'
        });

        this.orderUpdated = true;
        console.log('Order status updated to completed for order:', this.orderId);
        
      } catch (error) {
        console.error('Error updating order status:', error);
        // Don't show error to user as the payment was successful
        // This is just for backend tracking
      }
    },

    async fetchOrderItems() {
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
        // Fetch order doc for deliveryFee
        const orderDoc = await db.collection('web-orders').doc(this.orderId).get();
        if (orderDoc.exists) {
          const orderData = orderDoc.data();
          this.deliveryFee = orderData.deliveryFee || 0;
        }
        // Fetch cart items
        const cartSnap = await db.collection('web-orders').doc(this.orderId).collection('cart').get();
        this.orderItems = [];
        cartSnap.forEach(doc => {
          this.orderItems.push(doc.data());
        });
      } catch (e) {
        this.orderItems = [];
      }
    },

    async sendReceipt() {
      this.sendingReceipt = true;
      this.receiptSent = false;
      try {
        // Call backend endpoint to send receipt
        const response = await fetch('https://pay.theholylabs.com/send-receipt', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            orderId: this.orderId,
            email: this.email,
            name: this.customerName,
            total: this.total,
            currency: this.currency
          })
        });
        if (response.ok) {
          this.receiptSent = true;
        } else {
          this.receiptSent = false;
        }
      } catch (e) {
        this.receiptSent = false;
      } finally {
        this.sendingReceipt = false;
      }
    }
  }
}
</script>

<style scoped>
.success-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #4CAF50 0%, #81C784 100%);
  padding: 2rem;
}

.success-card {
  background: white;
  border-radius: 20px;
  padding: 3rem;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
  max-width: 500px;
  width: 100%;
}

.success-icon {
  font-size: 4rem;
  color: #4CAF50;
  margin-bottom: 1.5rem;
}

.success-title {
  color: #2d3748;
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
}

.success-message {
  color: #6c757d;
  font-size: 1.1rem;
  margin-bottom: 2rem;
}

.order-details {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 12px;
  margin-bottom: 2rem;
  text-align: left;
}

.order-details h3 {
  color: #2d3748;
  margin-bottom: 1rem;
  text-align: center;
}

.order-details p {
  margin-bottom: 0.5rem;
  color: #495057;
}

.order-status {
  margin-top: 1rem;
  padding: 0.5rem;
  background: #d4edda;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  justify-content: center;
}

.text-success {
  color: #28a745 !important;
}

.success-actions {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

@media (min-width: 576px) {
  .success-actions {
    flex-direction: row;
    justify-content: center;
  }
}

.btn {
  padding: 0.75rem 2rem;
  border-radius: 50px;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.3s ease;
}

.btn-primary {
  background: #4CAF50;
  border: none;
  color: white;
}

.btn-primary:hover {
  background: #45a049;
  transform: translateY(-2px);
}

.btn-dark {
  background: #343a40;
  border: none;
  color: white;
}

.btn-dark:hover {
  background: #23272b;
  transform: translateY(-2px);
}

.btn-outline-secondary {
  border: 2px solid #6c757d;
  color: #6c757d;
  background: transparent;
}

.btn-outline-secondary:hover {
  background: #6c757d;
  color: white;
  transform: translateY(-2px);
}

/* Order items list styles */
.order-items-list {
  background: #fff;
  border-radius: 8px;
  padding: 1rem;
  margin-top: 1rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}

.order-items-ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.order-item-li {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem 0;
  border-bottom: 1px solid #eee;
  font-size: 1.1rem;
}

.order-item-li:last-child {
  border-bottom: none;
}

.order-total-row {
  display: flex;
  justify-content: space-between;
  font-size: 1.2rem;
  margin-top: 0.5rem;
}
</style>
