<template>
  <div class="create-product-wrapper">
    <div class="create-product-content">
      <div class="header-actions">
        <button class="back-btn" @click="goBack">← Back</button>
      </div>
      
      <h1 class="create-product-title">Add New Product</h1>
      
      <form @submit.prevent="createProduct" class="product-form">
        <div class="form-group">
          <label>Product Name *</label>
          <input 
            v-model="productData.name" 
            type="text" 
            placeholder="Enter product name" 
            required 
          />
        </div>

        <div class="form-group">
          <label>Description</label>
          <textarea 
            v-model="productData.description" 
            placeholder="Product description"
            rows="3"
          ></textarea>
        </div>

        <div class="form-group">
          <label>Price *</label>
          <input 
            v-model="productData.price" 
            type="number" 
            step="0.01"
            min="0"
            placeholder="0.00" 
            required 
          />
        </div>

        <div class="form-group">
          <label>Product Image</label>
          <input 
            type="file" 
            accept="image/*" 
            @change="onImageChange"
            ref="imageInput"
          />
          <div v-if="imagePreview" class="image-preview">
            <img :src="imagePreview" alt="Product preview" />
          </div>
        </div>

        <div class="form-group">
          <label>Stock Quantity</label>
          <input 
            v-model="productData.stock" 
            type="number" 
            min="0"
            placeholder="Available quantity" 
          />
        </div>

        <button type="submit" class="create-btn" :disabled="loading">
          {{ loading ? 'Creating Product...' : 'Create Product' }}
        </button>
      </form>

      <p v-if="message" class="form-message" :class="messageType">{{ message }}</p>
    </div>
  </div>
</template>

<script>
import { auth, db, storage } from '../../firebase'

export default {
  name: 'CreateProduct',
  data() {
    return {
      storeId: '',
      user: null,
      productData: {
        name: '',
        description: '',
        price: '',
        stock: ''
      },
      imageFile: null,
      imagePreview: '',
      loading: false,
      message: '',
      messageType: ''
    }
  },
  mounted() {
    this.storeId = this.$route.params.storeId
    
    auth.onAuthStateChanged((user) => {
      if (user) {
        this.user = user
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
        const fileName = `product-images/${this.storeId}/${Date.now()}_${this.imageFile.name}`
        const storageRef = storage.ref().child(fileName)
        const snapshot = await storageRef.put(this.imageFile)
        const downloadURL = await snapshot.ref.getDownloadURL()
        return downloadURL
      } catch (error) {
        console.error('Error uploading image:', error)
        throw error
      }
    },

    async createProduct() {
      this.loading = true
      this.message = ''

      try {
        let imageUrl = null
        if (this.imageFile) {
          imageUrl = await this.uploadImage()
        }

        const productDoc = {
          name: this.productData.name,
          description: this.productData.description,
          price: parseFloat(this.productData.price),
          stock: this.productData.stock ? parseInt(this.productData.stock) : 0,
          image: imageUrl,
          storeId: this.storeId,
          createdAt: new Date(),
          updatedAt: new Date()
        }

        await db.collection('stores').doc(this.storeId).collection('products').add(productDoc)

        this.showMessage('Product created successfully! Redirecting...', 'success')
        
        setTimeout(() => {
          this.$router.push(`/store-owner/manage-store/${this.storeId}`)
        }, 2000)

      } catch (error) {
        console.error('Error creating product:', error)
        this.showMessage('Failed to create product. Please try again.', 'error')
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
      this.$router.push(`/store-owner/manage-store/${this.storeId}`)
    }
  }
}
</script>

<style scoped>
.create-product-wrapper {
  min-height: 100vh;
  background: #f8f9fa;
  padding: 2rem;
}

.create-product-content {
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

.create-product-title {
  text-align: center;
  margin-bottom: 2rem;
  color: #333;
  font-size: 1.8rem;
}

.product-form {
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
  .create-product-wrapper {
    padding: 1rem;
  }
  
  .create-product-content {
    padding: 1.5rem;
  }
}
</style> 