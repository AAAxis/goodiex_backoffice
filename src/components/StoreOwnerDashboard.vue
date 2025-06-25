<template>
  <div class="dashboard-wrapper">
    <div class="dashboard-content">
      <div class="dashboard-header">
        <h1 class="dashboard-title">{{ userName || userEmail }}</h1>
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
          <h3>Active Stores</h3>
          <p class="stat-number">{{ activeStores }}</p>
        </div>
        <div class="stat-card">
          <h3>Total Orders</h3>
          <p class="stat-number">{{ totalOrders }}</p>
        </div>
        <div class="stat-card">
          <h3>Total Revenue</h3>
          <div v-if="revenueByCurrency.length === 1" class="stat-number">
            {{ formatPrice(revenueByCurrency[0].total, revenueByCurrency[0].currency) }}
          </div>
          <div v-else-if="revenueByCurrency.length > 1" class="multiple-currencies">
            <div v-for="revenue in revenueByCurrency" :key="revenue.currency" class="currency-revenue">
              <span class="currency-code">{{ revenue.currency }}</span>
              <span class="revenue-amount">{{ formatPrice(revenue.total, revenue.currency) }}</span>
            </div>
          </div>
          <div v-else class="stat-number">$0.00</div>
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
          <div v-for="store in stores" :key="store.id" class="store-card">
            <div class="store-header">
              <span :class="['status-badge', store.isActive ? 'active' : 'inactive']">
                {{ store.isActive ? 'Active' : 'Inactive' }}
              </span>
              <div class="store-actions">
                <button class="btn-manage" @click="manageStore(store.id)">Manage</button>
                <button class="btn-edit" @click="editStore(store.id)">Edit</button>
                <button class="btn-toggle" @click="toggleStoreStatus(store.id, store.isActive)">
                  {{ store.isActive ? 'Deactivate' : 'Activate' }}
                </button>
              </div>
            </div>
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
      totalRevenue: 0,
      revenueByCurrency: []
    }
  },
  computed: {
    activeStores() {
      return this.stores.filter(store => store.isActive).length
    }
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
        let totalRevenue = 0
        
        for (const store of this.stores) {
          // Get orders for this specific store
          const ordersQuery = await db.collection('web-orders')
            .where('storeId', '==', store.id)
            .where('status', '==', 'completed')
            .get()
          
          let storeOrders = 0
          let storeRevenue = 0
          
          ordersQuery.forEach((doc) => {
            const orderData = doc.data()
            storeOrders++
            storeRevenue += parseFloat(orderData.total || 0)
          })
          
          // Update store object with stats
          store.totalOrders = storeOrders
          store.totalRevenue = storeRevenue
          
          // Add to overall totals
          totalOrders += storeOrders
          totalRevenue += storeRevenue
        }
        
        this.totalOrders = totalOrders
        this.totalRevenue = totalRevenue
        
        // Calculate revenue by currency
        this.revenueByCurrency = await this.calculateRevenueByCurrency()
        
      } catch (error) {
        console.error('Error calculating stats:', error)
        this.totalOrders = 0
        this.totalRevenue = 0
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
        'ZAR': 'R'
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

    editStore(storeId) {
      this.$router.push(`/store-owner/edit-store/${storeId}`)
    },

    async toggleStoreStatus(storeId, currentStatus) {
      try {
        await db.collection('stores').doc(storeId).update({
          isActive: !currentStatus,
          updatedAt: new Date()
        })
        await this.fetchStores()
      } catch (error) {
        console.error('Error updating store status:', error)
      }
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
    }
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
  align-items: center;
  margin-bottom: 2rem;
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.dashboard-title {
  font-size: 2rem;
  color: #333;
  margin: 0;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
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
}

.store-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

.store-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: #f8f9fa;
  border-bottom: 1px solid #e0e0e0;
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

.store-status {
  margin-bottom: 1rem;
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

.store-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-manage {
  background: #1976d2;
  color: white;
  border: none;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
}

.btn-manage:hover {
  background: #1565c0;
}

.btn-edit {
  background: #9c27b0;
  color: white;
  border: none;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
}

.btn-edit:hover {
  background: #7b1fa2;
}

.btn-toggle {
  background: #ff9800;
  color: white;
  border: none;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
}

.btn-toggle:hover {
  background: #f57c00;
}

@media (max-width: 768px) {
  .dashboard-wrapper {
    padding: 1rem;
  }
  
  .dashboard-header {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
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