<template>
  <nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container">
      <router-link class="navbar-brand" to="/">
        Goodiex
      </router-link>
      
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav me-auto">
          <li class="nav-item">
            <router-link class="nav-link" to="/">Home</router-link>
          </li>
          <li class="nav-item">
            <router-link class="nav-link" to="/shop">Shop</router-link>
          </li>
          <li class="nav-item">
            <router-link class="nav-link" to="/contact">Contact</router-link>
          </li>
          <li class="nav-item">
            <router-link class="nav-link" to="/plans">Plans</router-link>
          </li>
        </ul>
        
        <div class="d-flex align-items-center">
          <template v-if="!isLoggedIn">
            <router-link to="/store-owner/register" class="btn btn-outline-light">Register</router-link>
          </template>
          <div v-else class="dropdown">
            <button class="btn btn-outline-light dropdown-toggle" type="button" id="userMenu" data-bs-toggle="dropdown" aria-expanded="false">
              {{ userName }}
            </button>
            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userMenu">
              <li v-if="isAdmin"><router-link class="dropdown-item" to="/admin">Admin Dashboard</router-link></li>
              <li><router-link class="dropdown-item" to="/store-owner/dashboard">Profile</router-link></li>
              <li><hr class="dropdown-divider"></li>
              <li><a class="dropdown-item" href="#" @click.prevent="handleLogout">Logout</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </nav>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { getAuth, onAuthStateChanged, signOut } from 'firebase/auth'

export default {
  name: 'Navbar',
  setup() {
    const router = useRouter()
    const isLoggedIn = ref(false)
    const userName = ref('')
    const isAdmin = ref(false)

    onMounted(() => {
      const auth = getAuth()
      onAuthStateChanged(auth, (user) => {
        isLoggedIn.value = !!user
        if (user) {
          userName.value = user.displayName || user.email
          // Check if user has admin role - you'll need to implement this based on your data structure
          // isAdmin.value = ... check user's admin status
        }
      })
    })

    const handleLogout = async () => {
      try {
        const auth = getAuth()
        await signOut(auth)
        router.push('/')
      } catch (error) {
        console.error('Logout error:', error)
      }
    }

    return {
      isLoggedIn,
      userName,
      isAdmin,
      handleLogout
    }
  }
}
</script>

<style scoped>
.navbar {
  background-color: #1a1a1a;
  padding: 1rem 0;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
}

.navbar-brand {
  font-weight: 600;
  font-size: 1.5rem;
}

.nav-link {
  color: rgba(255, 255, 255, 0.8) !important;
  font-weight: 500;
  transition: color 0.3s ease;
}

.nav-link:hover {
  color: white !important;
}

.dropdown-menu {
  background-color: #ffffff;
  border: none;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.dropdown-item {
  padding: 0.5rem 1.5rem;
  color: #333;
}

.dropdown-item:hover {
  background-color: #f8f9fa;
  color: #4CAF50;
}

.btn-primary {
  background-color: #4CAF50;
  border-color: #4CAF50;
}

.btn-primary:hover {
  background-color: #388e3c;
  border-color: #388e3c;
}

@media (max-width: 991.98px) {
  .navbar-collapse {
    background-color: #1a1a1a;
    padding: 1rem;
    margin: 0 -1rem;
  }
}
</style> 