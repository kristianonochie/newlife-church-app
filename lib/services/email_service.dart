import 'package:dio/dio.dart';
import '../models/chat_message.dart';

class EmailService {
  final Dio _dio = Dio();
  
  // EmailJS Configuration
  // To set up: 
  // 1. Go to https://www.emailjs.com/ and create free account
  // 2. Create email service (Gmail, Outlook, etc.)
  // 3. Create email templates
  // 4. Replace these values with your actual EmailJS credentials
  static const String _serviceId = 'service_nlcc';  // Replace with your EmailJS Service ID
  static const String _publicKey = 'YOUR_EMAILJS_PUBLIC_KEY';  // Replace with your EmailJS Public Key
  static const String _chatTemplateId = 'template_chat';  // Replace with your Chat Template ID
  static const String _prayerConfirmTemplateId = 'template_prayer_confirm';  // Replace with your Prayer Confirmation Template ID
  static const String _prayerRequestTemplateId = 'template_prayer_request';  // Replace with your Prayer Request Template ID
  static const String _devotionTemplateId = 'template_devotion';  // Replace with your Devotion Template ID

  /// Send chat transcript via email directly using EmailJS
  Future<bool> sendChatTranscript({
    required String recipientEmail,
    required String userName,
    required List<ChatMessage> messages,
  }) async {
    try {
      // Build chat transcript
      final StringBuffer transcript = StringBuffer();
      
      for (final msg in messages) {
        final time = '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';
        transcript.writeln('[$time] ${msg.role}:');
        transcript.writeln(msg.content);
        transcript.writeln('');
      }

      // Send email via EmailJS
      final response = await _dio.post(
        'https://api.emailjs.com/api/v1.0/email/send',
        data: {
          'service_id': _serviceId,
          'template_id': _chatTemplateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': recipientEmail,
            'user_name': userName,
            'chat_transcript': transcript.toString(),
            'date': DateTime.now().toString().split(' ')[0],
          },
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending chat transcript: $e');
      return false;
    }
  }

  /// Send prayer confirmation email to person requesting prayer
  Future<bool> sendPrayerConfirmation({
    required String recipientEmail,
    required String firstName,
  }) async {
    try {
      final response = await _dio.post(
        'https://api.emailjs.com/api/v1.0/email/send',
        data: {
          'service_id': _serviceId,
          'template_id': _prayerConfirmTemplateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': recipientEmail,
            'first_name': firstName,
            'message': 'Thank you for reaching out to the NLCC Prayer Team.\n\n'
                'We want you to know that we are lifting you up in prayer. '
                'Our team will be praying for your request and will be in touch with you soon.\n\n'
                'Remember, God hears every prayer and cares deeply about every need.\n\n'
                '"Do not be anxious about anything, but in every situation, by prayer and petition, '
                'with thanksgiving, present your requests to God." - Philippians 4:6\n\n'
                'Blessings,\n'
                'NLCC Prayer Team\n'
                'New Life Community Church',
          },
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending prayer confirmation: $e');
      return false;
    }
  }

  /// Send prayer request details to prayer team
  Future<bool> sendPrayerRequestToTeam({
    required String teamEmail,
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String subject,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        'https://api.emailjs.com/api/v1.0/email/send',
        data: {
          'service_id': _serviceId,
          'template_id': _prayerRequestTemplateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': teamEmail,
            'first_name': firstName,
            'last_name': lastName,
            'requester_email': email,
            'mobile': mobile,
            'prayer_subject': subject,
            'prayer_description': description,
            'submitted_date': DateTime.now().toString().split('.')[0],
          },
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending prayer request to team: $e');
      return false;
    }
  }

  /// Send devotion with reflection via email directly using EmailJS
  Future<bool> sendDevotionEmail({
    required String toEmail,
    required String firstName,
    required String devotionTitle,
    required String devotionScripture,
    required String devotionBody,
    required String devotionAuthor,
    required String reflection,
    required String submittedDate,
  }) async {
    try {
      final response = await _dio.post(
        'https://api.emailjs.com/api/v1.0/email/send',
        data: {
          'service_id': _serviceId,
          'template_id': _devotionTemplateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': toEmail,
            'first_name': firstName,
            'devotion_title': devotionTitle,
            'devotion_scripture': devotionScripture,
            'devotion_body': devotionBody,
            'devotion_author': devotionAuthor,
            'reflection': reflection,
            'submitted_date': submittedDate,
          },
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending devotion email: $e');
      return false;
    }
  }
}
