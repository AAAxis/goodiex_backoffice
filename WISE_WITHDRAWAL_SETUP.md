# Wise Withdrawal System Setup

This system enables store owners to withdraw their earnings from their stores directly to their bank accounts using the Wise API.

## Features

- **Bank Account Management**: Add and manage multiple bank accounts
- **Balance Checking**: View available balance in different currencies
- **Withdrawal Processing**: Create withdrawals from Wise balance to bank accounts
- **Transaction History**: View all withdrawal transactions with status tracking

## Environment Variables

Add these environment variables to your payment service:

```bash
# Wise API Configuration
WISE_API_TOKEN=your_wise_api_token_here
WISE_MODE=sandbox  # or 'live' for production
```

## Wise API Setup

1. **Create Wise Account**: Sign up at [wise.com](https://wise.com)
2. **Get API Token**: 
   - Go to Wise Developer Portal
   - Create an application
   - Generate API token
3. **Set Environment Variables**: Add the token to your environment

## How to Use

### 1. Bank Accounts Tab
- **Add Bank Account**: Click "Add Bank Account" to add a new withdrawal destination
- **Required Information**:
  - Account holder name
  - Currency (USD, EUR, GBP, CAD)
  - Routing number (ABA)
  - Account number
  - Account type (checking/savings)

### 2. Balance & Withdrawals Tab
- **View Balance**: See available balance in all currencies
- **Create Withdrawal**:
  - Select amount to withdraw
  - Choose currency
  - Select target bank account
  - Click "Create Withdrawal"
- **Transaction History**: View all past withdrawals with status

## API Endpoints

The system adds these new endpoints to the payment service:

### Wise Profile Management
- `GET /wise/profiles` - Get Wise user profiles
- `POST /wise/balance` - Get balance for profile

### Bank Account Management
- `POST /wise/recipient-accounts` - Create bank account
- `GET /wise/recipient-accounts/{profile_id}` - Get bank accounts

### Withdrawal Processing
- `POST /wise/transfer-quote` - Create transfer quote
- `POST /wise/transfer` - Create transfer
- `POST /wise/transfer/{id}/fund` - Fund transfer
- `GET /wise/transfers/{profile_id}` - Get transfer history

## Transfer Statuses

- **incoming_payment_waiting**: Waiting for payment
- **processing**: Transfer is being processed
- **funds_converted**: Funds have been converted
- **outgoing_payment_sent**: Payment sent to bank account
- **charged**: Transfer completed successfully
- **cancelled**: Transfer was cancelled

## Security Notes

- API tokens are securely stored as environment variables
- All API requests use HTTPS
- Bank account details are handled by Wise's secure systems
- Only last 4 digits of account numbers are displayed in UI

## Testing

For testing, use Wise's sandbox environment:
- Set `WISE_MODE=sandbox`
- Use sandbox API token
- Transfers won't actually move real money

## Troubleshooting

1. **"Wise API token not configured"**: Check environment variables
2. **"No Wise profile selected"**: Ensure API token is valid and profile exists
3. **Transfer fails**: Check balance and bank account details
4. **API errors**: Check Wise API documentation for error codes

## Integration Notes

- The system automatically loads Wise data when the store management page loads
- Bank accounts are stored in Wise's system, not locally
- All monetary amounts are handled according to Wise's API requirements
- Currency formatting uses the existing store currency display system 