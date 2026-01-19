import 'package:go_router/go_router.dart';
import '../../../screens/home/home_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/blog/blog_screen.dart';
import '../screens/support/support_screen.dart';
import '../screens/contact/contact_screen.dart';
import '../screens/quote/quote_screen.dart';
import '../screens/blog_detail/blog_detail_screen.dart';
import '../screens/service_detail/service_detail_screen.dart';
import '../../../core/models/blog_post.dart';
import '../../../core/models/service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/services',
        name: 'services',
        builder: (context, state) => const ServicesScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            name: 'service-detail',
            builder: (context, state) {
              final service = state.extra as Service;
              return ServiceDetailScreen(service: service);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/blog',
        name: 'blog',
        builder: (context, state) => const BlogScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            name: 'blog-detail',
            builder: (context, state) {
              final post = state.extra as BlogPost;
              return BlogDetailScreen(post: post);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/quote',
        name: 'quote',
        builder: (context, state) => const QuoteScreen(),
      ),
      // Add more routes here
    ],
  );
}
