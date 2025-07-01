<template>
  <div class="plans-wrapper">
    <h1>Choose Your Plan</h1>
    <div class="plans-list">
      <div v-for="plan in plans" :key="plan.id" class="plan-card">
        <h2>{{ plan.name }}</h2>
        <p>{{ plan.description }}</p>
        <div class="plan-price">${{ plan.price }}/{{ plan.interval }}</div>
        <ul>
          <li v-for="feature in plan.features" :key="feature">{{ feature }}</li>
        </ul>
        <button @click="subscribe(plan.id)" :disabled="subscribing">
          {{ subscribing ? 'Subscribing...' : 'Subscribe' }}
        </button>
      </div>
    </div>
    <p v-if="message" :class="messageType">{{ message }}</p>
  </div>
</template>

<script>
import axios from 'axios'
import { getAuth } from 'firebase/auth'

export default {
  name: 'Plans',
  data() {
    return {
      plans: [
        {
          id: 'basic',
          name: 'Basic',
          description: 'For individuals starting out.',
          price: 9.99,
          interval: 'month',
          features: ['1 Store', 'Up to 10 Products', 'Basic Support']
        },
        {
          id: 'pro',
          name: 'Pro',
          description: 'For growing businesses.',
          price: 29.99,
          interval: 'month',
          features: ['5 Stores', 'Up to 100 Products', 'Priority Support']
        },
        {
          id: 'enterprise',
          name: 'Enterprise',
          description: 'For large businesses.',
          price: 99.99,
          interval: 'month',
          features: ['Unlimited Stores', 'Unlimited Products', '24/7 Support']
        }
      ],
      subscribing: false,
      message: '',
      messageType: ''
    }
  },
  methods: {
    async subscribe(planId) {
      this.subscribing = true
      this.message = ''
      try {
        const auth = getAuth()
        const user = auth.currentUser
        if (!user) {
          this.message = 'You must be logged in to subscribe.'
          this.messageType = 'error'
          this.subscribing = false
          return
        }
        await axios.post('https://pay.theholylabs.com/subscriptions', {
          user_id: user.uid,
          plan_id: planId
        })
        this.message = 'Subscription successful!'
        this.messageType = 'success'
      } catch (error) {
        this.message = 'Failed to subscribe. Please try again.'
        this.messageType = 'error'
      } finally {
        this.subscribing = false
      }
    }
  }
}
</script>

<style scoped>
.plans-wrapper {
  max-width: 900px;
  margin: 2rem auto;
  padding: 2rem;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
.plans-list {
  display: flex;
  gap: 2rem;
  justify-content: center;
  flex-wrap: wrap;
}
@media (min-width: 900px) {
  .plans-list {
    flex-wrap: nowrap;
  }
}
.plan-card {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 2rem;
  width: 260px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  display: flex;
  flex-direction: column;
  align-items: center;
}
.plan-card h2 {
  margin-bottom: 0.5rem;
}
.plan-price {
  font-size: 1.5rem;
  color: #4CAF50;
  margin: 1rem 0;
}
.plan-card ul {
  list-style: none;
  padding: 0;
  margin: 1rem 0;
}
.plan-card li {
  margin-bottom: 0.5rem;
}
.plan-card button {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
}
.plan-card button:disabled {
  background: #ccc;
  cursor: not-allowed;
}
.success {
  color: #155724;
  background: #d4edda;
  border: 1px solid #c3e6cb;
  padding: 0.75rem;
  border-radius: 6px;
  margin-top: 1rem;
}
.error {
  color: #721c24;
  background: #f8d7da;
  border: 1px solid #f5c6cb;
  padding: 0.75rem;
  border-radius: 6px;
  margin-top: 1rem;
}
</style> 