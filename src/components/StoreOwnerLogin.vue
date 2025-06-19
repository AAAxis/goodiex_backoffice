<template>
  <div class="login-wrapper">
    <div class="login-content">
      <h1 class="login-title">Store Owner Login</h1>
      <form @submit.prevent="login" class="login-form">
        <input 
          v-model="email" 
          type="email" 
          placeholder="Email Address" 
          required 
        />
        <input 
          v-model="password" 
          type="password" 
          placeholder="Password" 
          required 
        />
        <button type="submit" class="login-btn" :disabled="loading">
          {{ loading ? 'Logging in...' : 'Login' }}
        </button>
      </form>
      <p v-if="message" class="form-message error">{{ message }}</p>
      <div class="register-link">
        <p>Don't have an account? <router-link to="/store-owner/register">Register here</router-link></p>
      </div>
    </div>
  </div>
</template>

<script>
import { auth, db } from '../../firebase'

export default {
  name: 'StoreOwnerLogin',
  data() {
    return {
      email: '',
      password: '',
      loading: false,
      message: ''
    }
  },
  methods: {
    async login() {
      this.loading = true
      this.message = ''

      try {
        const userCredential = await auth.signInWithEmailAndPassword(this.email, this.password)
        const user = userCredential.user

        // Verify user is a store owner
        const userDoc = await db.collection('storeOwners').doc(user.uid).get()
        if (!userDoc.exists) {
          throw new Error('Account not found or access denied')
        }

        const userData = userDoc.data()
        if (userData.role !== 'store_owner' || !userData.isActive) {
          throw new Error('Access denied')
        }

        this.$router.push('/store-owner/dashboard')

      } catch (error) {
        console.error('Login error:', error)
        this.message = this.getErrorMessage(error.code || error.message)
      } finally {
        this.loading = false
      }
    },

    getErrorMessage(errorCode) {
      switch (errorCode) {
        case 'auth/user-not-found':
        case 'auth/wrong-password':
        case 'auth/invalid-credential':
          return 'Invalid email or password'
        case 'auth/too-many-requests':
          return 'Too many failed attempts. Please try again later.'
        case 'Account not found or access denied':
        case 'Access denied':
          return 'Access denied. Please contact support.'
        default:
          return 'Login failed. Please try again.'
      }
    }
  }
}
</script>

<style scoped>
.login-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  padding: 1rem;
}

.login-content {
  background: #fff;
  padding: 2rem 2.5rem;
  border-radius: 18px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.10);
  min-width: 320px;
  max-width: 420px;
  width: 100%;
  text-align: center;
}

.login-title {
  margin-bottom: 2rem;
  font-size: 1.8rem;
  font-weight: bold;
  color: #333;
}

.login-form input {
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

.login-form input:focus {
  border: 1.5px solid #4CAF50;
  outline: none;
}

.login-btn {
  width: 100%;
  padding: 1rem 2rem;
  background: #4CAF50;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 1.1rem;
  cursor: pointer;
  transition: background 0.2s;
  margin-top: 1rem;
}

.login-btn:hover:not(:disabled) {
  background: #388e3c;
}

.login-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.form-message {
  margin-top: 1rem;
  padding: 0.5rem;
  border-radius: 4px;
  font-size: 1rem;
}

.form-message.error {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.register-link {
  margin-top: 1.5rem;
  color: #666;
}

.register-link a {
  color: #4CAF50;
  text-decoration: none;
  font-weight: 500;
}

.register-link a:hover {
  text-decoration: underline;
}
</style> 