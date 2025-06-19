<template>
  <div class="edit-store-wrapper">
    <div class="edit-store-content">
      <div class="header-actions">
        <button class="back-btn" @click="goBack">← Back to Dashboard</button>
      </div>
      
      <h1 class="edit-store-title">Edit Store</h1>
      
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
  </div>
</template>

<script>
import { auth, db, storage } from '../../firebase'

export default {
  name: 'EditStore',
  data() {
    return {
      storeId: '',
      user: null,
      store: null,
      storeData: {
        name: '',
        description: '',
        email: '',
        phone: '',
        address: '',
        isActive: true
      },
      imageFile: null,
      imagePreview: '',
      currentImage: '',
      loading: false,
      message: '',
      messageType: '',
      showDeleteConfirmation: false,
      deleteConfirmation: '',
      deleting: false,
      totalProducts: 0,
      totalOrders: 0
    }
  },
  async mounted() {
    this.storeId = this.$route.params.storeId
    
    auth.onAuthStateChanged(async (user) => {
      if (user) {
        this.user = user
        await this.fetchStore()
        await this.fetchStoreStats()
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
          
          // Populate form with existing data
          this.storeData = {
            name: this.store.name || '',
            description: this.store.description || '',
            email: this.store.email || '',
            phone: this.store.phone || '',
            address: this.store.address || '',
            isActive: this.store.isActive !== undefined ? this.store.isActive : true
          }
          
          this.currentImage = this.store.image || ''
        } else {
          this.showMessage('Store not found.', 'error')
          this.goBack()
        }
      } catch (error) {
        console.error('Error fetching store:', error)
        this.showMessage('Error loading store information.', 'error')
      }
    },

    onImageChange(event) {
      const file = event.target.files[0]
      if (file) {
        this.imageFile = file
        this.imagePreview = URL.createObjectURL(file)
      }
    },

    async uploadImage() {
      if (!this.imageFile) return this.currentImage

      try {
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

        this.showMessage('Store updated successfully! Redirecting...', 'success')
        
        setTimeout(() => {
          this.$router.push('/store-owner/dashboard')
        }, 2000)

      } catch (error) {
        console.error('Error updating store:', error)
        this.showMessage('Failed to update store. Please try again.', 'error')
      } finally {
        this.loading = false
      }
    },

    showMessage(message, type) {
      this.message = message
      this.messageType = type
      setTimeout(() => {
        this.message = ''
      }, 5000)
    },

    async fetchStoreStats() {
      try {
        // Count products
        const productsSnapshot = await db.collection('stores').doc(this.storeId).collection('products').get()
        this.totalProducts = productsSnapshot.size

        // Count orders
        const ordersSnapshot = await db.collection('web-orders').where('storeId', '==', this.storeId).get()
        this.totalOrders = ordersSnapshot.size
      } catch (error) {
        console.error('Error fetching store stats:', error)
        this.totalProducts = 0
        this.totalOrders = 0
      }
    },

    cancelDelete() {
      this.showDeleteConfirmation = false
      this.deleteConfirmation = ''
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

        // Delete all orders (optional - you might want to keep order history)
        // const ordersSnapshot = await db.collection('web-orders').where('storeId', '==', this.storeId).get()
        // const orderDeletePromises = ordersSnapshot.docs.map(doc => doc.ref.delete())
        // await Promise.all(orderDeletePromises)

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

    goBack() {
      this.$router.push('/store-owner/dashboard')
    }
  }
}
</script>

<style scoped>
.edit-store-wrapper {
  min-height: 100vh;
  background: #f8f9fa;
  padding: 2rem;
}

.edit-store-content {
  max-width: 600px;
  margin: 0 auto;
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  position: relative;
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

.edit-store-title {
  text-align: center;
  margin-bottom: 2rem;
  color: #333;
  font-size: 1.8rem;
}

.store-form {
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

.loading {
  text-align: center;
  padding: 2rem;
  color: #666;
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

.danger-title {
  color: #dc3545;
  margin: 0 0 1rem 0;
  font-size: 1.3rem;
  font-weight: 600;
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

.danger-warning ul {
  color: #721c24;
  margin: 0.5rem 0;
  padding-left: 1.5rem;
}

.warning-text {
  font-weight: 600;
  color: #dc3545 !important;
  margin-top: 1rem !important;
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

@media (max-width: 768px) {
  .edit-store-wrapper {
    padding: 1rem;
  }
  
  .edit-store-content {
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