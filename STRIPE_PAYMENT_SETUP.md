# Stripe Payment Gateway Setup for NLCC Giving

This guide explains how to set up Stripe to process donations directly to the church's bank account.

## Overview

The app uses **Stripe** as the payment processor. Funds go directly to the church's UK bank account. The payment flow is:

1. User enters giving details (name, email, amount)
2. App sends payment request to your backend
3. Backend creates Stripe Payment Intent
4. User completes payment via Stripe Payment Sheet (secure)
5. Receipt sent to donor's email
6. Funds settle to church bank account

## Prerequisites

- Stripe account (https://stripe.com)
- UK bank account connected to Stripe
- Backend server to create Payment Intents (Firebase Cloud Functions, Node.js, etc.)

---

## Step 1: Create Stripe Account

1. Go to https://stripe.com
2. Click "Sign Up"
3. Enter church details: New Life Community Church, Tonyrefail
4. Verify email
5. Complete business information

## Step 2: Connect Bank Account

1. Log in to Stripe Dashboard
2. Go to "Settings" → "Bank accounts and transfers"
3. Click "Add bank account"
4. Enter church's UK bank details:
   - Account holder name
   - Sort code
   - Account number
5. Verify with small test deposits
6. Complete verification

## Step 3: Get Stripe Keys

1. Go to Stripe Dashboard → "Developers"
2. Click "API Keys"
3. Copy both keys:
   - **Publishable Key** (starts with `pk_`)
   - **Secret Key** (starts with `sk_`) - KEEP SECURE!

## Step 4: Update App Configuration

Open `lib/services/payment_service.dart` and update:

```dart
static const String _stripePublishableKey = 'pk_live_YOUR_KEY_HERE';
static const String _backendUrl = 'https://your-backend.com/api';
```

## Step 5: Create Backend Endpoints

Your backend needs TWO endpoints:

### Endpoint 1: Create Payment Intent
**POST** `/api/create-payment-intent`

Request body:
```json
{
  "amount": 5000,
  "currency": "gbp",
  "giving_type": "Offering",
  "donor_name": "John Smith",
  "donor_email": "john@example.com",
  "description": "Giving - Offering from NLCC App",
  "metadata": {
    "giving_type": "Offering",
    "donor_name": "John Smith",
    "donor_email": "john@example.com",
    "app_source": "nlcc_mobile_app"
  }
}
```

Backend implementation (Node.js example):
```javascript
const stripe = require('stripe')('sk_live_YOUR_SECRET_KEY');

app.post('/api/create-payment-intent', async (req, res) => {
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: req.body.amount, // in pence
      currency: req.body.currency,
      metadata: req.body.metadata,
      description: req.body.description,
    });

    res.json({
      id: paymentIntent.id,
      client_secret: paymentIntent.client_secret,
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});
```

### Endpoint 2: Send Receipt Email
**POST** `/api/send-giving-receipt`

Request body:
```json
{
  "payment_intent_id": "pi_xxxxx",
  "amount": 50.00,
  "giving_type": "Offering",
  "donor_email": "john@example.com"
}
```

Backend implementation:
```javascript
app.post('/api/send-giving-receipt', async (req, res) => {
  try {
    // Verify payment with Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(
      req.body.payment_intent_id
    );

    if (paymentIntent.status !== 'succeeded') {
      return res.status(400).json({ error: 'Payment not confirmed' });
    }

    // Send email receipt using Nodemailer, SendGrid, or similar
    await sendEmail({
      to: req.body.donor_email,
      subject: `Giving Receipt - NLCC ${req.body.giving_type}`,
      html: `
        <h2>Thank you for your giving!</h2>
        <p>Your ${req.body.giving_type} of £${req.body.amount} has been received.</p>
        <p>Reference: ${req.body.payment_intent_id}</p>
        <p>Blessings,<br>New Life Community Church</p>
      `,
    });

    res.json({ success: true });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});
```

## Step 6: Enable Payment Methods

In Stripe Dashboard:

1. Go to "Settings" → "Payment methods"
2. Enable:
   - Card payments (enabled by default)
   - Google Pay
   - Apple Pay
3. Go to "Settings" → "Webhooks"
4. Add webhook endpoint: `https://your-backend.com/webhooks/stripe`
5. Select events: `payment_intent.succeeded`, `payment_intent.payment_failed`

## Step 7: Test Payment Flow

### Test Mode
1. Use Stripe test keys for testing
2. Test card numbers:
   - Success: `4242 4242 4242 4242`
   - Decline: `4000 0000 0000 0002`
   - Auth required: `4000 0025 0000 3155`
3. Any future expiry date, any 3-digit CVC

### Go Live
1. Switch to live keys
2. Update app configuration
3. Deploy new app version

## Important Notes

### Security
- **NEVER** hardcode Secret Key in app
- Always use publishable key in app
- Secret key operations ONLY on backend
- Use HTTPS for all API calls

### Fees
- Stripe charges 1.4% + 20p per transaction (UK)
- Example: £100 giving = £1.40 + £0.20 = £98.40 to church

### Bank Settlements
- Funds settle to bank account typically within 2 business days
- Small test deposits first time (need to verify)
- View transactions in Stripe Dashboard → "Payments"

### Giving Types Tracking
All giving types are tracked by `giving_type` metadata:
- Offering
- Tithe
- Support
- First Fruits

View in Stripe Dashboard by filtering on metadata.

## Troubleshooting

### "Payment Intent creation failed"
- Check backend URL is correct
- Verify backend is running
- Check network connection

### "Card declined"
- Tell donor to contact card issuer
- Try different card
- Ensure card has contactless/online payment enabled

### "Webhook not working"
- Check webhook URL is correct
- Verify endpoint can handle POST requests
- Check Stripe webhook signing key

## Advanced: Firebase Cloud Functions Backend

If you don't have a backend server, use Firebase Cloud Functions:

```bash
npm install -g firebase-tools
firebase init functions
cd functions
npm install stripe
```

Create `functions/index.js`:
```javascript
const functions = require('firebase-functions');
const stripe = require('stripe')('sk_live_YOUR_SECRET_KEY');

exports.createPaymentIntent = functions.https.onRequest(async (req, res) => {
  const paymentIntent = await stripe.paymentIntents.create({
    amount: req.body.amount,
    currency: req.body.currency,
    metadata: req.body.metadata,
  });
  
  res.json({
    id: paymentIntent.id,
    client_secret: paymentIntent.client_secret,
  });
});
```

Deploy: `firebase deploy --only functions`

---

## Support

- Stripe docs: https://stripe.com/docs
- Flutter Stripe plugin: https://pub.dev/packages/flutter_stripe
- Contact: nlccapp@newlifecc.co.uk

---

**Last updated: January 14, 2026**
**Status: Ready for implementation**
