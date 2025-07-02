<template>
  <div class="order-details-page">
    <div class="order-details-header">
      <button class="back-btn" @click="goBack">← Back to Orders</button>
      <h2>Order Details</h2>
    </div>
    <div v-if="loading" class="loading">Loading order details...</div>
    <div v-else-if="!order" class="empty-state">Order not found.</div>
    <div v-else class="order-details-content">
      <div class="order-info-section">
        <div class="info-row"><strong>Order ID:</strong> {{ order.id }}</div>
        <div class="info-row"><strong>Customer:</strong> {{ order.name }}</div>
        <div v-if="order.phone" class="info-row"><strong>Phone:</strong> {{ order.phone }}</div>
        <div class="info-row"><strong>Email:</strong> {{ order.email }}</div>
        <div class="info-row"><strong>Date:</strong> {{ formatDate(order.timestamp) }}</div>
        <div class="info-row"><strong>Status:</strong> <span :class="['order-status', order.status]">{{ order.status.charAt(0).toUpperCase() + order.status.slice(1) }}</span></div>
        <div class="info-row"><strong>Address:</strong> {{ order.address || 'N/A' }}</div>
        <div class="info-row"><strong>Total:</strong> <span class="order-total">{{ formatPrice(order.total, order.currency) }}</span></div>
      </div>
      <div class="cart-section">
        <h4>Order Items</h4>
        <div v-if="orderItems.length === 0" class="empty-cart">No items found in this order.</div>
        <div v-else class="cart-items">
          <div v-for="item in orderItems" :key="item.id" class="cart-item">
            <div class="item-image">
              <img v-if="item.product_image_url" :src="item.product_image_url" :alt="item.product_name" />
              <div v-else class="no-image">No Image</div>
            </div>
            <div class="item-details">
              <div class="item-name">{{ item.product_name }}</div>
              <div class="item-price">{{ formatPrice(item.price, order.currency) }} × {{ item.quantity }}</div>
              <div class="item-total">{{ formatPrice(item.price * item.quantity, order.currency) }}</div>
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

export default {
  name: 'OrderDetails',
  props: {
    storeId: { type: String, required: true },
    orderId: { type: String, required: true },
    platform: { type: String, default: 'web' }
  },
  data() {
    return {
      order: null,
      orderItems: [],
      loading: true
    }
  },
  async created() {
    await this.fetchOrder();
  },
  methods: {
    async fetchOrder() {
      this.loading = true;
      try {
        const db = firebase.firestore();
        let orderDoc;
        if (this.platform === 'mobile') {
          orderDoc = await db.collection('orders').doc(this.orderId).get();
        } else {
          orderDoc = await db.collection('web-orders').doc(this.orderId).get();
        }
        if (orderDoc.exists) {
          this.order = { id: orderDoc.id, ...orderDoc.data() };
          // Fetch items
          if (this.platform === 'mobile' && Array.isArray(this.order.items)) {
            this.orderItems = this.order.items.map((item, idx) => ({
              id: idx,
              product_name: item.name || item.product_name,
              product_image_url: item.image || item.image_url || item.product_image_url,
              price: item.price,
              quantity: item.quantity
            }));
          } else {
            // Try to fetch from subcollection
            const cartSnap = await db.collection(this.platform === 'mobile' ? 'orders' : 'web-orders').doc(this.orderId).collection('cart').get();
            this.orderItems = [];
            cartSnap.forEach(doc => {
              this.orderItems.push({ id: doc.id, ...doc.data() });
            });
          }
        } else {
          this.order = null;
        }
      } catch (e) {
        this.order = null;
      } finally {
        this.loading = false;
      }
    },
    formatDate(timestamp) {
      if (!timestamp) return 'N/A';
      const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
      return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
    },
    formatPrice(amount, currency) {
      const symbols = {
        'USD': '$', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 'CAD': 'C$', 'AUD': 'A$', 'CHF': 'CHF', 'CNY': '¥', 'SEK': 'kr', 'NOK': 'kr', 'MXN': '$', 'INR': '₹', 'BRL': 'R$', 'RUB': '₽', 'KRW': '₩', 'SGD': 'S$', 'HKD': 'HK$', 'NZD': 'NZ$', 'TRY': '₺', 'ZAR': 'R', 'ILS': '₪'
      };
      const symbol = symbols[(currency || 'USD').toUpperCase()] || '$';
      if (!amount) return `${symbol}0.00`;
      return `${symbol}${parseFloat(amount).toFixed(2)}`;
    },
    goBack() {
      this.$router.push(`/store-owner/manage-store/${this.storeId}?tab=orders`);
    }
  }
}
</script>

<style scoped>
.order-details-page {
  max-width: 700px;
  margin: 2rem auto;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  padding: 2rem;
}
.order-details-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2rem;
}
.back-btn {
  background: #6c757d;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
}
.back-btn:hover {
  background: #5a6268;
}
.loading, .empty-state {
  text-align: center;
  color: #666;
  padding: 2rem 0;
}
.order-info-section {
  margin-bottom: 2rem;
}
.info-row {
  display: flex;
  margin-bottom: 0.75rem;
  align-items: center;
}
.info-row strong {
  min-width: 100px;
  margin-right: 1rem;
}
.order-status {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  text-transform: uppercase;
}
.order-status.pending {
  background: #fff3cd;
  color: #856404;
}
.order-status.completed {
  background: #e8f5e8;
  color: #2e7d32;
}
.order-status.cancelled {
  background: #ffebee;
  color: #c62828;
}
.order-total {
  font-weight: 600;
  color: #4CAF50;
}
.cart-section {
  border-top: 1px solid #e0e0e0;
  padding-top: 1.5rem;
}
.cart-section h4 {
  margin: 0 0 1rem 0;
  color: #333;
}
.empty-cart {
  text-align: center;
  color: #666;
  font-style: italic;
}
.cart-items {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.cart-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  background: #f8f9fa;
}
.item-image {
  width: 60px;
  height: 60px;
  margin-right: 1rem;
  flex-shrink: 0;
}
.item-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 4px;
}
.item-image .no-image {
  width: 100%;
  height: 100%;
  background: #e0e0e0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  color: #999;
  border-radius: 4px;
}
.item-details {
  flex: 1;
}
.item-name {
  font-weight: 500;
  margin-bottom: 0.25rem;
  color: #333;
}
.item-price {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 0.25rem;
}
.item-total {
  font-weight: 600;
  color: #4CAF50;
}
</style> 