<template>
  <!-- App Bar -->
  <nav class="navbar navbar-light bg-light mb-3 appbar">
    <div class="container-fluid d-flex align-items-center justify-content-between">
      <button class="btn btn-link text-dark p-0 me-2" @click="$router.back()" title="Back">
        <i class="fa fa-arrow-left"></i>
      </button>
      <span class="navbar-brand mb-0 h4 flex-grow-1 text-center">{{ storeName || 'Shop' }}</span>
      <span class="cart-icon ms-2 position-relative" @click="openCartModal" style="cursor:pointer;">
        <i class="fa fa-shopping-cart" style="color: #111;"></i>
        <span v-if="cartItems.length" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size:0.8rem;">
          {{ cartItems.length }}
        </span>
      </span>
    </div>
  </nav>
  <!-- Main Content -->
  <div>
    <router-view />
    <!-- Category Chips Block -->
    <div style="padding: 2rem;" class="container">
      <div class="row align-items-center mb-3">
        <div class="col-auto">
          <h2>Products</h2>
        </div>
        <div class="col">
          <div class="category-chips justify-content-end">
            <span
              v-for="cat in categories"
              :key="cat.id"
              class="chip"
              :class="{ selected: cat.id === selectedCategoryId }"
              @click="switchCategory(cat.id)"
            >
              {{ cat.name }}
            </span>
          </div>
        </div>
      </div>
      <div class="product-grid">
        <div class="product-grid__cards">
          <div v-for="product in products" :key="product.id" class="product-grid__card" @click="addToCart(product)">
            <div class="product-grid__info">
              <h4 class="product-grid__name">{{product.name}}</h4>
          
            </div>
            <div class="product-grid__image-wrapper">
            
         <img :src="product.image_url" class="product-grid__image">
              <div class="product-grid__add-to-cart">
              <button class="btn btn-success">Add ${{product.price}}.0</button> 
              </div>
            </div>
          
          </div>
        </div>
      </div>
    </div>

    <link href="https://polskoydm.pythonanywhere.com/static/styles/checkout.css" rel="stylesheet">
    <!-- Cart Modal -->
    <div class="modal fade" id="cartModal" tabindex="-1" aria-labelledby="cartModalLabel" aria-hidden="true" ref="cartModal">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="cartModalLabel">
              {{ checkoutStep === 'cart' ? 'Shopping Cart' : 'Checkout' }}
            </h5>
            <button type="button" class="btn-close" @click="closeCartModal"></button>
          </div>
          <div class="modal-body">
            <template v-if="checkoutStep === 'cart'">
              <div v-if="cartItems.length">
                <div v-for="(item, index) in cartItems" :key="index" class="item d-flex justify-content-between align-items-center p-2 rounded">
                  <div class="cart-modal-image-wrapper">
                    <img class="cart-modal-image" :src="item.product.image_url">
                    <div class="cart-modal-info ml-2">
                      <span class="font-weight-bold d-block">{{ item.product.name }}</span>
                      <span class="spec">{{ item.quantity }}x</span>
                    </div>
                  </div>
                  <div class="d-flex flex-row align-items-center">
                    <span class="d-block ml-3 font-weight-bold">${{ item.product.price }}.0</span>
                    <button class="btn btn-danger ml-3" style="margin-left: 2rem;" @click="removeFromCart(index)">
                      <i class="fa fa-trash-o text-white"></i>
                    </button>
                  </div>
                </div>
                <div class="d-flex justify-content-between align-items-center mt-3">
                  <span class="fw-bold">Total: ${{ cartTotal }}</span>
                  <button class="btn btn-primary" @click="checkoutStep = 'payment'">Checkout</button>
                </div>
              </div>
              <div v-else>
                <p>Your cart is empty.</p>
              </div>
            </template>
            <template v-else>
              <div>
                <div class="form-group mb-2">
                  <label for="email">Email</label>
                  <input type="email" id="email" v-model="email" required class="form-control">
                </div>
                <div class="form-group mb-2">
                  <label for="name">Name</label>
                  <input type="text" id="name" v-model="name" required class="form-control">
                </div>
                <div class="form-group mb-2">
                  <label for="address">Address</label>
                  <input type="text" id="address" v-model="address" required class="form-control">
                </div>
                <div class="d-flex justify-content-between align-items-center mt-3">
                  <button class="btn btn-secondary" @click="checkoutStep = 'cart'">Back</button>
                  <button class="btn btn-success" @click="submitPayment">Proceed to Payment</button>
                </div>
              </div>
            </template>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>
  
 <script>
import firebase from 'firebase/compat/app';
import 'firebase/compat/firestore';

export default {
  data() {
    return {
      storeName: '',
      products: [],
      cartItems: [],
      token: '', // Define token in data
      categories: [],
      selectedCategoryId: null,
      checkoutStep: 'cart', // 'cart' or 'payment'
      email: '',
      name: '',
      address: '',
      currentOrderID: null,
    }
  },
  created() {
    const token = window.location.href.split('/')[3]; // Assign token value
    const firebaseConfig = { 
    
        apiKey: "AIzaSyASwq11lvLT6YfaGwp7W_dCBICDzVsBbSM",
 authDomain: "bankapp-9798a.firebaseapp.com",
 projectId: "bankapp-9798a",
 storageBucket: "bankapp-9798a.appspot.com",
 messagingSenderId: "868698601721",
 appId: "1:868698601721:web:e061dcefcb437f53854a28",
 measurementId: "G-WY7R44DDM4"
    };
    firebase.initializeApp(firebaseConfig);
    const db = firebase.firestore();
    // Fetch all categories
    db.collection('categories').get().then(querySnapshot => {
      this.categories = [];
      querySnapshot.forEach(doc => {
        const data = doc.data();
        data.id = doc.id;
        this.categories.push(data);
      });
      // Set initial selected category
      this.selectedCategoryId = token || (this.categories[0] && this.categories[0].id);
      if (this.selectedCategoryId) {
        this.fetchProducts(this.selectedCategoryId);
      }
    });
  },
  computed: {
    cartTotal() {
      return this.cartItems.reduce((total, item) => total + item.product.price * item.quantity, 0);
    },
  },
  methods: {
    fetchProducts(categoryId) {
      const db = firebase.firestore();
      db.collection('categories').doc(categoryId).collection('products').get()
        .then(querySnapshot => {
          this.products = [];
          querySnapshot.forEach(doc => {
            const productData = doc.data();
            productData.id = doc.id;
            this.products.push(productData);
          });
          db.collection('categories').doc(categoryId).get()
            .then(categoryDoc => {
              if (categoryDoc.exists) {
                this.storeName = categoryDoc.data().name;
              } else {
                this.storeName = '';
              }
            });
        });
    },
    switchCategory(categoryId) {
      this.selectedCategoryId = categoryId;
      this.fetchProducts(categoryId);
    },
    addToCart(product) {
      console.log("Adding product to cart:", product);
      const cartItem = this.cartItems.find(item => item.product.id === product.id);
      if (cartItem) {
        cartItem.quantity++;
      } else {
        console.log("Adding new item to cart.");
        this.cartItems.push({
          product,
          quantity: 1,
        });
      }
    },
    removeFromCart(index) {
      this.cartItems.splice(index, 1);
    },
    checkout() {
      if (this.cartItems.length === 0) {
        alert('Your cart is empty!');
        return;
      }
      const token = window.location.href.split('/')[3]; // Assign token value
      const db = firebase.firestore();
      db.collection('orders').add({
        store: token,
        status: 'ordering',
        total: this.cartTotal,
        timestamp: firebase.firestore.FieldValue.serverTimestamp()
      })
      .then(docRef => {
        const orderID = docRef.id;
        const cartRef = db.collection('orders').doc(orderID).collection('cart');

        this.cartItems.forEach(item => {
          cartRef.add({
   

            product_image_url: item.product.image_url,
            product_name: item.product.name,
            
            price: item.product.price,
            quantity: item.quantity,
          })
          .then(() => {
            console.log('Item added to cart successfully');
          })
          .catch(error => {
            console.error('Error adding item to cart:', error);
          });
        });

        this.$router.push({ name: 'Payment', params: { orderID } });
      })
      .catch(error => {
        console.log('Error adding order:', error);
      });
    },
    openCartModal() {
      const modal = new window.bootstrap.Modal(this.$refs.cartModal);
      modal.show();
      this.checkoutStep = 'cart';
    },
    closeCartModal() {
      const modal = window.bootstrap.Modal.getInstance(this.$refs.cartModal);
      modal.hide();
      this.checkoutStep = 'cart';
    },
    async submitPayment() {
      if (!this.email || !this.name || !this.address) {
        alert('Please provide your email, name, and address.');
        return;
      }
      // Create or update order in Firestore
      const db = firebase.firestore();
      let orderID = this.currentOrderID;
      if (!orderID) {
        // Create new order
        const orderDoc = await db.collection('orders').add({
          store: this.storeName,
          status: 'ordering',
          total: this.cartTotal,
          timestamp: firebase.firestore.FieldValue.serverTimestamp(),
          email: this.email,
          name: this.name,
          address: this.address
        });
        orderID = orderDoc.id;
        this.currentOrderID = orderID;
        // Add cart items
        const cartRef = db.collection('orders').doc(orderID).collection('cart');
        for (const item of this.cartItems) {
          await cartRef.add({
            product_image_url: item.product.image_url,
            product_name: item.product.name,
            price: item.product.price,
            quantity: item.quantity,
          });
        }
      } else {
        // Update existing order
        await db.collection('orders').doc(orderID).update({
          email: this.email,
          name: this.name,
          address: this.address
        });
      }
      // Call backend to create checkout session
      try {
        const axios = (await import('axios')).default;
        const response = await axios.post('https://api.theholylabs.com/create-checkout-session', {
          order: orderID,
          email: this.email,
          total: this.cartTotal,
          name: this.name
        });
        window.location.href = response.data.sessionUrl;
      } catch (error) {
        console.error('Error creating checkout session:', error);
      }
    },
  }
};
</script>





<style>
.product-grid__card {
  position: relative;
}

.product-grid__add-to-cart {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: rgba(0, 0, 0, 0.5);
  
}




.product-grid__add-to-cart button {
  margin: 10px;
}


.product-grid {
  max-width: 1200px;
  margin: 0 auto;
}

.product-grid__cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));

  grid-gap: 20px;

}

.product-grid__card {
  border: 1px solid #ddd;
  border-radius: 5px;
  overflow: hidden;
  box-shadow: 0 0 5px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
}

.product-grid__image {
  width: 16rem;
  height: 16rem;
  
  object-fit: cover;
  display: block;
  margin: 0 auto;
}

.product-grid__info {
  flex: 1;
  padding: 10px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.product-grid__name {
  margin: 0;
}

.product-grid__description {
  margin: 10px 0;
}

.product-grid__price {
  margin: 0;
}

.product-grid__actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 10px;
}

.category-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 0;
}
.chip {
  display: inline-block;
  padding: 0.5rem 1.2rem;
  border-radius: 16px;
  background: #f1f1f1 !important;
  color: #333 !important;
  cursor: pointer;
  font-size: 1rem;
  border: 1px solid #ddd;
  transition: background 0.2s, color 0.2s;
}
.chip.selected {
  background: #111 !important;
  color: #fff !important;
  border-color: #111 !important;
}
.appbar {
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
.cart-icon {
  font-size: 1.5rem;
  color: #4caf50;
}
/* Modal cart item image and text layout */
.cart-modal-image-wrapper {
  display: flex;
  align-items: center;
}
.cart-modal-image {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #eee;
  margin-right: 1rem;
}
.cart-modal-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
</style>