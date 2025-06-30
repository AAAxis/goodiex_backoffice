# Domain Management Feature

This feature allows store owners to connect their stores to custom domains, making their stores more professional and easier to remember.

## Features

### 1. Domain Connection
- Connect custom domains to stores
- Domain validation and verification
- Automatic DNS configuration generation
- Support for www redirects

### 2. DNS Management
- Automatic CNAME generation for each store
- DNS configuration instructions
- Real-time DNS status checking
- Copy DNS settings to clipboard

### 3. Domain Status Tracking
- Pending: Domain connected but DNS not configured
- Active: Domain properly configured and working
- Error: DNS configuration issues

## How It Works

### 1. Domain Connection Process
1. Store owner enters their domain name
2. System validates domain format
3. Backend verifies domain exists and resolves
4. System generates unique CNAME for the store
5. Store is updated with domain information

### 2. DNS Configuration
Users need to configure their domain's DNS settings:
- **Type**: CNAME
- **Name**: @ (or root domain)
- **Value**: `store-{storeId}.goodiex.com`

### 3. Status Monitoring
- Users can check DNS configuration status
- System automatically updates domain status
- Real-time feedback on configuration progress

## Backend Endpoints

### `/api/domain/verify`
- **Method**: POST
- **Purpose**: Verify domain validity and accessibility
- **Input**: `{ "domain": "example.com" }`
- **Output**: Domain verification results

### `/api/domain/check-dns`
- **Method**: POST
- **Purpose**: Check if DNS is properly configured
- **Input**: `{ "domain": "example.com", "store_id": "123", "expected_cname": "store-123.goodiex.com" }`
- **Output**: DNS configuration status

### `/api/domain/generate-cname`
- **Method**: POST
- **Purpose**: Generate unique CNAME for store
- **Input**: `{ "store_id": "123" }`
- **Output**: Generated CNAME and DNS settings

## Database Schema

### Store Document Updates
```javascript
{
  domain: "example.com",
  includeWww: true,
  domainStatus: "pending" | "active" | "error",
  domainCname: "store-123.goodiex.com",
  domainUpdatedAt: Timestamp,
  lastDnsCheck: Timestamp
}
```

## Security Considerations

1. **Domain Ownership**: Users must own the domains they connect
2. **DNS Validation**: System verifies DNS configuration before activation
3. **Rate Limiting**: Implement rate limiting on domain verification endpoints
4. **SSL Certificates**: Automatic SSL provisioning for connected domains

## Future Enhancements

1. **Bulk Domain Management**: Manage multiple domains per store
2. **Domain Analytics**: Track domain performance and traffic
3. **Automatic SSL**: Automatic SSL certificate provisioning
4. **Domain Transfer**: Transfer domains between stores
5. **Subdomain Support**: Support for subdomains (shop.example.com)

## Installation Requirements

### Backend Dependencies
```bash
pip install flask flask-cors dnspython
```

### Frontend Integration
The domain management feature is integrated into the ManageStore component with:
- Domain settings tab
- Real-time status updates
- DNS configuration assistance
- Professional UI/UX design 