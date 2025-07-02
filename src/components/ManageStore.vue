<template>
  <div class="manage-store-wrapper">
    <div class="manage-store-content">
      <div class="header-actions">
        <button class="back-btn" @click="goBack">← Back to Dashboard</button>
      </div>

      <div v-if="!store" class="loading">Loading store information...</div>
      
      <div class="store-header" v-if="store">
        <div class="store-info">
          <h1>{{ store.name }}</h1>
          <p class="store-description">
            {{ store.description && store.description.length > 40 ? store.description.slice(0, 40) + '...' : store.description }}
          </p>
      
          <div v-if="store.currency || store.phone || store.email || store.address" class="store-contact-row">
            <span v-if="store.currency" class="contact-value">{{ store.currency }}</span>
            <span v-if="store.phone" class="contact-value">{{ store.phone }}</span>
            <span v-if="store.email" class="contact-value">{{ store.email }}</span>
            <span v-if="store.address" class="contact-value">{{ store.address }}</span>
            <router-link
              v-if="store.id"
              :to="`/store-owner/manage-store/${store.id}/edit`"
              class="edit-store-chip"
            >
              Edit Store
            </router-link>
          </div>
        </div>

      </div>

      <div class="management-tabs" v-if="store">
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
          All Orders ({{ allOrdersCount }})
        </button>
        <button 
          :class="['tab-btn', { active: activeTab === 'domain' }]" 
          @click="activeTab = 'domain'"
        >
          Domain Settings
        </button>
        <button 
          :class="['tab-btn', { active: activeTab === 'bank-accounts' }]" 
          @click="activeTab = 'bank-accounts'"
        >
          Bank Accounts
        </button>
        <button 
          :class="['tab-btn', { active: activeTab === 'withdrawals' }]" 
          @click="activeTab = 'withdrawals'"
        >
          Withdrawals
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
                <td>
                  {{
                    product.description
                      ? (product.description.split('\n')[0].length > 40
                          ? product.description.split('\n')[0].slice(0, 40) + '...'
                          : product.description.split('\n')[0])
                      : 'No description'
                  }}
                </td>
                <td>{{ formatPrice(product.price) }}</td>
                <td>
                  <span :class="['availability-badge', (product.stock > 0) ? 'available' : 'unavailable']">
                    {{ (product.stock > 0) ? `${product.stock} Available` : 'Out of Stock' }}
                  </span>
                </td>
                <td>
                  <div class="table-actions">
                    <button class="btn-small btn-edit" @click="editProduct(product)">Edit</button>
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
          <h2>All Orders</h2>
          <div class="header-controls">
            <div class="order-filter">
              <label for="order-filter">Filter by Platform:</label>
              <select id="order-filter" v-model="orderFilter" class="filter-select">
                <option value="all">All Orders</option>
                <option value="web">Web Orders</option>
                <option value="mobile">Mobile Orders</option>
              </select>
            </div>
            <div class="order-stats">
              <span class="stat-item">Total: {{ filteredAllOrders.length }}</span>
              <span class="stat-item">Revenue: {{ formatPrice(totalAllOrdersRevenue) }}</span>
            </div>
          </div>
        </div>

        <div v-if="ordersLoading || mobileOrdersLoading" class="loading">Loading orders...</div>
        
        <div v-else-if="filteredAllOrders.length === 0" class="empty-state">
          <p v-if="orderFilter === 'all'">No orders yet for this store.</p>
          <p v-else-if="orderFilter === 'web'">No web orders yet for this store.</p>
          <p v-else>No mobile orders yet for this store.</p>
        </div>

        <div v-else class="orders-table">
          <table>
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Platform</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Total</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in filteredAllOrders" :key="`${order.platform}-${order.id}`">
                <td class="order-id">{{ order.id.substring(0, 8) }}...</td>
                <td>
                  <span :class="['platform-badge', order.platform]">
                    {{ order.platform === 'web' ? 'Web' : 'Mobile' }}
                  </span>
                </td>
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
                  <router-link
                    class="btn-small btn-view"
                    :to="{
                      name: 'OrderDetails',
                      params: {
                        storeId: storeId,
                        orderId: order.id,
                        platform: order.platform
                      }
                    }"
                  >
                    View Details
                  </router-link>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
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
                
                <!-- DNS Status Details -->
                <div v-if="store?.domain && store?.dnsMessage" class="dns-status-details">
                  <div class="dns-message" :class="store.domainStatus">
                    <span class="dns-icon">
                      {{ store.domainStatus === 'active' ? '✅' : store.domainStatus === 'error' ? '❌' : '⏳' }}
                    </span>
                    {{ store.dnsMessage }}
                  </div>
                  <div v-if="store.lastDnsCheck" class="last-check">
                    Last checked: {{ formatDate(store.lastDnsCheck) }}
                  </div>
                </div>
                
                <!-- DNS Records Display -->
                <div v-if="store?.domain && store?.dnsRecords && store.dnsRecords.length > 0" class="dns-records-display">
                  <h4>Current DNS Records:</h4>
                  <div class="dns-records-list">
                    <div v-for="(record, index) in store.dnsRecords" :key="index" class="dns-record-item">
                      <span class="record-type">A</span>
                      <span class="record-value">{{ record.data }}</span>
                      <span :class="['record-status', record.data === getDnsValue() ? 'correct' : 'incorrect']">
                        {{ record.data === getDnsValue() ? '✓ Correct' : '✗ Incorrect' }}
                      </span>
                    </div>
                  </div>
                </div>
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
                    <strong>Type:</strong> A
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
                <button class="btn-secondary" @click="showDnsIpInput" style="margin-left: 10px;">
                  Update DNS IP
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

      <!-- Bank Accounts Tab -->
      <div v-if="activeTab === 'bank-accounts'" class="tab-content">
        <div class="tab-header">
          <h2>Bank Accounts</h2>
          <button 
            class="btn-primary" 
            @click="showAddBankAccountForm = true"
            :disabled="!wiseConfigured"
          >
            Add Bank Account
          </button>
        </div>

        <div v-if="!wiseConfigured" class="error-state">
          <h3>Wise API Not Configured</h3>
          <p>To use withdrawals, you need to configure your Wise API token.</p>
          <p>Please check the WISE_WITHDRAWAL_SETUP.md file for setup instructions.</p>
        </div>

        <div v-else-if="bankAccountsLoading" class="loading">Loading bank accounts...</div>

        <div v-else-if="bankAccounts.length === 0" class="empty-state">
          <p>No bank accounts configured. Add a bank account to enable withdrawals.</p>
        </div>

        <div v-else class="bank-accounts-list">
          <div v-for="account in bankAccounts" :key="account.id" class="bank-account-card">
            <div class="account-info">
              <h4>{{ account.accountHolderName }}</h4>
              <p><strong>Currency:</strong> {{ account.currency }}</p>
              <p><strong>Account Type:</strong> {{ account.type }}</p>
                              <p><strong>Account Number:</strong> ****{{ account.account_number?.slice(-4) }}</p>
                <p><strong>Institution:</strong> {{ account.institution }}</p>
                <p><strong>Transit:</strong> {{ account.transit }}</p>
            </div>
            <div class="account-actions">
              <button class="btn-small btn-delete" @click="deleteBankAccount(account.id)">
                Delete
              </button>
            </div>
          </div>
        </div>

        <!-- Add Bank Account Form Modal -->
        <div v-if="showAddBankAccountForm" class="modal-overlay" @click="cancelAddBankAccount">
          <div class="modal-content" @click.stop>
            <div class="modal-header">
              <h3>Add Bank Account</h3>
              <button class="modal-close" @click="cancelAddBankAccount">&times;</button>
            </div>
            <div class="modal-body">
              <form @submit.prevent="addBankAccount" class="bank-account-form">
                <div class="form-group">
                  <label>Account Holder Name *</label>
                  <input 
                    v-model="bankAccountData.account_holder_name" 
                    type="text" 
                    placeholder="Enter account holder name" 
                    required 
                  />
                </div>

                <div class="form-group">
                  <label>Currency *</label>
                  <select v-model="bankAccountData.currency" required>
                    <option value="USD">USD - US Dollar</option>
                    <option value="EUR">EUR - Euro</option>
                    <option value="GBP">GBP - British Pound</option>
                    <option value="CAD">CAD - Canadian Dollar</option>
                  </select>
                </div>

                <div class="form-group">
                  <label>{{ bankAccountData.currency === 'CAD' ? 'Institution Number *' : 'Bank Name *' }}</label>
                  <input 
                    v-model="bankAccountData.institution" 
                    type="text" 
                    :placeholder="bankAccountData.currency === 'CAD' ? 'e.g. 001 (3 digits)' : 'e.g. Bank of America'" 
                    required 
                  />
                </div>

                <div class="form-group">
                  <label>{{ bankAccountData.currency === 'CAD' ? 'Transit Number *' : 'Routing Number *' }}</label>
                  <input 
                    v-model="bankAccountData.transit" 
                    type="text" 
                    :placeholder="bankAccountData.currency === 'CAD' ? 'e.g. 00040 (5 digits)' : 'e.g. 123456789 (9 digits)'" 
                    required 
                  />
                </div>

                <div class="form-group">
                  <label>Account Number *</label>
                  <input 
                    v-model="bankAccountData.account_number" 
                    type="text" 
                    :placeholder="bankAccountData.currency === 'CAD' ? 'e.g. 1234567 (7-12 digits)' : 'e.g. 123456789012 (4-17 digits)'" 
                    required 
                  />
                </div>

                <div class="form-group">
                  <label>Account Type *</label>
                  <select v-model="bankAccountData.type" required>
                    <option value="checking">Checking</option>
                    <option value="savings">Savings</option>
                  </select>
                </div>

                <button type="submit" class="btn-primary" :disabled="bankAccountsLoading">
                  {{ bankAccountsLoading ? 'Adding Account...' : 'Add Bank Account' }}
                </button>
              </form>
            </div>
          </div>
        </div>
        </div>
      </div>

      <!-- Balance & Withdrawals Tab -->
      <div v-if="activeTab === 'withdrawals'" class="tab-content">
        <div class="tab-header">
          <h2>Withdrawals</h2>
          <button @click="debugCurrency" class="btn-secondary">Debug Currency</button>
        </div>





        <!-- Earnings Summary Section -->
        <div class="earnings-section">
          <h3>Earnings Summary</h3>
          <div class="earnings-cards">
            <div class="earnings-card">
              <div class="earnings-label">Total Earnings</div>
              <div class="earnings-amount">{{ formatPrice(totalEarnings) }}</div>
              <div class="earnings-detail">From {{ completedOrdersCount }} completed orders</div>
            </div>
            <div class="earnings-card">
              <div class="earnings-label">Already Withdrawn</div>
              <div class="earnings-amount">{{ formatPrice(totalWithdrawn) }}</div>
              <div class="earnings-detail">From previous withdrawals</div>
            </div>
            <div class="earnings-card available">
              <div class="earnings-label">Available to Withdraw</div>
              <div class="earnings-amount">{{ formatPrice(availableBalance) }}</div>
              <div class="earnings-detail">{{ store?.currency || 'USD' }} ready for withdrawal</div>
            </div>
          </div>
        </div>

        <!-- Withdrawal Section -->
        <div class="withdrawal-section">
          <h3>Make Withdrawal</h3>
          
          <!-- Subscription Required Notice for Withdrawals Only -->
          <div v-if="!hasActiveSubscription" class="subscription-required">
            <h4>🔒 Subscription Required for Withdrawals</h4>
            
            <!-- Show subscription details -->
            <div class="subscription-details">
              <p><strong>Current Status:</strong> {{ userSubscription?.subscriptionStatus || 'No subscription' }}</p>
              <p v-if="userSubscription?.stripeCustomerId"><strong>Customer ID:</strong> {{ userSubscription.stripeCustomerId }}</p>
              <p v-if="userSubscription?.planId"><strong>Plan:</strong> {{ userSubscription.planId }}</p>
            </div>
            
            <p>Withdrawals are only available with an active subscription.</p>
            <p v-if="userSubscription?.stripeCustomerId" class="sync-note">
              If you have an active subscription but it's not showing here, try syncing your subscription status.
            </p>
            
            <div class="subscription-actions">
              <router-link to="/plans" class="btn-primary">View Plans</router-link>
            </div>
          </div>

          <!-- Withdrawal Form (only show if subscription active) -->
          <form v-else @submit.prevent="createWithdrawal" class="withdrawal-form">
            <div class="withdrawal-info">
              <p><strong>Withdrawal Amount:</strong> {{ formatPrice(availableBalance) }} ({{ store?.currency || 'USD' }})</p>
              <p class="info-text" v-if="!hasWithdrawnAll">This will withdraw your complete available balance.</p>
              <p class="info-text warning" v-else>You have already withdrawn all available funds.</p>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label>Bank Account *</label>
                <select v-model="withdrawalData.target_account" required>
                  <option value="">Select bank account</option>
                  <option v-for="account in bankAccounts" :key="account.id" :value="account.id">
                    {{ account.account_holder_name }} - {{ account.currency }} (****{{ account.account_number?.slice(-4) }})
                  </option>
                </select>
              </div>
            </div>

            <button type="submit" class="btn-primary" :disabled="withdrawalLoading || !withdrawalData.target_account || hasWithdrawnAll">
              {{ withdrawalLoading ? 'Processing Withdrawal...' : hasWithdrawnAll ? 'No Funds Available' : `Withdraw ${formatPrice(availableBalance)}` }}
            </button>
          </form>
        </div>

        <!-- Transactions History -->
        <div class="transactions-section">
          <h3>Transaction History</h3>
          <div v-if="transfersLoading" class="loading">Loading transactions...</div>
          <div v-else-if="transfers.length === 0" class="empty-state">
            <p>No transactions yet.</p>
          </div>
          <div v-else class="transactions-table">
            <table>
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Reference</th>
                  <th>Amount</th>
                  <th>Status</th>
                  <th>Target Account</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="transfer in transfers" :key="transfer.id">
                  <td>{{ formatDate(transfer.createdAt) }}</td>
                  <td>{{ transfer.reference || transfer.id }}</td>
                  <td>{{ formatPrice(transfer.amount, transfer.currency) }}</td>
                  <td>
                    <span :class="['transfer-status', (transfer.status || 'processing').toLowerCase()]">
                      {{ transfer.status || 'Processing' }}
                    </span>
                  </td>
                  <td>{{ transfer.bank_account ? transfer.bank_account.account_holder_name : 'Unknown' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    <!-- Edit Product Modal -->
    <div v-if="showEditProductModal" class="modal-overlay" @click="closeEditProductModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>Edit Product</h3>
          <button class="modal-close" @click="closeEditProductModal">&times;</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="updateProduct" class="product-form" v-if="editingProduct">
            <div class="form-group">
              <label>Product Name *</label>
              <input 
                v-model="editingProduct.name" 
                type="text" 
                placeholder="Enter product name" 
                required 
              />
            </div>

            <div class="form-group">
              <label>Description</label>
              <textarea 
                v-model="editingProduct.description" 
                placeholder="Product description"
                rows="3"
              ></textarea>
            </div>

            <div class="form-group">
              <label>Price *</label>
              <input 
                v-model="editingProduct.price" 
                type="number" 
                step="0.01" 
                min="0"
                placeholder="0.00" 
                required 
              />
            </div>

            <div class="form-group">
              <label>Stock Quantity *</label>
              <input 
                v-model="editingProduct.stock" 
                type="number" 
                min="0"
                placeholder="0" 
                required 
              />
            </div>

            <div class="form-group">
              <label>Product Images</label>
              <div class="images-section">
                <input 
                  type="file" 
                  accept="image/*" 
                  @change="onImagesChange"
                  ref="imagesInput"
                  multiple
                  style="display:none;"
                />
                <button type="button" class="add-image-ghost-btn" @click="$refs.imagesInput.click()" title="Add Image">
                  <i class="fa fa-plus"></i>
                </button>
                <div class="images-row">
                  <div v-for="(img, idx) in editingProduct.images" :key="img" class="image-thumb-wrapper">
                    <img :src="img" class="image-thumb" :class="{ hero: idx === 0 }" :alt="`Product image ${idx+1}`" />
                    <span v-if="idx === 0" class="hero-badge">Hero</span>
                    <button type="button" class="btn-remove" @click="removeImage(idx)" title="Remove image">×</button>
                  </div>
                </div>
                <div v-if="uploadingImages" class="uploading-overlay">
                  <div class="spinner large"></div>
                </div>
              </div>
              <small>First image is the main (hero) image. You can remove images before saving.</small>
            </div>

            <div class="modal-actions">
              <button type="button" class="btn-secondary" @click="closeEditProductModal">Cancel</button>
              <button type="submit" class="btn-primary" :disabled="productLoading">
                {{ productLoading ? 'Updating...' : 'Update Product' }}
              </button>
              <button type="button" class="btn-delete" @click="confirmDeleteProduct" :disabled="productLoading">
                Delete Product
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Delete Product Confirmation Modal -->
    <div v-if="showDeleteProductConfirmation" class="modal-overlay" @click="cancelDeleteProduct">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>Delete Product</h3>
          <button class="modal-close" @click="cancelDeleteProduct">&times;</button>
        </div>
        <div class="modal-body">
          <p>Are you sure you want to delete <strong>"{{ editingProduct?.name }}"</strong>?</p>
          <p class="modal-warning">This action cannot be undone.</p>
          <div class="modal-actions">
            <button class="btn-secondary" @click="cancelDeleteProduct">Cancel</button>
            <button 
              class="btn-delete" 
              @click="deleteProduct"
              :disabled="productLoading"
            >
              {{ productLoading ? 'Deleting...' : 'Delete Product' }}
            </button>
          </div>
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
        currency: 'USD',
        email: '',
        phone: '',
        address: '',
        isActive: true,
        deliveryFee: 0
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
      showRemoveDomainConfirmation: false,
      // Bank account data
      bankAccounts: [],
      wiseConfigured: false,
      bankAccountData: {
        account_holder_name: '',
        currency: 'USD',
        institution: '',
        transit: '',
        account_number: '',
        type: 'checking'
      },
      withdrawalData: {
        amount: '',
        target_account: '',
        currency: ''
      },
      transfers: [],
      transfersLoading: false,
      bankAccountsLoading: false,
      withdrawalLoading: false,
      showAddBankAccountForm: false,
      // Subscription data
      currentUser: null,
      userSubscription: null,
      hasActiveSubscription: false,
      subscriptionLoading: true,
      // Orders filter
      orderFilter: 'all', // 'all', 'web', 'mobile'
      // Edit product modal
      showEditProductModal: false,
      showDeleteProductConfirmation: false,
      editingProduct: null,
      uploadingImages: false,
      uploadingImageIndexes: [],
      newImages: [],
      productLoading: false,
      heroImagePreview: null,
      heroImageFile: null,
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
    },
    filteredOrders() {
      return this.orders.filter(order => order.status !== 'pending');
    },
    totalEarnings() {
      return this.storeRevenue + this.mobileStoreRevenue;
    },
    totalWithdrawn() {
      return this.transfers
        .filter(transfer => 
          transfer.status === 'completed' || 
          transfer.status === 'outgoing_payment_sent' || 
          transfer.status === 'charged' ||
          transfer.status === 'processing' ||
          transfer.status === 'incoming_payment_waiting' ||
          transfer.status === 'funds_converted'
        )
        .reduce((total, transfer) => total + (parseFloat(transfer.amount) || 0), 0);
    },
    availableBalance() {
      return Math.max(0, this.totalEarnings - this.totalWithdrawn);
    },
    hasWithdrawnAll() {
      return this.availableBalance <= 0;
    },
    completedOrdersCount() {
      return this.filteredOrders.length;
    },
    completedWebOrdersCount() {
      return this.filteredOrders.filter(order => !order.platform || order.platform === 'web').length;
    },
    completedMobileOrdersCount() {
      return this.filteredOrders.filter(order => order.platform === 'mobile').length;
    },
    completedWebOrdersCount() {
      return this.orders.filter(order => order.status === 'completed').length;
    },
    completedMobileOrdersCount() {
      return this.mobileOrders.filter(order => order.status === 'completed').length;
    },
    // Combined orders functionality
    allOrders() {
      // Combine web and mobile orders with platform identifier
      const webOrders = this.orders.map(order => ({
        ...order,
        platform: 'web'
      }));
      const mobileOrders = this.mobileOrders.map(order => ({
        ...order,
        platform: 'mobile'
      }));
      
      // Combine and sort by timestamp (newest first)
      return [...webOrders, ...mobileOrders].sort((a, b) => {
        const timeA = a.timestamp?.toDate ? a.timestamp.toDate() : new Date(a.timestamp);
        const timeB = b.timestamp?.toDate ? b.timestamp.toDate() : new Date(b.timestamp);
        return timeB - timeA;
      });
    },
    filteredAllOrders() {
      // Filter out pending orders first
      const nonPendingOrders = this.allOrders.filter(order => order.status !== 'pending');
      
      // Then apply platform filter
      if (this.orderFilter === 'web') {
        return nonPendingOrders.filter(order => order.platform === 'web');
      } else if (this.orderFilter === 'mobile') {
        return nonPendingOrders.filter(order => order.platform === 'mobile');
      }
      return nonPendingOrders;
    },
    allOrdersCount() {
      return this.filteredAllOrders.length;
    },
    totalAllOrdersRevenue() {
      return this.filteredAllOrders
        .filter(order => order.status === 'completed')
        .reduce((total, order) => total + (parseFloat(order.total) || 0), 0);
    }
  },
  async mounted() {
    this.storeId = this.$route.params.storeId
    
    auth.onAuthStateChanged(async (user) => {
      if (user) {
        this.currentUser = user
        await this.fetchUserSubscription()
        await this.fetchStore()
        await this.fetchProducts()
        await this.fetchOrders()
        await this.fetchMobileOrders()
        await this.fetchBankAccounts()
        await this.fetchTransfers()
        await this.checkWiseAuth()
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
            currency: this.store.currency || 'USD',
            email: this.store.email,
            phone: this.store.phone,
            address: this.store.address,
            isActive: this.store.isActive,
            deliveryFee: this.store.deliveryFee || 0
          }
          this.currentImage = this.store.image
          
          // Populate domain data if it exists
          if (this.store.domain) {
            this.domainData.domain = this.store.domain
            this.domainData.includeWww = this.store.includeWww || false
          }
          
          // Set withdrawal currency to store currency
          if (!this.withdrawalData.currency) {
            this.withdrawalData.currency = this.store.currency || 'USD'
          }
        }
      } catch (error) {
        console.error('Error fetching store:', error)
      }
    },

    async fetchUserSubscription() {
      this.subscriptionLoading = true
      try {
        const userDoc = await db.collection('storeOwners').doc(this.currentUser.uid).get()
        if (userDoc.exists) {
          const userData = userDoc.data()
          this.userSubscription = {
            stripeCustomerId: userData.stripeCustomerId || '',
            subscriptionStatus: userData.subscriptionStatus || 'inactive',
            planId: userData.planId || '',
            subscriptionId: userData.subscriptionId || ''
          }
          
          // Check if user has active subscription
          this.hasActiveSubscription = userData.subscriptionStatus === 'active'
          
          // If we have a customer ID but no active subscription, try to sync with Stripe
          if (userData.stripeCustomerId && !this.hasActiveSubscription) {
            console.log('Subscription not active in Firebase, checking Stripe...')
            await this.syncSubscriptionWithStripe(userData.stripeCustomerId)
          }
        } else {
          this.hasActiveSubscription = false
        }
      } catch (error) {
        console.error('Error fetching user subscription:', error)
        this.hasActiveSubscription = false
      } finally {
        this.subscriptionLoading = false
      }
    },

    async syncSubscriptionWithStripe(customerId) {
      this.subscriptionLoading = true
      try {
        console.log('Syncing subscription status with Stripe for customer:', customerId)
        
        const response = await fetch('https://pay.theholylabs.com/check-subscription-status', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            customer_id: customerId
          })
        })
        
        if (response.ok) {
          const data = await response.json()
          console.log('Stripe subscription data:', data)
          
          if (data.hasActiveSubscription) {
            // Prepare update data, filtering out undefined values
            const updateData = {
              subscriptionStatus: 'active',
              lastSyncedAt: new Date()
            }

            // Only add fields if they have valid values
            if (data.planId) {
              updateData.planId = data.planId
            }

            if (data.subscriptionId) {
              updateData.subscriptionId = data.subscriptionId
            }

            if (data.planName) {
              updateData.planName = data.planName
            }

            // Update Firebase with the correct subscription status
            await db.collection('storeOwners').doc(this.currentUser.uid).update(updateData)
            
            // Update local state
            this.hasActiveSubscription = true
            this.userSubscription.subscriptionStatus = 'active'
            this.userSubscription.planId = data.planId || ''
            this.userSubscription.subscriptionId = data.subscriptionId || ''
            
            this.showMessage('✅ Subscription status updated! You can now make withdrawals.', 'success')
            console.log('Subscription status synced successfully!')
          } else {
            // Update Firebase to reflect no active subscription
            await db.collection('storeOwners').doc(this.currentUser.uid).update({
              subscriptionStatus: 'inactive',
              lastSyncedAt: new Date()
            })
            
            this.hasActiveSubscription = false
            this.userSubscription.subscriptionStatus = 'inactive'
            this.showMessage('No active subscription found in Stripe. Please subscribe to enable withdrawals.', 'warning')
          }
        } else {
          const errorData = await response.json()
          console.warn('Failed to sync with Stripe:', errorData)
          this.showMessage(`Failed to sync subscription: ${errorData.error || response.statusText}`, 'error')
        }
      } catch (error) {
        console.error('Error syncing subscription with Stripe:', error)
        this.showMessage('Error syncing subscription status. Please try again.', 'error')
      } finally {
        this.subscriptionLoading = false
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

    editProduct(product) {
      this.editingProduct = {
        ...product,
        images: product.images || (product.image ? [product.image] : [])
      }
      this.newImages = []
      this.showEditProductModal = true
    },

    closeEditProductModal() {
      this.showEditProductModal = false
      this.editingProduct = null
      this.newImages = []
    },

    onImagesChange(event) {
      const files = Array.from(event.target.files)
      if (!files.length) return
      this.autoUploadImages(files)
      // Clear the input so the same file can be selected again if needed
      this.$refs.imagesInput.value = ''
    },

    async autoUploadImages(files) {
      try {
        this.uploadingImages = true
        const { storage } = await import('../../firebase')
        for (const file of files) {
          const fileName = `product-images/${this.storeId}/${Date.now()}_${file.name}`
          const storageRef = storage.ref().child(fileName)
          const snapshot = await storageRef.put(file)
          const url = await snapshot.ref.getDownloadURL()
          if (!this.editingProduct.images) this.editingProduct.images = []
          this.editingProduct.images.push(url)
        }
      } catch (e) {
        console.error('Error auto-uploading images:', e)
        this.showMessage('Failed to upload image. Please try again.', 'error')
      } finally {
        this.uploadingImages = false
      }
    },

    removeImage(idx) {
      this.editingProduct.images.splice(idx, 1)
    },

    removeNewImage(idx) {
      this.newImages.splice(idx, 1)
    },

    async updateProduct() {
      this.productLoading = true
      try {
        // Upload new images if any
        let newImageUrls = []
        if (this.newImages.length > 0) {
          newImageUrls = await this.uploadImages()
        }
        // Merge existing and new
        const images = [...(this.editingProduct.images || []), ...newImageUrls]
        const updateData = {
          name: this.editingProduct.name,
          description: this.editingProduct.description || '',
          price: parseFloat(this.editingProduct.price),
          stock: parseInt(this.editingProduct.stock),
          images,
          updatedAt: new Date()
        }
        await db.collection('stores')
          .doc(this.storeId)
          .collection('products')
          .doc(this.editingProduct.id)
          .update(updateData)
        this.showMessage('Product updated successfully!', 'success')
        this.closeEditProductModal()
        await this.fetchProducts()
      } catch (error) {
        console.error('Error updating product:', error)
        this.showMessage('Failed to update product. Please try again.', 'error')
      } finally {
        this.productLoading = false
      }
    },

    async uploadImages() {
      if (!this.newImages.length) return []
      try {
        const { storage } = await import('../../firebase')
        const uploadPromises = this.newImages.map(imgObj => {
          const fileName = `product-images/${this.storeId}/${Date.now()}_${imgObj.file.name}`
          const storageRef = storage.ref().child(fileName)
          return storageRef.put(imgObj.file).then(snap => snap.ref.getDownloadURL())
        })
        return await Promise.all(uploadPromises)
      } catch (e) {
        console.error('Error uploading images:', e)
        throw e
      }
    },

    confirmDeleteProduct() {
      this.showDeleteProductConfirmation = true
    },

    cancelDeleteProduct() {
      this.showDeleteProductConfirmation = false
    },

    async deleteProduct() {
      this.productLoading = true
      try {
        await db.collection('stores')
          .doc(this.storeId)
          .collection('products')
          .doc(this.editingProduct.id)
          .delete()

        this.showMessage('Product deleted successfully!', 'success')
        this.cancelDeleteProduct()
        this.closeEditProductModal()
        await this.fetchProducts()

      } catch (error) {
        console.error('Error deleting product:', error)
        this.showMessage('Failed to delete product. Please try again.', 'error')
      } finally {
        this.productLoading = false
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
      return symbols[currency?.toUpperCase()] || '$'
    },

    formatPrice(price) {
      const currency = this.store?.currency || 'USD'
      const symbol = this.getCurrencySymbol(currency)
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
        // Check if environment variables are set
        const apiToken = import.meta.env.VITE_VERCEL_API_TOKEN
        const projectId = import.meta.env.VITE_VERCEL_PROJECT_ID
        
        if (!apiToken) {
          this.showMessage('Vercel API token not configured. Please set VITE_VERCEL_API_TOKEN environment variable.', 'error')
          return
        }
        
        if (!projectId) {
          this.showMessage('Vercel Project ID not configured. Please set VITE_VERCEL_PROJECT_ID environment variable.', 'error')
          return
        }

        // Validate domain format
        if (!this.domainData.domain || !this.domainData.domain.includes('.')) {
          this.showMessage('Please enter a valid domain name (e.g., yourstore.com)', 'error')
          return
        }

        console.log('Adding domain to Vercel:', {
          name: this.domainData.domain,
          projectId: projectId
        })

        // Use the project-specific domains endpoint
        const vercelResponse = await fetch(`https://api.vercel.com/v1/projects/${projectId}/domains`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${apiToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            name: this.domainData.domain
          })
        })

        if (!vercelResponse.ok) {
          const errorText = await vercelResponse.text()
          console.error('Vercel API Error Response:', errorText)
          
          let errorMessage = 'Unknown error'
          try {
            const error = JSON.parse(errorText)
            errorMessage = error.error?.message || error.message || errorText
          } catch (e) {
            errorMessage = errorText
          }
          
          this.showMessage(`Failed to add domain: ${errorMessage}`, 'error')
          return
        }

        const vercelResult = await vercelResponse.json()
        console.log('Vercel API Success Response:', vercelResult)
        console.log('Vercel Result ID:', vercelResult.id)
        console.log('Vercel Result Keys:', Object.keys(vercelResult))

        // Update store with domain info
        const updateData = {
          domain: this.domainData.domain,
          includeWww: this.domainData.includeWww,
          domainStatus: 'pending',
          domainUpdatedAt: new Date()
        }

        // Only add vercelDomainId if it exists in the response
        if (vercelResult.id) {
          updateData.vercelDomainId = vercelResult.id
        } else {
          console.warn('No ID found in Vercel response, skipping vercelDomainId')
        }

        await db.collection('stores').doc(this.storeId).update(updateData)

        this.showMessage('Domain added successfully! Please configure your DNS settings.', 'success')
        await this.fetchStore()
        
        // Reset form
        this.domainData.domain = ''
        this.domainData.includeWww = false

      } catch (error) {
        console.error('Error adding domain:', error)
        this.showMessage(`Failed to add domain: ${error.message}`, 'error')
      } finally {
        this.domainLoading = false
      }
    },

    getDnsValue() {
      // Use the IP address Vercel provided, with fallback to default
      return this.store?.vercelDnsIp || '216.198.79.193'
    },

    // Add method to get CNAME value
    getCnameValue() {
      return this.store?.vercelCname || 'cname.vercel-dns.com'
    },

    // Add method to manually update DNS IP
    async updateDnsIp(newIp) {
      if (!newIp || !newIp.match(/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/)) {
        this.showMessage('Please enter a valid IP address (e.g., 216.198.79.193)', 'error')
        return
      }
      try {
        const updateData = {
          vercelDnsIp: newIp,
          lastDnsConfigFetch: new Date()
        }
        await db.collection('stores').doc(this.storeId).update(updateData)
        await this.fetchStore()
        this.showMessage(`DNS IP updated to ${newIp}!`, 'success')
      } catch (error) {
        console.error('Error updating DNS IP:', error)
        this.showMessage('Failed to update DNS IP.', 'error')
      }
    },

    // Method to manually input DNS IP
    showDnsIpInput() {
      const newIp = prompt('Enter the DNS IP address from Vercel:', this.store?.vercelDnsIp || '216.198.79.193')
      if (newIp) {
        this.updateDnsIp(newIp)
      }
    },

    async checkDnsStatus() {
      if (!this.store?.domain) {
        this.showMessage('No domain configured for this store.', 'error')
        return
      }

      this.domainLoading = true
      this.showMessage('Checking DNS status...', 'info')

      try {
        const apiToken = import.meta.env.VITE_VERCEL_API_TOKEN
        if (!apiToken) {
          this.showMessage('Vercel API token not configured. Please set VITE_VERCEL_API_TOKEN environment variable.', 'error')
          return
        }

        const projectId = import.meta.env.VITE_VERCEL_PROJECT_ID
        if (!projectId) {
          this.showMessage('Vercel Project ID not configured. Please set VITE_VERCEL_PROJECT_ID environment variable.', 'error')
          return
        }

        // First, check if domain exists in Vercel project
        const vercelResponse = await fetch(`https://api.vercel.com/v1/projects/${projectId}/domains/${this.store.domain}`, {
          headers: {
            'Authorization': `Bearer ${apiToken}`,
          }
        })

        if (!vercelResponse.ok) {
          const errorText = await vercelResponse.text()
          console.error('Vercel API Error Response:', errorText)
          this.showMessage('Domain not found in Vercel. Please add the domain first.', 'error')
          return
        }

        const vercelResult = await vercelResponse.json()
        
        // Check DNS propagation using a DNS lookup service
        const dnsCheckResponse = await fetch(`https://dns.google/resolve?name=${this.store.domain}&type=A`)
        const dnsResult = await dnsCheckResponse.json()
        
        let dnsStatus = 'pending'
        let dnsMessage = ''
        
        if (dnsResult.Answer && dnsResult.Answer.length > 0) {
          const dnsRecords = dnsResult.Answer.map(record => record.data)
          const expectedIP = this.getDnsValue()
          
          if (dnsRecords.includes(expectedIP)) {
            dnsStatus = 'active'
            dnsMessage = 'DNS is properly configured and propagated!'
          } else {
            dnsStatus = 'error'
            dnsMessage = `DNS records found but pointing to wrong IP. Expected: ${expectedIP}, Found: ${dnsRecords.join(', ')}`
          }
        } else {
          dnsStatus = 'pending'
          dnsMessage = 'DNS records not found. Please wait for propagation or check your DNS settings.'
        }

        // Update store with comprehensive status
        const updateData = {
          domainStatus: dnsStatus,
          vercelDomainStatus: vercelResult.verification?.status || 'pending',
          lastDnsCheck: new Date(),
          dnsRecords: dnsResult.Answer || [],
          dnsMessage: dnsMessage
        }

        await db.collection('stores').doc(this.storeId).update(updateData)
        await this.fetchStore()
        
        // Show appropriate message based on status
        if (dnsStatus === 'active') {
          this.showMessage('✅ Domain is properly configured and active!', 'success')
        } else if (dnsStatus === 'error') {
          this.showMessage(`❌ ${dnsMessage}`, 'error')
        } else {
          this.showMessage(`⏳ ${dnsMessage}`, 'warning')
        }

      } catch (error) {
        console.error('Error checking DNS status:', error)
        this.showMessage('Failed to check DNS status. Please try again.', 'error')
      } finally {
        this.domainLoading = false
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
        const apiToken = import.meta.env.VITE_VERCEL_API_TOKEN
        if (!apiToken) {
          this.showMessage('Vercel API token not configured. Please set VITE_VERCEL_API_TOKEN environment variable.', 'error')
          return
        }

        const projectId = import.meta.env.VITE_VERCEL_PROJECT_ID
        if (!projectId) {
          this.showMessage('Vercel Project ID not configured. Please set VITE_VERCEL_PROJECT_ID environment variable.', 'error')
          return
        }

        // Remove domain from Vercel project
        if (this.store?.domain) {
          const response = await fetch(`https://api.vercel.com/v1/projects/${projectId}/domains/${this.store.domain}`, {
            method: 'DELETE',
            headers: {
              'Authorization': `Bearer ${apiToken}`,
            }
          })

          if (!response.ok) {
            const errorText = await response.text()
            console.warn('Failed to remove domain from Vercel:', errorText)
          }
        }

        // Update store
        const updateData = {
          domain: null,
          includeWww: false,
          domainStatus: null,
          vercelDomainId: null,
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
    },

    // Debug method to check environment variables (remove in production)
    debugEnvironment() {
      const apiToken = import.meta.env.VITE_VERCEL_API_TOKEN
      const projectId = import.meta.env.VITE_VERCEL_PROJECT_ID
      
      console.log('Environment Variables Check:')
      console.log('VITE_VERCEL_API_TOKEN:', apiToken ? 'Set' : 'Not set')
      console.log('VITE_VERCEL_PROJECT_ID:', projectId ? `Set (${projectId})` : 'Not set')
      
      if (!apiToken || !projectId) {
        this.showMessage('Environment variables not configured. Check DOMAIN_SETUP.md for setup instructions.', 'error')
      } else {
        this.showMessage('Environment variables are configured correctly.', 'success')
      }
    },

    async fetchBankAccounts() {
      this.bankAccountsLoading = true
      try {
        const querySnapshot = await db.collection('stores').doc(this.storeId).collection('bankAccounts').get()
        this.bankAccounts = []
        
        querySnapshot.forEach((doc) => {
          this.bankAccounts.push({
            id: doc.id,
            ...doc.data()
          })
        })
        
      } catch (error) {
        console.error('Error fetching bank accounts:', error)
        this.showMessage('Failed to load bank accounts.', 'error')
      } finally {
        this.bankAccountsLoading = false
      }
    },

    async fetchBalance() {
      // Balance is now calculated from totalEarnings, no API call needed
      this.showMessage('Balance updated from order totals.', 'info')
    },

    async checkWiseAuth() {
      try {
        const response = await fetch('https://pay.theholylabs.com/wise/auth', {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json'
          }
        })
        
        if (response.ok) {
          this.wiseConfigured = true
        } else {
          this.wiseConfigured = false
        }
      } catch (error) {
        console.error('Error checking Wise auth:', error)
        this.wiseConfigured = false
      }
    },

    async fetchTransfers() {
      this.transfersLoading = true
      try {
        const querySnapshot = await db.collection('stores').doc(this.storeId).collection('withdrawals')
          .orderBy('createdAt', 'desc')
          .get()
        
        this.transfers = []
        
        querySnapshot.forEach((doc) => {
          this.transfers.push({
            id: doc.id,
            ...doc.data()
          })
        })
        
      } catch (error) {
        console.error('Error fetching transfers:', error)
        this.showMessage('Failed to load transaction history.', 'error')
      } finally {
        this.transfersLoading = false
      }
    },

    async addBankAccount() {
      this.bankAccountsLoading = true
      try {
        const bankAccountDoc = {
          ...this.bankAccountData,
          createdAt: new Date(),
          storeId: this.storeId
        }

        await db.collection('stores').doc(this.storeId).collection('bankAccounts').add(bankAccountDoc)
        
        this.showMessage('Bank account added successfully!', 'success')
        this.showAddBankAccountForm = false
        this.resetBankAccountForm()
        await this.fetchBankAccounts()
        
      } catch (error) {
        console.error('Error adding bank account:', error)
        this.showMessage(`Failed to add bank account: ${error.message}`, 'error')
      } finally {
        this.bankAccountsLoading = false
      }
    },

    async createWithdrawal() {
      this.withdrawalLoading = true
      try {
        // Check Wise auth before proceeding
        await this.checkWiseAuth()
        if (!this.wiseConfigured) {
          throw new Error('Wise API is not configured. Please check your API token.')
        }

        // Get the selected bank account
        const selectedBankAccount = this.bankAccounts.find(acc => acc.id === this.withdrawalData.target_account)
        if (!selectedBankAccount) {
          throw new Error('Selected bank account not found')
        }

        // Single API call to create withdrawal with bank account details
        const withdrawalAmount = this.availableBalance
        const withdrawalCurrency = this.store?.currency || 'USD'
        
        const response = await fetch('https://pay.theholylabs.com/wise/withdrawal', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            amount: parseFloat(withdrawalAmount),
            currency: withdrawalCurrency,
            bank_account: {
              account_holder_name: selectedBankAccount.account_holder_name,
              currency: selectedBankAccount.currency,
              institution: selectedBankAccount.institution,
              transit: selectedBankAccount.transit,
              account_number: selectedBankAccount.account_number,
              type: selectedBankAccount.type
            },
            store_id: this.storeId,
            reference: `Withdrawal from ${this.store.name} - ${new Date().toISOString()}`
          })
        })
        
        const data = await response.json()
        
        if (!response.ok) {
          throw new Error(data.error || 'Failed to create withdrawal')
        }

        // Save withdrawal record to Firebase
        const withdrawalRecord = {
          amount: parseFloat(withdrawalAmount),
          currency: withdrawalCurrency,
          bank_account: selectedBankAccount,
          reference: `Withdrawal from ${this.store.name} - ${new Date().toISOString()}`,
          status: 'processing',
          wise_transfer_id: data.transfer?.id,
          wise_recipient_id: data.recipient?.id,
          createdAt: new Date(),
          storeId: this.storeId
        }

        await db.collection('stores').doc(this.storeId).collection('withdrawals').add(withdrawalRecord)

        this.showMessage('Withdrawal created successfully!', 'success')
        this.resetWithdrawalForm()
        await this.fetchTransfers()
        
      } catch (error) {
        console.error('Error creating withdrawal:', error)
        this.showMessage(`Failed to create withdrawal: ${error.message}`, 'error')
      } finally {
        this.withdrawalLoading = false
      }
    },



    cancelAddBankAccount() {
      this.showAddBankAccountForm = false
      this.resetBankAccountForm()
    },

    resetBankAccountForm() {
      this.bankAccountData = {
        account_holder_name: '',
        currency: 'USD',
        institution: '',
        transit: '',
        account_number: '',
        type: 'checking'
      }
    },

    resetWithdrawalForm() {
      this.withdrawalData = {
        target_account: ''
      }
    },

    async deleteBankAccount(accountId) {
      if (confirm('Are you sure you want to delete this bank account?')) {
        try {
          await db.collection('stores').doc(this.storeId).collection('bankAccounts').doc(accountId).delete()
          this.showMessage('Bank account deleted successfully!', 'success')
          await this.fetchBankAccounts()
        } catch (error) {
          console.error('Error deleting bank account:', error)
          this.showMessage('Failed to delete bank account.', 'error')
        }
      }
    },

    getAccountName(accountId) {
      const account = this.bankAccounts.find(acc => acc.id === accountId)
      return account ? `${account.account_holder_name} (****${account.account_number?.slice(-4)})` : 'Unknown Account'
    },

    formatPrice(amount, currency) {
      const currencyToUse = currency || this.store?.currency || 'USD'
      const symbol = this.getCurrencySymbol(currencyToUse)
      if (!amount) return `${symbol}0.00`
      return `${symbol}${parseFloat(amount).toFixed(2)}`
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

    debugCurrency() {
      console.log('=== CURRENCY DEBUG ===')
      console.log('Store object:', this.store)
      console.log('Store currency:', this.store?.currency)
      console.log('Store data currency:', this.storeData?.currency)
      console.log('Test ZAR symbol:', this.getCurrencySymbol('ZAR'))
      console.log('Test ILS symbol:', this.getCurrencySymbol('ILS'))
      console.log('Current formatPrice result:', this.formatPrice(100))
      alert(`Store Currency: ${this.store?.currency}\nZAR Symbol: ${this.getCurrencySymbol('ZAR')}\nILS Symbol: ${this.getCurrencySymbol('ILS')}\nFormatPrice(100): ${this.formatPrice(100)}`)
    },

    onHeroImageChange(event) {
      const file = event.target.files[0]
      if (file) {
        this.heroImagePreview = URL.createObjectURL(file)
      }
    },

    onAdditionalImageChange(event) {
      const files = event.target.files
      this.newAdditionalImages = Array.from(files).map(file => ({
        preview: URL.createObjectURL(file)
      }))
    },

    removeCurrentAdditionalImage(index) {
      this.editingProduct.additionalImages.splice(index, 1)
    },

    removeNewAdditionalImage(index) {
      this.newAdditionalImages.splice(index, 1)
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

.store-phone {
  margin-top: 0.5rem;
  display: flex;
  align-items: center;
}

.store-phone .currency-label {
  margin-right: 0.5rem;
}

.store-phone .currency-value {
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

.error-state {
  text-align: center;
  padding: 2rem;
  background: #fff3cd;
  border: 1px solid #ffeaa7;
  border-radius: 8px;
  color: #856404;
}

.error-state h3 {
  margin: 0 0 1rem 0;
  color: #856404;
}

.error-state p {
  margin: 0.5rem 0;
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

.btn-edit {
  background: #2196f3;
  color: white;
}

.btn-edit:hover {
  background: #1976d2;
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

.header-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 2rem;
  flex-wrap: wrap;
}

.order-filter {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.order-filter label {
  font-weight: 500;
  color: #333;
}

.filter-select {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
  font-size: 0.9rem;
  min-width: 120px;
}

.filter-select:focus {
  outline: none;
  border-color: #4CAF50;
}

.order-stats {
  display: flex;
  gap: 1rem;
}

.platform-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  text-transform: uppercase;
}

.platform-badge.web {
  background: #e3f2fd;
  color: #1976d2;
}

.platform-badge.mobile {
  background: #f3e5f5;
  color: #7b1fa2;
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

.form-message.info {
  background: #d1ecf1;
  color: #0c5460;
  border: 1px solid #bee5eb;
}

.form-message.warning {
  background: #fff3cd;
  color: #856404;
  border: 1px solid #ffeaa7;
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

.dns-status-details {
  margin-top: 16px;
  padding: 16px;
  background: white;
  border-radius: 6px;
  border: 1px solid #e9ecef;
}

.dns-message {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
  margin-bottom: 8px;
}

.dns-message.active {
  color: #155724;
}

.dns-message.error {
  color: #721c24;
}

.dns-message.pending {
  color: #856404;
}

.dns-icon {
  font-size: 16px;
}

.last-check {
  font-size: 12px;
  color: #6c757d;
  font-style: italic;
}

.dns-records-display {
  margin-top: 16px;
}

.dns-records-display h4 {
  margin: 0 0 12px 0;
  font-size: 14px;
  color: #495057;
}

.dns-records-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.dns-record-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 12px;
  background: #f8f9fa;
  border-radius: 4px;
  font-family: monospace;
  font-size: 13px;
}

.record-type {
  background: #007bff;
  color: white;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 11px;
  font-weight: 600;
}

.record-value {
  flex: 1;
  color: #495057;
}

.record-status {
  font-size: 11px;
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 3px;
}

.record-status.correct {
  background: #d4edda;
  color: #155724;
}

.record-status.incorrect {
  background: #f8d7da;
  color: #721c24;
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

/* Bank Accounts & Withdrawals Styles */
.tab-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.tab-header h2 {
  margin: 0;
  color: #333;
}

.bank-accounts-list {
  display: grid;
  gap: 1.5rem;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
}

.bank-account-card {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.account-info h4 {
  margin: 0 0 0.5rem 0;
  color: #2c3e50;
}

.account-info p {
  margin: 0.25rem 0;
  color: #6c757d;
  font-size: 0.9rem;
}

.account-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.bank-account-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.earnings-section,
.balance-section,
.withdrawal-section,
.transactions-section {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

.earnings-section h3,
.balance-section h3,
.withdrawal-section h3,
.transactions-section h3 {
  margin: 0 0 1rem 0;
  color: #2c3e50;
}

.balance-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
}

.balance-card {
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 1rem;
  text-align: center;
}

.balance-currency {
  font-size: 0.9rem;
  color: #6c757d;
  margin-bottom: 0.5rem;
}

.balance-amount {
  font-size: 1.5rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.25rem;
}

.balance-type {
  font-size: 0.8rem;
  color: #6c757d;
  text-transform: uppercase;
}

.balance-breakdown {
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 1rem;
  margin-top: 1rem;
}

.balance-breakdown p {
  margin: 0.5rem 0;
  color: #495057;
}

.balance-breakdown strong {
  color: #2c3e50;
}

.earnings-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
  margin: 1rem 0;
}

.earnings-card {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  border: 1px solid #e9ecef;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.earnings-card.available {
  border-color: #4CAF50;
  background: linear-gradient(135deg, #f8fff8 0%, #e8f5e8 100%);
}

.earnings-label {
  font-size: 0.9rem;
  color: #6c757d;
  margin-bottom: 0.5rem;
  font-weight: 500;
  text-transform: uppercase;
}

.earnings-amount {
  font-size: 1.8rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.earnings-card.available .earnings-amount {
  color: #4CAF50;
}

.earnings-detail {
  font-size: 0.8rem;
  color: #6c757d;
}

.earnings-breakdown {
  margin-top: 1rem;
  padding: 1rem;
  background: white;
  border-radius: 8px;
  border: 1px solid #e9ecef;
}

.earnings-breakdown p {
  margin: 0.5rem 0;
  font-size: 0.9rem;
  color: #495057;
}

.withdrawal-form {
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 1.5rem;
}

.withdrawal-info {
  background: #e3f2fd;
  border: 1px solid #bbdefb;
  border-radius: 6px;
  padding: 1rem;
  margin-bottom: 1.5rem;
}

.withdrawal-info p {
  margin: 0.25rem 0;
}

.withdrawal-info .info-text {
  color: #666;
  font-size: 0.9rem;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.transactions-table {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #e9ecef;
}

.transactions-table table {
  width: 100%;
  border-collapse: collapse;
}

.transactions-table th,
.transactions-table td {
  text-align: left;
  padding: 0.75rem;
  border-bottom: 1px solid #e9ecef;
}

.transactions-table th {
  background: #f8f9fa;
  font-weight: 500;
  color: #495057;
}

.transfer-status {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  text-transform: uppercase;
}

.transfer-status.incoming_payment_waiting {
  background: #fff3cd;
  color: #856404;
}

.transfer-status.processing {
  background: #cce5ff;
  color: #0066cc;
}

.transfer-status.funds_converted {
  background: #e3f2fd;
  color: #1976d2;
}

.transfer-status.outgoing_payment_sent {
  background: #e8f5e8;
  color: #2e7d32;
}

.transfer-status.cancelled {
  background: #ffebee;
  color: #c62828;
}

.transfer-status.charged {
  background: #e8f5e8;
  color: #2e7d32;
}

/* Subscription Required Styles */
.subscription-required {
  text-align: center;
  padding: 3rem 2rem;
  background: linear-gradient(135deg, #fff3cd 0%, #ffeeba 100%);
  border: 2px solid #ffc107;
  border-radius: 12px;
  margin: 2rem 0;
}

.subscription-required h3 {
  color: #856404;
  margin-bottom: 1rem;
  font-size: 1.5rem;
}

.subscription-required p {
  color: #856404;
  margin-bottom: 2rem;
  font-size: 1.1rem;
}

.subscription-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.subscription-actions .btn-primary,
.subscription-actions .btn-secondary {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s;
}

.subscription-actions .btn-primary {
  background: #4CAF50;
  color: white;
  border: none;
}

.subscription-actions .btn-primary:hover {
  background: #388e3c;
}

.subscription-actions .btn-secondary {
  background: #6c757d;
  color: white;
  border: none;
}

.subscription-actions .btn-secondary:hover {
  background: #5a6268;
}

.subscription-details {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 6px;
  margin: 1rem 0;
  text-align: left;
}

.subscription-details p {
  margin: 0.5rem 0;
  font-size: 0.9rem;
  color: #495057;
}

.sync-note {
  font-style: italic;
  color: #6c757d !important;
  font-size: 0.85rem !important;
}

.btn-sync {
  background: #17a2b8;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 500;
  transition: all 0.2s;
  cursor: pointer;
}

.btn-sync:hover:not(:disabled) {
  background: #138496;
}

.btn-sync:disabled {
  background: #6c757d;
  cursor: not-allowed;
}

.tab-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.btn-refresh {
  background: #28a745;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-refresh:hover:not(:disabled) {
  background: #218838;
}

.btn-refresh:disabled {
  background: #6c757d;
  cursor: not-allowed;
}

/* Responsive Design */
@media (max-width: 768px) {
  .header-controls {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .order-filter {
    width: 100%;
  }
  
  .filter-select {
    flex: 1;
    min-width: auto;
  }
  
  .bank-accounts-list {
    grid-template-columns: 1fr;
  }
  
  .bank-account-card {
    flex-direction: column;
    gap: 1rem;
  }
  
  .balance-cards {
    grid-template-columns: 1fr;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .tab-header {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }
  
  .transactions-table,
  .orders-table {
    overflow-x: auto;
  }
}

/* Product Form Styles */
.product-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.product-form .form-group {
  display: flex;
  flex-direction: column;
}

.product-form .form-group label {
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #333;
}

.product-form .form-group input,
.product-form .form-group textarea {
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.product-form .form-group input:focus,
.product-form .form-group textarea:focus {
  outline: none;
  border-color: #4CAF50;
}

.product-form .form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.product-form .image-preview {
  margin-top: 1rem;
  text-align: center;
}

.product-form .image-preview img {
  max-width: 200px;
  max-height: 200px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #ddd;
}

.product-form .current-image-label {
  margin-top: 0.5rem;
  color: #666;
  font-size: 0.9rem;
  font-style: italic;
}

.product-form .modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #e0e0e0;
}

.product-form .modal-actions button {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: background 0.2s;
}

.product-form .modal-actions .btn-secondary {
  background: #6c757d;
  color: white;
}

.product-form .modal-actions .btn-secondary:hover {
  background: #5a6268;
}

.product-form .modal-actions .btn-primary {
  background: #4CAF50;
  color: white;
}

.product-form .modal-actions .btn-primary:hover:not(:disabled) {
  background: #388e3c;
}

.product-form .modal-actions .btn-primary:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.product-form .modal-actions .btn-delete {
  background: #dc3545;
  color: white;
}

.product-form .modal-actions .btn-delete:hover:not(:disabled) {
  background: #c82333;
}

.product-form .modal-actions .btn-delete:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.images-section {
  display: flex;
  gap: 1rem;
}

.hero-image-section,
.additional-images-section {
  flex: 1;
}

.add-image-controls {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
}

.images-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.image-item {
  position: relative;
}

.image-item img {
  width: 100px;
  height: 100px;
  object-fit: cover;
  border-radius: 4px;
}

.image-label {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 0 0 4px 4px;
}

.btn-remove {
  position: absolute;
  top: 0;
  right: 0;
  background: none;
  border: none;
  font-size: 1rem;
  color: white;
  cursor: pointer;
  padding: 0.25rem;
}

.btn-remove:hover {
  color: #dc3545;
}

.hero-preview,
.new-additional-images {
  text-align: center;
  padding: 1rem;
  border: 1px dashed #ccc;
  border-radius: 8px;
  background: #f8f9fa;
}

.hero-preview img,
.new-additional-images img {
  max-width: 200px;
  max-height: 200px;
  object-fit: cover;
  border-radius: 8px;
}

.new-additional-images h5 {
  margin: 0;
  color: #6c757d;
  font-size: 1rem;
}

.images-row {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
  flex-wrap: wrap;
}

.image-thumb-wrapper {
  position: relative;
  display: inline-block;
}

.image-thumb {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 4px;
  border: 2px solid #eee;
}

.image-thumb.hero {
  border: 2px solid #4CAF50;
}

.hero-badge {
  position: absolute;
  top: 2px;
  left: 2px;
  background: #4CAF50;
  color: white;
  font-size: 0.7rem;
  padding: 2px 6px;
  border-radius: 4px;
  z-index: 2;
}

.btn-remove {
  position: absolute;
  top: 2px;
  right: 2px;
  background: rgba(0,0,0,0.5);
  color: white;
  border: none;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  font-size: 1rem;
  cursor: pointer;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-remove:hover {
  background: #dc3545;
}

.add-image-ghost-btn {
  width: 40px;
  height: 40px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 1.5px dashed #bbb;
  background: none;
  color: #2196f3;
  border-radius: 8px;
  font-size: 1.3rem;
  cursor: pointer;
  margin-right: 0.5rem;
  transition: border-color 0.2s, color 0.2s, background 0.2s;
  outline: none;
}

.add-image-ghost-btn:hover {
  border-color: #2196f3;
  color: #1565c0;
  background: #f4faff;
}

/* Spinner styles */
.spinner {
  border: 3px solid #f3f3f3;
  border-top: 3px solid #2196f3;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  animation: spin 1s linear infinite;
  margin: 0 auto;
}
.spinner.large {
  width: 48px;
  height: 48px;
  border-width: 4px;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
.uploading-thumb {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 80px;
  height: 80px;
  background: #f8f9fa;
  border-radius: 4px;
  border: 2px dashed #eee;
  margin-right: 0.5rem;
}
.uploading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255,255,255,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.store-contact-row {
  margin-top: 0.5rem;
  display: flex;
  align-items: center;
  gap: 1.5rem;
  flex-wrap: wrap;
}

.store-contact-row .contact-value {
  background: #e3f2fd;
  color: #1976d2;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  margin-right: 1rem;
  display: inline-block;
}

.edit-store-chip {
  background: #fffde7;
  color: #f9a825;
  border-radius: 20px;
  padding: 0.25rem 0.9rem;
  font-size: 0.85rem;
  font-weight: 600;
  margin-right: 1rem;
  margin-left: 0.5rem;
  text-decoration: none;
  border: 1px solid #ffe082;
  transition: background 0.2s, color 0.2s;
  display: inline-block;
}
.edit-store-chip:hover {
  background: #ffe082;
  color: #fffde7;
}
</style> 