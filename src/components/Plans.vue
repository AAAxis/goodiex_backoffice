<template>
  <div class="plans-wrapper">
    <h1>Choose Your Plan</h1>
    <div v-if="user">
      <div class="plans-list">
        <div v-for="plan in plans" :key="plan.id" class="plan-card">
          <h2>{{ plan.name }}</h2>
          <p>{{ plan.description }}</p>
          <div class="plan-price">${{ plan.price }}/{{ plan.interval }}</div>
          <ul>
            <li v-for="feature in plan.features" :key="feature">{{ feature }}</li>
          </ul>
          <button @click="subscribe(plan)" :disabled="subscribingId === plan.id">
            {{ subscribingId === plan.id ? 'Redirecting...' : 'Subscribe' }}
          </button>
        </div>
      </div>
    </div>
    <div v-else>
      <p>Please <router-link to="/store-owner/login">log in</router-link> to subscribe to a plan.</p>
    </div>
    <p v-if="message" :class="messageType">{{ message }}</p>
  </div>
</template>

<script>
import axios from 'axios'
import { getAuth, onAuthStateChanged } from 'firebase/auth'
import { getFirestore, doc, getDoc } from 'firebase/firestore'

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
      subscribingId: '',
      message: '',
      messageType: '',
      user: null,
      profileName: ''
    }
  },
  created() {
    const auth = getAuth()
    this.user = auth.currentUser
    onAuthStateChanged(auth, async (user) => {
      this.user = user
      if (user) {
        // Fetch name from Firestore
        const db = getFirestore()
        const userDoc = await getDoc(doc(db, 'storeOwners', user.uid))
        if (userDoc.exists()) {
          this.profileName = userDoc.data().name || user.displayName || user.email
        } else {
          this.profileName = user.displayName || user.email
        }
      } else {
        this.profileName = ''
      }
    })
  },
  methods: {
    async subscribe(plan) {
      this.subscribingId = plan.id
      this.message = ''
      try {
        const auth = getAuth()
        const user = auth.currentUser
        if (!user) {
          this.message = 'You must be logged in to subscribe.'
          this.messageType = 'error'
          this.subscribingId = ''
          return
        }
        const nameToSend = this.profileName || user.displayName || user.email
        const res = await axios.post('https://pay.theholylabs.com/create-checkout-session', {
          order: plan.id,
          email: user.email,
          name: nameToSend,
          total: plan.price,
          currency: 'usd',
          isYearly: plan.interval === 'year',
          domain: window.location.origin
        })
        if (res.data && res.data.sessionUrl) {
          window.location.href = res.data.sessionUrl
        } else {
          this.message = 'Failed to start payment session.'
          this.messageType = 'error'
        }
      } catch (error) {
        this.message = 'Failed to start payment session.'
        this.messageType = 'error'
      } finally {
        this.subscribingId = ''
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