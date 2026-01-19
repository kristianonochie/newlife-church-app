import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../../core/models/service.dart';
import 'package:go_router/go_router.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Our Services')),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: provider.services.length,
                itemBuilder: (context, i) {
                  final Service service = provider.services[i];
                  return Card(
                    child: ListTile(
                      leading: service.icon != null
                          ? Image.asset(service.icon!, width: 40)
                          : null,
                      title: Text(
                        service.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        service.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        context.goNamed('service-detail', extra: service);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
