<template>
  <div class="success-container">
    <div class="success-card">
      <div class="success-icon">
        <i class="fa fa-check-circle"></i>
      </div>
      <h1 class="success-title">Subscription Successful!</h1>
      <p class="success-message">
        Thank you {{ customerName }} for your subscription!
      </p>
      <div v-if="loading" class="loading">
        <p>Processing your subscription...</p>
      </div>
      <div v-else-if="subscriptionDetails" class="subscription-details">
        <h3>Subscription Details</h3>
        <p><strong>Plan:</strong> {{ planName }}</p>
        <p><strong>Amount:</strong> {{ formatPrice(subscriptionDetails.amount_total, subscriptionDetails.currency) }}</p>
        <p><strong>Email:</strong> {{ subscriptionDetails.customer_email }}</p>
        <div v-if="subscriptionProcessed" class="subscription-status">
          <i class="fa fa-check-circle text-success"></i>
          <span class="text-success">Subscription activated successfully</span>
        </div>
      </div>
      <div v-if="error" class="error-message">
        <p>{{ error }}</p>
      </div>
      <div class="success-actions">
        <router-link to="/store-owner/dashboard" class="btn btn-primary btn-lg">
          Go to Dashboard
        </router-link>

      </div>
    </div>
  </div>
</template>

<script>
import { auth, db } from '../../firebase'
import axios from 'axios'

export default {
  name: 'SubscriptionSuccess',
  data() {
    return {
      loading: true,
      subscriptionDetails: null,
      customerName: '',
      planName: '',
      subscriptionProcessed: false,
      error: null,
      user: null
    }
  },
  async mounted() {
    // Wait for auth state
    auth.onAuthStateChanged(async (user) => {
      if (user) {
        this.user = user
        await this.processSubscription()
      } else {
        this.error = 'Please log in to access this page'
        this.loading = false
      }
    })
  },
  methods: {
    async processSubscription() {
      try {
        // Get session ID from URL
        const urlParams = new URLSearchParams(window.location.search)
        const sessionId = urlParams.get('session_id')
        
        if (!sessionId) {
          throw new Error('No session ID found in URL')
        }
        
        // Retrieve session details from Stripe
        const response = await axios.post('https://pay.theholylabs.com/retrieve-session', {
          session_id: sessionId
        })
        
        if (response.data.status !== 'success') {
          throw new Error(response.data.error || 'Failed to retrieve session')
        }
        
        this.subscriptionDetails = response.data
        
        // Get customer name from Firebase user
        const userDoc = await db.collection('storeOwners').doc(this.user.uid).get()
        if (userDoc.exists) {
          this.customerName = userDoc.data().name || this.user.displayName || this.user.email
        } else {
          this.customerName = this.user.displayName || this.user.email
        }
        
        // Extract plan name from URL params or set default
        const planId = urlParams.get('plan') || 'subscription'
        this.planName = this.formatPlanName(planId)
        
        // Save Stripe customer ID to Firebase
        if (response.data.customer_id) {
          await this.saveCustomerIdToFirebase(response.data.customer_id)
          this.subscriptionProcessed = true
        }
        
      } catch (error) {
        console.error('Error processing subscription:', error)
        this.error = error.message || 'Failed to process subscription'
      } finally {
        this.loading = false
      }
    },
    
    async saveCustomerIdToFirebase(customerId) {
      try {
        // Prepare update data, filtering out undefined values
        const updateData = {
          stripeCustomerId: customerId,
          subscriptionStatus: 'active',
          subscriptionProcessedAt: new Date(),
          updatedAt: new Date()
        }

        // Only add fields if they have valid values
        if (this.subscription?.items?.data?.[0]?.price?.lookup_key) {
          updateData.planId = this.subscription.items.data[0].price.lookup_key
        }

        if (this.subscription?.id) {
          updateData.subscriptionId = this.subscription.id
        }

        if (this.subscription?.items?.data?.[0]?.price?.nickname) {
          updateData.planName = this.subscription.items.data[0].price.nickname
        }

        console.log('Saving subscription data to Firebase:', updateData)

        await db.collection('storeOwners').doc(this.user.uid).update(updateData)
        console.log('Stripe customer ID and subscription status saved to Firebase:', customerId)
      } catch (error) {
        console.error('Error saving customer ID to Firebase:', error)
        throw new Error('Failed to save subscription details')
      }
    },
    
    getCurrencySymbol(currency) {
      const symbols = {
        'USD': '$',
        'EUR': '€',
        'GBP': '£',
        'JPY': '¥',
        'CAD': 'C$',
        'AUD': 'A$',
        'CHF': 'CHF',
        'CNY': '¥',
        'SEK': 'kr',
        'NOK': 'kr',
        'MXN': '$',
        'INR': '₹',
        'BRL': 'R$',
        'RUB': '₽',
        'KRW': '₩',
        'SGD': 'S$',
        'HKD': 'HK$',
        'NZD': 'NZ$',
        'TRY': '₺',
        'ZAR': 'R',
        'ILS': '₪'
      }
      return symbols[currency?.toUpperCase()] || '$'
    },
    
    formatPrice(amount, currency) {
      if (!amount || !currency) return '$0.00'
      const symbol = this.getCurrencySymbol(currency)
      const price = (amount / 100).toFixed(2) // Stripe amounts are in cents
      return `${symbol}${price}`
    },
    
    formatPlanName(planId) {
      const planNames = {
        'basic': 'Basic Plan',
        'pro': 'Pro Plan', 
        'enterprise': 'Enterprise Plan',
        'starter': 'Starter Plan',
        'premium': 'Premium Plan'
      }
      return planNames[planId?.toLowerCase()] || (planId ? planId.charAt(0).toUpperCase() + planId.slice(1) + ' Plan' : 'Subscription Plan')
    }
  }
}
</script>

<style scoped>
.success-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #4CAF50 0%, #81C784 100%);
  padding: 2rem;
}

.success-card {
  background: white;
  border-radius: 20px;
  padding: 3rem;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
  max-width: 600px;
  width: 100%;
}

.success-icon {
  font-size: 4rem;
  color: #4CAF50;
  margin-bottom: 1.5rem;
}

.success-title {
  color: #2d3748;
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
}

.success-message {
  color: #6c757d;
  font-size: 1.1rem;
  margin-bottom: 2rem;
}

.loading {
  margin: 2rem 0;
  color: #6c757d;
}

.subscription-details {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 12px;
  margin-bottom: 2rem;
  text-align: left;
}

.subscription-details h3 {
  color: #2d3748;
  margin-bottom: 1rem;
  text-align: center;
}

.subscription-details p {
  margin-bottom: 0.5rem;
  color: #495057;
}

.subscription-status {
  margin-top: 1rem;
  padding: 0.5rem;
  background: #d4edda;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  justify-content: center;
}

.text-success {
  color: #28a745 !important;
}

.error-message {
  background: #f8d7da;
  color: #721c24;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 2rem;
}

.success-actions {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

@media (min-width: 576px) {
  .success-actions {
    flex-direction: row;
    justify-content: center;
  }
}

.btn {
  padding: 0.75rem 2rem;
  border-radius: 50px;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
}

.btn-primary {
  background: #4CAF50;
  color: white;
}

.btn-primary:hover {
  background: #45a049;
  transform: translateY(-2px);
}

.btn-outline-secondary {
  border: 2px solid #6c757d;
  color: #6c757d;
  background: transparent;
}

.btn-outline-secondary:hover {
  background: #6c757d;
  color: white;
  transform: translateY(-2px);
}

@media (max-width: 768px) {
  .success-container {
    padding: 1rem;
  }
  
  .success-card {
    padding: 2rem;
  }
  
  .success-title {
    font-size: 2rem;
  }
  
  .success-actions {
    flex-direction: column;
  }
}
</style> 