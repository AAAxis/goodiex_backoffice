// Updated methods for ManageStore.vue

// Replace the existing getDnsValue method:
getDnsValue() {
  // Use the IP address Vercel provided, with fallback to default
  return this.store?.vercelDnsIp || '216.198.79.193'
},

// Add method to get CNAME value
getCnameValue() {
  return this.store?.vercelCname || 'cname.vercel-dns.com'
},

// Add method to manually update DNS IP
async updateDnsIp(newIp) {
  if (!newIp || !newIp.match(/^\d+\.\d+\.\d+\.\d+$/)) {
    this.showMessage('Please enter a valid IP address (e.g., 216.198.79.193)', 'error')
    return
  }

  try {
    const updateData = {
      vercelDnsIp: newIp,
      lastDnsConfigFetch: new Date()
    }

    await db.collection('stores').doc(this.storeId).update(updateData)
    await this.fetchStore()
    
    this.showMessage(`DNS IP updated to ${newIp}!`, 'success')
    
  } catch (error) {
    console.error('Error updating DNS IP:', error)
    this.showMessage('Failed to update DNS IP.', 'error')
  }
},

// Method to manually input DNS IP
showDnsIpInput() {
  const newIp = prompt('Enter the DNS IP address from Vercel:', this.store?.vercelDnsIp || '216.198.79.193')
  if (newIp) {
    this.updateDnsIp(newIp)
  }
}, 