import { createRouter, createWebHistory } from 'vue-router';
import Home from './components/Index.vue';
import StoreList from './components/StoreList.vue';
import ProductList from './components/ProductList.vue';
import ProductDetail from './components/ProductDetail.vue';
import Cart from './components/Cart.vue';
import PaymentSuccess from './components/PaymentSuccess.vue';
import Contact from './components/Contact.vue';
import PrivacyPolicy from './components/PrivacyPolicy.vue';
import DeleteData from './components/DeleteData.vue';

// Store Owner Components
import StoreOwnerRegister from './components/StoreOwnerRegister.vue';
import StoreOwnerLogin from './components/StoreOwnerLogin.vue';
import StoreOwnerDashboard from './components/StoreOwnerDashboard.vue';
import StoreOwnerSettings from './components/StoreOwnerSettings.vue';
import CreateStore from './components/CreateStore.vue';
import ManageStore from './components/ManageStore.vue';
import CreateProduct from './components/CreateProduct.vue';

// Import Firestore
import { db } from '../firebase';

const routes = [
  // Domain-based routing for root path
  {
    path: '/',
    name: 'DomainHome',
    component: Home,
    async beforeEnter(to, from, next) {
      const hostname = window.location.hostname;
      // Only redirect for custom domains (not localhost or main vercel domain)
      if (
        hostname !== 'localhost' &&
        hostname !== '127.0.0.1' &&
        !hostname.endsWith('.vercel.app')
      ) {
        try {
          const storesRef = db.collection('stores');
          const querySnapshot = await storesRef.where('domain', '==', hostname).get();
          if (!querySnapshot.empty) {
            const storeDoc = querySnapshot.docs[0];
            const storeId = storeDoc.id;
            next({ name: 'ShopStore', params: { storeId } });
            return;
          }
        } catch (error) {
          console.error('Domain lookup error:', error);
        }
      }
      next();
    }
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
    path: '/shop/store/:storeId/product/:productId',
    name: 'ProductDetail',
    component: ProductDetail,
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
  {
    path: '/privacy-policy',
    name: 'PrivacyPolicy',
    component: PrivacyPolicy
  },
  {
    path: '/delete-data',
    name: 'DeleteData',
    component: DeleteData
  },
];


const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
