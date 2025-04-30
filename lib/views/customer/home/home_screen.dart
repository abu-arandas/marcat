import '/config/exports.dart';
import 'sections/hero_section.dart';
import 'sections/brands_section.dart';
import 'sections/deals_section.dart';
import 'sections/new_arrivals_section.dart';
import 'sections/featured_section.dart';
import 'sections/services_section.dart';
import 'sections/instagram_section.dart';
import 'sections/testimonials_section.dart';
import 'sections/newsletter_section.dart';
import 'sections/footer_section.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomerScaffold(
        title: 'index',
        body: Column(
          children: const [
            HeroSection(),
            BrandsSection(),
            DealsSection(),
            NewArrivalsSection(),
            FeaturedSection(),
            ServicesSection(),
            InstagramSection(),
            TestimonialsSection(),
            NewsletterSection(),
            FooterSection(),
          ],
        ),
      );
}
