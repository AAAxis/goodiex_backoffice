<template>
  <div class="container mt-5">
    <div class="row justify-content-center">
      <div class="col-lg-8">
        <div class="card shadow">
          <div class="card-header bg-danger text-white">
            <h2 class="mb-0">
              <i class="fas fa-trash-alt me-2"></i>
              Delete My Data
            </h2>
          </div>
          <div class="card-body">
            <div class="alert alert-warning">
              <i class="fas fa-exclamation-triangle me-2"></i>
              <strong>Important:</strong> This action will permanently delete your account and all associated data from our mobile applications. This action cannot be undone.
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-info-circle text-primary me-2"></i>What Will Be Deleted</h5>
              <ul>
                <li>Your user account and profile information</li>
                <li>Order history and preferences</li>
                <li>Saved addresses and payment methods</li>
                <li>App usage data and analytics</li>
                <li>All personal information stored in our systems</li>
              </ul>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-clock text-primary me-2"></i>Deletion Process</h5>
              <ol>
                <li>Submit your deletion request using the form below</li>
                <li>We will verify your identity within 24-48 hours</li>
                <li>Your data will be permanently deleted within 30 days</li>
                <li>You will receive a confirmation email once deletion is complete</li>
              </ol>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-shield-alt text-primary me-2"></i>Data Retention Exceptions</h5>
              <p>Some data may be retained for legal or regulatory purposes:</p>
              <ul>
                <li>Transaction records required for tax purposes</li>
                <li>Information needed for legal compliance</li>
                <li>Data required for fraud prevention</li>
              </ul>
            </div>

            <form @submit.prevent="submitDeletionRequest" class="mt-4">
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label for="firstName" class="form-label">First Name *</label>
                  <input 
                    type="text" 
                    class="form-control" 
                    id="firstName" 
                    v-model="form.firstName"
                    required
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label for="lastName" class="form-label">Last Name *</label>
                  <input 
                    type="text" 
                    class="form-control" 
                    id="lastName" 
                    v-model="form.lastName"
                    required
                  >
                </div>
              </div>

              <div class="mb-3">
                <label for="email" class="form-label">Email Address *</label>
                <input 
                  type="email" 
                  class="form-control" 
                  id="email" 
                  v-model="form.email"
                  required
                >
                <div class="form-text">This should be the email associated with your mobile app account</div>
              </div>

              <div class="mb-3">
                <label for="phone" class="form-label">Phone Number</label>
                <input 
                  type="tel" 
                  class="form-control" 
                  id="phone" 
                  v-model="form.phone"
                  placeholder="+1 (555) 123-4567"
                >
              </div>

              <div class="mb-3">
                <label for="appType" class="form-label">Mobile App Type *</label>
                <select class="form-select" id="appType" v-model="form.appType" required>
                  <option value="">Select your app</option>
                  <option value="ios">iOS App</option>
                  <option value="android">Android App</option>
                  <option value="both">Both iOS and Android</option>
                </select>
              </div>

              <div class="mb-3">
                <label for="reason" class="form-label">Reason for Deletion (Optional)</label>
                <textarea 
                  class="form-control" 
                  id="reason" 
                  rows="3"
                  v-model="form.reason"
                  placeholder="Please let us know why you're requesting data deletion. This helps us improve our services."
                ></textarea>
              </div>

              <div class="mb-3">
                <div class="form-check">
                  <input 
                    class="form-check-input" 
                    type="checkbox" 
                    id="confirmDeletion" 
                    v-model="form.confirmDeletion"
                    required
                  >
                  <label class="form-check-label" for="confirmDeletion">
                    I understand that this action will permanently delete my account and all associated data. This action cannot be undone.
                  </label>
                </div>
              </div>

              <div class="mb-3">
                <div class="form-check">
                  <input 
                    class="form-check-input" 
                    type="checkbox" 
                    id="confirmIdentity" 
                    v-model="form.confirmIdentity"
                    required
                  >
                  <label class="form-check-label" for="confirmIdentity">
                    I confirm that I am the rightful owner of this account and have the authority to request data deletion.
                  </label>
                </div>
              </div>

              <div class="d-grid gap-2">
                <button 
                  type="submit" 
                  class="btn btn-danger btn-lg"
                  :disabled="!form.confirmDeletion || !form.confirmIdentity || isSubmitting"
                >
                  <i class="fas fa-trash-alt me-2"></i>
                  {{ isSubmitting ? 'Submitting Request...' : 'Submit Deletion Request' }}
                </button>
                <button 
                  type="button" 
                  class="btn btn-outline-secondary"
                  @click="$router.push('/')"
                >
                  <i class="fas fa-arrow-left me-2"></i>
                  Cancel
                </button>
              </div>
            </form>

            <div class="mt-4">
              <h5><i class="fas fa-question-circle text-primary me-2"></i>Need Help?</h5>
              <p>If you have questions about the data deletion process or need assistance, please contact us:</p>
              <ul>
                <li><strong>Email:</strong> privacy@foodiex.com</li>
                <li><strong>Phone:</strong> +1 (555) 123-4567</li>
                <li><strong>Response Time:</strong> Within 24-48 hours</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Success Modal -->
    <div class="modal fade" id="successModal" tabindex="-1" ref="successModal">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header bg-success text-white">
            <h5 class="modal-title">
              <i class="fas fa-check-circle me-2"></i>
              Request Submitted Successfully
            </h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <p>Your data deletion request has been submitted successfully. We will:</p>
            <ul>
              <li>Verify your identity within 24-48 hours</li>
              <li>Process your deletion request within 30 days</li>
              <li>Send you a confirmation email once completed</li>
            </ul>
            <p class="mb-0"><strong>Reference ID:</strong> {{ referenceId }}</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-success" data-bs-dismiss="modal" @click="$router.push('/')">
              Return to Home
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { Modal } from 'bootstrap'

export default {
  name: 'DeleteData',
  data() {
    return {
      form: {
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        appType: '',
        reason: '',
        confirmDeletion: false,
        confirmIdentity: false
      },
      isSubmitting: false,
      referenceId: ''
    }
  },
  mounted() {
    // Scroll to top when component mounts
    window.scrollTo(0, 0);
  },
  methods: {
    async submitDeletionRequest() {
      this.isSubmitting = true;
      
      try {
        // Generate a reference ID
        this.referenceId = 'DEL-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9).toUpperCase();
        
        // Simulate API call
        await new Promise(resolve => setTimeout(resolve, 2000));
        
        // Show success modal
        const modal = new Modal(this.$refs.successModal);
        modal.show();
        
        // Reset form
        this.form = {
          firstName: '',
          lastName: '',
          email: '',
          phone: '',
          appType: '',
          reason: '',
          confirmDeletion: false,
          confirmIdentity: false
        };
        
      } catch (error) {
        console.error('Error submitting deletion request:', error);
        alert('An error occurred while submitting your request. Please try again.');
      } finally {
        this.isSubmitting = false;
      }
    }
  }
}
</script>

<style scoped>
.card {
  border: none;
  border-radius: 15px;
}

.card-header {
  border-radius: 15px 15px 0 0 !important;
  background: linear-gradient(135deg, #dc3545, #c82333) !important;
}

.card-body {
  padding: 2rem;
}

h5 {
  color: #333;
  border-bottom: 2px solid #f8f9fa;
  padding-bottom: 0.5rem;
  margin-bottom: 1rem;
}

ul, ol {
  padding-left: 1.5rem;
}

li {
  margin-bottom: 0.5rem;
}

.alert {
  border-radius: 10px;
  border: none;
}

.form-control, .form-select {
  border-radius: 8px;
  border: 1px solid #dee2e6;
}

.form-control:focus, .form-select:focus {
  border-color: #dc3545;
  box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
}

.btn {
  border-radius: 8px;
  font-weight: 500;
}

.btn-danger {
  background: linear-gradient(135deg, #dc3545, #c82333);
  border: none;
}

.btn-danger:hover {
  background: linear-gradient(135deg, #c82333, #bd2130);
}

.modal-content {
  border-radius: 15px;
  border: none;
}

.modal-header {
  border-radius: 15px 15px 0 0;
}
</style> 