<template>
  <div class="admin-dashboard-wrapper">
    <div>
      <div class="admin-header">
        <span class="admin-email">{{ loginEmail }}</span>
        <button class="logout-btn" @click="logout">Logout</button>
      </div>
      <h1 class="admin-dashboard-title">Admin Dashboard</h1>
      <div class="table-responsive">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Receiving Orders</th>
              <th>Email</th>
              <th>Image</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="category in categories" :key="category.id">
              <td>{{ category.name }}</td>
              <td>{{ category.receivingOrders ? 'Yes' : 'No' }}</td>
              <td>{{ category.email }}</td>
              <td>
                <img v-if="category.link" :src="category.link" alt="Category Image" style="width:60px; height:60px; object-fit:cover; border-radius:6px;" />
              </td>
              <td>
                <button class="edit-btn" @click="goToMenu(category.id)">Edit</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <!-- Floating Action Button -->
      <button class="fab" @click="goToAdd">+</button>
    </div>
  </div>
</template>

<script>
import { db } from '../../firebase';

export default {
  data() {
    return {
      loginEmail: '',
      categories: [],
      showDeleteConfirm: false,
      deleteTarget: null
    };
  },
  methods: {
    logout() {
      this.loginEmail = '';
    },
    fetchCategories() {
      db.collection('categories').get().then(querySnapshot => {
        this.categories = [];
        querySnapshot.forEach(doc => {
          const data = doc.data();
          data.id = doc.id;
          this.categories.push(data);
        });
      });
    },
    goToAdd() {
      this.$router.push('/admin/add');
    },
    goToMenu(id) {
      this.$router.push(`/admin/menu/${id}`);
    },
    confirmDelete(category) {
      this.deleteTarget = category;
      this.showDeleteConfirm = true;
    },
    deleteCategory() {
      db.collection('categories').doc(this.deleteTarget.id).delete().then(() => {
        this.fetchCategories();
        this.showDeleteConfirm = false;
        this.deleteTarget = null;
      });
    }
  },
  mounted() {
    this.loginEmail = '';
    this.fetchCategories();
  }
};
</script>

<style scoped>
.admin-dashboard-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
}
.admin-dashboard-content {
  background: #fff;
  padding: 2rem 2.5rem;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.08);
  min-width: 320px;
  max-width: 90vw;
  text-align: center;
  position: relative;
}
.admin-dashboard-title {
  margin-bottom: 2rem;
  font-size: 2.2rem;
  font-weight: bold;
  color: #333;
}
.admin-header {
  position: absolute;
  top: 1.5rem;
  right: 2rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  z-index: 10;
}
.admin-email {
  color: #333;
  font-size: 1rem;
  background: #f5f5f5;
  padding: 0.4rem 1rem;
  border-radius: 6px;
  font-weight: 500;
}
.logout-btn {
  background: #e53935;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 0.5rem 1.2rem;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
}
.logout-btn:hover {
  background: #b71c1c;
}
.admin-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 2rem;
}
.admin-table th, .admin-table td {
  border: 1px solid #ddd;
  padding: 0.5rem 0.7rem;
  text-align: left;
}
.admin-table th {
  background: #f0f0f0;
}
.table-responsive {
  overflow-x: auto;
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
.edit-btn {
  background: #1976d2;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 0.4rem 1rem;
  font-size: 1rem;
  cursor: pointer;
  margin-right: 0.5rem;
  transition: background 0.2s;
}
.edit-btn:hover {
  background: #0d47a1;
}
.menu-btn {
  background: #ffb300;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 0.4rem 1rem;
  font-size: 1rem;
  cursor: pointer;
  margin-right: 0.5rem;
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
.admin-login-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  padding: 1rem;
}
.admin-login-card {
  background: #fff;
  padding: 2rem 2.5rem;
  border-radius: 18px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.10);
  min-width: 320px;
  max-width: 420px;
  width: 100%;
  text-align: center;
  margin: 0 auto;
}
.admin-login-title {
  margin-bottom: 2rem;
  font-size: 1.5rem;
  font-weight: bold;
  color: #333;
}
.admin-login-input {
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
.admin-login-input:focus {
  border: 1.5px solid #4CAF50;
  outline: none;
}
.form-message.error {
  color: #e53935;
  margin-top: 1rem;
}
</style> 