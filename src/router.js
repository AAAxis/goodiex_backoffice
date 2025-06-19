import { createRouter, createWebHistory } from 'vue-router';
import Home from './components/Index.vue';
import ProductList from './components/ProductList.vue';
import Cart from './components/Cart.vue';
import PaymentSuccess from './components/PaymentSuccess.vue';
import AdminDashboard from './components/AdminDashboard.vue';
import AdminAddCategory from './components/AdminAddCategory.vue';
import AdminEditCategory from './components/AdminEditCategory.vue';
import AdminMenuManager from './components/AdminMenuManager.vue';
import AdminAddProduct from './components/AdminAddProduct.vue';
import Contact from './components/Contact.vue';



const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home,
  },
  {
    path: '/shop',
    name: 'Shop',
    component: ProductList
  },
  {
    path: '/shop/:categoryId',
    name: 'ShopCategory',
    component: ProductList,
    props: true
  },
  {
    path: '/shop/:categoryId/:productId',
    name: 'ShopProduct',
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

  {
    path: '/admin',
    name: 'AdminDashboard',
    component: AdminDashboard,
  },

  {
    path: '/admin/add',
    name: 'AdminAddCategory',
    component: AdminAddCategory,
  },

  {
    path: '/admin/edit/:id',
    name: 'AdminEditCategory',
    component: AdminEditCategory,
    props: true
  },

  {
    path: '/admin/menu/:categoryId',
    name: 'AdminMenuManager',
    component: AdminMenuManager,
    props: true
  },

  {
    path: '/admin/menu/:categoryId/add',
    name: 'AdminAddProduct',
    component: AdminAddProduct,
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
