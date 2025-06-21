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
                <td>${{ product.price }}</td>
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
            <span class="stat-item">Revenue: ${{ storeRevenue.toFixed(2) }}</span>
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
                <td class="order-total">${{ order.total.toFixed(2) }}</td>
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
            <span class="stat-item">Revenue: ${{ mobileStoreRevenue.toFixed(2) }}</span>
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
                <td class="order-total">${{ order.total.toFixed(2) }}</td>
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
      totalMobileOrders: 0
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

    viewOrderDetails(order) {
      // For now, just show an alert with order details
      // You can implement a proper modal later
      alert(`Order Details:\n\nOrder ID: ${order.id}\nCustomer: ${order.name}\nEmail: ${order.email}\nTotal: $${order.total}\nStatus: ${order.status}\nAddress: ${order.address}`)
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

    viewMobileOrderDetails(order) {
      // For now, just show an alert with order details
      // You can implement a proper modal later
      alert(`Mobile Order Details:\n\nOrder ID: ${order.id}\nCustomer: ${order.name}\nEmail: ${order.email}\nTotal: $${order.total}\nStatus: ${order.status}\nAddress: ${order.address}`)
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
}
</style> 