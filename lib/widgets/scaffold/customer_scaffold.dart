import '/config/exports.dart';

class CustomerScaffold extends StatefulWidget {
  final String title;
  final Widget body;

  static const String logo = 'assets/images/logo.png';

  const CustomerScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  State<CustomerScaffold> createState() => _CustomerScaffoldState();
}

class _CustomerScaffoldState extends State<CustomerScaffold> {
  bool scroll = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(
        () => setState(() => scroll = scrollController.offset > 0));
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: CustomScrollView(
            controller: scrollController,
            shrinkWrap: true,
            slivers: [
              // Navbar
              SliverFloatingHeader(
                child: Column(
                  children: [
                    // Main
                    FB5Container(
                      child: FB5Row(
                        children: [
                          // Logo
                          FB5Col(
                            classNames:
                                'col-lg-3 col-md-6 col-sm-3 align-self-start',
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {},
                                child: Image.asset(
                                  CustomerScaffold.logo,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          // Web Menu
                          FB5Col(
                            classNames:
                                'col-6 align-self-center d-xl-block d-lg-block d-none',
                            child: Row(
                              children: [
                                // Home
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: navbarMenu(
                                    onPressed: () {},
                                    title: 'Home',
                                  ),
                                ),

                                // About
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: navbarMenu(
                                    onPressed: () {},
                                    title: 'Shop',
                                  ),
                                ),

                                // Shop
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: navbarMenu(
                                    onPressed: () {},
                                    title: 'About',
                                  ),
                                ),
                                // Contact
                                navbarMenu(
                                  onPressed: () {},
                                  title: 'Contact',
                                ),
                              ],
                            ),
                          ),

                          // Mobile Menu
                          FB5Col(
                            classNames:
                                'col-lg-3 col-md-6 col-sm-9 align-self-end',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Search
                                navBarIcon(
                                  onPressed: () {},
                                  icon: Icons.search,
                                ),

                                // Cart
                                navBarIcon(
                                  onPressed: () {},
                                  icon: Icons.shopping_cart,
                                ),

                                // Menu
                                navBarIcon(
                                  onPressed: () {},
                                  icon: Icons.menu,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              SliverToBoxAdapter(
                child: SizedBox(
                  width: double.maxFinite,
                  height: 10000000000,
                  child: widget.body,
                ),
              ),
            ],
          ),

          // Back to Top
          floatingActionButton: scroll
              ? FloatingActionButton(
                  onPressed: () => scrollController.animateTo(
                    0,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                  ),
                  child: const Icon(Icons.arrow_upward),
                )
              : null,
        ),
      );

  Widget navbarMenu({
    required void Function()? onPressed,
    required String title,
  }) =>
      TextButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(),
        child: Text(title),
      );

  Widget navBarIcon({
    required void Function()? onPressed,
    required IconData icon,
  }) =>
      IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
      );
}
