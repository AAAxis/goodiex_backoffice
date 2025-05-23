<template>
  <div class="admin-merchant-wrapper">
    <div class="admin-merchant-content">
      <div class="edit-actions">
        <button class="back-btn" @click="goBack" title="Back">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M15 19l-7-7 7-7" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </button>
      </div>
      <h1 class="admin-dashboard-title">Add Category</h1>
      <form @submit.prevent="addCategory" class="admin-form">
        <div class="image-upload-row">
          <label class="image-upload-label">Hero Image</label>
          <input type="file" accept="image/*" @change="onFileChange" />
        </div>
        <div v-if="imagePreview" class="image-preview-container">
          <img :src="imagePreview" class="image-preview" alt="Preview" />
        </div>
        <input v-model="name" placeholder="Category Name" required />
        <div class="switch-row">
          <label class="switch-label">Receiving Orders</label>
          <label class="switch">
            <input type="checkbox" v-model="receivingOrders">
            <span class="slider"></span>
          </label>
          <span class="switch-value">{{ receivingOrders ? 'Yes' : 'No' }}</span>
        </div>
        <button type="submit" class="primary-btn" :disabled="uploading">Add Category</button>
      </form>
      <p v-if="message" class="form-message">{{ message }}</p>
    </div>
  </div>
</template>

<script>
import firebase from 'firebase/compat/app';
import 'firebase/compat/firestore';
import 'firebase/compat/storage';

const ADMIN_EMAIL_KEY = 'admin_dashboard_email';

export default {
  data() {
    return {
      name: '',
      receivingOrders: false,
      email: '',
      message: '',
      imageFile: null,
      imagePreview: '',
      uploading: false
    };
  },
  mounted() {
    this.email = localStorage.getItem(ADMIN_EMAIL_KEY) || '';
  },
  methods: {
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
      const fileName = `category_images/${Date.now()}_${this.imageFile.name}`;
      const imageRef = storageRef.child(fileName);
      await imageRef.put(this.imageFile);
      const url = await imageRef.getDownloadURL();
      this.uploading = false;
      return url;
    },
    async addCategory() {
      let link = '';
      if (this.imageFile) {
        link = await this.uploadImage();
      }
      const email = localStorage.getItem(ADMIN_EMAIL_KEY) || this.email;
      const db = firebase.firestore();
      db.collection('categories').add({
        name: this.name,
        link: link,
        receivingOrders: this.receivingOrders,
        email: email
      }).then(() => {
        this.message = 'Category added!';
        setTimeout(() => {
          this.$router.push('/admin');
        }, 1000);
      }).catch(err => {
        this.message = 'Error: ' + err.message;
      });
    },
    goBack() {
      this.$router.push('/admin');
    }
  }
};
</script>

<style scoped>
.admin-merchant-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  padding: 1rem;
}
.admin-merchant-content {
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
.edit-actions {
  position: absolute;
  top: 1.2rem;
  left: 1.2rem;
  z-index: 10;
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
.admin-form input,
.admin-form select {
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
.admin-form input:focus,
.admin-form select:focus {
  border: 1.5px solid #4CAF50;
  outline: none;
}
.switch-row {
  display: flex;
  align-items: center;
  margin: 1rem 0 1rem 0;
  gap: 1rem;
  justify-content: flex-start;
}
.switch-label {
  font-size: 1rem;
  color: #333;
  margin-right: 0.5rem;
  min-width: 120px;
}
.switch {
  position: relative;
  display: inline-block;
  width: 46px;
  height: 24px;
}
.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}
.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: .4s;
  border-radius: 24px;
}
.switch input:checked + .slider {
  background-color: #4CAF50;
}
.slider:before {
  position: absolute;
  content: "";
  height: 18px;
  width: 18px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: .4s;
  border-radius: 50%;
}
.switch input:checked + .slider:before {
  transform: translateX(22px);
}
.switch-value {
  min-width: 30px;
  text-align: left;
  font-size: 1rem;
  color: #333;
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
.image-upload-row {
  display: flex;
  align-items: center;
  margin: 1rem 0 0.5rem 0;
  gap: 1rem;
  justify-content: flex-start;
}
.image-upload-label {
  font-size: 1rem;
  color: #333;
  min-width: 120px;
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
  .admin-merchant-content {
    padding: 1rem 0.5rem;
    min-width: unset;
    max-width: 100vw;
    border-radius: 0.7rem;
  }
  .admin-dashboard-title {
    font-size: 1.3rem;
  }
  .admin-form input,
  .admin-form select {
    font-size: 1rem;
    padding: 0.7rem;
  }
  .primary-btn {
    font-size: 1rem;
    padding: 0.7rem 1rem;
  }
}
</style> 