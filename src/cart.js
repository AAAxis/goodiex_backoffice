// Shared cart store using Vue 3 reactive system
import { reactive } from 'vue'

const cartStore = reactive({
  items: [],
  
  get total() {
    return this.items.reduce((total, item) => total + item.product.price * item.quantity, 0);
  },
  
  get itemCount() {
    return this.items.reduce((total, item) => total + item.quantity, 0);
  },
  
  addItem(product) {
    const existingItem = this.items.find(item => item.product.id === product.id);
    if (existingItem) {
      existingItem.quantity++;
    } else {
      this.items.push({
        product,
        quantity: 1
      });
    }
    this.saveToStorage();
  },
  
  removeItem(index) {
    this.items.splice(index, 1);
    this.saveToStorage();
  },
  
  updateQuantity(index, quantity) {
    if (quantity <= 0) {
      this.removeItem(index);
    } else {
      this.items[index].quantity = quantity;
      this.saveToStorage();
    }
  },
  
  clearCart() {
    this.items = [];
    this.saveToStorage();
  },
  
  saveToStorage() {
    localStorage.setItem('foodiex_cart', JSON.stringify(this.items));
  },
  
  loadFromStorage() {
    const savedCart = localStorage.getItem('foodiex_cart');
    if (savedCart) {
      this.items = JSON.parse(savedCart);
    }
  }
});

// Load cart from storage on initialization
cartStore.loadFromStorage();

export default cartStore;