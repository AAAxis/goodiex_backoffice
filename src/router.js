import { createRouter, createWebHistory } from 'vue-router';
import Home from './components/Index.vue';
import ShoppingCart from './components/ShoppingCart.vue';
import Payment from './components/Payment.vue';



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
];


const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
