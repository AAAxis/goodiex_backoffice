<template>
  <div class="manage-store-wrapper">
    <div class="manage-store-content">
      <div class="header-actions">
        <button class="back-btn" @click="goBack">← Back to Dashboard</button>
      </div>

      <div class="store-header">
        <div class="store-info">
          <h1>{{ store.name }}</h1>
          <p class="store-description">{{ store.description }}</p>
          <div class="store-currency">
            <span class="currency-label">Currency:</span>
            <span class="currency-value">{{ store.currency || 'USD' }}</span>
          </div>
        </div>

      </div>

      <div class="management-tabs">
        <button 
          :class="['tab-btn', activeTab === 'products' ? 'active' : '']"
          @click="activeTab = 'products'"
        >
          Products ({{ totalProducts }})
        </button>
        <button 
          :class="['tab-btn', activeTab === 'orders' ? 'active' : '']"
          @click="activeTab = 'orders'"
        >
          Orders ({{ totalOrders }})
        </button>
        <button 
          :class="['tab-btn', activeTab === 'mobile-orders' ? 'active' : '']"
          @click="activeTab = 'mobile-orders'"
        >
          Mobile Orders ({{ totalMobileOrders }})
        </button>
        <button 
          :class="['tab-btn', activeTab === 'settings' ? 'active' : '']"
          @click="activeTab = 'settings'"
        >
          Store Settings
        </button>
      </div>



      <!-- Products Tab -->
      <div v-if="activeTab === 'products'" class="tab-content">
        <div class="section-header">
          <h2>All Products</h2>
          <div class="header-right">
            <button class="btn-primary" @click="createProduct">Add Product</button>
          </div>
        </div>

        <div v-if="productsLoading" class="loading">Loading products...</div>

        <div v-else-if="products.length === 0" class="empty-state">
          <p>No products found.</p>
        </div>

        <div v-else class="products-table">
          <table>
            <thead>
              <tr>
                <th>Image</th>
                <th>Name</th>
                <th>Description</th>
                <th>Price</th>
                <th>Available</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="product in products" :key="product.id">
                <td>
                  <img v-if="product.image" :src="product.image" class="product-thumb" />
                  <div v-else class="no-thumb">No Image</div>
                </td>
                <td>{{ product.name }}</td>
                <td>{{ product.description || 'No description' }}</td>
                <td>{{ formatPrice(product.price) }}</td>
                <td>
                  <span :class="['availability-badge', (product.stock > 0) ? 'available' : 'unavailable']">
                    {{ (product.stock > 0) ? `${product.stock} Available` : 'Out of Stock' }}
                  </span>
                </td>
                <td>
                  <div class="table-actions">
                    <button class="btn-small btn-delete" @click="deleteProduct(product.id)">Delete</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Orders Tab -->
      <div v-if="activeTab === 'orders'" class="tab-content">
        <div class="section-header">
          <h2>Store Orders</h2>
          <div class="order-stats">
            <span class="stat-item">Total: {{ orders.length }}</span>
            <span class="stat-item">Revenue: {{ formatPrice(storeRevenue) }}</span>
          </div>
        </div>

        <div v-if="ordersLoading" class="loading">Loading orders...</div>
        
        <div v-else-if="orders.length === 0" class="empty-state">
          <p>No orders yet for this store.</p>
        </div>

        <div v-else class="orders-table">
          <table>
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Total</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in orders" :key="order.id">
                <td class="order-id">{{ order.id.substring(0, 8) }}...</td>
                <td>
                  <div class="customer-info">
                    <div class="customer-name">{{ order.name }}</div>
                    <div class="customer-email">{{ order.email }}</div>
                  </div>
                </td>
                <td>{{ formatDate(order.timestamp) }}</td>
                <td class="order-total">{{ formatPrice(order.total) }}</td>
                <td>
                  <span :class="['order-status', order.status]">
                    {{ order.status.charAt(0).toUpperCase() + order.status.slice(1) }}
                  </span>
                </td>
                <td>
                  <button class="btn-small btn-view" @click="viewOrderDetails(order)">View Details</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Mobile Orders Tab -->
      <div v-if="activeTab === 'mobile-orders'" class="tab-content">
        <div class="section-header">
          <h2>Mobile Orders</h2>
          <div class="order-stats">
            <span class="stat-item">Total: {{ mobileOrders.length }}</span>
            <span class="stat-item">Revenue: {{ formatPrice(mobileStoreRevenue) }}</span>
          </div>
        </div>

        <div v-if="mobileOrdersLoading" class="loading">Loading mobile orders...</div>
        
        <div v-else-if="mobileOrders.length === 0" class="empty-state">
          <p>No mobile orders yet for this store.</p>
        </div>

        <div v-else class="mobile-orders-table">
          <table>
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Total</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in mobileOrders" :key="order.id">
                <td class="order-id">{{ order.id.substring(0, 8) }}...</td>
                <td>
                  <div class="customer-info">
                    <div class="customer-name">{{ order.name }}</div>
                    <div class="customer-email">{{ order.email }}</div>
                  </div>
                </td>
                <td>{{ formatDate(order.timestamp) }}</td>
                <td class="order-total">{{ formatPrice(order.total) }}</td>
                <td>
                  <span :class="['order-status', order.status]">
                    {{ order.status.charAt(0).toUpperCase() + order.status.slice(1) }}
                  </span>
                </td>
                <td>
                  <button class="btn-small btn-view" @click="viewMobileOrderDetails(order)">View Details</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Store Settings Tab -->
      <div v-if="activeTab === 'settings'" class="tab-content">
        <div class="section-header">
          <h2>Store Settings</h2>
        </div>

        <div class="settings-section">
          <div class="setting-row">
            <div class="setting-info">
              <h3>Store Status</h3>
              <p>{{ store.isActive ? 'Your store is currently active and visible to customers' : 'Your store is currently inactive and hidden from customers' }}</p>
            </div>
            <div class="setting-action">
              <span :class="['status-badge', store.isActive ? 'active' : 'inactive']">
                {{ store.isActive ? 'Active' : 'Inactive' }}
              </span>
              <button class="btn-toggle" @click="toggleStoreStatus">
                {{ store.isActive ? 'Deactivate Store' : 'Activate Store' }}
              </button>
            </div>
          </div>

          <div class="setting-row">
            <div class="setting-info">
              <h3>Store Information</h3>
              <p>Update your store name, description, currency, and other details</p>
            </div>
            <div class="setting-action">
              <button class="btn-edit" @click="editStore">
                Edit Store Details
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Order Details Modal -->
    <div v-if="showOrderModal" class="modal-overlay" @click="closeOrderModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>Order Details</h3>
          <button class="modal-close" @click="closeOrderModal">&times;</button>
        </div>
        <div class="modal-body">
          <div v-if="loadingOrderDetails" class="loading">Loading order details...</div>
          <div v-else>
            <div class="order-info-section">
              <div class="info-row">
                <strong>Order ID:</strong> {{ selectedOrder.id }}
              </div>
              <div class="info-row">
                <strong>Customer:</strong> {{ selectedOrder.name }}
              </div>
              <div class="info-row">
                <strong>Email:</strong> {{ selectedOrder.email }}
              </div>
              <div class="info-row">
                <strong>Date:</strong> {{ formatDate(selectedOrder.timestamp) }}
              </div>
              <div class="info-row">
                <strong>Status:</strong> 
                <span :class="['order-status', selectedOrder.status]">
                  {{ selectedOrder.status.charAt(0).toUpperCase() + selectedOrder.status.slice(1) }}
                </span>
              </div>
              <div class="info-row">
                <strong>Address:</strong> {{ selectedOrder.address || 'N/A' }}
              </div>
              <div class="info-row">
                <strong>Total:</strong> <span class="order-total">{{ formatPrice(selectedOrder.total) }}</span>
              </div>
            </div>

            <div class="cart-section">
              <h4>Order Items</h4>
              <div v-if="orderCartItems.length === 0" class="empty-cart">
                <p>No items found in this order.</p>
              </div>
              <div v-else class="cart-items">
                <div v-for="item in orderCartItems" :key="item.id" class="cart-item">
                  <div class="item-image">
                    <img v-if="item.product_image_url" :src="item.product_image_url" :alt="item.product_name" />
                    <div v-else class="no-image">No Image</div>
                  </div>
                  <div class="item-details">
                    <div class="item-name">{{ item.product_name }}</div>
                    <div class="item-price">{{ formatPrice(item.price) }} × {{ item.quantity }}</div>
                    <div class="item-total">{{ formatPrice(item.price * item.quantity) }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-secondary" @click="closeOrderModal">Close</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { auth, db } from '../../firebase'

export default {
  name: 'ManageStore',
  data() {
    return {
      storeId: '',
      store: {},
      products: [],
      orders: [],
      mobileOrders: [],
      activeTab: 'products',
      productsLoading: false,
      ordersLoading: false,
      mobileOrdersLoading: false,
      totalProducts: 0,
      totalOrders: 0,
      totalMobileOrders: 0,
      showOrderModal: false,
      selectedOrder: {},
      orderCartItems: [],
      loadingOrderDetails: false
    }
  },
  computed: {
    storeRevenue() {
      return this.orders
        .filter(order => order.status === 'completed')
        .reduce((total, order) => total + (parseFloat(order.total) || 0), 0);
    },
    mobileStoreRevenue() {
      return this.mobileOrders
        .filter(order => order.status === 'completed')
        .reduce((total, order) => total + (parseFloat(order.total) || 0), 0);
    }
  },
  async mounted() {
    this.storeId = this.$route.params.storeId
    
    auth.onAuthStateChanged(async (user) => {
      if (user) {
        await this.fetchStore()
        await this.fetchProducts()
        await this.fetchOrders()
        await this.fetchMobileOrders()
      } else {
        this.$router.push('/store-owner/login')
      }
    })
  },
  methods: {
    async fetchStore() {
      try {
        const storeDoc = await db.collection('stores').doc(this.storeId).get()
        if (storeDoc.exists) {
          this.store = { id: storeDoc.id, ...storeDoc.data() }
        }
      } catch (error) {
        console.error('Error fetching store:', error)
      }
    },

    async fetchProducts() {
      this.productsLoading = true
      try {
        const querySnapshot = await db.collection('stores').doc(this.storeId).collection('products').get()
        this.products = []
        
        querySnapshot.forEach((doc) => {
          this.products.push({
            id: doc.id,
            ...doc.data()
          })
        })
        
        this.totalProducts = this.products.length
        
      } catch (error) {
        console.error('Error fetching products:', error)
      } finally {
        this.productsLoading = false
      }
    },

    goBack() {
      this.$router.push('/store-owner/dashboard')
    },

    createProduct() {
      this.$router.push(`/store-owner/manage-store/${this.storeId}/create-product`)
    },

    async deleteProduct(productId) {
      if (confirm('Are you sure you want to delete this product?')) {
        try {
          await db.collection('stores').doc(this.storeId).collection('products').doc(productId).delete()
          await this.fetchProducts()
        } catch (error) {
          console.error('Error deleting product:', error)
        }
      }
    },

    async fetchOrders() {
      this.ordersLoading = true
      try {
        const querySnapshot = await db.collection('web-orders')
          .where('storeId', '==', this.storeId)
          .orderBy('timestamp', 'desc')
          .get()
        
        this.orders = []
        
        querySnapshot.forEach((doc) => {
          this.orders.push({
            id: doc.id,
            ...doc.data()
          })
        })
        
        this.totalOrders = this.orders.length
        
      } catch (error) {
        console.error('Error fetching orders:', error)
      } finally {
        this.ordersLoading = false
      }
    },

    formatDate(timestamp) {
      if (!timestamp) return 'N/A'
      const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp)
      return date.toLocaleDateString() + ' ' + date.toLocaleTimeString()
    },

    async viewOrderDetails(order) {
      this.selectedOrder = order
      this.showOrderModal = true
      this.loadingOrderDetails = true
      this.orderCartItems = []

      try {
        // Fetch cart items from web-orders collection
        const cartSnapshot = await db.collection('web-orders').doc(order.id).collection('cart').get()
        
        cartSnapshot.forEach((doc) => {
          this.orderCartItems.push({
            id: doc.id,
            ...doc.data()
          })
        })
        
      } catch (error) {
        console.error('Error fetching order cart items:', error)
      } finally {
        this.loadingOrderDetails = false
      }
    },

    async fetchMobileOrders() {
      this.mobileOrdersLoading = true
      try {
        const querySnapshot = await db.collection('orders')
          .where('storeId', '==', this.storeId)
          .orderBy('timestamp', 'desc')
          .get()
        
        this.mobileOrders = []
        
        querySnapshot.forEach((doc) => {
          this.mobileOrders.push({
            id: doc.id,
            ...doc.data()
          })
        })
        
        this.totalMobileOrders = this.mobileOrders.length
        
      } catch (error) {
        console.error('Error fetching mobile orders:', error)
      } finally {
        this.mobileOrdersLoading = false
      }
    },

    async viewMobileOrderDetails(order) {
      this.selectedOrder = order
      this.showOrderModal = true
      this.loadingOrderDetails = true
      this.orderCartItems = []

      try {
        // For mobile orders, the cart items might be stored differently
        // Check if items are stored directly in the order document or in a subcollection
        if (order.items && Array.isArray(order.items)) {
          // Items are stored directly in the order document
          this.orderCartItems = order.items.map((item, index) => ({
            id: index,
            product_name: item.name || item.product_name,
            product_image_url: item.image || item.image_url || item.product_image_url,
            price: item.price,
            quantity: item.quantity
          }))
        } else {
          // Try to fetch from subcollection (similar to web orders)
          const cartSnapshot = await db.collection('orders').doc(order.id).collection('cart').get()
          
          cartSnapshot.forEach((doc) => {
            this.orderCartItems.push({
              id: doc.id,
              ...doc.data()
            })
          })
        }
        
      } catch (error) {
        console.error('Error fetching mobile order cart items:', error)
      } finally {
        this.loadingOrderDetails = false
      }
    },

    closeOrderModal() {
      this.showOrderModal = false
      this.selectedOrder = {}
      this.orderCartItems = []
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
      return symbols[currency] || '$'
    },

    formatPrice(price) {
      const symbol = this.getCurrencySymbol(this.store.currency || 'USD')
      return `${symbol}${parseFloat(price).toFixed(2)}`
    },

    editStore() {
      this.$router.push(`/store-owner/edit-store/${this.storeId}`)
    },

    async toggleStoreStatus() {
      if (confirm(`Are you sure you want to ${this.store.isActive ? 'deactivate' : 'activate'} this store?`)) {
        try {
          await db.collection('stores').doc(this.storeId).update({
            isActive: !this.store.isActive,
            updatedAt: new Date()
          })
          await this.fetchStore()
        } catch (error) {
          console.error('Error updating store status:', error)
        }
      }
    }
  }
}
</script>

<style scoped>
.manage-store-wrapper {
  min-height: 100vh;
  background: #f8f9fa;
  padding: 2rem;
}

.manage-store-content {
  max-width: 1200px;
  margin: 0 auto;
}

.header-actions {
  margin-bottom: 1rem;
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

.store-header {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.store-info h1 {
  margin: 0 0 0.5rem 0;
  color: #333;
}

.store-description {
  color: #666;
  margin: 0 0 1rem 0;
}

.store-currency {
  display: flex;
  align-items: center;
  margin-top: 0.5rem;
}

.currency-label {
  color: #666;
  font-size: 0.9rem;
  margin-right: 0.5rem;
}

.currency-value {
  background: #e3f2fd;
  color: #1976d2;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  text-transform: uppercase;
}

.status-badge.active {
  background: #e8f5e8;
  color: #2e7d32;
}

.status-badge.inactive {
  background: #ffebee;
  color: #c62828;
}

.management-tabs {
  display: flex;
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
}

.tab-btn {
  flex: 1;
  background: white;
  border: none;
  padding: 1rem;
  cursor: pointer;
  font-size: 1rem;
  color: #666;
  transition: all 0.2s;
}

.tab-btn:hover {
  background: #f8f9fa;
}

.tab-btn.active {
  background: #000;
  color: white;
}

.tab-content {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  min-height: 400px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.section-header h2 {
  margin: 0;
  color: #333;
}

.btn-primary {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
}

.btn-primary:hover {
  background: #388e3c;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.loading, .empty-state {
  text-align: center;
  padding: 2rem;
  color: #666;
}

.categories-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
}

.category-card {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  overflow: hidden;
}

.category-image {
  height: 150px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
}

.category-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.no-image {
  color: #999;
  font-style: italic;
}

.category-info {
  padding: 1rem;
}

.category-info h3 {
  margin: 0 0 0.5rem 0;
  color: #333;
}

.product-count {
  color: #666;
  font-size: 0.9rem;
  margin: 0 0 1rem 0;
}

.category-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.btn-small {
  padding: 0.375rem 0.75rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.85rem;
  text-decoration: none;
  display: inline-block;
}

.btn-manage {
  background: #ff9800;
  color: white;
}

.btn-manage:hover {
  background: #f57c00;
}

.btn-delete {
  background: #f44336;
  color: white;
}

.btn-delete:hover {
  background: #d32f2f;
}

.products-table {
  overflow-x: auto;
}

.products-table table {
  width: 100%;
  border-collapse: collapse;
}

.products-table th,
.products-table td {
  text-align: left;
  padding: 0.75rem;
  border-bottom: 1px solid #e0e0e0;
}

.products-table th {
  background: #f8f9fa;
  font-weight: 500;
}

.product-thumb {
  width: 50px;
  height: 50px;
  object-fit: cover;
  border-radius: 4px;
}

.no-thumb {
  width: 50px;
  height: 50px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  color: #999;
  border-radius: 4px;
}

.table-actions {
  display: flex;
  gap: 0.5rem;
}

.availability-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  text-transform: uppercase;
}

.availability-badge.available {
  background: #e8f5e8;
  color: #2e7d32;
}

.availability-badge.unavailable {
  background: #ffebee;
  color: #c62828;
}

.order-stats {
  display: flex;
  gap: 1rem;
}

.stat-item {
  padding: 0.5rem 1rem;
  background: #f8f9fa;
  border-radius: 6px;
  font-size: 0.9rem;
  font-weight: 500;
}

.orders-table {
  overflow-x: auto;
}

.orders-table table {
  width: 100%;
  border-collapse: collapse;
}

.orders-table th,
.orders-table td {
  text-align: left;
  padding: 0.75rem;
  border-bottom: 1px solid #e0e0e0;
}

.orders-table th {
  background: #f8f9fa;
  font-weight: 500;
}

.order-id {
  font-family: monospace;
  color: #666;
}

.customer-info {
  display: flex;
  flex-direction: column;
}

.customer-name {
  font-weight: 500;
  margin-bottom: 0.25rem;
}

.customer-email {
  font-size: 0.85rem;
  color: #666;
}

.order-total {
  font-weight: 600;
  color: #4CAF50;
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

.btn-view {
  background: #2196f3;
  color: white;
}

.btn-view:hover {
  background: #1976d2;
}

.mobile-orders-table {
  overflow-x: auto;
}

.mobile-orders-table table {
  width: 100%;
  border-collapse: collapse;
}

.mobile-orders-table th,
.mobile-orders-table td {
  text-align: left;
  padding: 0.75rem;
  border-bottom: 1px solid #e0e0e0;
}

.mobile-orders-table th {
  background: #f8f9fa;
  font-weight: 500;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  max-height: 80vh;
  overflow-y: auto;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
}

.modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  color: #333;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #666;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close:hover {
  color: #333;
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #e0e0e0;
  display: flex;
  justify-content: flex-end;
}

.btn-secondary {
  background: #6c757d;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
}

.btn-secondary:hover {
  background: #5a6268;
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
  padding: 2rem;
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

.settings-section {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.setting-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  background: #f8f9fa;
}

.setting-info h3 {
  margin: 0 0 0.5rem 0;
  color: #333;
  font-size: 1.1rem;
}

.setting-info p {
  margin: 0;
  color: #666;
  font-size: 0.9rem;
}

.setting-action {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.btn-toggle {
  background: #ff9800;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background 0.2s;
}

.btn-toggle:hover {
  background: #f57c00;
}

.btn-edit {
  background: #9c27b0;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background 0.2s;
}

.btn-edit:hover {
  background: #7b1fa2;
}

@media (max-width: 768px) {
  .manage-store-wrapper {
    padding: 1rem;
  }
  
  .store-header {
    flex-direction: column;
    gap: 1rem;
  }
  
  .management-tabs {
    flex-direction: column;
  }
  
  .section-header {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }
  
  .categories-grid {
    grid-template-columns: 1fr;
  }

  .modal-content {
    width: 95%;
    margin: 1rem;
  }

  .info-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .info-row strong {
    min-width: auto;
    margin-right: 0;
    margin-bottom: 0.25rem;
  }

  .cart-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .item-image {
    margin-right: 0;
    margin-bottom: 0.5rem;
  }
}
</style> 