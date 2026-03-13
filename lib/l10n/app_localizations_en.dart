// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Marcat';

  @override
  String get tagline => 'Men\'s elegance, every step';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to your Marcat account';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String registerPrompt(String link) {
    return 'New to Marcat? $link';
  }

  @override
  String get registerLink => 'Create Account';

  @override
  String loginPrompt(String link) {
    return 'Already have an account? $link';
  }

  @override
  String get loginLink => 'Sign In';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Join Marcat today';

  @override
  String get firstNameLabel => 'First Name';

  @override
  String get lastNameLabel => 'Last Name';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get registerButton => 'Create Account';

  @override
  String get termsText =>
      'By creating an account you agree to our Terms & Conditions';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email to receive a reset link';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetEmailSentTitle => 'Check your email';

  @override
  String resetEmailSentBody(String email) {
    return 'We sent a password reset link to $email';
  }

  @override
  String get onboardingTitle1 => 'Premium Men\'s Fashion';

  @override
  String get onboardingBody1 =>
      'Discover curated men\'s clothing from top brands, all in one place.';

  @override
  String get onboardingTitle2 => 'Shop Multiple Stores';

  @override
  String get onboardingBody2 =>
      'Browse products from stores across Jordan with real-time availability.';

  @override
  String get onboardingTitle3 => 'Earn Loyalty Points';

  @override
  String get onboardingBody3 =>
      'Every purchase earns you points. Redeem them for exclusive discounts.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String currency(String amount) {
    return 'JD $amount';
  }

  @override
  String loyaltyPoints(int count) {
    return '$count pts';
  }

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get featuredStores => 'Featured Stores';

  @override
  String get newArrivals => 'New Arrivals';

  @override
  String get shopByCategory => 'Shop by Category';

  @override
  String get topPicks => 'Top Picks for You';

  @override
  String get activeOffers => 'Exclusive Offers';

  @override
  String get viewAll => 'View All';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get searchHint => 'Search by name, SKU or brand';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPriceLow => 'Price: Low to High';

  @override
  String get sortPriceHigh => 'Price: High to Low';

  @override
  String get sortBestSelling => 'Best Selling';

  @override
  String get gridView => 'Grid View';

  @override
  String get listView => 'List View';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterBrand => 'Brand';

  @override
  String get filterPriceRange => 'Price Range';

  @override
  String get filterSize => 'Size';

  @override
  String get filterColor => 'Color';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String resultsCount(int count) {
    return '$count results';
  }

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get addToWishlist => 'Add to Wishlist';

  @override
  String get removeFromWishlist => 'Remove from Wishlist';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get inStock => 'In Stock';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get selectColor => 'Select Color';

  @override
  String get selectSize => 'Select Size';

  @override
  String get quantity => 'Quantity';

  @override
  String get material => 'Material';

  @override
  String get careInstructions => 'Care Instructions';

  @override
  String get checkAvailability => 'Check Store Availability';

  @override
  String get relatedProducts => 'You May Also Like';

  @override
  String get shareProduct => 'Share';

  @override
  String get productDescription => 'Description';

  @override
  String get availableAt => 'Available at';

  @override
  String get notAvailable => 'Not available';

  @override
  String get cart => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptySubtitle => 'Add items to get started';

  @override
  String get startShopping => 'Start Shopping';

  @override
  String cartItems(int count) {
    return '$count items';
  }

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get shipping => 'Shipping';

  @override
  String get tax => 'Tax';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get couponCode => 'Coupon Code';

  @override
  String get couponHint => 'Enter coupon code';

  @override
  String get applyCoupon => 'Apply';

  @override
  String couponApplied(String amount) {
    return 'Coupon applied! You saved $amount';
  }

  @override
  String get couponInvalid => 'Invalid or expired coupon code';

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String get removeItem => 'Remove Item';

  @override
  String get confirmRemoveItem => 'Remove this item from your cart?';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get deliveryOptions => 'Delivery Options';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get reviewOrder => 'Review Order';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get standardDelivery => 'Standard Delivery (2-3 days)';

  @override
  String get expressDelivery => 'Express Delivery (Next Day)';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get cvv => 'CVV';

  @override
  String get cardHolder => 'Cardholder Name';

  @override
  String get addNewAddress => '+ Add New Address';

  @override
  String get noAddresses => 'No saved addresses';

  @override
  String get orderConfirmed => 'Order Confirmed!';

  @override
  String get orderReference => 'Order Reference';

  @override
  String get copyReference => 'Copy Reference';

  @override
  String pointsEarned(int points) {
    return 'You earned $points loyalty points';
  }

  @override
  String get trackOrder => 'Track Order';

  @override
  String get continueShopping => 'Continue Shopping';

  @override
  String get orders => 'Orders';

  @override
  String get ordersAll => 'All';

  @override
  String get ordersActive => 'Active';

  @override
  String get ordersCompleted => 'Completed';

  @override
  String get ordersCancelled => 'Cancelled';

  @override
  String get ordersEmpty => 'No orders found';

  @override
  String get ordersEmptySubtitle => 'Your order history will appear here';

  @override
  String get orderDate => 'Order Date';

  @override
  String orderItems(int count) {
    return '$count items';
  }

  @override
  String get orderDetail => 'Order Details';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get orderItems2 => 'Order Items';

  @override
  String get paymentInfo => 'Payment Information';

  @override
  String get deliveryInfo => 'Delivery Information';

  @override
  String get trackingNumber => 'Tracking Number';

  @override
  String get estimatedDelivery => 'Estimated Delivery';

  @override
  String get downloadReceipt => 'Download Receipt';

  @override
  String get requestReturn => 'Request Return';

  @override
  String get returnRequest => 'Return Request';

  @override
  String get selectItemsToReturn => 'Select items to return';

  @override
  String get returnReason => 'Return Reason';

  @override
  String get returnReasonDefective => 'Defective';

  @override
  String get returnReasonWrongItem => 'Wrong Item';

  @override
  String get returnReasonWrongSize => 'Wrong Size';

  @override
  String get returnReasonChangedMind => 'Changed Mind';

  @override
  String get returnReasonOther => 'Other';

  @override
  String get returnNote => 'Additional Notes (optional)';

  @override
  String get submitReturn => 'Submit Return';

  @override
  String get profile => 'Profile';

  @override
  String get myAddresses => 'My Addresses';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get loyaltyHistory => 'Loyalty History';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get aboutMarcat => 'About Marcat';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get addresses => 'My Addresses';

  @override
  String get defaultAddress => 'Default';

  @override
  String get setDefault => 'Set as Default';

  @override
  String get deleteAddress => 'Delete Address';

  @override
  String get confirmDeleteAddress => 'Delete this address?';

  @override
  String get addAddress => '+ Add Address';

  @override
  String get addressLabel => 'Address Label (e.g. Home, Work)';

  @override
  String get addressLine1 => 'Street Address';

  @override
  String get addressLine2 => 'Apartment / Suite (optional)';

  @override
  String get city => 'City';

  @override
  String get stateProvince => 'State / Province';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get country => 'Country';

  @override
  String get saveAddress => 'Save Address';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistEmpty => 'Your wishlist is empty';

  @override
  String get wishlistEmptySubtitle => 'Save items you love';

  @override
  String get loyaltyTitle => 'Loyalty Points';

  @override
  String get loyaltyBalance => 'Your Balance';

  @override
  String get loyaltyHowItWorks => 'How It Works';

  @override
  String get loyaltyEarnRule => 'Earn 1 point for every JOD spent';

  @override
  String get loyaltyRedeemRule => 'Redeem 100 points = JD 1.000 discount';

  @override
  String get loyaltyTransactions => 'Transaction History';

  @override
  String get loyaltyEarn => 'Earned';

  @override
  String get loyaltyRedeem => 'Redeemed';

  @override
  String get loyaltyExpire => 'Expired';

  @override
  String get loyaltyAdjust => 'Adjustment';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get todayRevenue => 'Today\'s Revenue';

  @override
  String get todayOrders => 'Orders Today';

  @override
  String get pendingDeliveries => 'Pending Deliveries';

  @override
  String get lowStockAlerts => 'Low Stock Alerts';

  @override
  String get products => 'Products';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get productName => 'Product Name';

  @override
  String get productNameAr => 'Product Name (Arabic)';

  @override
  String get productSku => 'SKU';

  @override
  String get productSlug => 'Slug';

  @override
  String get productDescription2 => 'Description';

  @override
  String get productBrand => 'Brand';

  @override
  String get productCategory => 'Category';

  @override
  String get productBasePrice => 'Base Price (JD)';

  @override
  String get productCostPrice => 'Cost Price (JD)';

  @override
  String get productCommissionRate => 'Commission Rate (%)';

  @override
  String get productSizeSystem => 'Size System';

  @override
  String get productMaterial => 'Material';

  @override
  String get productCareInstructions => 'Care Instructions';

  @override
  String get productStatus => 'Status';

  @override
  String get productColors2 => 'Colors';

  @override
  String get addColor => 'Add Color';

  @override
  String get colorName => 'Color Name';

  @override
  String get colorHex => 'Hex Code';

  @override
  String get productSizes2 => 'Sizes';

  @override
  String get addSize => 'Add Size';

  @override
  String get sizeLabel => 'Size Label';

  @override
  String get uploadImages => 'Upload Images';

  @override
  String get storeAssignment => 'Store Assignment';

  @override
  String get priceOverride => 'Price Override (JD)';

  @override
  String get saveProduct => 'Save Product';

  @override
  String get inventory => 'Inventory';

  @override
  String get stockQuantity => 'Stock Quantity';

  @override
  String get reservedStock => 'Reserved';

  @override
  String get availableStock => 'Available';

  @override
  String get reorderLevel => 'Reorder Level';

  @override
  String get lastRestocked => 'Last Restocked';

  @override
  String get updateStock => 'Update Stock';

  @override
  String get bulkRestock => 'Bulk Restock';

  @override
  String get lowStockTab => 'Low Stock';

  @override
  String get ordersAdmin => 'Orders';

  @override
  String get orderFilters => 'Filters';

  @override
  String get dateRange => 'Date Range';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get assignDriver => 'Assign Driver';

  @override
  String get updateStatus => 'Update Status';

  @override
  String get addNote => 'Add Note';

  @override
  String get customers => 'Customers';

  @override
  String get customerDetail => 'Customer Detail';

  @override
  String get totalOrders2 => 'Total Orders';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get adjustPoints => 'Adjust Points';

  @override
  String get pointsAdjustment => 'Points Adjustment';

  @override
  String get adjustmentNote => 'Reason / Note';

  @override
  String get staff => 'Staff';

  @override
  String get addStaff => 'Add Staff Member';

  @override
  String get employeeCode => 'Employee Code';

  @override
  String get department => 'Department';

  @override
  String get hireDate => 'Hire Date';

  @override
  String get storeAssignment2 => 'Store Assignment';

  @override
  String get role => 'Role';

  @override
  String get commissions => 'Commissions';

  @override
  String get pendingCommissions => 'Pending';

  @override
  String get approvedCommissions => 'Approved';

  @override
  String get paidCommissions => 'Paid';

  @override
  String get approveCommission => 'Approve';

  @override
  String get markPaid => 'Mark as Paid';

  @override
  String get deliveries => 'Deliveries';

  @override
  String get activeDeliveries => 'Active';

  @override
  String get driverName => 'Driver';

  @override
  String get deliveryStatus => 'Status';

  @override
  String get trackingInfo => 'Tracking';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusPickedUp => 'Picked Up';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusReturned => 'Returned';

  @override
  String get offers => 'Offers & Promotions';

  @override
  String get addOffer => 'Add Offer';

  @override
  String get offerName => 'Offer Name';

  @override
  String get offerDescription => 'Description';

  @override
  String get discountType => 'Discount Type';

  @override
  String get discountValue => 'Discount Value';

  @override
  String get minOrderValue => 'Minimum Order Value';

  @override
  String get maxUses => 'Maximum Uses';

  @override
  String get couponCodeLabel => 'Coupon Code';

  @override
  String get validFrom => 'Valid From';

  @override
  String get validTo => 'Valid To';

  @override
  String get isActive => 'Active';

  @override
  String get restrictions => 'Restrictions';

  @override
  String get byStore => 'By Store';

  @override
  String get byCategory => 'By Category';

  @override
  String get byProduct => 'By Product';

  @override
  String get saveOffer => 'Save Offer';

  @override
  String get returns => 'Returns';

  @override
  String get returnId => 'Return #';

  @override
  String get saleReference => 'Sale Reference';

  @override
  String get approveReturn => 'Approve';

  @override
  String get rejectReturn => 'Reject';

  @override
  String get processRefund => 'Process Refund';

  @override
  String get returnStatus => 'Status';

  @override
  String get refundTotal => 'Refund Total';

  @override
  String get stores => 'Stores';

  @override
  String get addStore => 'Add Store';

  @override
  String get storeName => 'Store Name';

  @override
  String get storeCode => 'Store Code';

  @override
  String get storeCity => 'City';

  @override
  String get storePhone => 'Phone';

  @override
  String get storeType => 'Type';

  @override
  String get storeTypeOnline => 'Online';

  @override
  String get storeTypePhysical => 'Physical';

  @override
  String get storeTypePos => 'POS';

  @override
  String get storeStatus => 'Status';

  @override
  String get posTitle => 'Marcat POS';

  @override
  String get posShift => 'Shift';

  @override
  String get posStartShift => 'Start Shift';

  @override
  String get posEndShift => 'End Shift';

  @override
  String get posTodayRevenue => 'Today\'s Revenue';

  @override
  String get posTodayTransactions => 'Transactions Today';

  @override
  String get posSearchProducts => 'Search product, SKU, or scan barcode...';

  @override
  String get posScanBarcode => 'Scan Barcode';

  @override
  String get posCart => 'Cart';

  @override
  String get posClearCart => 'Clear Cart';

  @override
  String get posCustomer => 'Customer';

  @override
  String get posAnonymous => 'Walk-in / Anonymous';

  @override
  String get posSearchCustomer => 'Search by name or phone';

  @override
  String get posPayment => 'Payment';

  @override
  String get posCash => 'Cash';

  @override
  String get posCard => 'Card';

  @override
  String get posLoyalty => 'Loyalty Points';

  @override
  String get posAmountTendered => 'Amount Tendered';

  @override
  String get posChangeDue => 'Change Due';

  @override
  String get posCardReference => 'Card Reference #';

  @override
  String get posPointsToRedeem => 'Points to Redeem';

  @override
  String get posCompleteSale => 'Complete Sale';

  @override
  String get posReceipt => 'Receipt';

  @override
  String get posPrintReceipt => 'Print Receipt';

  @override
  String get posNewSale => 'New Sale';

  @override
  String get posSalesHistory => 'Today\'s Sales';

  @override
  String get posReprintReceipt => 'Reprint Receipt';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPending2 => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get salePending => 'Pending';

  @override
  String get saleConfirmed => 'Confirmed';

  @override
  String get saleProcessing => 'Processing';

  @override
  String get saleShipped => 'Shipped';

  @override
  String get saleDelivered => 'Delivered';

  @override
  String get saleCancelled => 'Cancelled';

  @override
  String get saleCompleted => 'Completed';

  @override
  String get paymentPending => 'Pending';

  @override
  String get paymentCompleted => 'Completed';

  @override
  String get paymentFailed => 'Failed';

  @override
  String get paymentRefunded => 'Refunded';

  @override
  String get adminDashboard => 'Dashboard';

  @override
  String get adminProducts => 'Products';

  @override
  String get adminOrders => 'Orders';

  @override
  String get adminStaff => 'Staff';

  @override
  String get navHome => 'Home';

  @override
  String get navCategories => 'Categories';

  @override
  String get navCart => 'Cart';

  @override
  String get navWishlist => 'Wishlist';

  @override
  String get navProfile => 'Profile';

  @override
  String get cartTitle => 'Shopping Cart';

  @override
  String get cartSubtotal => 'Subtotal';

  @override
  String get checkoutButton => 'Checkout';

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String get orderSuccessTitle => 'Order Placed Successfully!';

  @override
  String get orderSuccessBody => 'Thank you for your order.';

  @override
  String get selectColorSizeFirst => 'Please select a color and size first.';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get colorTitle => 'Color';

  @override
  String get sizeTitle => 'Size';

  @override
  String get descriptionTitle => 'Description';

  @override
  String get addToCartButton => 'Add to Cart';

  @override
  String get addressEmpty => 'No addresses found';

  @override
  String get defaultLabel => 'Default';

  @override
  String get myOrders => 'My Orders';

  @override
  String get orderTotal => 'Total';

  @override
  String get myLoyaltyBalance => 'Loyalty Balance';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get aboutUs => 'About Us';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Something went wrong';

  @override
  String get networkError => 'Check your internet connection';

  @override
  String get noData => 'No data found';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get search => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get submit => 'Submit';

  @override
  String get select => 'Select';

  @override
  String get optional => '(optional)';

  @override
  String get required => 'Required';

  @override
  String get na => 'N/A';

  @override
  String get unknown => 'Unknown';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';
}
