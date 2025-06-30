# Domain Management Setup Guide

This guide will help you set up the domain management feature for your store.

## Required Environment Variables

You need to set up the following environment variables for the domain management feature to work:

### 1. Vercel API Token

1. Go to your [Vercel Dashboard](https://vercel.com/dashboard)
2. Navigate to Settings → Tokens
3. Create a new token with the following scopes:
   - `domains:read`
   - `domains:write`
   - `projects:read`
4. Copy the generated token

### 2. Vercel Project ID

1. In your Vercel Dashboard, go to your project
2. Navigate to Settings → General
3. Copy the Project ID (it starts with `prj_`)

## Environment Configuration

Create a `.env` file in your project root with the following variables:

```env
VITE_VERCEL_API_TOKEN=your_vercel_api_token_here
VITE_VERCEL_PROJECT_ID=your_vercel_project_id_here
```

## Common Issues and Solutions

### 400 Bad Request Error

If you're getting a 400 Bad Request error when adding a domain, check the following:

1. **Environment Variables**: Make sure both `VITE_VERCEL_API_TOKEN` and `VITE_VERCEL_PROJECT_ID` are set correctly
2. **Domain Format**: Ensure the domain is in the correct format (e.g., `yourstore.com` without `http://` or `www.`)
3. **Domain Ownership**: You must own the domain you're trying to add
4. **Vercel Project**: The project ID must be valid and you must have access to it
5. **API Token Permissions**: Your API token must have the required scopes

### Domain Already Exists

If a domain already exists in Vercel (either in your account or another account), you'll need to:
1. Remove it from the other project first
2. Or use a different domain

### DNS Configuration

After successfully adding a domain, you'll need to configure DNS records:

1. **A Record**: Point your domain to `76.76.19.76`
2. **CNAME Record** (optional): Point `www.yourdomain.com` to `cname.vercel-dns.com`

## Testing the Setup

1. Start your development server
2. Go to a store's management page
3. Navigate to the "Domain Settings" tab
4. Try adding a domain
5. Check the browser console for detailed error messages if issues occur

## Troubleshooting

### Check Environment Variables

You can verify your environment variables are loaded by checking the browser console. The domain management code will log the values being used (without exposing the actual token).

### API Token Validation

To test if your API token is valid, you can make a test request:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" https://api.vercel.com/v1/user
```

### Project ID Validation

To verify your project ID is correct, check it matches the one in your Vercel dashboard under Project Settings → General.

## Security Notes

- Never commit your `.env` file to version control
- Keep your API tokens secure and rotate them regularly
- Use environment-specific tokens for development and production 