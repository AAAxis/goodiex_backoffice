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
        <p><strong>Total:</strong> ${{ total }}</p>
        <p><strong>Email:</strong> {{ email }}</p>
        <div v-if="orderUpdated" class="order-status">
          <i class="fa fa-check-circle text-success"></i>
          <span class="text-success">Order processed successfully</span>
        </div>
      </div>
      <div class="success-actions">
        <router-link to="/shop" class="btn btn-primary btn-lg">
          Continue Shopping
        </router-link>
        <router-link to="/" class="btn btn-outline-secondary btn-lg ms-3">
          Back to Home
        </router-link>
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
      orderUpdated: false
    }
  },
  async created() {
    // Get data from URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    this.orderId = urlParams.get('order') || '';
    this.email = urlParams.get('email') || '';
    this.total = urlParams.get('total') || '';
    this.customerName = decodeURIComponent(urlParams.get('name') || '');

    console.log('PaymentSuccess created with params:', {
      orderId: this.orderId,
      email: this.email,
      total: this.total,
      customerName: this.customerName
    });

    // Update order status to 'completed' if we have an order ID
    if (this.orderId) {
      await this.updateOrderStatus();
    }
  },
  methods: {
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
</style>
