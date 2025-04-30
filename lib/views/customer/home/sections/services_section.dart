import '/config/exports.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {'icon': Icons.verified, 'title': 'High Quality', 'desc': 'Certified top-tier materials'},
      {'icon': Icons.security, 'title': 'Warranty Protection', 'desc': 'Care & trust'},
      {'icon': Icons.local_shipping, 'title': 'Free Shipping', 'desc': 'Order over 50\$'},
      {'icon': Icons.support_agent, 'title': '24/7 Support', 'desc': 'Dedicated support'},
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: services
                .map((service) => Column(
                      children: [
                        Icon(service['icon'] as IconData, size: 36, color: Colors.black87),
                        const SizedBox(height: 8),
                        Text(service['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(service['desc'] as String, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
