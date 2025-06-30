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
          :class="['tab-btn', activeTab === 'edit-store' ? 'active' : '']"
          @click="activeTab = 'edit-store'"
        >
          Edit Store
        </button>
        <button 
          :class="['tab-btn', { active: activeTab === 'domain' }]" 
          @click="activeTab = 'domain'"
        >
          Domain Settings
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

      <!-- Edit Store Tab -->
      <div v-if="activeTab === 'edit-store'" class="tab-content">
        <div class="section-header">
          <h2>Edit Store</h2>
        </div>

        <form @submit.prevent="updateStore" class="store-form" v-if="store">
          <div class="form-group">
            <label>Store Name *</label>
            <input 
              v-model="storeData.name" 
              type="text" 
              placeholder="Enter store name" 
              required 
            />
          </div>

          <div class="form-group">
            <label>Description</label>
            <textarea 
              v-model="storeData.description" 
              placeholder="Store description"
              rows="3"
            ></textarea>
          </div>

          <div class="form-group">
            <label>Email *</label>
            <input 
              v-model="storeData.email" 
              type="email" 
              placeholder="Contact email" 
              required 
            />
          </div>

          <div class="form-group">
            <label>Phone</label>
            <input 
              v-model="storeData.phone" 
              type="tel" 
              placeholder="Phone number" 
            />
          </div>

          <div class="form-group">
            <label>Address</label>
            <textarea 
              v-model="storeData.address" 
              placeholder="Store address"
              rows="2"
            ></textarea>
          </div>

          <div class="form-group">
            <label>Store Image</label>
            <input 
              type="file" 
              accept="image/*" 
              @change="onImageChange"
              ref="imageInput"
            />
            <div v-if="imagePreview" class="image-preview">
              <img :src="imagePreview" alt="Store preview" />
            </div>
            <div v-else-if="currentImage" class="image-preview">
              <img :src="currentImage" alt="Current store image" />
              <p class="current-image-label">Current Image</p>
            </div>
          </div>

          <div class="form-group">
            <label class="checkbox-label">
              <input 
                type="checkbox" 
                v-model="storeData.isActive"
              />
              <span class="checkmark"></span>
              Active (store will be visible to customers)
            </label>
          </div>

          <button type="submit" class="update-btn" :disabled="loading">
            {{ loading ? 'Updating Store...' : 'Update Store' }}
          </button>
        </form>

        <!-- Danger Zone -->
        <div v-if="store" class="danger-zone">
          <div class="danger-content">
            <div class="danger-warning">
              <h4>Delete Store</h4>
              <p>Once you delete a store, there is no going back.</p>
            </div>
            <button 
              class="delete-btn" 
              @click="showDeleteConfirmation = true"
              :disabled="loading"
            >
              Delete Store Permanently
            </button>
          </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div v-if="showDeleteConfirmation" class="modal-overlay" @click="cancelDelete">
          <div class="modal-content" @click.stop>
            <h3>Confirm Store Deletion</h3>
            <p>Are you absolutely sure you want to delete <strong>"{{ store.name }}"</strong>?</p>
            <p class="modal-warning">This action will permanently delete:</p>
            <ul class="modal-list">
              <li>The store and all its information</li>
              <li>{{ totalProducts }} products</li>
              <li>{{ totalOrders }} orders</li>
              <li>All associated data</li>
            </ul>
            <div class="confirmation-input">
              <label>Type <strong>DELETE</strong> to confirm:</label>
              <input 
                v-model="deleteConfirmation" 
                type="text" 
                placeholder="Type DELETE here"
                class="delete-input"
              />
            </div>
            <div class="modal-actions">
              <button class="cancel-btn" @click="cancelDelete">Cancel</button>
              <button 
                class="confirm-delete-btn" 
                @click="deleteStore"
                :disabled="deleteConfirmation !== 'DELETE' || deleting"
              >
                {{ deleting ? 'Deleting...' : 'Delete Store Forever' }}
              </button>
            </div>
          </div>
        </div>

        <p v-if="message" class="form-message" :class="messageType">{{ message }}</p>
      </div>

      <!-- Domain Settings Tab -->
      <div v-if="activeTab === 'domain'" class="tab-content">
        <div class="tab-header">
          <h2>Domain Settings</h2>
        </div>

        <div class="domain-settings">
          <div class="domain-info">
            <h3>Current Domain</h3>
            <div class="current-domain">
              <div class="domain-display">
                <span class="domain-url">{{ store?.domain || 'No custom domain set' }}</span>
                <span v-if="store?.domain" :class="['domain-status', store?.domainStatus || 'pending']">
                  {{ store?.domainStatus || 'Pending' }}
                </span>
              </div>
              <p v-if="store?.domain" class="domain-note">
                Your store is accessible at: <strong>{{ store.domain }}</strong>
              </p>
              <p v-else class="domain-note">
                Connect a custom domain to make your store more professional and easier to remember.
              </p>
            </div>
          </div>

          <div class="domain-form">
            <h3>Connect Custom Domain</h3>
            <form @submit.prevent="updateDomain" class="domain-form-content">
              <div class="form-group">
                <label>Domain Name *</label>
                <div class="domain-input-group">
                  <input 
                    v-model="domainData.domain" 
                    type="text" 
                    placeholder="yourstore.com" 
                    required 
                    class="domain-input"
                  />
                  <span class="domain-suffix">.com</span>
                </div>
                <small class="form-help">
                  Enter your domain without http:// or www. (e.g., mystore.com)
                </small>
              </div>

              <div class="form-group">
                <label class="checkbox-label">
                  <input 
                    type="checkbox" 
                    v-model="domainData.includeWww"
                  />
                  <span class="checkmark"></span>
                  Also redirect www.yourdomain.com to yourdomain.com
                </label>
              </div>

              <div class="domain-requirements">
                <h4>Domain Requirements</h4>
                <ul>
                  <li>You must own the domain you want to connect</li>
                  <li>Domain must be active and not expired</li>
                  <li>DNS settings need to be configured (instructions provided after setup)</li>
                  <li>SSL certificate will be automatically provisioned</li>
                </ul>
              </div>

              <button type="submit" class="update-btn" :disabled="domainLoading">
                {{ domainLoading ? 'Connecting Domain...' : 'Connect Domain' }}
              </button>
            </form>
          </div>

          <div v-if="store?.domain" class="domain-actions">
            <h3>Domain Management</h3>
            <div class="domain-actions-content">
              <div class="action-item">
                <h4>DNS Configuration</h4>
                <p>Configure your domain's DNS settings to point to our proxy server. The proxy will automatically route your domain to the correct store:</p>
                <div class="dns-settings">
                  <div class="dns-record">
                    <strong>Type:</strong> CNAME
                  </div>
                  <div class="dns-record">
                    <strong>Name:</strong> @
                  </div>
                  <div class="dns-record">
                    <strong>Value:</strong> {{ getDnsValue() }}
                  </div>
                </div>
                <p class="dns-note">
                  <strong>How it works:</strong> When someone visits your custom domain, our proxy server will automatically detect which store it belongs to and serve the correct content.
                </p>
                <button class="btn-secondary" @click="copyDnsValue">
                  Copy DNS Settings
                </button>
                <button class="btn-secondary" @click="checkDnsStatus" style="margin-left: 10px;">
                  Check DNS Status
                </button>
              </div>

              <div class="action-item">
                <h4>Remove Domain</h4>
                <p>Disconnect your custom domain and revert to the default URL.</p>
                <button 
                  class="remove-domain-btn" 
                  @click="showRemoveDomainConfirmation = true"
                  :disabled="domainLoading"
                >
                  Remove Domain
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Remove Domain Confirmation Modal -->
        <div v-if="showRemoveDomainConfirmation" class="modal-overlay" @click="cancelRemoveDomain">
          <div class="modal-content" @click.stop>
            <h3>Remove Custom Domain</h3>
            <p>Are you sure you want to remove the domain <strong>"{{ store?.domain }}"</strong>?</p>
            <p>Your store will revert to the default URL after removal.</p>
            <div class="modal-actions">
              <button class="cancel-btn" @click="cancelRemoveDomain">Cancel</button>
              <button 
                class="confirm-delete-btn" 
                @click="removeDomain"
                :disabled="domainLoading"
              >
                {{ domainLoading ? 'Removing...' : 'Remove Domain' }}
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
      store: null,
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
      selectedOrder: null,
      orderCartItems: [],
      loadingOrderDetails: false,
      showDeleteConfirmation: false,
      deleteConfirmation: '',
      message: '',
      messageType: '',
      storeData: {
        name: '',
        description: '',
        email: '',
        phone: '',
        address: '',
        isActive: true
      },
      imageFile: null,
      imagePreview: null,
      currentImage: null,
      loading: false,
      deleting: false,
      domainData: {
        domain: '',
        includeWww: false
      },
      domainLoading: false,
      showRemoveDomainConfirmation: false
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
          this.storeData = {
            name: this.store.name,
            description: this.store.description,
            email: this.store.email,
            phone: this.store.phone,
            address: this.store.address,
            isActive: this.store.isActive
          }
          this.currentImage = this.store.image
          
          // Populate domain data if it exists
          if (this.store.domain) {
            this.domainData.domain = this.store.domain
            this.domainData.includeWww = this.store.includeWww || false
          }
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
      this.selectedOrder = null
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

    async updateStore() {
      this.loading = true
      this.message = ''

      try {
        let imageUrl = this.currentImage
        if (this.imageFile) {
          imageUrl = await this.uploadImage()
        }

        const updateData = {
          ...this.storeData,
          image: imageUrl,
          updatedAt: new Date()
        }

        await db.collection('stores').doc(this.storeId).update(updateData)

        this.showMessage('Store updated successfully!', 'success')
        await this.fetchStore()

      } catch (error) {
        console.error('Error updating store:', error)
        this.showMessage('Failed to update store. Please try again.', 'error')
      } finally {
        this.loading = false
      }
    },

    async uploadImage() {
      if (!this.imageFile) return this.currentImage

      try {
        const { storage } = await import('../../firebase')
        const fileName = `store-images/${Date.now()}_${this.imageFile.name}`
        const storageRef = storage.ref().child(fileName)
        const snapshot = await storageRef.put(this.imageFile)
        const downloadURL = await snapshot.ref.getDownloadURL()
        return downloadURL
      } catch (error) {
        console.error('Error uploading image:', error)
        throw error
      }
    },

    showMessage(message, type) {
      this.message = message
      this.messageType = type
      setTimeout(() => {
        this.message = ''
      }, 5000)
    },

    async deleteStore() {
      if (this.deleteConfirmation !== 'DELETE') {
        return
      }

      this.deleting = true

      try {
        // Delete all products first
        const productsSnapshot = await db.collection('stores').doc(this.storeId).collection('products').get()
        const productDeletePromises = productsSnapshot.docs.map(doc => doc.ref.delete())
        await Promise.all(productDeletePromises)

        // Delete the store itself
        await db.collection('stores').doc(this.storeId).delete()

        this.showMessage('Store deleted successfully. Redirecting...', 'success')
        
        setTimeout(() => {
          this.$router.push('/store-owner/dashboard')
        }, 2000)

      } catch (error) {
        console.error('Error deleting store:', error)
        this.showMessage('Failed to delete store. Please try again.', 'error')
      } finally {
        this.deleting = false
        this.showDeleteConfirmation = false
      }
    },

    onImageChange(event) {
      const file = event.target.files[0]
      if (file) {
        this.imageFile = file
        this.imagePreview = URL.createObjectURL(file)
      }
    },

    cancelDelete() {
      this.showDeleteConfirmation = false
      this.deleteConfirmation = ''
    },

    async updateDomain() {
      this.domainLoading = true
      this.message = ''

      try {
        // Validate domain format
        const domainRegex = /^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?\.[a-zA-Z]{2,}$/
        if (!domainRegex.test(this.domainData.domain)) {
          this.showMessage('Please enter a valid domain name (e.g., mystore.com)', 'error')
          return
        }

        // Verify domain with backend
        const verifyResponse = await fetch('https://api.theholylabs.com/api/domain/verify', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            domain: this.domainData.domain
          })
        })

        if (!verifyResponse.ok) {
          this.showMessage('Failed to verify domain. Please try again.', 'error')
          return
        }

        const verifyResult = await verifyResponse.json()
        
        if (verifyResult.dns_status === 'unresolved') {
          this.showMessage('Domain does not resolve. Please check if the domain exists and is active.', 'error')
          return
        }

        // Generate CNAME for the store
        const cnameResponse = await fetch('https://api.theholylabs.com/api/domain/generate-cname', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            store_id: this.storeId
          })
        })

        if (!cnameResponse.ok) {
          this.showMessage('Failed to generate DNS settings. Please try again.', 'error')
          return
        }

        const cnameResult = await cnameResponse.json()

        const updateData = {
          domain: this.domainData.domain,
          includeWww: this.domainData.includeWww,
          domainStatus: 'pending',
          domainCname: cnameResult.cname,
          domainUpdatedAt: new Date()
        }

        await db.collection('stores').doc(this.storeId).update(updateData)

        this.showMessage('Domain connected successfully! Please configure your DNS settings.', 'success')
        await this.fetchStore()
        
        // Reset form
        this.domainData.domain = ''
        this.domainData.includeWww = false

      } catch (error) {
        console.error('Error updating domain:', error)
        this.showMessage('Failed to connect domain. Please try again.', 'error')
      } finally {
        this.domainLoading = false
      }
    },

    getDnsValue() {
      // Return the proxy domain that handles custom domains
      // This should point to your server where Nginx is running
      return 'theholylabs.com' // Update this to your actual server domain
    },

    async checkDnsStatus() {
      if (!this.store?.domain || !this.store?.domainCname) {
        return
      }

      try {
        const response = await fetch('https://api.theholylabs.com/api/domain/check-dns', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            domain: this.store.domain,
            store_id: this.storeId,
            expected_cname: this.store.domainCname
          })
        })

        if (response.ok) {
          const result = await response.json()
          
          // Update store with DNS status
          await db.collection('stores').doc(this.storeId).update({
            domainStatus: result.status,
            lastDnsCheck: new Date()
          })
          
          await this.fetchStore()
          
          if (result.status === 'active') {
            this.showMessage('DNS is properly configured! Your domain is now active.', 'success')
          } else {
            this.showMessage('DNS is not yet configured. Please update your DNS settings.', 'warning')
          }
        }
      } catch (error) {
        console.error('Error checking DNS status:', error)
      }
    },

    copyDnsValue() {
      const dnsValue = this.getDnsValue()
      navigator.clipboard.writeText(dnsValue).then(() => {
        this.showMessage('DNS settings copied to clipboard!', 'success')
      }).catch(() => {
        this.showMessage('Failed to copy DNS settings', 'error')
      })
    },

    async removeDomain() {
      this.domainLoading = true
      this.message = ''

      try {
        const updateData = {
          domain: null,
          includeWww: false,
          domainStatus: null,
          domainUpdatedAt: new Date()
        }

        await db.collection('stores').doc(this.storeId).update(updateData)

        this.showMessage('Domain removed successfully!', 'success')
        await this.fetchStore()
        this.showRemoveDomainConfirmation = false

      } catch (error) {
        console.error('Error removing domain:', error)
        this.showMessage('Failed to remove domain. Please try again.', 'error')
      } finally {
        this.domainLoading = false
      }
    },

    cancelRemoveDomain() {
      this.showRemoveDomainConfirmation = false
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

/* Edit Store Styles */
.store-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #333;
}

.form-group input,
.form-group select,
.form-group textarea {
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #4CAF50;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.image-preview {
  margin-top: 1rem;
  text-align: center;
}

.image-preview img {
  max-width: 200px;
  max-height: 200px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #ddd;
}

.current-image-label {
  margin-top: 0.5rem;
  color: #666;
  font-size: 0.9rem;
  font-style: italic;
}

.checkbox-label {
  display: flex !important;
  align-items: center;
  cursor: pointer;
  font-weight: normal !important;
  margin-bottom: 0 !important;
}

.checkbox-label input[type="checkbox"] {
  margin-right: 0.5rem;
  width: auto;
  padding: 0;
}

.update-btn {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 8px;
  font-size: 1.1rem;
  cursor: pointer;
  transition: background 0.2s;
  margin-top: 1rem;
}

.update-btn:hover:not(:disabled) {
  background: #388e3c;
}

.update-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.form-message {
  margin-top: 1rem;
  padding: 0.75rem;
  border-radius: 6px;
  text-align: center;
  font-weight: 500;
}

.form-message.success {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.form-message.error {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

/* Danger Zone Styles */
.danger-zone {
  margin-top: 3rem;
  padding: 2rem;
  border: 2px solid #dc3545;
  border-radius: 8px;
  background: #fff5f5;
}

.danger-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 2rem;
}

.danger-warning {
  flex: 1;
}

.danger-warning h4 {
  color: #721c24;
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
}

.danger-warning p {
  color: #721c24;
  margin-bottom: 0.5rem;
}

.delete-btn {
  background: #dc3545;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  transition: background 0.2s;
  white-space: nowrap;
}

.delete-btn:hover:not(:disabled) {
  background: #c82333;
}

.delete-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

/* Delete Modal Styles */
.modal-warning {
  color: #721c24;
  font-weight: 600;
}

.modal-list {
  color: #721c24;
  margin: 0.5rem 0 1.5rem 0;
  padding-left: 1.5rem;
}

.confirmation-input {
  margin: 1.5rem 0;
}

.confirmation-input label {
  display: block;
  margin-bottom: 0.5rem;
  color: #333;
  font-weight: 500;
}

.delete-input {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #dc3545;
  border-radius: 6px;
  font-size: 1rem;
  background: #fff5f5;
}

.delete-input:focus {
  outline: none;
  border-color: #c82333;
  background: white;
}

.modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
}

.cancel-btn {
  background: #6c757d;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
}

.cancel-btn:hover {
  background: #5a6268;
}

.confirm-delete-btn {
  background: #dc3545;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
}

.confirm-delete-btn:hover:not(:disabled) {
  background: #c82333;
}

.confirm-delete-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
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

/* Domain Settings Styles */
.domain-settings {
  max-width: 800px;
  margin: 0 auto;
}

.domain-info {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 24px;
  margin-bottom: 32px;
}

.current-domain {
  margin-top: 16px;
}

.domain-display {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.domain-url {
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
}

.domain-status {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
}

.domain-status.active {
  background: #d4edda;
  color: #155724;
}

.domain-status.pending {
  background: #fff3cd;
  color: #856404;
}

.domain-status.error {
  background: #f8d7da;
  color: #721c24;
}

.domain-note {
  color: #6c757d;
  margin: 0;
}

.domain-form {
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 24px;
  margin-bottom: 32px;
}

.domain-form h3 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #2c3e50;
}

.domain-input-group {
  position: relative;
  display: flex;
  align-items: center;
}

.domain-input {
  flex: 1;
  padding-right: 60px;
}

.domain-suffix {
  position: absolute;
  right: 12px;
  color: #6c757d;
  font-weight: 500;
  pointer-events: none;
}

.form-help {
  color: #6c757d;
  font-size: 14px;
  margin-top: 4px;
  display: block;
}

.domain-requirements {
  background: #fff3cd;
  border: 1px solid #ffeaa7;
  border-radius: 6px;
  padding: 16px;
  margin: 20px 0;
}

.domain-requirements h4 {
  margin-top: 0;
  margin-bottom: 12px;
  color: #856404;
}

.domain-requirements ul {
  margin: 0;
  padding-left: 20px;
  color: #856404;
}

.domain-requirements li {
  margin-bottom: 6px;
}

.domain-actions {
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 24px;
}

.domain-actions h3 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #2c3e50;
}

.domain-actions-content {
  display: grid;
  gap: 24px;
}

.action-item {
  padding: 20px;
  border: 1px solid #e9ecef;
  border-radius: 6px;
  background: #f8f9fa;
}

.action-item h4 {
  margin-top: 0;
  margin-bottom: 12px;
  color: #2c3e50;
}

.action-item p {
  color: #6c757d;
  margin-bottom: 16px;
}

.dns-settings {
  background: white;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 16px;
  margin-bottom: 16px;
}

.dns-record {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f1f3f4;
}

.dns-record:last-child {
  border-bottom: none;
}

.dns-record strong {
  color: #495057;
  min-width: 80px;
}

.dns-note {
  background: #e3f2fd;
  border: 1px solid #bbdefb;
  border-radius: 6px;
  padding: 12px;
  margin-top: 12px;
  color: #1565c0;
  font-size: 14px;
  line-height: 1.4;
}

.remove-domain-btn {
  background: #dc3545;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.2s;
}

.remove-domain-btn:hover {
  background: #c82333;
}

.remove-domain-btn:disabled {
  background: #6c757d;
  cursor: not-allowed;
}

/* Responsive Design for Domain Settings */
@media (max-width: 768px) {
  .domain-settings {
    padding: 0 16px;
  }
  
  .domain-info,
  .domain-form,
  .domain-actions {
    padding: 16px;
  }
  
  .domain-display {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  
  .dns-record {
    flex-direction: column;
    gap: 4px;
  }
  
  .dns-record strong {
    min-width: auto;
  }
}
</style> 