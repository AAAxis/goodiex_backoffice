<template>
  <div class="container mt-5">
    <div class="row justify-content-center">
      <div class="col-lg-8">
        <div class="card shadow">
          <div class="card-header bg-primary text-white">
            <h2 class="mb-0">
              <i class="fas fa-shield-alt me-2"></i>
              Privacy Policy
            </h2>
          </div>
          <div class="card-body">
            <div class="mb-4">
              <h4>Last Updated: {{ new Date().toLocaleDateString() }}</h4>
              <p class="text-muted">This Privacy Policy describes how Foodie Express ("we," "us," or "our") collects, uses, and protects your information when you use our mobile applications and services.</p>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-info-circle text-primary me-2"></i>Information We Collect</h5>
              <ul>
                <li><strong>Personal Information:</strong> Name, email address, phone number, delivery address</li>
                <li><strong>Device Information:</strong> Device ID, IP address, operating system, app version</li>
                <li><strong>Usage Data:</strong> Order history, preferences, search queries, location data</li>
                <li><strong>Payment Information:</strong> Payment method details (processed securely through Stripe)</li>
              </ul>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-cogs text-primary me-2"></i>How We Use Your Information</h5>
              <ul>
                <li>Process and fulfill your food orders</li>
                <li>Provide customer support and respond to inquiries</li>
                <li>Send order confirmations and delivery updates</li>
                <li>Improve our services and user experience</li>
                <li>Send promotional offers (with your consent)</li>
                <li>Ensure security and prevent fraud</li>
              </ul>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-share-alt text-primary me-2"></i>Information Sharing</h5>
              <p>We do not sell, trade, or rent your personal information to third parties. We may share your information with:</p>
              <ul>
                <li>Restaurant partners to fulfill your orders</li>
                <li>Delivery services to complete deliveries</li>
                <li>Payment processors to process payments</li>
                <li>Legal authorities when required by law</li>
              </ul>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-lock text-primary me-2"></i>Data Security</h5>
              <p>We implement appropriate security measures to protect your personal information, including:</p>
              <ul>
                <li>Encryption of sensitive data</li>
                <li>Secure payment processing</li>
                <li>Regular security audits</li>
                <li>Access controls and authentication</li>
              </ul>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-cookie-bite text-primary me-2"></i>Cookies and Tracking</h5>
              <p>We use cookies and similar technologies to:</p>
              <ul>
                <li>Remember your preferences</li>
                <li>Analyze app usage</li>
                <li>Provide personalized content</li>
                <li>Improve our services</li>
              </ul>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-user-check text-primary me-2"></i>Your Rights</h5>
              <p>You have the right to:</p>
              <ul>
                <li>Access your personal information</li>
                <li>Correct inaccurate data</li>
                <li>Request deletion of your data</li>
                <li>Opt-out of marketing communications</li>
                <li>Withdraw consent at any time</li>
              </ul>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-globe text-primary me-2"></i>International Transfers</h5>
              <p>Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your data.</p>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-baby text-primary me-2"></i>Children's Privacy</h5>
              <p>Our services are not intended for children under 13. We do not knowingly collect personal information from children under 13.</p>
            </div>

            <div class="mb-4">
              <h5><i class="fas fa-phone text-primary me-2"></i>Contact Us</h5>
              <p>If you have questions about this Privacy Policy or our data practices, please contact us:</p>
              <ul>
                <li><strong>Email:</strong> dima@theholylabs.com</li>
                <li><strong>Phone:</strong> +1 (236) 234-4580</li>
                <li><strong>Address:</strong> 1578 Hunter St, North Vancouver, BC</li>
              </ul>
            </div>

            <div class="alert alert-info">
              <i class="fas fa-exclamation-triangle me-2"></i>
              <strong>Note:</strong> This Privacy Policy may be updated from time to time. We will notify you of any material changes through the app or email.
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PrivacyPolicy',
  mounted() {
    // Scroll to top when component mounts
    window.scrollTo(0, 0);
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
  background: linear-gradient(135deg, #007bff, #0056b3) !important;
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

ul {
  padding-left: 1.5rem;
}

li {
  margin-bottom: 0.5rem;
}

.alert {
  border-radius: 10px;
  border: none;
}
</style> 