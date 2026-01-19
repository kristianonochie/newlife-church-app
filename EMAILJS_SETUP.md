# EmailJS Setup Instructions

This app uses EmailJS to send emails directly without requiring a backend server. Follow these steps to configure it:

## 1. Create EmailJS Account

1. Go to https://www.emailjs.com/
2. Click "Sign Up" (free tier allows 200 emails/month)
3. Verify your email address

## 2. Add Email Service

1. In EmailJS dashboard, click "Email Services"
2. Click "Add New Service"
3. Choose your email provider:
   - **Gmail** (recommended for testing)
   - Outlook
   - Yahoo
   - Custom SMTP
4. Follow the connection wizard
5. Copy your **Service ID** (e.g., `service_nlcc`)

## 3. Create Email Templates

You need to create 3 email templates:

### Template 1: Chat Transcript
**Template ID**: `template_chat`

**Subject**: `Your NLCChat Conversation - {{date}}`

**Content**:
```
Dear {{user_name}},

Thank you for chatting with NLCChat - your spiritual companion from New Life Community Church.

Here is a transcript of your conversation:

==================================================

{{chat_transcript}}

==================================================

We hope this conversation was helpful on your spiritual journey.

For more information, visit us at:
🌐 https://www.newlifecc.co.uk
📧 church@newlifecc.co.uk

Blessings,
New Life Community Church, Tonyrefail
```

**Template Parameters**:
- `to_email`
- `user_name`
- `chat_transcript`
- `date`

---

### Template 2: Prayer Confirmation
**Template ID**: `template_prayer_confirm`

**Subject**: `NLCC Prayer Team - We are praying for you`

**Content**:
```
Dear {{first_name}},

{{message}}

Blessings,
NLCC Prayer Team
New Life Community Church

🌐 https://www.newlifecc.co.uk
📧 nlccapp@newlifecc.co.uk
```

**Template Parameters**:
- `to_email`
- `first_name`
- `message`

---

### Template 3: Prayer Request to Team
**Template ID**: `template_prayer_request`

**Subject**: `New Prayer Request from {{first_name}} {{last_name}}`

**Content**:
```
New Prayer Request Received

==================================================

Contact Information:
------------------------------
Name: {{first_name}} {{last_name}}
Email: {{requester_email}}
Mobile: {{mobile}}

Prayer Request:
------------------------------
Subject: {{prayer_subject}}

Description:
{{prayer_description}}

==================================================

Please reach out to this person and let them know we are praying for them.

Submitted: {{submitted_date}}
Consent Given: Yes
```

**Template Parameters**:
- `to_email` (set to `nlccapp@newlifecc.co.uk`)
- `first_name`
- `last_name`
- `requester_email`
- `mobile`
- `prayer_subject`
- `prayer_description`
- `submitted_date`

---

### Template 4: Devotion with Reflection
**Template ID**: `template_devotion`

**Subject**: `Your Devotion & Reflection from NLCC - {{submitted_date}}`

**Content**:
```
Dear {{first_name}},

Thank you for reading today's devotion from New Life Community Church. Below is your devotion and reflection saved for your spiritual growth.

==================================================

DEVOTION: {{devotion_title}}

Scripture: {{devotion_scripture}}

{{devotion_body}}

By: {{devotion_author}}

==================================================

YOUR REFLECTION:

{{reflection}}

==================================================

We hope this devotion and your reflection have blessed your spiritual journey. Keep praying and growing in faith!

Blessings,
NLCC App Team
New Life Community Church

🌐 https://www.newlifecc.co.uk
📧 nlccapp@newlifecc.co.uk
```

**Template Parameters**:
- `to_email`
- `first_name`
- `devotion_title`
- `devotion_scripture`
- `devotion_body`
- `devotion_author`
- `reflection`
- `submitted_date`

## 4. Get Your Public Key

1. Go to "Account" in EmailJS dashboard
2. Find your **Public Key** (looks like: `YOUR_EMAILJS_PUBLIC_KEY`)
3. Copy it

## 5. Update the App Configuration

Open `lib/services/email_service.dart` and replace these values:

```dart
static const String _serviceId = 'service_nlcc';  // Your Service ID
static const String _publicKey = 'YOUR_EMAILJS_PUBLIC_KEY';  // Your Public Key
static const String _chatTemplateId = 'template_chat';  // Your Chat Template ID
static const String _prayerConfirmTemplateId = 'template_prayer_confirm';  // Prayer Confirmation Template ID
static const String _prayerRequestTemplateId = 'template_prayer_request';  // Prayer Request Template ID
static const String _devotionTemplateId = 'template_devotion';  // Devotion Template ID
```

## 6. Test the Configuration

1. Run the app
2. Test prayer request:
   - Fill out prayer form
   - Submit
   - Check if emails are received
3. Test chat transcript:
   - Start NLCChat
   - Enable email transcript
   - End chat
   - Check if email is received

## 7. Monitoring Usage

- EmailJS free tier: **200 emails/month**
- Check usage in EmailJS dashboard
- Upgrade to paid plan if needed (starts at $15/month for 1000 emails)

## Troubleshooting

### Emails not sending?
1. Check EmailJS dashboard for error logs
2. Verify Service ID, Public Key, and Template IDs are correct
3. Ensure templates have all required parameters
4. Check email service is connected properly

### Emails in spam?
1. Add your domain to SPF/DKIM records (advanced)
2. Ask users to whitelist prayers@newlifecc.co.uk
3. Use professional email service for production

### Rate limiting?
- Free tier: 200 emails/month, 5 emails/second
- Upgrade if you exceed limits

## Alternative: Backend Solution

For production with high volume, consider:
1. **Firebase Cloud Functions** with SendGrid/Nodemailer
2. **AWS SES** with Lambda functions
3. **Custom backend** with SMTP

These provide better deliverability and no rate limits.

---

**Note**: EmailJS is perfect for low-volume apps. For church production use with many prayer requests, consider upgrading or implementing a backend solution.
