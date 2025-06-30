from flask import Flask, request, jsonify
from flask_cors import CORS
import dns.resolver
import socket
import re
import requests
from datetime import datetime
import json

app = Flask(__name__)
CORS(app)

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

@app.route('/api/domain/verify', methods=['POST'])
def verify_domain():
    """Verify if a domain is valid and accessible"""
    try:
        data = request.get_json()
        domain = data.get('domain')
        
        if not domain:
            return jsonify({'error': 'Domain is required'}), 400
        
        # Basic domain format validation
        domain_pattern = r'^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?\.[a-zA-Z]{2,}$'
        if not re.match(domain_pattern, domain):
            return jsonify({'error': 'Invalid domain format'}), 400
        
        # Check if domain resolves
        try:
            ip_address = socket.gethostbyname(domain)
            dns_status = 'resolved'
        except socket.gaierror:
            ip_address = None
            dns_status = 'unresolved'
        
        # Check for common DNS records
        dns_records = {}
        try:
            # Check A record
            answers = dns.resolver.resolve(domain, 'A')
            dns_records['A'] = [str(rdata) for rdata in answers]
        except:
            dns_records['A'] = []
        
        try:
            # Check CNAME record
            answers = dns.resolver.resolve(domain, 'CNAME')
            dns_records['CNAME'] = [str(rdata) for rdata in answers]
        except:
            dns_records['CNAME'] = []
        
        try:
            # Check MX record
            answers = dns.resolver.resolve(domain, 'MX')
            dns_records['MX'] = [str(rdata) for rdata in answers]
        except:
            dns_records['MX'] = []
        
        return jsonify({
            'domain': domain,
            'dns_status': dns_status,
            'ip_address': ip_address,
            'dns_records': dns_records,
            'verified_at': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/domain/check-dns', methods=['POST'])
def check_dns_configuration():
    """Check if DNS is properly configured for the store"""
    try:
        data = request.get_json()
        domain = data.get('domain')
        store_id = data.get('store_id')
        expected_cname = data.get('expected_cname')
        
        if not all([domain, store_id, expected_cname]):
            return jsonify({'error': 'Domain, store_id, and expected_cname are required'}), 400
        
        # Check if CNAME is properly configured
        cname_configured = False
        try:
            answers = dns.resolver.resolve(domain, 'CNAME')
            for rdata in answers:
                if str(rdata).rstrip('.') == expected_cname.rstrip('.'):
                    cname_configured = True
                    break
        except:
            pass
        
        # Check if domain resolves to our infrastructure
        resolves_correctly = False
        try:
            ip_address = socket.gethostbyname(domain)
            # You can add additional checks here to verify the IP belongs to your infrastructure
            resolves_correctly = True
        except:
            pass
        
        return jsonify({
            'domain': domain,
            'store_id': store_id,
            'cname_configured': cname_configured,
            'resolves_correctly': resolves_correctly,
            'expected_cname': expected_cname,
            'status': 'active' if cname_configured and resolves_correctly else 'pending',
            'checked_at': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/domain/generate-cname', methods=['POST'])
def generate_cname():
    """Generate a unique CNAME for a store"""
    try:
        data = request.get_json()
        store_id = data.get('store_id')
        
        if not store_id:
            return jsonify({'error': 'Store ID is required'}), 400
        
        # Generate a unique CNAME for the store
        cname = f"store-{store_id}.goodiex.com"
        
        return jsonify({
            'store_id': store_id,
            'cname': cname,
            'dns_type': 'CNAME',
            'dns_name': '@',
            'dns_value': cname,
            'generated_at': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)


