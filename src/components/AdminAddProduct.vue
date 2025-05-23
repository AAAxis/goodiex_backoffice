<template>
  <div class="admin-add-product-wrapper">
    <div class="admin-add-product-content">
      <button class="back-btn" @click="goBack" title="Back">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M15 19l-7-7 7-7" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
      </button>
      <h1 class="admin-dashboard-title">Add Product</h1>
      <form @submit.prevent="addProduct" class="admin-form">
        <input v-model="name" placeholder="Product Name" required />
        <input v-model.number="price" placeholder="Price" type="number" min="0" step="0.01" required />
        <input type="file" accept="image/*" @change="onFileChange" />
        <div v-if="imagePreview" class="image-preview-container">
          <img :src="imagePreview" class="image-preview" alt="Preview" />
        </div>
        <button type="submit" class="primary-btn" :disabled="uploading">Add Product</button>
      </form>
      <p v-if="message" class="form-message">{{ message }}</p>
    </div>
  </div>
</template>

<script>
import firebase from 'firebase/compat/app';
import 'firebase/compat/firestore';
import 'firebase/compat/storage';

export default {
  data() {
    return {
      name: '',
      price: '',
      imageFile: null,
      imagePreview: '',
      uploading: false,
      message: ''
    };
  },
  methods: {
    goBack() {
      this.$router.push(`/admin/menu/${this.$route.params.categoryId}`);
    },
    onFileChange(e) {
      const file = e.target.files[0];
      if (file) {
        this.imageFile = file;
        this.imagePreview = URL.createObjectURL(file);
      }
    },
    async uploadImage() {
      if (!this.imageFile) return '';
      this.uploading = true;
      const storageRef = firebase.storage().ref();
      const fileName = `product_images/${Date.now()}_${this.imageFile.name}`;
      const imageRef = storageRef.child(fileName);
      await imageRef.put(this.imageFile);
      const url = await imageRef.getDownloadURL();
      this.uploading = false;
      return url;
    },
    async addProduct() {
      let image_url = '';
      if (this.imageFile) {
        image_url = await this.uploadImage();
      }
      const db = firebase.firestore();
      const categoryId = this.$route.params.categoryId;
      db.collection('categories').doc(categoryId).collection('products').add({
        name: this.name,
        price: this.price,
        image_url: image_url
      }).then(() => {
        this.message = 'Product added!';
        setTimeout(() => {
          this.$router.push(`/admin/menu/${categoryId}`);
        }, 1000);
      }).catch(err => {
        this.message = 'Error: ' + err.message;
      });
    }
  }
};
</script>

<style scoped>
.admin-add-product-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  padding: 1rem;
}
.admin-add-product-content {
  background: #fff;
  padding: 2rem 2.5rem;
  border-radius: 18px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.10);
  min-width: 320px;
  max-width: 420px;
  width: 100%;
  text-align: center;
  position: relative;
  margin: 0 auto;
}
.back-btn {
  background: #bbb;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 0.4rem 1rem;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
  position: absolute;
  top: 1.2rem;
  left: 1.2rem;
}
.back-btn:hover {
  background: #888;
}
.admin-dashboard-title {
  margin-bottom: 2rem;
  font-size: 2rem;
  font-weight: bold;
  color: #333;
}
.admin-form input {
  display: block;
  width: 100%;
  margin: 0.7rem 0;
  padding: 1rem;
  border: 1px solid #ccc;
  border-radius: 8px;
  font-size: 1.1rem;
  background: #f9f9f9;
  box-sizing: border-box;
  transition: border 0.2s;
}
.admin-form input:focus {
  border: 1.5px solid #4CAF50;
  outline: none;
}
.primary-btn {
  margin-top: 1rem;
  padding: 1rem 2rem;
  background: #4CAF50;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 1.1rem;
  cursor: pointer;
  transition: background 0.2s;
  width: 100%;
  margin-bottom: 0.5rem;
}
.primary-btn:hover {
  background: #388e3c;
}
.form-message {
  margin-top: 1.5rem;
  font-size: 1.1rem;
  color: #388e3c;
}
.image-preview-container {
  display: flex;
  justify-content: flex-start;
  margin-bottom: 1rem;
}
.image-preview {
  width: 100px;
  height: 100px;
  object-fit: cover;
  border-radius: 10px;
  border: 1px solid #eee;
}
@media (max-width: 600px) {
  .admin-add-product-content {
    padding: 1rem 0.5rem;
    min-width: unset;
    max-width: 100vw;
    border-radius: 0.7rem;
  }
  .admin-dashboard-title {
    font-size: 1.3rem;
  }
  .admin-form input {
    font-size: 1rem;
    padding: 0.7rem;
  }
  .primary-btn {
    font-size: 1rem;
    padding: 0.7rem 1rem;
  }
}
</style> 