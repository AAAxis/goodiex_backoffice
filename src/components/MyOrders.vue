<template>
  <div class="orders-container">
    <div class="orders-card">
      <h1 class="orders-title">My Orders</h1>
      <form v-if="!userEmail" @submit.prevent="fetchOrders" class="email-form mb-4">
        <label for="email" class="form-label">Enter your email to view your orders:</label>
        <div class="input-group">
          <input v-model="emailInput" type="email" id="email" class="form-control" required placeholder="you@example.com" />
          <button class="btn btn-primary" type="submit">View Orders</button>
        </div>
      </form>
      <div v-else>
        <div class="d-flex justify-content-between align-items-center mb-3">
          <div><strong>Email:</strong> {{ userEmail }}</div>
          <button class="btn btn-link p-0" @click="resetEmail">Change Email</button>
        </div>
        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div>
        </div>
        <div v-else-if="orders.length === 0" class="text-center py-5">
          <i class="fa fa-box-open fa-3x text-muted mb-3"></i>
          <h4 class="text-muted">No orders found for this email.</h4>
        </div>
        <div v-else class="orders-table-wrapper">
          <table class="orders-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Date</th>
                <th>Total</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in orders" :key="order.id">
                <td>{{ order.id.substring(0, 8) }}...</td>
                <td>{{ formatDate(order.timestamp) }}</td>
                <td>{{ formatPrice(order.total, order.currency || 'USD') }}</td>
                <td>
                  <span :class="['order-status', order.status]">
                    {{ order.status.charAt(0).toUpperCase() + order.status.slice(1) }}
                  </span>
                </td>
                <td>
                  <button class="btn btn-outline-primary btn-sm" @click="viewOrder(order)">View</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import firebase from 'firebase/compat/app';
import 'firebase/compat/firestore';

export default {
  name: 'MyOrders',
  data() {
    return {
      emailInput: '',
      userEmail: '',
      orders: [],
      loading: false
    }
  },
  async created() {
    // Try to get email from query param
    const urlParams = new URLSearchParams(window.location.search);
    const email = urlParams.get('email');
    if (email) {
      this.userEmail = email;
      await this.fetchOrders();
    }
  },
  methods: {
    async fetchOrders() {
      const email = this.userEmail || this.emailInput;
      if (!email) return;
      this.loading = true;
      this.orders = [];
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
        const querySnap = await db.collection('web-orders')
          .where('email', '==', email)
          .orderBy('timestamp', 'desc')
          .get();
        this.orders = [];
        querySnap.forEach(doc => {
          this.orders.push({ id: doc.id, ...doc.data() });
        });
        this.userEmail = email;
      } catch (e) {
        this.orders = [];
      } finally {
        this.loading = false;
      }
    },
    resetEmail() {
      this.userEmail = '';
      this.emailInput = '';
      this.orders = [];
    },
    formatDate(timestamp) {
      if (!timestamp) return 'N/A';
      const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
      return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
    },
    getCurrencySymbol(currency) {
      const symbols = {
        'USD': '$', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 'CAD': 'C$', 'AUD': 'A$', 'CHF': 'CHF',
        'CNY': '¥', 'SEK': 'kr', 'NOK': 'kr', 'MXN': '$', 'INR': '₹', 'BRL': 'R$', 'RUB': '₽',
        'KRW': '₩', 'SGD': 'S$', 'HKD': 'HK$', 'NZD': 'NZ$', 'TRY': '₺', 'ZAR': 'R', 'ILS': '₪'
      };
      return symbols[currency?.toUpperCase()] || '$';
    },
    formatPrice(amount, currency) {
      const symbol = this.getCurrencySymbol(currency);
      if (!amount) return `${symbol}0.00`;
      return `${symbol}${parseFloat(amount).toFixed(2)}`;
    },
    viewOrder(order) {
      // Route to PaymentSuccess with order details as query params
      this.$router.push({
        path: '/payment-success',
        query: {
          order: order.id,
          email: order.email,
          total: order.total,
          name: encodeURIComponent(order.name || ''),
          currency: order.currency || 'USD'
        }
      });
    }
  }
}
</script>

<style scoped>
.orders-container {
  min-height: 100vh;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  background: #f8f9fa;
  padding: 2rem;
}
.orders-card {
  background: white;
  border-radius: 16px;
  padding: 2.5rem 2.5rem 2rem 2.5rem;
  box-shadow: 0 4px 24px rgba(0,0,0,0.08);
  max-width: 900px;
  width: 100%;
}
.orders-title {
  font-size: 2.2rem;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 2rem;
  text-align: center;
}
.email-form {
  max-width: 400px;
  margin: 0 auto 2rem auto;
}
.input-group {
  display: flex;
  gap: 0.5rem;
}
.orders-table-wrapper {
  overflow-x: auto;
}
.orders-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.orders-table th, .orders-table td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #e9ecef;
  text-align: left;
}
.orders-table th {
  background: #f8f9fa;
  font-weight: 600;
  color: #495057;
}
.order-status {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 500;
  text-transform: uppercase;
  background: #e3f2fd;
  color: #1976d2;
}
.order-status.completed {
  background: #e8f5e8;
  color: #2e7d32;
}
.order-status.pending {
  background: #fff3cd;
  color: #856404;
}
.order-status.cancelled {
  background: #ffebee;
  color: #c62828;
}
.btn-link {
  color: #2196f3;
  text-decoration: underline;
  font-size: 1rem;
}
.btn-link:hover {
  color: #1565c0;
}
</style> 