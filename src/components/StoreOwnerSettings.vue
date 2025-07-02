<template>
  <div class="settings-wrapper">
    <div class="settings-content">
      <div class="header-actions">
        <button class="back-btn" @click="goBack">← Back to Dashboard</button>
      </div>
      
      <h1 class="settings-title">Account Settings</h1>

      <!-- Edit Name Section -->
      <div class="settings-section">
        <h3>Profile Information</h3>
        <form @submit.prevent="updateProfile" class="settings-form">
          <div class="form-group">
            <label>Full Name *</label>
            <input 
              v-model="profileData.name" 
              type="text" 
              placeholder="Enter your full name" 
              required 
            />
          </div>
          <div class="form-group">
            <label>Email Address</label>
            <input 
              :value="userEmail" 
              type="email" 
              disabled
              class="disabled-input"
            />
            <small class="form-note">Email cannot be changed</small>
          </div>
          <button type="submit" class="update-btn" :disabled="profileLoading">
            {{ profileLoading ? 'Updating...' : 'Update Profile' }}
          </button>
        </form>
      </div>

      <!-- Change Password Section -->
      <div class="settings-section">
        <h3>Change Password</h3>
        <form @submit.prevent="changePassword" class="settings-form">
          <div class="form-group">
            <label>Current Password *</label>
            <input 
              v-model="passwordData.currentPassword" 
              type="password" 
              placeholder="Enter current password" 
              required 
            />
          </div>
          <div class="form-group">
            <label>New Password *</label>
            <input 
              v-model="passwordData.newPassword" 
              type="password" 
              placeholder="Enter new password" 
              required 
              minlength="6"
            />
          </div>
          <button type="submit" class="update-btn" :disabled="passwordLoading">
            {{ passwordLoading ? 'Changing...' : 'Change Password' }}
          </button>
        </form>
      </div>

      <!-- Subscription Section -->
      <div class="settings-section">
        <h3>Subscription</h3>
        <div>
          <button class="update-btn" @click="openStripePortal" :disabled="portalLoading">
            {{ portalLoading ? 'Redirecting...' : 'Manage Subscription' }}
          </button>
        </div>
        <p v-if="subscriptionMessage" :class="subscriptionMessageType">{{ subscriptionMessage }}</p>
      </div>

      <!-- Delete Account Section -->
      <div class="settings-section danger-zone">
        <div class="danger-content">
          <div class="danger-warning">
            <h4>Delete Account</h4>
            <p>Once you delete your account, there is no going back.</p>
          </div>
          <button 
            class="delete-btn" 
            @click="showDeleteConfirmation = true"
          >
            Delete Account Permanently
          </button>
        </div>
      </div>

      <!-- Delete Confirmation Modal -->
      <div v-if="showDeleteConfirmation" class="modal-overlay" @click="cancelDelete">
        <div class="modal-content" @click.stop>
          <h3>Confirm Account Deletion</h3>
          <p>Are you absolutely sure you want to delete your account?</p>
          <p class="modal-warning">This action will permanently delete:</p>
          <ul class="modal-list">
            <li>Your account and profile</li>
            <li>All your stores ({{ totalStores }})</li>
            <li>All products and orders</li>
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
              @click="deleteAccount"
              :disabled="deleteConfirmation !== 'DELETE' || deleting"
            >
              {{ deleting ? 'Deleting...' : 'Delete Account Forever' }}
            </button>
          </div>
        </div>
      </div>

      <p v-if="message" class="form-message" :class="messageType">{{ message }}</p>
    </div>
  </div>
</template>

<script>
import { auth, db } from '../../firebase'
import axios from 'axios'

export default {
  name: 'StoreOwnerSettings',
  data() {
    return {
      user: null,
      userEmail: '',
      profileData: {
        name: ''
      },
      passwordData: {
        currentPassword: '',
        newPassword: ''
      },
      profileLoading: false,
      passwordLoading: false,
      message: '',
      messageType: '',
      showDeleteConfirmation: false,
      deleteConfirmation: '',
      deleting: false,
      totalStores: 0,
      subscriptionMessage: '',
      subscriptionMessageType: '',
      stripeCustomerId: '',
      portalLoading: false
    }
  },

  async mounted() {
    auth.onAuthStateChanged(async (user) => {
      if (user) {
        this.user = user
        this.userEmail = user.email
        await this.fetchUserProfile()
        await this.fetchUserStats()
      } else {
        this.$router.push('/store-owner/login')
      }
    })
  },
  methods: {
    async fetchUserProfile() {
      try {
        const userDoc = await db.collection('storeOwners').doc(this.user.uid).get()
        if (userDoc.exists) {
          const userData = userDoc.data()
          this.profileData.name = userData.name || ''
          this.stripeCustomerId = userData.stripeCustomerId || ''
        }
      } catch (error) {
        console.error('Error fetching user profile:', error)
      }
    },

    async fetchUserStats() {
      try {
        const storesSnapshot = await db.collection('stores').where('ownerId', '==', this.user.uid).get()
        this.totalStores = storesSnapshot.size
      } catch (error) {
        console.error('Error fetching user stats:', error)
        this.totalStores = 0
      }
    },

    async updateProfile() {
      this.profileLoading = true
      this.message = ''

      try {
        // Update in storeOwners collection
        await db.collection('storeOwners').doc(this.user.uid).update({
          name: this.profileData.name,
          updatedAt: new Date()
        })

        // Update Firebase Auth profile
        await this.user.updateProfile({
          displayName: this.profileData.name
        })

        this.showMessage('Profile updated successfully!', 'success')
      } catch (error) {
        console.error('Error updating profile:', error)
        this.showMessage('Failed to update profile. Please try again.', 'error')
      } finally {
        this.profileLoading = false
      }
    },

    async changePassword() {
      this.passwordLoading = true
      this.message = ''

      try {
        // Re-authenticate user with current password
        const credential = auth.EmailAuthProvider.credential(
          this.user.email,
          this.passwordData.currentPassword
        )
        await this.user.reauthenticateWithCredential(credential)

        // Update password
        await this.user.updatePassword(this.passwordData.newPassword)

        // Clear form
        this.passwordData = {
          currentPassword: '',
          newPassword: ''
        }

        this.showMessage('Password changed successfully!', 'success')
      } catch (error) {
        console.error('Error changing password:', error)
        if (error.code === 'auth/wrong-password') {
          this.showMessage('Current password is incorrect.', 'error')
        } else {
          this.showMessage('Failed to change password. Please try again.', 'error')
        }
      } finally {
        this.passwordLoading = false
      }
    },

    cancelDelete() {
      this.showDeleteConfirmation = false
      this.deleteConfirmation = ''
    },

    async deleteAccount() {
      if (this.deleteConfirmation !== 'DELETE') {
        return
      }

      this.deleting = true

      try {
        // Delete all stores and their products
        const storesSnapshot = await db.collection('stores').where('ownerId', '==', this.user.uid).get()
        
        for (const storeDoc of storesSnapshot.docs) {
          // Delete all products in each store
          const productsSnapshot = await storeDoc.ref.collection('products').get()
          const productDeletePromises = productsSnapshot.docs.map(doc => doc.ref.delete())
          await Promise.all(productDeletePromises)
          
          // Delete the store
          await storeDoc.ref.delete()
        }

        // Delete user profile from storeOwners collection
        await db.collection('storeOwners').doc(this.user.uid).delete()

        // Delete Firebase Auth account
        await this.user.delete()

        this.showMessage('Account deleted successfully. Redirecting...', 'success')
        
        setTimeout(() => {
          this.$router.push('/')
        }, 2000)

      } catch (error) {
        console.error('Error deleting account:', error)
        this.showMessage('Failed to delete account. Please try again.', 'error')
      } finally {
        this.deleting = false
        this.showDeleteConfirmation = false
      }
    },

    showMessage(message, type) {
      this.message = message
      this.messageType = type
      setTimeout(() => {
        this.message = ''
      }, 5000)
    },

    goBack() {
      this.$router.push('/store-owner/dashboard')
    },

    async openStripePortal() {
      if (!this.stripeCustomerId) {
        this.subscriptionMessage = 'No Stripe customer ID found. Please contact support.'
        this.subscriptionMessageType = 'error'
        return
      }
      this.portalLoading = true
      this.subscriptionMessage = ''
      try {
        console.log('Creating customer portal session for:', this.stripeCustomerId)
        const res = await axios.post('https://pay.theholylabs.com/create-customer-portal-session', {
          customer_id: this.stripeCustomerId,
          return_url: window.location.origin + '/store-owner/settings'
        })
        
        if (res.data && res.data.url) {
          window.location.href = res.data.url
        } else {
          console.error('Invalid response from portal API:', res.data)
          this.subscriptionMessage = 'Invalid response from payment system. Please try again.'
          this.subscriptionMessageType = 'error'
        }
      } catch (error) {
        console.error('Customer portal error:', error.response?.data || error.message)
        
        if (error.response?.status === 500) {
          this.subscriptionMessage = 'Payment system temporarily unavailable. Please try again in a few minutes.'
        } else if (error.response?.status === 404) {
          this.subscriptionMessage = 'Customer portal service not found. Please contact support.'
        } else if (error.response?.data?.message) {
          this.subscriptionMessage = `Error: ${error.response.data.message}`
        } else {
          this.subscriptionMessage = 'Failed to open subscription management. Please contact support if this persists.'
        }
        this.subscriptionMessageType = 'error'
      } finally {
        this.portalLoading = false
      }
    }
  }
}
</script>

<style scoped>
.settings-wrapper {
  min-height: 100vh;
  background: #f8f9fa;
  padding: 2rem;
}

.settings-content {
  max-width: 600px;
  margin: 0 auto;
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
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

.settings-title {
  text-align: center;
  margin-bottom: 2rem;
  color: #333;
  font-size: 1.8rem;
}

.settings-section {
  margin-bottom: 3rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid #e0e0e0;
}

.settings-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.settings-section h3 {
  color: #333;
  margin-bottom: 1.5rem;
  font-size: 1.2rem;
}

.settings-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
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

.form-group input {
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.form-group input:focus {
  outline: none;
  border-color: #4CAF50;
}

.disabled-input {
  background: #f8f9fa !important;
  color: #6c757d !important;
  cursor: not-allowed !important;
}

.form-note {
  margin-top: 0.25rem;
  color: #6c757d;
  font-size: 0.85rem;
}

.error-text {
  color: #dc3545;
  font-size: 0.85rem;
  margin-top: 0.25rem;
}

.update-btn {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
  align-self: flex-start;
}

.update-btn:hover:not(:disabled) {
  background: #388e3c;
}

.update-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

/* Danger Zone Styles */
.danger-zone {
  padding: 2rem;
  border: 2px solid #dc3545;
  border-radius: 8px;
  background: #fff5f5;
  margin-top: 2rem;
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

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  max-width: 500px;
  width: 90%;
  max-height: 80vh;
  overflow-y: auto;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

.modal-content h3 {
  color: #dc3545;
  margin: 0 0 1rem 0;
  font-size: 1.4rem;
}

.modal-content p {
  margin-bottom: 1rem;
  color: #333;
}

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

@media (max-width: 768px) {
  .settings-wrapper {
    padding: 1rem;
  }
  
  .settings-content {
    padding: 1.5rem;
  }
  
  .danger-content {
    flex-direction: column;
    gap: 1rem;
  }
  
  .modal-content {
    padding: 1.5rem;
    margin: 1rem;
  }
  
  .modal-actions {
    flex-direction: column;
  }
}
</style> 