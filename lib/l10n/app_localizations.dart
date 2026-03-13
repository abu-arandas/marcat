import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Marcat'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Men\'s elegance, every step'**
  String get tagline;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Marcat account'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @registerPrompt.
  ///
  /// In en, this message translates to:
  /// **'New to Marcat? {link}'**
  String registerPrompt(String link);

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerLink;

  /// No description provided for @loginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? {link}'**
  String loginPrompt(String link);

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Marcat today'**
  String get registerSubtitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// No description provided for @termsText.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to our Terms & Conditions'**
  String get termsText;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetEmailSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get resetEmailSentTitle;

  /// No description provided for @resetEmailSentBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to {email}'**
  String resetEmailSentBody(String email);

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Premium Men\'s Fashion'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Discover curated men\'s clothing from top brands, all in one place.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Shop Multiple Stores'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Browse products from stores across Jordan with real-time availability.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Earn Loyalty Points'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Every purchase earns you points. Redeem them for exclusive discounts.'**
  String get onboardingBody3;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'JD {amount}'**
  String currency(String amount);

  /// No description provided for @loyaltyPoints.
  ///
  /// In en, this message translates to:
  /// **'{count} pts'**
  String loyaltyPoints(int count);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @featuredStores.
  ///
  /// In en, this message translates to:
  /// **'Featured Stores'**
  String get featuredStores;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get newArrivals;

  /// No description provided for @shopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by Category'**
  String get shopByCategory;

  /// No description provided for @topPicks.
  ///
  /// In en, this message translates to:
  /// **'Top Picks for You'**
  String get topPicks;

  /// No description provided for @activeOffers.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Offers'**
  String get activeOffers;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, SKU or brand'**
  String get searchHint;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get sortPriceHigh;

  /// No description provided for @sortBestSelling.
  ///
  /// In en, this message translates to:
  /// **'Best Selling'**
  String get sortBestSelling;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @filterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// No description provided for @filterBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get filterBrand;

  /// No description provided for @filterPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get filterPriceRange;

  /// No description provided for @filterSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get filterSize;

  /// No description provided for @filterColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get filterColor;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(int count);

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Add to Wishlist'**
  String get addToWishlist;

  /// No description provided for @removeFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from Wishlist'**
  String get removeFromWishlist;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @selectSize.
  ///
  /// In en, this message translates to:
  /// **'Select Size'**
  String get selectSize;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @careInstructions.
  ///
  /// In en, this message translates to:
  /// **'Care Instructions'**
  String get careInstructions;

  /// No description provided for @checkAvailability.
  ///
  /// In en, this message translates to:
  /// **'Check Store Availability'**
  String get checkAvailability;

  /// No description provided for @relatedProducts.
  ///
  /// In en, this message translates to:
  /// **'You May Also Like'**
  String get relatedProducts;

  /// No description provided for @shareProduct.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareProduct;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescription;

  /// No description provided for @availableAt.
  ///
  /// In en, this message translates to:
  /// **'Available at'**
  String get availableAt;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items to get started'**
  String get cartEmptySubtitle;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get startShopping;

  /// No description provided for @cartItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String cartItems(int count);

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code'**
  String get couponCode;

  /// No description provided for @couponHint.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get couponHint;

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyCoupon;

  /// No description provided for @couponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied! You saved {amount}'**
  String couponApplied(String amount);

  /// No description provided for @couponInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired coupon code'**
  String get couponInvalid;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove Item'**
  String get removeItem;

  /// No description provided for @confirmRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove this item from your cart?'**
  String get confirmRemoveItem;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @deliveryOptions.
  ///
  /// In en, this message translates to:
  /// **'Delivery Options'**
  String get deliveryOptions;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @reviewOrder.
  ///
  /// In en, this message translates to:
  /// **'Review Order'**
  String get reviewOrder;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @standardDelivery.
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery (2-3 days)'**
  String get standardDelivery;

  /// No description provided for @expressDelivery.
  ///
  /// In en, this message translates to:
  /// **'Express Delivery (Next Day)'**
  String get expressDelivery;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardHolder;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'+ Add New Address'**
  String get addNewAddress;

  /// No description provided for @noAddresses.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses'**
  String get noAddresses;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed!'**
  String get orderConfirmed;

  /// No description provided for @orderReference.
  ///
  /// In en, this message translates to:
  /// **'Order Reference'**
  String get orderReference;

  /// No description provided for @copyReference.
  ///
  /// In en, this message translates to:
  /// **'Copy Reference'**
  String get copyReference;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'You earned {points} loyalty points'**
  String pointsEarned(int points);

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @ordersAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ordersAll;

  /// No description provided for @ordersActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ordersActive;

  /// No description provided for @ordersCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersCompleted;

  /// No description provided for @ordersCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersCancelled;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get ordersEmpty;

  /// No description provided for @ordersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your order history will appear here'**
  String get ordersEmptySubtitle;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String orderItems(int count);

  /// No description provided for @orderDetail.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetail;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @orderItems2.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems2;

  /// No description provided for @paymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get paymentInfo;

  /// No description provided for @deliveryInfo.
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInfo;

  /// No description provided for @trackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking Number'**
  String get trackingNumber;

  /// No description provided for @estimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery'**
  String get estimatedDelivery;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download Receipt'**
  String get downloadReceipt;

  /// No description provided for @requestReturn.
  ///
  /// In en, this message translates to:
  /// **'Request Return'**
  String get requestReturn;

  /// No description provided for @returnRequest.
  ///
  /// In en, this message translates to:
  /// **'Return Request'**
  String get returnRequest;

  /// No description provided for @selectItemsToReturn.
  ///
  /// In en, this message translates to:
  /// **'Select items to return'**
  String get selectItemsToReturn;

  /// No description provided for @returnReason.
  ///
  /// In en, this message translates to:
  /// **'Return Reason'**
  String get returnReason;

  /// No description provided for @returnReasonDefective.
  ///
  /// In en, this message translates to:
  /// **'Defective'**
  String get returnReasonDefective;

  /// No description provided for @returnReasonWrongItem.
  ///
  /// In en, this message translates to:
  /// **'Wrong Item'**
  String get returnReasonWrongItem;

  /// No description provided for @returnReasonWrongSize.
  ///
  /// In en, this message translates to:
  /// **'Wrong Size'**
  String get returnReasonWrongSize;

  /// No description provided for @returnReasonChangedMind.
  ///
  /// In en, this message translates to:
  /// **'Changed Mind'**
  String get returnReasonChangedMind;

  /// No description provided for @returnReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get returnReasonOther;

  /// No description provided for @returnNote.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes (optional)'**
  String get returnNote;

  /// No description provided for @submitReturn.
  ///
  /// In en, this message translates to:
  /// **'Submit Return'**
  String get submitReturn;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @loyaltyHistory.
  ///
  /// In en, this message translates to:
  /// **'Loyalty History'**
  String get loyaltyHistory;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @aboutMarcat.
  ///
  /// In en, this message translates to:
  /// **'About Marcat'**
  String get aboutMarcat;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get addresses;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAddress;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setDefault;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// No description provided for @confirmDeleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete this address?'**
  String get confirmDeleteAddress;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'+ Add Address'**
  String get addAddress;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address Label (e.g. Home, Work)'**
  String get addressLabel;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Apartment / Suite (optional)'**
  String get addressLine2;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @stateProvince.
  ///
  /// In en, this message translates to:
  /// **'State / Province'**
  String get stateProvince;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get saveAddress;

  /// No description provided for @wishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistTitle;

  /// No description provided for @wishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get wishlistEmpty;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save items you love'**
  String get wishlistEmptySubtitle;

  /// No description provided for @loyaltyTitle.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Points'**
  String get loyaltyTitle;

  /// No description provided for @loyaltyBalance.
  ///
  /// In en, this message translates to:
  /// **'Your Balance'**
  String get loyaltyBalance;

  /// No description provided for @loyaltyHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get loyaltyHowItWorks;

  /// No description provided for @loyaltyEarnRule.
  ///
  /// In en, this message translates to:
  /// **'Earn 1 point for every JOD spent'**
  String get loyaltyEarnRule;

  /// No description provided for @loyaltyRedeemRule.
  ///
  /// In en, this message translates to:
  /// **'Redeem 100 points = JD 1.000 discount'**
  String get loyaltyRedeemRule;

  /// No description provided for @loyaltyTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get loyaltyTransactions;

  /// No description provided for @loyaltyEarn.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get loyaltyEarn;

  /// No description provided for @loyaltyRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get loyaltyRedeem;

  /// No description provided for @loyaltyExpire.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get loyaltyExpire;

  /// No description provided for @loyaltyAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get loyaltyAdjust;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @todayRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Revenue'**
  String get todayRevenue;

  /// No description provided for @todayOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders Today'**
  String get todayOrders;

  /// No description provided for @pendingDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Pending Deliveries'**
  String get pendingDeliveries;

  /// No description provided for @lowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get lowStockAlerts;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @productNameAr.
  ///
  /// In en, this message translates to:
  /// **'Product Name (Arabic)'**
  String get productNameAr;

  /// No description provided for @productSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get productSku;

  /// No description provided for @productSlug.
  ///
  /// In en, this message translates to:
  /// **'Slug'**
  String get productSlug;

  /// No description provided for @productDescription2.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescription2;

  /// No description provided for @productBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get productBrand;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productCategory;

  /// No description provided for @productBasePrice.
  ///
  /// In en, this message translates to:
  /// **'Base Price (JD)'**
  String get productBasePrice;

  /// No description provided for @productCostPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price (JD)'**
  String get productCostPrice;

  /// No description provided for @productCommissionRate.
  ///
  /// In en, this message translates to:
  /// **'Commission Rate (%)'**
  String get productCommissionRate;

  /// No description provided for @productSizeSystem.
  ///
  /// In en, this message translates to:
  /// **'Size System'**
  String get productSizeSystem;

  /// No description provided for @productMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get productMaterial;

  /// No description provided for @productCareInstructions.
  ///
  /// In en, this message translates to:
  /// **'Care Instructions'**
  String get productCareInstructions;

  /// No description provided for @productStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get productStatus;

  /// No description provided for @productColors2.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get productColors2;

  /// No description provided for @addColor.
  ///
  /// In en, this message translates to:
  /// **'Add Color'**
  String get addColor;

  /// No description provided for @colorName.
  ///
  /// In en, this message translates to:
  /// **'Color Name'**
  String get colorName;

  /// No description provided for @colorHex.
  ///
  /// In en, this message translates to:
  /// **'Hex Code'**
  String get colorHex;

  /// No description provided for @productSizes2.
  ///
  /// In en, this message translates to:
  /// **'Sizes'**
  String get productSizes2;

  /// No description provided for @addSize.
  ///
  /// In en, this message translates to:
  /// **'Add Size'**
  String get addSize;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size Label'**
  String get sizeLabel;

  /// No description provided for @uploadImages.
  ///
  /// In en, this message translates to:
  /// **'Upload Images'**
  String get uploadImages;

  /// No description provided for @storeAssignment.
  ///
  /// In en, this message translates to:
  /// **'Store Assignment'**
  String get storeAssignment;

  /// No description provided for @priceOverride.
  ///
  /// In en, this message translates to:
  /// **'Price Override (JD)'**
  String get priceOverride;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProduct;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantity;

  /// No description provided for @reservedStock.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reservedStock;

  /// No description provided for @availableStock.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableStock;

  /// No description provided for @reorderLevel.
  ///
  /// In en, this message translates to:
  /// **'Reorder Level'**
  String get reorderLevel;

  /// No description provided for @lastRestocked.
  ///
  /// In en, this message translates to:
  /// **'Last Restocked'**
  String get lastRestocked;

  /// No description provided for @updateStock.
  ///
  /// In en, this message translates to:
  /// **'Update Stock'**
  String get updateStock;

  /// No description provided for @bulkRestock.
  ///
  /// In en, this message translates to:
  /// **'Bulk Restock'**
  String get bulkRestock;

  /// No description provided for @lowStockTab.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStockTab;

  /// No description provided for @ordersAdmin.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersAdmin;

  /// No description provided for @orderFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get orderFilters;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @assignDriver.
  ///
  /// In en, this message translates to:
  /// **'Assign Driver'**
  String get assignDriver;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @customerDetail.
  ///
  /// In en, this message translates to:
  /// **'Customer Detail'**
  String get customerDetail;

  /// No description provided for @totalOrders2.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders2;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @adjustPoints.
  ///
  /// In en, this message translates to:
  /// **'Adjust Points'**
  String get adjustPoints;

  /// No description provided for @pointsAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Points Adjustment'**
  String get pointsAdjustment;

  /// No description provided for @adjustmentNote.
  ///
  /// In en, this message translates to:
  /// **'Reason / Note'**
  String get adjustmentNote;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @addStaff.
  ///
  /// In en, this message translates to:
  /// **'Add Staff Member'**
  String get addStaff;

  /// No description provided for @employeeCode.
  ///
  /// In en, this message translates to:
  /// **'Employee Code'**
  String get employeeCode;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @hireDate.
  ///
  /// In en, this message translates to:
  /// **'Hire Date'**
  String get hireDate;

  /// No description provided for @storeAssignment2.
  ///
  /// In en, this message translates to:
  /// **'Store Assignment'**
  String get storeAssignment2;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @commissions.
  ///
  /// In en, this message translates to:
  /// **'Commissions'**
  String get commissions;

  /// No description provided for @pendingCommissions.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingCommissions;

  /// No description provided for @approvedCommissions.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvedCommissions;

  /// No description provided for @paidCommissions.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidCommissions;

  /// No description provided for @approveCommission.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveCommission;

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markPaid;

  /// No description provided for @deliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveries;

  /// No description provided for @activeDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeDeliveries;

  /// No description provided for @driverName.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverName;

  /// No description provided for @deliveryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get deliveryStatus;

  /// No description provided for @trackingInfo.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get trackingInfo;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get statusAssigned;

  /// No description provided for @statusPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get statusPickedUp;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get statusReturned;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers & Promotions'**
  String get offers;

  /// No description provided for @addOffer.
  ///
  /// In en, this message translates to:
  /// **'Add Offer'**
  String get addOffer;

  /// No description provided for @offerName.
  ///
  /// In en, this message translates to:
  /// **'Offer Name'**
  String get offerName;

  /// No description provided for @offerDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get offerDescription;

  /// No description provided for @discountType.
  ///
  /// In en, this message translates to:
  /// **'Discount Type'**
  String get discountType;

  /// No description provided for @discountValue.
  ///
  /// In en, this message translates to:
  /// **'Discount Value'**
  String get discountValue;

  /// No description provided for @minOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Value'**
  String get minOrderValue;

  /// No description provided for @maxUses.
  ///
  /// In en, this message translates to:
  /// **'Maximum Uses'**
  String get maxUses;

  /// No description provided for @couponCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code'**
  String get couponCodeLabel;

  /// No description provided for @validFrom.
  ///
  /// In en, this message translates to:
  /// **'Valid From'**
  String get validFrom;

  /// No description provided for @validTo.
  ///
  /// In en, this message translates to:
  /// **'Valid To'**
  String get validTo;

  /// No description provided for @isActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get isActive;

  /// No description provided for @restrictions.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get restrictions;

  /// No description provided for @byStore.
  ///
  /// In en, this message translates to:
  /// **'By Store'**
  String get byStore;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get byCategory;

  /// No description provided for @byProduct.
  ///
  /// In en, this message translates to:
  /// **'By Product'**
  String get byProduct;

  /// No description provided for @saveOffer.
  ///
  /// In en, this message translates to:
  /// **'Save Offer'**
  String get saveOffer;

  /// No description provided for @returns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returns;

  /// No description provided for @returnId.
  ///
  /// In en, this message translates to:
  /// **'Return #'**
  String get returnId;

  /// No description provided for @saleReference.
  ///
  /// In en, this message translates to:
  /// **'Sale Reference'**
  String get saleReference;

  /// No description provided for @approveReturn.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveReturn;

  /// No description provided for @rejectReturn.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectReturn;

  /// No description provided for @processRefund.
  ///
  /// In en, this message translates to:
  /// **'Process Refund'**
  String get processRefund;

  /// No description provided for @returnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get returnStatus;

  /// No description provided for @refundTotal.
  ///
  /// In en, this message translates to:
  /// **'Refund Total'**
  String get refundTotal;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @addStore.
  ///
  /// In en, this message translates to:
  /// **'Add Store'**
  String get addStore;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// No description provided for @storeCode.
  ///
  /// In en, this message translates to:
  /// **'Store Code'**
  String get storeCode;

  /// No description provided for @storeCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get storeCity;

  /// No description provided for @storePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get storePhone;

  /// No description provided for @storeType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get storeType;

  /// No description provided for @storeTypeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get storeTypeOnline;

  /// No description provided for @storeTypePhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get storeTypePhysical;

  /// No description provided for @storeTypePos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get storeTypePos;

  /// No description provided for @storeStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get storeStatus;

  /// No description provided for @posTitle.
  ///
  /// In en, this message translates to:
  /// **'Marcat POS'**
  String get posTitle;

  /// No description provided for @posShift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get posShift;

  /// No description provided for @posStartShift.
  ///
  /// In en, this message translates to:
  /// **'Start Shift'**
  String get posStartShift;

  /// No description provided for @posEndShift.
  ///
  /// In en, this message translates to:
  /// **'End Shift'**
  String get posEndShift;

  /// No description provided for @posTodayRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Revenue'**
  String get posTodayRevenue;

  /// No description provided for @posTodayTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions Today'**
  String get posTodayTransactions;

  /// No description provided for @posSearchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search product, SKU, or scan barcode...'**
  String get posSearchProducts;

  /// No description provided for @posScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get posScanBarcode;

  /// No description provided for @posCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get posCart;

  /// No description provided for @posClearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get posClearCart;

  /// No description provided for @posCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get posCustomer;

  /// No description provided for @posAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Walk-in / Anonymous'**
  String get posAnonymous;

  /// No description provided for @posSearchCustomer.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get posSearchCustomer;

  /// No description provided for @posPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get posPayment;

  /// No description provided for @posCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get posCash;

  /// No description provided for @posCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get posCard;

  /// No description provided for @posLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Points'**
  String get posLoyalty;

  /// No description provided for @posAmountTendered.
  ///
  /// In en, this message translates to:
  /// **'Amount Tendered'**
  String get posAmountTendered;

  /// No description provided for @posChangeDue.
  ///
  /// In en, this message translates to:
  /// **'Change Due'**
  String get posChangeDue;

  /// No description provided for @posCardReference.
  ///
  /// In en, this message translates to:
  /// **'Card Reference #'**
  String get posCardReference;

  /// No description provided for @posPointsToRedeem.
  ///
  /// In en, this message translates to:
  /// **'Points to Redeem'**
  String get posPointsToRedeem;

  /// No description provided for @posCompleteSale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get posCompleteSale;

  /// No description provided for @posReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get posReceipt;

  /// No description provided for @posPrintReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get posPrintReceipt;

  /// No description provided for @posNewSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get posNewSale;

  /// No description provided for @posSalesHistory.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get posSalesHistory;

  /// No description provided for @posReprintReceipt.
  ///
  /// In en, this message translates to:
  /// **'Reprint Receipt'**
  String get posReprintReceipt;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusPending2.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending2;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// No description provided for @salePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get salePending;

  /// No description provided for @saleConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get saleConfirmed;

  /// No description provided for @saleProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get saleProcessing;

  /// No description provided for @saleShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get saleShipped;

  /// No description provided for @saleDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get saleDelivered;

  /// No description provided for @saleCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get saleCancelled;

  /// No description provided for @saleCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get saleCompleted;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentPending;

  /// No description provided for @paymentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get paymentCompleted;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get paymentFailed;

  /// No description provided for @paymentRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get paymentRefunded;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminProducts;

  /// No description provided for @adminOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get adminOrders;

  /// No description provided for @adminStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get adminStaff;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get navWishlist;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get cartTitle;

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @checkoutButton.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutButton;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Placed Successfully!'**
  String get orderSuccessTitle;

  /// No description provided for @orderSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your order.'**
  String get orderSuccessBody;

  /// No description provided for @selectColorSizeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a color and size first.'**
  String get selectColorSizeFirst;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @colorTitle.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorTitle;

  /// No description provided for @sizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sizeTitle;

  /// No description provided for @descriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionTitle;

  /// No description provided for @addToCartButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCartButton;

  /// No description provided for @addressEmpty.
  ///
  /// In en, this message translates to:
  /// **'No addresses found'**
  String get addressEmpty;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderTotal;

  /// No description provided for @myLoyaltyBalance.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Balance'**
  String get myLoyaltyBalance;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get networkError;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noData;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
