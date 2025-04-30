import '/config/exports.dart';

class BrandsSection extends StatelessWidget {
  const BrandsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final brands = [
      'CHANEL',
      'LOUIS VUITTON',
      'PRADA',
      'Calvin Klein',
      'DENIM',
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: brands
            .map((brand) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    brand,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.black87,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
