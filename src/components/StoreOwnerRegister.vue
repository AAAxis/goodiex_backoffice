<template>
  <div class="register-wrapper">
    <div class="register-content">
      <h1 class="register-title">Create Store Owner Account</h1>
      <form @submit.prevent="register" class="register-form">
        <input 
          v-model="formData.name" 
          type="text" 
          placeholder="Full Name" 
          required 
        />
        <input 
          v-model="formData.email" 
          type="email" 
          placeholder="Email Address" 
          required 
        />
        <input 
          v-model="formData.password" 
          type="password" 
          placeholder="Password (min 6 characters)" 
          required 
          minlength="6"
        />
        <button type="submit" class="register-btn" :disabled="loading">
          {{ loading ? 'Creating Account...' : 'Create Account' }}
        </button>
      </form>
      <p v-if="message" class="form-message" :class="messageType">{{ message }}</p>
      <div class="login-link">
        <p>Already have an account? <router-link to="/store-owner/login">Login here</router-link></p>
      </div>
    </div>
  </div>
</template>

<script>
import { auth, db } from '../../firebase'

export default {
  name: 'StoreOwnerRegister',
  data() {
    return {
      formData: {
        name: '',
        email: '',
        password: ''
      },
      loading: false,
      message: '',
      messageType: ''
    }
  },
  methods: {
    async register() {
      this.loading = true
      this.message = ''

      try {
        // Create user account
        const userCredential = await auth.createUserWithEmailAndPassword(
          this.formData.email, 
          this.formData.password
        )
        
        const user = userCredential.user

        // Update user profile
        await user.updateProfile({
          displayName: this.formData.name
        })

        // Save additional user data to Firestore
        await db.collection('storeOwners').doc(user.uid).set({
          name: this.formData.name,
          email: this.formData.email,
          role: 'store_owner',
          createdAt: new Date(),
          isActive: true
        })

        this.showMessage('Account created successfully! Redirecting...', 'success')
        
        setTimeout(() => {
          this.$router.push('/store-owner/dashboard')
        }, 2000)

      } catch (error) {
        console.error('Registration error:', error)
        this.showMessage(this.getErrorMessage(error.code), 'error')
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

    getErrorMessage(errorCode) {
      switch (errorCode) {
        case 'auth/email-already-in-use':
          return 'An account with this email already exists'
        case 'auth/weak-password':
          return 'Password should be at least 6 characters'
        case 'auth/invalid-email':
          return 'Please enter a valid email address'
        default:
          return 'Registration failed. Please try again.'
      }
    }
  }
}
</script>

<style scoped>
.register-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  padding: 1rem;
}

.register-content {
  background: #fff;
  padding: 2rem 2.5rem;
  border-radius: 18px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.10);
  min-width: 320px;
  max-width: 420px;
  width: 100%;
  text-align: center;
}

.register-title {
  margin-bottom: 2rem;
  font-size: 1.8rem;
  font-weight: bold;
  color: #333;
}

.register-form input {
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

.register-form input:focus {
  border: 1.5px solid #4CAF50;
  outline: none;
}

.register-btn {
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

.register-btn:hover:not(:disabled) {
  background: #388e3c;
}

.register-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.form-message {
  margin-top: 1rem;
  padding: 0.5rem;
  border-radius: 4px;
  font-size: 1rem;
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

.login-link {
  margin-top: 1.5rem;
  color: #666;
}

.login-link a {
  color: #4CAF50;
  text-decoration: none;
  font-weight: 500;
}

.login-link a:hover {
  text-decoration: underline;
}
</style> 