@app.route('/create-payment-order', methods=['POST'])
def create_checkout_session():
    if not stripe.api_key:
        # Try to reload API keys from database
        load_api_keys_from_db()
        if not stripe.api_key:
            return jsonify({'error': 'Stripe API key not configured. Please configure via environment variables'}), 503
    
    try:
        data = request.json
        order = data.get('order')
        email = data.get('email')
        total = data.get('total')
        name = data.get('name')
        currency = data.get('currency', 'usd').lower()  # Accept currency from frontend, default to USD

        # Validate currency format (Stripe expects lowercase 3-letter codes)
        if not currency or len(currency) != 3:
            currency = 'usd'

        # Create checkout session with Stripe
        session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=[{
                'price_data': {
                    'currency': currency,  # Use dynamic currency
                    'product_data': {
                        'name': f'Order {order}',
                    },
                    'unit_amount': int(float(total) * 100),
                },
                'quantity': 1,
            }],
            mode='payment',

            success_url=f'https://goodiex.vercel.app/payment-success?order={order}&email={email}&total={total}&name={name}&currency={currency}',
        
            cancel_url='https://api.theholylabs.com/error',
            customer_email=email,
        )

        return jsonify({'sessionUrl': session.url, 'status': 'success'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


