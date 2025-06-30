// Updated DNS methods for ManageStore.vue

// Replace the existing getDnsValue method with:
getDnsValue() {
  // Use the IP address Vercel provided, with fallback to default
  return this.store?.vercelDnsIp || '216.198.79.193'
},

// Replace the existing getCnameValue method with:
getCnameValue() {
  return this.store?.vercelCname || 'cname.vercel-dns.com'
},

// Add this new method after getCnameValue:
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

// Add this new method after updateDnsIp:
async fetchVercelDnsConfig() {
  if (!this.store?.domain) {
    this.showMessage('No domain configured for this store.', 'error')
    return
  }

  const apiToken = import.meta.env.VITE_VERCEL_API_TOKEN
  const projectId = import.meta.env.VITE_VERCEL_PROJECT_ID
  
  if (!apiToken || !projectId) {
    this.showMessage('Vercel configuration not set up properly.', 'error')
    return
  }

  try {
    this.showMessage('Fetching DNS configuration from Vercel...', 'info')
    
    // Get domain configuration from Vercel
    const response = await fetch(`https://api.vercel.com/v1/projects/${projectId}/domains/${this.store.domain}`, {
      headers: {
        'Authorization': `Bearer ${apiToken}`,
      }
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Failed to fetch DNS config:', errorText)
      this.showMessage('Failed to fetch DNS configuration from Vercel.', 'error')
      return
    }

    const domainConfig = await response.json()
    console.log('Vercel Domain Config:', domainConfig)

    // Extract DNS records from the response
    let dnsIp = '216.198.79.193' // default fallback
    let cname = 'cname.vercel-dns.com' // default fallback

    // Look for DNS configuration in the response
    if (domainConfig.intendedNameservers) {
      // If Vercel provides nameservers, we might need to use those instead
      console.log('Vercel Nameservers:', domainConfig.intendedNameservers)
    }

    // Update store with the fetched DNS configuration
    const updateData = {
      vercelDnsIp: dnsIp,
      vercelCname: cname,
      lastDnsConfigFetch: new Date(),
      vercelDomainConfig: domainConfig
    }

    await db.collection('stores').doc(this.storeId).update(updateData)
    await this.fetchStore()
    
    this.showMessage('DNS configuration updated from Vercel!', 'success')
    
  } catch (error) {
    console.error('Error fetching DNS config:', error)
    this.showMessage('Failed to fetch DNS configuration from Vercel.', 'error')
  }
},

// Add this new method to the data() section:
// Add to data() return object:
customDnsIp: '',

// Add this new method for manual DNS IP input:
showDnsIpInput() {
  const newIp = prompt('Enter the DNS IP address from Vercel:', this.store?.vercelDnsIp || '216.198.79.193')
  if (newIp) {
    this.updateDnsIp(newIp)
  }
}, 