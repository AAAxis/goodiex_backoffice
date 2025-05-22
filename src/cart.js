export default {
    namespaced: true,
    state: {
      items: [],
      total: 0,
    },
    mutations: {
      addItem(state, item) {
        state.items.push(item);
        state.total += item.price;
      },
      removeItem(state, index) {
        const item = state.items[index];
        state.items.splice(index, 1);
        state.total -= item.price;
      },
      clearCart(state) {
        state.items = [];
        state.total = 0;
      },
    },
    actions: {
      addToCart({ commit }, item) {
        commit('addItem', item);
      },
      removeFromCart({ commit, state }, index) {
        commit('removeItem', index);
      },
      clearCart({ commit }) {
        commit('clearCart');
      },
    },
  };