<template>
  <div class="container my-5">
    <h2 class="mb-4">Contact Us</h2>
    <form @submit.prevent="submitForm">
      <div class="mb-3">
        <label for="contact-name" class="form-label">Your Name</label>
        <input type="text" class="form-control" id="contact-name" v-model="name" required />
      </div>
      <div class="mb-3">
        <label for="contact-email" class="form-label">Your Email</label>
        <input type="email" class="form-control" id="contact-email" v-model="email" required />
      </div>
      <div class="mb-3">
        <label for="contact-message" class="form-label">Message</label>
        <textarea class="form-control" id="contact-message" v-model="message" rows="5" required></textarea>
      </div>
      <button type="submit" class="btn btn-success" :disabled="loading">Send Message</button>
      <div class="mt-3">
        <span v-if="successMessage" class="text-success">{{ successMessage }}</span>
        <span v-if="errorMessage" class="text-danger">{{ errorMessage }}</span>
      </div>
    </form>
  </div>
</template>

<script>
export default {
  name: 'Contact',
  data() {
    return {
      name: '',
      email: '',
      message: '',
      loading: false,
      successMessage: '',
      errorMessage: ''
    };
  },
  methods: {
    async submitForm() {
      this.successMessage = '';
      this.errorMessage = '';
      this.loading = true;
      try {
        const params = new URLSearchParams({
          name: this.name,
          email: this.email,
          text: this.message
        });
        const response = await fetch(`https://api.theholylabs.com/subscribe?${params.toString()}`, {
          method: 'POST'
        });
        if (response.ok) {
          this.successMessage = 'Thank you for contacting us!';
          this.name = '';
          this.email = '';
          this.message = '';
        } else {
          this.errorMessage = 'There was an error. Please try again later.';
        }
      } catch (error) {
        this.errorMessage = 'There was an error. Please try again later.';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script> 