import 'package:flutter/material.dart';

class SocialAuthentications extends StatelessWidget {
  const SocialAuthentications({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Or
            Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 2.5,
                    color: Colors.grey.shade400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 2.5,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),

            // Social
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                {'icon': Icons.facebook, 'color': Colors.blue.shade700},
                {'icon': Icons.apple, 'color': Colors.black},
                {'icon': Icons.g_mobiledata, 'color': Colors.red.shade700},
              ]
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(50, 50),
                          foregroundColor: Colors.white,
                          backgroundColor: e['color'] as Color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: e['color'] as Color),
                          ),
                        ),
                        child: Icon(e['icon'] as IconData),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
}
