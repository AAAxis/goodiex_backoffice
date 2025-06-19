<template>
  <div class="create-store-wrapper">
    <div class="create-store-content">
      <div class="header-actions">
        <button class="back-btn" @click="goBack">← Back</button>
      </div>
      
      <h1 class="create-store-title">Create New Store</h1>
      
      <form @submit.prevent="createStore" class="store-form">
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
            placeholder="Brief description of your store"
            rows="3"
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
        </div>

        <div class="form-group">
          <label>Contact Email *</label>
          <input 
            v-model="storeData.email" 
            type="email" 
            placeholder="store@example.com" 
            required 
          />
        </div>

        <div class="form-group">
          <label>Phone Number</label>
          <input 
            v-model="storeData.phone" 
            type="tel" 
            placeholder="+1 (555) 123-4567" 
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
          <label class="checkbox-label">
            <input 
              type="checkbox" 
              v-model="storeData.isActive"
            />
            <span class="checkmark"></span>
            Active (store will be visible to customers)
          </label>
        </div>

        <button type="submit" class="create-btn" :disabled="loading">
          {{ loading ? 'Creating Store...' : 'Create Store' }}
        </button>
      </form>

      <p v-if="message" class="form-message" :class="messageType">{{ message }}</p>
    </div>
  </div>
</template>

<script>
import { auth, db, storage } from '../../firebase'

export default {
  name: 'CreateStore',
  data() {
    return {
      user: null,
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
      loading: false,
      message: '',
      messageType: ''
    }
  },
  mounted() {
    auth.onAuthStateChanged((user) => {
      if (user) {
        this.user = user
        this.storeData.email = user.email // Pre-fill with user's email
      } else {
        this.$router.push('/store-owner/login')
      }
    })
  },
  methods: {
    onImageChange(event) {
      const file = event.target.files[0]
      if (file) {
        this.imageFile = file
        this.imagePreview = URL.createObjectURL(file)
      }
    },

    async uploadImage() {
      if (!this.imageFile) return null

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

    async createStore() {
      this.loading = true
      this.message = ''

      try {
        let imageUrl = null
        if (this.imageFile) {
          imageUrl = await this.uploadImage()
        }

        const storeDoc = {
          ...this.storeData,
          image: imageUrl,
          ownerId: this.user.uid,
          ownerEmail: this.user.email,
          createdAt: new Date(),
          updatedAt: new Date(),
          totalProducts: 0,
          totalOrders: 0
        }

        await db.collection('stores').add(storeDoc)

        this.showMessage('Store created successfully! Redirecting...', 'success')
        
        setTimeout(() => {
          this.$router.push('/store-owner/dashboard')
        }, 2000)

      } catch (error) {
        console.error('Error creating store:', error)
        this.showMessage('Failed to create store. Please try again.', 'error')
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

    goBack() {
      this.$router.push('/store-owner/dashboard')
    }
  }
}
</script>

<style scoped>
.create-store-wrapper {
  min-height: 100vh;
  background: #f8f9fa;
  padding: 2rem;
}

.create-store-content {
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

.create-store-title {
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

.create-btn {
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

.create-btn:hover:not(:disabled) {
  background: #388e3c;
}

.create-btn:disabled {
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
  .create-store-wrapper {
    padding: 1rem;
  }
  
  .create-store-content {
    padding: 1.5rem;
  }
}
</style> 