import { createRouter, createWebHistory } from 'vue-router';
import Home from './components/Index.vue';
import StoreList from './components/StoreList.vue';
import ProductList from './components/ProductList.vue';
import Cart from './components/Cart.vue';
import PaymentSuccess from './components/PaymentSuccess.vue';
import Contact from './components/Contact.vue';

// Store Owner Components
import StoreOwnerRegister from './components/StoreOwnerRegister.vue';
import StoreOwnerLogin from './components/StoreOwnerLogin.vue';
import StoreOwnerDashboard from './components/StoreOwnerDashboard.vue';
import StoreOwnerSettings from './components/StoreOwnerSettings.vue';
import CreateStore from './components/CreateStore.vue';
import EditStore from './components/EditStore.vue';
import ManageStore from './components/ManageStore.vue';
import CreateProduct from './components/CreateProduct.vue';



const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home,
  },
  {
    path: '/shop',
    name: 'Shop',
    component: StoreList
  },
  {
    path: '/shop/store/:storeId',
    name: 'ShopStore',
    component: ProductList,
    props: true
  },
  {
    path: '/cart',
    name: 'Cart',
    component: Cart
  },
  {
    path: '/payment-success',
    name: 'PaymentSuccess',
    component: PaymentSuccess
  },

  // Store Owner Routes
  {
    path: '/store-owner/register',
    name: 'StoreOwnerRegister',
    component: StoreOwnerRegister,
  },
  {
    path: '/store-owner/login',
    name: 'StoreOwnerLogin',
    component: StoreOwnerLogin,
  },
  {
    path: '/store-owner/dashboard',
    name: 'StoreOwnerDashboard',
    component: StoreOwnerDashboard,
  },
  {
    path: '/store-owner/settings',
    name: 'StoreOwnerSettings',
    component: StoreOwnerSettings,
  },
  {
    path: '/store-owner/create-store',
    name: 'CreateStore',
    component: CreateStore,
  },
  {
    path: '/store-owner/edit-store/:storeId',
    name: 'EditStore',
    component: EditStore,
    props: true
  },
  {
    path: '/store-owner/manage-store/:storeId',
    name: 'ManageStore',
    component: ManageStore,
    props: true
  },
  {
    path: '/store-owner/manage-store/:storeId/create-product',
    name: 'CreateProduct',
    component: CreateProduct,
    props: true
  },

  {
    path: '/contact',
    name: 'Contact',
    component: Contact
  },
];


const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
