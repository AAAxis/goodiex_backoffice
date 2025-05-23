<template>
  <div class="admin-menu-wrapper">
    <div class="admin-menu-content">
      <div class="edit-actions">
        <button class="back-btn" @click="goBack" title="Back">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M15 19l-7-7 7-7" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </button>
        <div class="edit-actions-right">
          <div class="dropdown-wrapper" ref="dropdown">
            <button class="burger-btn" @click="toggleDropdown" title="More actions">
              <svg width="24" height="24" viewBox="0 0 24 24"><circle cx="5" cy="12" r="2" fill="#333"/><circle cx="12" cy="12" r="2" fill="#333"/><circle cx="19" cy="12" r="2" fill="#333"/></svg>
            </button>
            <div v-if="showDropdown" class="dropdown-menu">
              <button class="dropdown-item" @click="goToEditCategory">Edit Category</button>
              <button class="dropdown-item delete" @click="deleteCategory">Delete Category</button>
              <button class="dropdown-item" @click="toggleReceivingOrders">Receiving Orders: {{ receivingOrders ? 'On' : 'Off' }}</button>
            </div>
          </div>
        </div>
      </div>
      <h1 class="admin-dashboard-title">Edit Menu</h1>
      <p v-if="message" class="form-message">{{ message }}</p>
      <div v-if="!loaded" class="loading">Loading...</div>
      <div v-else>
        <h2 class="category-name">{{ categoryName }}</h2>
        <div class="menu-table-wrapper">
          <table class="menu-table">
            <thead>
              <tr>
                <th>Image</th>
                <th>Name</th>
                <th>Price</th>
                <th>Edit</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="product in products" :key="product.id">
                <td>
                  <img v-if="product.image_url" :src="product.image_url" class="menu-item-image" alt="Product" />
                </td>
                <td>{{ product.name }}</td>
                <td>${{ product.price }}</td>
                <td>
                  <button class="delete-icon-btn" @click="deleteProduct(product)" title="Delete">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                      <path d="M3 6h18" stroke="#e53935" stroke-width="2" stroke-linecap="round"/>
                      <path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" stroke="#e53935" stroke-width="2"/>
                      <rect x="5" y="6" width="14" height="14" rx="2" stroke="#e53935" stroke-width="2"/>
                      <path d="M10 11v6" stroke="#e53935" stroke-width="2" stroke-linecap="round"/>
                      <path d="M14 11v6" stroke="#e53935" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <!-- Floating Add Button -->
        <button class="fab" @click="goToAdd">+</button>
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
      categoryId: '',
      categoryName: '',
      products: [],
      loaded: false,
      categoryLoaded: false,
      name: '',
      link: '',
      imageFile: null,
      imagePreview: '',
      uploading: false,
      message: '',
      showDropdown: false,
      receivingOrders: false
    };
  },
  mounted() {
    this.categoryId = this.$route.params.categoryId;
    this.fetchCategory();
    this.fetchProducts();
    document.addEventListener('click', this.handleClickOutside);
  },
  beforeDestroy() {
    document.removeEventListener('click', this.handleClickOutside);
  },
  methods: {
    fetchCategory() {
      const db = firebase.firestore();
      db.collection('categories').doc(this.categoryId).get().then(doc => {
        if (doc.exists) {
          const data = doc.data();
          this.categoryName = data.name || '';
          this.name = data.name || '';
          this.link = data.link || '';
          this.receivingOrders = data.receivingOrders === true;
          this.categoryLoaded = true;
        }
      });
    },
    fetchProducts() {
      this.loaded = false;
      const db = firebase.firestore();
      db.collection('categories').doc(this.categoryId).collection('products').get().then(querySnapshot => {
        this.products = [];
        querySnapshot.forEach(doc => {
          const data = doc.data();
          data.id = doc.id;
          this.products.push(data);
        });
        this.loaded = true;
      });
    },
    deleteProduct(product) {
      const db = firebase.firestore();
      db.collection('categories').doc(this.categoryId).collection('products').doc(product.id).delete().then(() => {
        this.fetchProducts();
      });
    },
    goToAdd() {
      this.$router.push(`/admin/menu/${this.categoryId}/add`);
    },
    goBack() {
      this.$router.push('/admin');
    },
    goToEditCategory() {
      this.$router.push(`/admin/edit/${this.categoryId}`);
    },
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
      let newLink = this.link;
      if (this.imageFile) {
        newLink = await this.uploadImage();
      }
      const db = firebase.firestore();
      db.collection('categories').doc(this.categoryId).update({
        name: this.name,
        link: newLink,
      }).then(() => {
        this.message = 'Category updated!';
        setTimeout(() => {
          this.message = '';
        }, 1000);
        this.fetchCategory();
      }).catch(err => {
        this.message = 'Error: ' + err.message;
      });
    },
    toggleDropdown() {
      this.showDropdown = !this.showDropdown;
    },
    toggleReceivingOrders() {
      const db = firebase.firestore();
      const newValue = !this.receivingOrders;
      db.collection('categories').doc(this.categoryId).update({ receivingOrders: newValue }).then(() => {
        this.receivingOrders = newValue;
        this.showDropdown = false;
      });
    },
    handleClickOutside(event) {
      if (this.showDropdown && this.$refs.dropdown && !this.$refs.dropdown.contains(event.target)) {
        this.showDropdown = false;
      }
    },
    deleteCategory() {
      this.showDropdown = false;
      const db = firebase.firestore();
      db.collection('categories').doc(this.categoryId).delete().then(() => {
        this.message = 'Category deleted!';
        setTimeout(() => {
          this.message = '';
          this.$router.push('/admin');
        }, 1000);
      }).catch(err => {
        this.message = 'Error: ' + err.message;
      });
    }
  }
};
</script>

<style scoped>
.admin-menu-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  padding: 1rem;
}
.admin-menu-content {
  background: #fff;
  padding: 2rem 2.5rem;
  border-radius: 18px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.10);
  min-width: 320px;
  max-width: 480px;
  width: 100%;
  text-align: center;
  position: relative;
  margin: 0 auto;
}
.admin-dashboard-title {
  margin-bottom: 2rem;
  font-size: 2rem;
  font-weight: bold;
  color: #333;
}
.category-name {
  font-size: 1.2rem;
  color: #555;
  margin-bottom: 1.5rem;
}
.menu-table-wrapper {
  width: 100%;
  overflow-x: auto;
  margin-bottom: 2rem;
}
.menu-table {
  width: 100%;
  border-collapse: collapse;
  background: #f9f9f9;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
.menu-table th, .menu-table td {
  padding: 0.8rem 0.5rem;
  text-align: left;
  border-bottom: 1px solid #eee;
  font-size: 1rem;
}
.menu-table th {
  background: #f1f1f1;
  color: #333;
  font-weight: 600;
}
.menu-table td img.menu-item-image {
  width: 48px;
  height: 48px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #eee;
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
.loading {
  color: #888;
  font-size: 1.2rem;
  margin: 2rem 0;
}
.fab {
  position: fixed;
  bottom: 32px;
  right: 32px;
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: #4CAF50;
  color: #fff;
  font-size: 2.5rem;
  border: none;
  box-shadow: 0 4px 16px rgba(0,0,0,0.18);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1001;
  transition: background 0.2s;
}
.fab:hover {
  background: #388e3c;
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
.delete-icon-btn {
  background: none;
  border: none;
  padding: 0.2rem;
  border-radius: 50%;
  cursor: pointer;
  transition: background 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}
.delete-icon-btn:hover {
  background: #ffeaea;
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
  .admin-menu-content {
    padding: 1rem 0.5rem;
    min-width: unset;
    max-width: 100vw;
    border-radius: 0.7rem;
  }
  .admin-dashboard-title {
    font-size: 1.3rem;
  }
  .primary-btn, .close-btn {
    font-size: 1rem;
    padding: 0.7rem 1rem;
  }
  .menu-table th, .menu-table td {
    font-size: 0.95rem;
    padding: 0.5rem 0.2rem;
  }
  .fab {
    bottom: 1.2rem;
    right: 1.2rem;
    width: 48px;
    height: 48px;
  }
  .fab svg {
    width: 28px;
    height: 28px;
  }
}
.edit-actions {
  position: relative;
  display: flex;
  justify-content: flex-start;
  align-items: center;
  z-index: 10;
  min-height: 48px;
}
.edit-actions-right {
  margin-left: auto;
  display: flex;
  gap: 0.5rem;
}
.dropdown-wrapper {
  position: relative;
  display: inline-block;
}
.burger-btn {
  background: none;
  border: none;
  padding: 0.2rem 0.5rem;
  cursor: pointer;
  border-radius: 50%;
  transition: background 0.2s;
}
.burger-btn:hover {
  background: #f0f0f0;
}
.dropdown-menu {
  position: absolute;
  top: 2.2rem;
  right: 0;
  background: #fff;
  border: 1px solid #eee;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.10);
  min-width: 180px;
  z-index: 100;
  display: flex;
  flex-direction: column;
  padding: 0.5rem 0;
}
.dropdown-item {
  background: none;
  border: none;
  text-align: left;
  padding: 0.7rem 1.2rem;
  font-size: 1rem;
  color: #333;
  cursor: pointer;
  transition: background 0.2s;
}
.dropdown-item:hover {
  background: #f5f5f5;
}
.dropdown-item.delete {
  color: #e53935;
}
</style> 