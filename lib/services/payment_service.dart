import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  final Dio _dio = Dio();

  // Stripe Configuration - Replace with your actual keys
  // These should be retrieved from your backend for security
  static const String _stripePublishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY';
  static const String _backendUrl = 'YOUR_BACKEND_URL/api';

  /// Initialize Stripe with publishable key
  Future<void> initialize() async {
    try {
      Stripe.publishableKey = _stripePublishableKey;
      await Stripe.instance.applySettings();
      print('Stripe initialized successfully');
    } catch (e) {
      print('Error initializing Stripe: $e');
      rethrow;
    }
  }

  /// Create a payment intent for giving
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount, // Amount in pounds (£)
    required String currency, // e.g., 'gbp'
    required String givingType, // Offering, Tithe, Support, First Fruits
    required String donorName,
    required String donorEmail,
  }) async {
    try {
      // Convert pounds to pence (Stripe uses cents)
      final amountInPence = (amount * 100).toInt();

      // Call backend to create payment intent
      final response = await _dio.post(
        '$_backendUrl/create-payment-intent',
        data: {
          'amount': amountInPence,
          'currency': currency,
          'giving_type': givingType,
          'donor_name': donorName,
          'donor_email': donorEmail,
          'description': 'Giving - $givingType from NLCC App',
          'metadata': {
            'giving_type': givingType,
            'donor_name': donorName,
            'donor_email': donorEmail,
            'app_source': 'nlcc_mobile_app',
          },
        },
      );

      if (response.statusCode == 200) {
        return {
          'client_secret': response.data['client_secret'],
          'payment_intent_id': response.data['id'],
          'success': true,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to create payment intent',
        };
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Process payment with Stripe
  Future<Map<String, dynamic>> processPayment({
    required String clientSecret,
    required String paymentIntentId,
  }) async {
    try {
      // Confirm payment using Stripe Payment Sheet
      await Stripe.instance.confirmPaymentSheetPayment();

      // Payment successful
      return {
        'success': true,
        'payment_intent_id': paymentIntentId,
        'message': 'Payment processed successfully',
      };
    } catch (e) {
      if (e is StripeException) {
        print('Stripe error: ${e.error.localizedMessage}');
        return {
          'success': false,
          'error': e.error.localizedMessage ?? 'Payment failed',
        };
      } else {
        print('Payment error: $e');
        return {
          'success': false,
          'error': e.toString(),
        };
      }
    }
  }

  /// Initialize payment sheet for presenting to user
  Future<bool> initializePaymentSheet({
    required String paymentIntentClientSecret,
    required String merchantDisplayName,
    required String amount,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.system,
          googlePay: const PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: 'GBP',
            merchantCountryCode: 'GB',
          ),
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'GB',
          ),
        ),
      );
      return true;
    } catch (e) {
      print('Error initializing payment sheet: $e');
      return false;
    }
  }

  /// Display payment sheet to user
  Future<Map<String, dynamic>> displayPaymentSheet({
    required BuildContext context,
  }) async {
    try {
      // This will show the Stripe Payment Sheet UI
      await Stripe.instance.presentPaymentSheet();
      return {
        'success': true,
        'message': 'Payment sheet displayed',
      };
    } catch (e) {
      if (e is StripeException) {
        print('User cancelled or error: ${e.error.localizedMessage}');
        return {
          'success': false,
          'error': e.error.localizedMessage ?? 'Payment cancelled',
          'cancelled': e.error.code.name == 'Cancelled',
        };
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Complete giving transaction
  Future<bool> completeGiving({
    required String paymentIntentId,
    required double amount,
    required String givingType,
    required String donorEmail,
  }) async {
    try {
      // Send email receipt to donor
      final response = await _dio.post(
        '$_backendUrl/send-giving-receipt',
        data: {
          'payment_intent_id': paymentIntentId,
          'amount': amount,
          'giving_type': givingType,
          'donor_email': donorEmail,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error completing giving transaction: $e');
      return false;
    }
  }
}
