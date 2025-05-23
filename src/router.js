import { createRouter, createWebHistory } from 'vue-router';
import Home from './components/Index.vue';
import ShoppingCart from './components/ShoppingCart.vue';
import Payment from './components/Payment.vue';
import AdminDashboard from './components/AdminDashboard.vue';
import AdminAddCategory from './components/AdminAddCategory.vue';
import AdminEditCategory from './components/AdminEditCategory.vue';
import AdminMenuManager from './components/AdminMenuManager.vue';
import AdminAddProduct from './components/AdminAddProduct.vue';



const routes = [

 

  {
    path: '/payment/:orderID',
    name: 'Payment',
    component: Payment,
  },


  {
    path: '/',
    name: 'Home',
    component: Home,
  },


  {
    path: '/:token?/shop',
    name: 'ShoppingCart',
    component: ShoppingCart
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
];


const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
