<template>
  <div class="dashboard-wrapper">
    <div class="dashboard-content">
      <div class="dashboard-header">
        <div class="header-left">
          <h1 class="dashboard-title">{{ userName || userEmail }}</h1>
          <div class="header-charts">
            <div class="chart-container">
              <h4>Revenue by Currency</h4>
              <canvas ref="revenueChart" width="200" height="200"></canvas>
            </div>
            <div class="chart-container">
              <h4>Orders by Platform</h4>
              <canvas ref="ordersChart" width="200" height="200"></canvas>
            </div>
          </div>
        </div>
        <div class="header-actions">
          <span class="user-email">{{ userEmail }}</span>
          <button class="settings-btn" @click="goToSettings">Settings</button>
          <button class="logout-btn" @click="logout">Logout</button>
        </div>
      </div>

      <div class="stats-grid">
        <div class="stat-card">
          <h3>Total Stores</h3>
          <p class="stat-number">{{ stores.length }}</p>
        </div>

        <div class="stat-card">
          <h3>Total Orders</h3>
          <p class="stat-number">{{ totalOrders }}</p>
        </div>

        <div class="stat-card">
          <h3>Pending Orders</h3>
          <p class="stat-number">{{ totalPendingOrders }}</p>
        </div>

        <div class="stat-card">
          <h3>Average Order Value</h3>
          <p class="stat-number">{{ formatPrice(averageOrderValue, 'USD') }}</p>
        </div>

        <div class="stat-card">
          <h3>Top Product</h3>
          <p v-if="topProduct" class="stat-text">{{ topProduct.name }}</p>
          <p v-else class="stat-text">No orders yet</p>
        </div>

        <div class="stat-card">
          <h3>Total Revenue</h3>
          <div v-if="revenueByCurrency.length === 1" class="stat-number">
            {{ formatPrice(revenueByCurrency[0].total, revenueByCurrency[0].currency) }}
          </div>
          <div v-else class="multiple-currencies">
            <div v-for="revenue in revenueByCurrency" :key="revenue.currency" class="currency-revenue">
              <span class="currency-code">{{ revenue.currency }}</span>
              <span class="revenue-amount">{{ formatPrice(revenue.total, revenue.currency) }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="stores-section">
        <div class="section-header">
          <h2>My Stores</h2>
          <button class="btn-primary" @click="createStore">Create New Store</button>
        </div>

        <div v-if="loading" class="loading">Loading stores...</div>
        
        <div v-else-if="stores.length === 0" class="no-stores">
          <p>No stores created yet.</p>
        </div>

        <div v-else class="stores-grid">
          <div v-for="store in stores" :key="store.id" class="store-card" @click="manageStore(store.id)">
            <div class="store-image">
              <img v-if="store.image" :src="store.image" :alt="store.name" />
              <div v-else class="no-image">No Image</div>
            </div>
            <div class="store-info">
              <h3>{{ store.name }}</h3>
              <p class="store-description">{{ store.description }}</p>
              <div class="store-stats">
                <div class="stat-mini">
                  <span class="stat-label">Orders:</span>
                  <span class="stat-value">{{ store.totalOrders || 0 }}</span>
                </div>
                <div class="stat-mini">
                  <span class="stat-label">Revenue:</span>
                  <span class="stat-value">{{ formatPrice(store.totalRevenue || 0, store.currency || 'USD') }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { auth, db } from '../../firebase'

export default {
  name: 'StoreOwnerDashboard',
  data() {
    return {
      user: null,
      userEmail: '',
      userName: '',
      stores: [],
      loading: true,
      totalOrders: 0,
      totalWebOrders: 0,
      totalMobileOrders: 0,
      totalPendingOrders: 0,
      averageOrderValue: 0,
      topProduct: null,
      revenueByCurrency: [],
      revenueChart: null,
      ordersChart: null
    }
  },
  computed: {
  },
  async mounted() {
    auth.onAuthStateChanged(async (user) => {
      if (user) {
        this.user = user
        this.userEmail = user.email
        await this.fetchUserName()
        await this.fetchStores()
      } else {
        this.$router.push('/store-owner/login')
      }
    })
  },
  beforeUnmount() {
    if (this.revenueChart) {
      this.revenueChart.destroy()
    }
    if (this.ordersChart) {
      this.ordersChart.destroy()
    }
  },
  methods: {
    async fetchUserName() {
      try {
        const userDoc = await db.collection('storeOwners').doc(this.user.uid).get()
        if (userDoc.exists) {
          const userData = userDoc.data()
          this.userName = userData.name || ''
        }
      } catch (error) {
        console.error('Error fetching user name:', error)
      }
    },

    async fetchStores() {
      this.loading = true
      try {
        const querySnapshot = await db.collection('stores')
          .where('ownerId', '==', this.user.uid)
          .orderBy('createdAt', 'desc')
          .get()
        
        this.stores = []
        
        querySnapshot.forEach((doc) => {
          this.stores.push({
            id: doc.id,
            ...doc.data()
          })
        })
        
        // Calculate total orders and revenue for all stores
        await this.calculateTotalStats()
        
      } catch (error) {
        console.error('Error fetching stores:', error)
      } finally {
        this.loading = false
      }
    },

    async calculateTotalStats() {
      try {
        let totalOrders = 0
        let totalWebOrders = 0
        let totalMobileOrders = 0
        let totalPendingOrders = 0
        let totalRevenue = 0
        let allOrderItems = new Map() // Track product sales
        
        for (const store of this.stores) {
          // Get web orders for this specific store
          const webOrdersQuery = await db.collection('web-orders')
            .where('storeId', '==', store.id)
            .get()
          
          // Get mobile orders for this specific store
          const mobileOrdersQuery = await db.collection('orders')
            .where('storeId', '==', store.id)
            .get()
          
          let storeOrders = 0
          let storeRevenue = 0
          let storeWebOrders = 0
          let storeMobileOrders = 0
          let storePendingOrders = 0
          
          // Calculate web orders revenue and pending orders
          webOrdersQuery.forEach((doc) => {
            const orderData = doc.data()
            storeOrders++
            storeWebOrders++
            
            if (orderData.status === 'completed') {
              storeRevenue += parseFloat(orderData.total || 0)
            } else if (orderData.status === 'pending') {
              storePendingOrders++
            }
            
            // Track product sales from web orders
            if (orderData.cart && Array.isArray(orderData.cart)) {
              orderData.cart.forEach(item => {
                const productId = item.product_id || item.id
                if (productId) {
                  const currentCount = allOrderItems.get(productId) || 0
                  allOrderItems.set(productId, currentCount + (item.quantity || 1))
                }
              })
            }
          })
          
          // Calculate mobile orders revenue and pending orders
          mobileOrdersQuery.forEach((doc) => {
            const orderData = doc.data()
            storeOrders++
            storeMobileOrders++
            
            if (orderData.status === 'completed') {
              storeRevenue += parseFloat(orderData.total || 0)
            } else if (orderData.status === 'pending') {
              storePendingOrders++
            }
            
            // Track product sales from mobile orders
            if (orderData.items && Array.isArray(orderData.items)) {
              orderData.items.forEach(item => {
                const productId = item.product_id || item.id
                if (productId) {
                  const currentCount = allOrderItems.get(productId) || 0
                  allOrderItems.set(productId, currentCount + (item.quantity || 1))
                }
              })
            }
          })
          
          // Update store object with stats
          store.totalOrders = storeOrders
          store.totalRevenue = storeRevenue
          store.webOrders = storeWebOrders
          store.mobileOrders = storeMobileOrders
          
          // Add to overall totals
          totalOrders += storeOrders
          totalWebOrders += storeWebOrders
          totalMobileOrders += storeMobileOrders
          totalPendingOrders += storePendingOrders
          totalRevenue += storeRevenue
        }
        
        this.totalOrders = totalOrders
        this.totalWebOrders = totalWebOrders
        this.totalMobileOrders = totalMobileOrders
        this.totalPendingOrders = totalPendingOrders
        
        // Calculate average order value
        this.averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0
        
        // Find top product
        await this.findTopProduct(allOrderItems)
        
        // Calculate revenue by currency
        this.revenueByCurrency = await this.calculateRevenueByCurrency()
        
        // Update charts
        this.$nextTick(() => {
          this.createCharts()
        })
        
      } catch (error) {
        console.error('Error calculating stats:', error)
        this.totalOrders = 0
        this.totalWebOrders = 0
        this.totalMobileOrders = 0
        this.totalPendingOrders = 0
        this.averageOrderValue = 0
        this.topProduct = null
      }
    },

    async calculateRevenueByCurrency() {
      const revenueByCurrency = new Map()
      
      for (const store of this.stores) {
        const currency = store.currency || 'USD'
        const storeRevenue = store.totalRevenue || 0
        
        if (revenueByCurrency.has(currency)) {
          revenueByCurrency.set(currency, revenueByCurrency.get(currency) + storeRevenue)
        } else {
          revenueByCurrency.set(currency, storeRevenue)
        }
      }
      
      return Array.from(revenueByCurrency.entries()).map(([currency, total]) => ({
        currency,
        total
      }))
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

    formatPrice(total, currency) {
      const symbol = this.getCurrencySymbol(currency)
      return `${symbol}${total.toFixed(2)}`
    },

    createStore() {
      this.$router.push('/store-owner/create-store')
    },

    manageStore(storeId) {
      this.$router.push(`/store-owner/manage-store/${storeId}`)
    },

    goToSettings() {
      this.$router.push('/store-owner/settings')
    },

    async logout() {
      try {
        await auth.signOut()
        this.$router.push('/store-owner/login')
      } catch (error) {
        console.error('Logout error:', error)
      }
    },

    createCharts() {
      this.createRevenueChart()
      this.createOrdersChart()
    },

    createRevenueChart() {
      const ctx = this.$refs.revenueChart
      if (!ctx) return

      if (this.revenueChart) {
        this.revenueChart.destroy()
      }

      const labels = this.revenueByCurrency.map(item => item.currency)
      const data = this.revenueByCurrency.map(item => item.total)
      const colors = [
        '#4CAF50', '#2196F3', '#FF9800', '#9C27B0', 
        '#F44336', '#00BCD4', '#FF5722', '#795548',
        '#607D8B', '#E91E63', '#3F51B5', '#009688'
      ]

      this.revenueChart = new Chart(ctx, {
        type: 'pie',
        data: {
          labels: labels,
          datasets: [{
            data: data,
            backgroundColor: colors.slice(0, labels.length),
            borderWidth: 2,
            borderColor: '#fff'
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          interaction: {
            intersect: false,
            mode: 'index'
          },
          plugins: {
            legend: {
              position: 'bottom',
              labels: {
                padding: 10,
                usePointStyle: true,
                font: {
                  size: 11
                }
              }
            },
            tooltip: {
              callbacks: {
                label: (context) => {
                  const label = context.label || ''
                  const value = context.parsed
                  return `${label}: ${this.formatPrice(value, label)}`
                }
              }
            }
          }
        }
      })
    },

    createOrdersChart() {
      const ctx = this.$refs.ordersChart
      if (!ctx) return

      if (this.ordersChart) {
        this.ordersChart.destroy()
      }

      const labels = ['Web Orders', 'Mobile Orders']
      const data = [this.totalWebOrders, this.totalMobileOrders]
      const colors = ['#2196F3', '#4CAF50']

      this.ordersChart = new Chart(ctx, {
        type: 'pie',
        data: {
          labels: labels,
          datasets: [{
            data: data,
            backgroundColor: colors,
            borderWidth: 2,
            borderColor: '#fff'
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          interaction: {
            intersect: false,
            mode: 'index'
          },
          plugins: {
            legend: {
              position: 'bottom',
              labels: {
                padding: 10,
                usePointStyle: true,
                font: {
                  size: 11
                }
              }
            },
            tooltip: {
              callbacks: {
                label: (context) => {
                  const label = context.label || ''
                  const value = context.parsed
                  return `${label}: ${value}`
                }
              }
            }
          }
        }
      })
    },

    async findTopProduct(allOrderItems) {
      if (allOrderItems.size === 0) {
        this.topProduct = null
        return
      }

      let topProduct = null
      let maxSales = 0
      
      // Find the product with highest sales
      for (const [productId, sales] of allOrderItems) {
        if (sales > maxSales) {
          maxSales = sales
          topProduct = {
            id: productId,
            name: productId,
            sales: sales
          }
        }
      }
      
      // Try to get the actual product name from any store
      if (topProduct) {
        for (const store of this.stores) {
          try {
            const productDoc = await db.collection('stores').doc(store.id).collection('products').doc(topProduct.id).get()
            if (productDoc.exists) {
              const productData = productDoc.data()
              topProduct.name = productData.name || productId
              break
            }
          } catch (error) {
            console.error('Error fetching product name:', error)
          }
        }
      }
      
      this.topProduct = topProduct
    },
  }
}
</script>

<style scoped>
.dashboard-wrapper {
  min-height: 100vh;
  background: #f8f9fa;
  padding: 2rem;
}

.dashboard-content {
  max-width: 1200px;
  margin: 0 auto;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.header-left {
  display: flex;
  align-items: flex-start;
  gap: 2rem;
  flex: 1;
}

.dashboard-title {
  font-size: 2rem;
  color: #333;
  margin: 0;
  white-space: nowrap;
}

.header-charts {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.chart-container {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 8px;
  text-align: center;
  min-width: 200px;
}

.chart-container h4 {
  margin: 0 0 0.5rem 0;
  color: #666;
  font-size: 0.8rem;
  text-transform: uppercase;
  font-weight: 600;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-shrink: 0;
}

.user-email {
  color: #666;
  font-size: 0.9rem;
}

.settings-btn {
  background: #607d8b;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.2s;
}

.settings-btn:hover {
  background: #546e7a;
}

.logout-btn {
  background: #e53935;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.2s;
}

.logout-btn:hover {
  background: #c62828;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  text-align: center;
}

.stat-card h3 {
  margin: 0 0 0.5rem 0;
  color: #666;
  font-size: 0.9rem;
  text-transform: uppercase;
}

.stat-number {
  font-size: 2rem;
  font-weight: bold;
  color: #4CAF50;
  margin: 0;
}

.stat-text {
  font-size: 1rem;
  font-weight: 600;
  color: #333;
  margin: 0;
  text-align: center;
  line-height: 1.3;
}

.multiple-currencies {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.currency-revenue {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.25rem 0;
}

.currency-code {
  font-size: 0.8rem;
  font-weight: 600;
  color: #666;
  background: #f0f0f0;
  padding: 0.125rem 0.5rem;
  border-radius: 12px;
}

.revenue-amount {
  font-size: 1.1rem;
  font-weight: bold;
  color: #4CAF50;
}

.stores-section {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
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
  transition: background 0.2s;
}

.btn-primary:hover {
  background: #388e3c;
}

.loading, .no-stores {
  text-align: center;
  padding: 2rem;
  color: #666;
}

.stores-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.store-card {
  border: 1px solid #e0e0e0;
  border-radius: 12px;
  overflow: hidden;
  transition: transform 0.2s;
  background: white;
  cursor: pointer;
}

.store-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

.store-image {
  height: 200px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
}

.store-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.no-image {
  color: #999;
  font-style: italic;
}

.store-info {
  padding: 1.5rem;
}

.store-info h3 {
  margin: 0 0 0.5rem 0;
  color: #333;
}

.store-description {
  color: #666;
  font-size: 0.9rem;
  margin: 0 0 1rem 0;
  line-height: 1.4;
}

.store-stats {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.stat-mini {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0.5rem;
  background: #f8f9fa;
  border-radius: 8px;
  flex: 1;
}

.stat-label {
  font-size: 0.75rem;
  color: #666;
  text-transform: uppercase;
  margin-bottom: 0.25rem;
}

.stat-value {
  font-size: 1rem;
  font-weight: bold;
  color: #4CAF50;
}

@media (max-width: 768px) {
  .dashboard-wrapper {
    padding: 1rem;
  }
  
  .dashboard-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .header-left {
    flex-direction: column;
    gap: 1rem;
    align-items: center;
  }
  
  .dashboard-title {
    text-align: center;
  }
  
  .header-charts {
    justify-content: center;
    width: 100%;
  }
  
  .chart-container {
    min-width: 150px;
    flex: 1;
  }
  
  .header-actions {
    justify-content: center;
  }
  
  .section-header {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }
  
  .stores-grid {
    grid-template-columns: 1fr;
  }
}
</style> 