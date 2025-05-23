import '/config/exports.dart';

class CartSection extends StatelessWidget {
  const CartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Shopping Cart',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Home', style: TextStyle(color: Colors.black54)),
                Icon(Icons.chevron_right, size: 18, color: Colors.black38),
                Text('Your Shopping Cart', style: TextStyle(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 32),
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.grey[100],
              child: Row(
                children: const [
                  Expanded(flex: 4, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            // Cart item
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Product info
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/cart_product.jpg',
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Mini Dress With Ruffled Straps',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('Color : Red', style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {},
                                child: const Text('Remove',
                                    style: TextStyle(color: Colors.red, decoration: TextDecoration.underline)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price
                  const Expanded(
                    flex: 2,
                    child: Text(' 14.90', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  // Quantity
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {},
                          splashRadius: 18,
                        ),
                        Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: const Text('01', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {},
                          splashRadius: 18,
                        ),
                      ],
                    ),
                  ),
                  // Total
                  const Expanded(
                    flex: 2,
                    child: Text(' 14.90', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            // Gift wrap
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                children: [
                  Checkbox(value: false, onChanged: (v) {}),
                  const Text('For '),
                  const Text(' 10.00', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text(' Please Wrap The Product', style: TextStyle(color: Colors.black38)),
                ],
              ),
            ),
            const Divider(),
            // Subtotal and actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 24),
                  const Text(' 100.00', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Checkout'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 300,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('View Cart'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
