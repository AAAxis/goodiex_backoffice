<template>
  <div class="admin-merchant-wrapper">
    <div class="admin-merchant-content">
      <div class="edit-actions">
        <button class="back-btn" @click="goBack" title="Back">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M15 19l-7-7 7-7" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </button>
      </div>
      <h1 class="admin-dashboard-title">Edit Category</h1>
      <form v-if="loaded" @submit.prevent="updateCategory" class="admin-form">
        <div class="image-upload-row">
          <label class="image-upload-label">Hero Image</label>
          <div class="image-hero-container">
            <img :src="imagePreview || link" class="image-preview" alt="Hero" />
            <button type="button" class="edit-image-btn" @click="triggerFileInput" title="Replace image">
              <svg width="22" height="22" viewBox="0 0 20 20" fill="none">
                <path d="M17.414 2.586a2 2 0 0 0-2.828 0l-9.5 9.5A2 2 0 0 0 4 13.414V16a1 1 0 0 0 1 1h2.586a2 2 0 0 0 1.414-.586l9.5-9.5a2 2 0 0 0 0-2.828l-2-2z" stroke="#333" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M15 5l-10 10" stroke="#333" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
            <input ref="fileInput" type="file" accept="image/*" @change="onFileChange" style="display:none" />
          </div>
        </div>
        <input v-model="name" placeholder="Category Name" required />
        <button type="submit" class="primary-btn" :disabled="uploading">Update Category</button>
      </form>
      <p v-if="message" class="form-message">{{ message }}</p>
      <!-- Delete Confirmation -->
      <div v-if="showDeleteConfirm" class="modal-overlay">
        <div class="modal-content">
          <h2>Delete Category</h2>
          <p>Are you sure you want to delete <b>{{ name }}</b>? This cannot be undone.</p>
          <button class="delete-btn" @click="deleteCategory">Yes, Delete</button>
          <button class="close-btn" @click="showDeleteConfirm = false">Cancel</button>
        </div>
      </div>
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
      link: '',
      receivingOrders: false,
      email: '',
      message: '',
      loaded: false,
      imageFile: null,
      imagePreview: '',
      uploading: false,
      showDeleteConfirm: false
    };
  },
  mounted() {
    const id = this.$route.params.id;
    const db = firebase.firestore();
    db.collection('categories').doc(id).get().then(doc => {
      if (doc.exists) {
        const data = doc.data();
        this.name = data.name || '';
        this.link = data.link || '';
        this.receivingOrders = data.receivingOrders === true;
        this.email = data.email || '';
        this.loaded = true;
      } else {
        this.message = 'Category not found.';
      }
    }).catch(err => {
      this.message = 'Error: ' + err.message;
    });
  },
  methods: {
    triggerFileInput() {
      this.$refs.fileInput.click();
    },
    onFileChange(e) {
      const file = e.target.files[0];
      if (file) {
        this.imageFile = file;
        this.imagePreview = URL.createObjectURL(file);
      }
    },
    async uploadImage() {
      if (!this.imageFile) return this.link;
      this.uploading = true;
      const storageRef = firebase.storage().ref();
      const fileName = `category_images/${Date.now()}_${this.imageFile.name}`;
      const imageRef = storageRef.child(fileName);
      await imageRef.put(this.imageFile);
      const url = await imageRef.getDownloadURL();
      this.uploading = false;
      return url;
    },
    async updateCategory() {
      const id = this.$route.params.id;
      let newLink = this.link;
      if (this.imageFile) {
        newLink = await this.uploadImage();
      }
      const db = firebase.firestore();
      db.collection('categories').doc(id).update({
        name: this.name,
        link: newLink,
        receivingOrders: this.receivingOrders,
        email: this.email
      }).then(() => {
        this.message = 'Category updated!';
        setTimeout(() => {
          this.$router.push('/admin');
        }, 1000);
      }).catch(err => {
        this.message = 'Error: ' + err.message;
      });
    },
    goBack() {
      this.$router.push('/admin');
    },
    async deleteCategory() {
      const id = this.$route.params.id;
      const db = firebase.firestore();
      await db.collection('categories').doc(id).delete();
      this.showDeleteConfirm = false;
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
  right: 1.2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  z-index: 10;
}
.edit-actions-right {
  display: flex;
  gap: 0.5rem;
}
.menu-btn {
  background: #ffb300;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 0.4rem 1rem;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
}
.menu-btn:hover {
  background: #ff9800;
}
.delete-btn {
  background: #e53935;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 0.4rem 1rem;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
}
.delete-btn:hover {
  background: #b71c1c;
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
.close-btn {
  background: #e53935 !important;
  color: #fff !important;
  border: none !important;
  border-radius: 8px;
  padding: 1rem 2rem;
  font-size: 1.1rem;
  cursor: pointer;
  transition: background 0.2s;
  width: 100%;
  margin-bottom: 0.5rem;
}
.close-btn:hover {
  background: #b71c1c !important;
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
.image-hero-container {
  position: relative;
  display: inline-block;
}
.image-preview {
  width: 100px;
  height: 100px;
  object-fit: cover;
  border-radius: 10px;
  border: 1px solid #eee;
}
.edit-image-btn {
  position: absolute;
  bottom: 8px;
  right: 8px;
  background: #fff;
  border: none;
  border-radius: 50%;
  box-shadow: 0 2px 8px rgba(0,0,0,0.10);
  padding: 0.3rem 0.4rem 0.2rem 0.4rem;
  cursor: pointer;
  z-index: 2;
  transition: background 0.2s;
}
.edit-image-btn:hover {
  background: #f0f0f0;
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
  .primary-btn, .close-btn {
    font-size: 1rem;
    padding: 0.7rem 1rem;
  }
}
</style> 