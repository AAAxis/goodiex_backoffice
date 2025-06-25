// Shared cart store using Vue 3 reactive system
import { reactive } from 'vue'

const cartStore = reactive({
  items: [],
  currentStoreId: null, // Track which store the cart belongs to
  
  get total() {
    return this.items.reduce((total, item) => total + item.product.price * item.quantity, 0);
  },
  
  get itemCount() {
    return this.items.reduce((total, item) => total + item.quantity, 0);
  },
  
  addItem(product) {
    // Check if this product is from a different store
    if (this.currentStoreId && this.currentStoreId !== product.storeId) {
      // Clear cart if switching to a different store
      this.clearCart();
    }
    
    // Set the current store ID
    this.currentStoreId = product.storeId;
    
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
    
    // If cart becomes empty, clear the store ID
    if (this.items.length === 0) {
      this.currentStoreId = null;
    }
    
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
    this.currentStoreId = null;
    this.saveToStorage();
  },
  
  saveToStorage() {
    const cartData = {
      items: this.items,
      currentStoreId: this.currentStoreId
    };
    localStorage.setItem('foodiex_cart', JSON.stringify(cartData));
  },
  
  loadFromStorage() {
    const savedCart = localStorage.getItem('foodiex_cart');
    if (savedCart) {
      try {
        const cartData = JSON.parse(savedCart);
        if (cartData.items) {
          this.items = cartData.items;
          this.currentStoreId = cartData.currentStoreId || null;
        } else {
          // Handle old format
          this.items = cartData;
          this.currentStoreId = this.items.length > 0 ? this.items[0].product.storeId : null;
        }
      } catch (error) {
        console.error('Error loading cart from storage:', error);
        this.items = [];
        this.currentStoreId = null;
      }
    }
  }
});

// Load cart from storage on initialization
cartStore.loadFromStorage();

export default cartStore;