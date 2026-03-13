// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ماركات';

  @override
  String get tagline => 'أناقة رجالية في كل خطوة';

  @override
  String get loginTitle => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجّل دخولك إلى حسابك في ماركات';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String registerPrompt(String link) {
    return 'جديد في ماركات؟ $link';
  }

  @override
  String get registerLink => 'إنشاء حساب';

  @override
  String loginPrompt(String link) {
    return 'لديك حساب بالفعل؟ $link';
  }

  @override
  String get loginLink => 'تسجيل الدخول';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'انضم إلى ماركات اليوم';

  @override
  String get firstNameLabel => 'الاسم الأول';

  @override
  String get lastNameLabel => 'اسم العائلة';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get registerButton => 'إنشاء الحساب';

  @override
  String get termsText => 'بإنشاء حساب، فإنك توافق على الشروط والأحكام';

  @override
  String get forgotPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني لاستلام رابط الاستعادة';

  @override
  String get sendResetLink => 'إرسال رابط الاستعادة';

  @override
  String get resetEmailSentTitle => 'تفقّد بريدك الإلكتروني';

  @override
  String resetEmailSentBody(String email) {
    return 'أرسلنا رابط استعادة كلمة المرور إلى $email';
  }

  @override
  String get onboardingTitle1 => 'أزياء رجالية راقية';

  @override
  String get onboardingBody1 =>
      'اكتشف أرقى الملابس الرجالية من أشهر الماركات في مكان واحد.';

  @override
  String get onboardingTitle2 => 'تسوّق من متاجر متعددة';

  @override
  String get onboardingBody2 =>
      'تصفّح منتجات المتاجر عبر الأردن مع توفر مباشر للمخزون.';

  @override
  String get onboardingTitle3 => 'اكسب نقاط الولاء';

  @override
  String get onboardingBody3 =>
      'كل عملية شراء تكسبك نقاطاً. استبدلها للحصول على خصومات حصرية.';

  @override
  String get onboardingSkip => 'تخطّ';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String currency(String amount) {
    return 'JD $amount';
  }

  @override
  String loyaltyPoints(int count) {
    return '$count نقطة';
  }

  @override
  String homeGreeting(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get featuredStores => 'المتاجر المميزة';

  @override
  String get newArrivals => 'وصل حديثاً';

  @override
  String get shopByCategory => 'تسوّق حسب الفئة';

  @override
  String get topPicks => 'مختارات خاصة لك';

  @override
  String get activeOffers => 'عروض حصرية';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String get searchProducts => 'ابحث عن منتجات...';

  @override
  String get searchHint => 'ابحث بالاسم أو الرمز أو الماركة';

  @override
  String get filter => 'تصفية';

  @override
  String get sort => 'ترتيب';

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get sortPriceLow => 'السعر: من الأقل للأعلى';

  @override
  String get sortPriceHigh => 'السعر: من الأعلى للأقل';

  @override
  String get sortBestSelling => 'الأكثر مبيعاً';

  @override
  String get gridView => 'عرض شبكي';

  @override
  String get listView => 'عرض قائمة';

  @override
  String get filterCategory => 'الفئة';

  @override
  String get filterBrand => 'الماركة';

  @override
  String get filterPriceRange => 'نطاق السعر';

  @override
  String get filterSize => 'المقاس';

  @override
  String get filterColor => 'اللون';

  @override
  String get applyFilters => 'تطبيق الفلاتر';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String resultsCount(int count) {
    return '$count نتيجة';
  }

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get addToWishlist => 'أضف للمفضلة';

  @override
  String get removeFromWishlist => 'إزالة من المفضلة';

  @override
  String get outOfStock => 'نفد المخزون';

  @override
  String get inStock => 'متوفر';

  @override
  String get lowStock => 'مخزون محدود';

  @override
  String get selectColor => 'اختر اللون';

  @override
  String get selectSize => 'اختر المقاس';

  @override
  String get quantity => 'الكمية';

  @override
  String get material => 'الخامة';

  @override
  String get careInstructions => 'تعليمات العناية';

  @override
  String get checkAvailability => 'التحقق من التوفر في المتاجر';

  @override
  String get relatedProducts => 'قد يعجبك أيضاً';

  @override
  String get shareProduct => 'مشاركة';

  @override
  String get productDescription => 'الوصف';

  @override
  String get availableAt => 'متوفر في';

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String get cart => 'سلة المشتريات';

  @override
  String get cartEmpty => 'سلة التسوق فارغة';

  @override
  String get cartEmptySubtitle => 'أضف منتجات للبدء';

  @override
  String get startShopping => 'ابدأ التسوق';

  @override
  String cartItems(int count) {
    return '$count عناصر';
  }

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get subtotal => 'المجموع الجزئي';

  @override
  String get discount => 'الخصم';

  @override
  String get shipping => 'الشحن';

  @override
  String get tax => 'الضريبة';

  @override
  String get grandTotal => 'الإجمالي';

  @override
  String get couponCode => 'كود الخصم';

  @override
  String get couponHint => 'أدخل كود الخصم';

  @override
  String get applyCoupon => 'تطبيق';

  @override
  String couponApplied(String amount) {
    return 'تم تطبيق الكوبون! وفّرت $amount';
  }

  @override
  String get couponInvalid => 'كود الخصم غير صالح أو منتهي الصلاحية';

  @override
  String get proceedToCheckout => 'إتمام الشراء';

  @override
  String get removeItem => 'إزالة المنتج';

  @override
  String get confirmRemoveItem => 'هل تريد إزالة هذا المنتج من سلتك؟';

  @override
  String get checkoutTitle => 'إتمام الشراء';

  @override
  String get shippingAddress => 'عنوان الشحن';

  @override
  String get deliveryOptions => 'خيارات التوصيل';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get reviewOrder => 'مراجعة الطلب';

  @override
  String get placeOrder => 'تأكيد الطلب';

  @override
  String get standardDelivery => 'توصيل عادي (2-3 أيام)';

  @override
  String get expressDelivery => 'توصيل سريع (اليوم التالي)';

  @override
  String get cashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get bankTransfer => 'حوالة بنكية';

  @override
  String get creditCard => 'بطاقة ائتمان';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get expiryDate => 'تاريخ الانتهاء';

  @override
  String get cvv => 'CVV';

  @override
  String get cardHolder => 'اسم حامل البطاقة';

  @override
  String get addNewAddress => '+ إضافة عنوان جديد';

  @override
  String get noAddresses => 'لا توجد عناوين محفوظة';

  @override
  String get orderConfirmed => 'تم تأكيد طلبك!';

  @override
  String get orderReference => 'رقم الطلب';

  @override
  String get copyReference => 'نسخ الرقم';

  @override
  String pointsEarned(int points) {
    return 'حصلت على $points نقطة ولاء';
  }

  @override
  String get trackOrder => 'تتبع الطلب';

  @override
  String get continueShopping => 'مواصلة التسوق';

  @override
  String get orders => 'الطلبات';

  @override
  String get ordersAll => 'الكل';

  @override
  String get ordersActive => 'النشطة';

  @override
  String get ordersCompleted => 'المكتملة';

  @override
  String get ordersCancelled => 'الملغاة';

  @override
  String get ordersEmpty => 'لا توجد طلبات';

  @override
  String get ordersEmptySubtitle => 'سجل طلباتك سيظهر هنا';

  @override
  String get orderDate => 'تاريخ الطلب';

  @override
  String orderItems(int count) {
    return '$count عناصر';
  }

  @override
  String get orderDetail => 'تفاصيل الطلب';

  @override
  String get orderStatus => 'حالة الطلب';

  @override
  String get orderItems2 => 'المنتجات';

  @override
  String get paymentInfo => 'معلومات الدفع';

  @override
  String get deliveryInfo => 'معلومات التوصيل';

  @override
  String get trackingNumber => 'رقم التتبع';

  @override
  String get estimatedDelivery => 'الوقت المتوقع للتوصيل';

  @override
  String get downloadReceipt => 'تنزيل الفاتورة';

  @override
  String get requestReturn => 'طلب إرجاع';

  @override
  String get returnRequest => 'طلب إرجاع';

  @override
  String get selectItemsToReturn => 'اختر المنتجات المراد إرجاعها';

  @override
  String get returnReason => 'سبب الإرجاع';

  @override
  String get returnReasonDefective => 'معيب';

  @override
  String get returnReasonWrongItem => 'منتج خاطئ';

  @override
  String get returnReasonWrongSize => 'مقاس خاطئ';

  @override
  String get returnReasonChangedMind => 'غيّرت رأيي';

  @override
  String get returnReasonOther => 'سبب آخر';

  @override
  String get returnNote => 'ملاحظات إضافية (اختياري)';

  @override
  String get submitReturn => 'تقديم طلب الإرجاع';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get myAddresses => 'عناويني';

  @override
  String get wishlist => 'المفضلة';

  @override
  String get loyaltyHistory => 'سجل نقاط الولاء';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get language => 'اللغة';

  @override
  String get aboutMarcat => 'عن ماركات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get addresses => 'عناويني';

  @override
  String get defaultAddress => 'الافتراضي';

  @override
  String get setDefault => 'تعيين كافتراضي';

  @override
  String get deleteAddress => 'حذف العنوان';

  @override
  String get confirmDeleteAddress => 'هل تريد حذف هذا العنوان؟';

  @override
  String get addAddress => '+ إضافة عنوان';

  @override
  String get addressLabel => 'تسمية العنوان (مثال: منزل، عمل)';

  @override
  String get addressLine1 => 'عنوان الشارع';

  @override
  String get addressLine2 => 'الشقة / الجناح (اختياري)';

  @override
  String get city => 'المدينة';

  @override
  String get stateProvince => 'المحافظة / الولاية';

  @override
  String get postalCode => 'الرمز البريدي';

  @override
  String get country => 'الدولة';

  @override
  String get saveAddress => 'حفظ العنوان';

  @override
  String get wishlistTitle => 'المفضلة';

  @override
  String get wishlistEmpty => 'قائمة المفضلة فارغة';

  @override
  String get wishlistEmptySubtitle => 'احفظ المنتجات التي تعجبك';

  @override
  String get loyaltyTitle => 'نقاط الولاء';

  @override
  String get loyaltyBalance => 'رصيدك الحالي';

  @override
  String get loyaltyHowItWorks => 'كيف يعمل النظام';

  @override
  String get loyaltyEarnRule => 'اكسب نقطة واحدة لكل دينار أردني تنفقه';

  @override
  String get loyaltyRedeemRule => 'استبدل 100 نقطة بخصم قدره JD 1.000';

  @override
  String get loyaltyTransactions => 'سجل المعاملات';

  @override
  String get loyaltyEarn => 'مكتسبة';

  @override
  String get loyaltyRedeem => 'مستبدلة';

  @override
  String get loyaltyExpire => 'منتهية';

  @override
  String get loyaltyAdjust => 'تعديل';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get todayRevenue => 'إيرادات اليوم';

  @override
  String get todayOrders => 'طلبات اليوم';

  @override
  String get pendingDeliveries => 'التوصيلات المعلقة';

  @override
  String get lowStockAlerts => 'تنبيهات المخزون المنخفض';

  @override
  String get products => 'المنتجات';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get productNameAr => 'اسم المنتج (عربي)';

  @override
  String get productSku => 'رمز المنتج (SKU)';

  @override
  String get productSlug => 'الرابط المختصر';

  @override
  String get productDescription2 => 'الوصف';

  @override
  String get productBrand => 'الماركة';

  @override
  String get productCategory => 'الفئة';

  @override
  String get productBasePrice => 'السعر الأساسي (JD)';

  @override
  String get productCostPrice => 'سعر التكلفة (JD)';

  @override
  String get productCommissionRate => 'نسبة العمولة (%)';

  @override
  String get productSizeSystem => 'نظام المقاسات';

  @override
  String get productMaterial => 'الخامة';

  @override
  String get productCareInstructions => 'تعليمات العناية';

  @override
  String get productStatus => 'الحالة';

  @override
  String get productColors2 => 'الألوان';

  @override
  String get addColor => 'إضافة لون';

  @override
  String get colorName => 'اسم اللون';

  @override
  String get colorHex => 'كود اللون';

  @override
  String get productSizes2 => 'المقاسات';

  @override
  String get addSize => 'إضافة مقاس';

  @override
  String get sizeLabel => 'تسمية المقاس';

  @override
  String get uploadImages => 'رفع الصور';

  @override
  String get storeAssignment => 'تعيين المتاجر';

  @override
  String get priceOverride => 'تجاوز السعر (JD)';

  @override
  String get saveProduct => 'حفظ المنتج';

  @override
  String get inventory => 'المخزون';

  @override
  String get stockQuantity => 'الكمية المتاحة';

  @override
  String get reservedStock => 'المحجوز';

  @override
  String get availableStock => 'المتاح';

  @override
  String get reorderLevel => 'حد إعادة الطلب';

  @override
  String get lastRestocked => 'آخر تعبئة';

  @override
  String get updateStock => 'تحديث المخزون';

  @override
  String get bulkRestock => 'تعبئة جماعية';

  @override
  String get lowStockTab => 'مخزون منخفض';

  @override
  String get ordersAdmin => 'الطلبات';

  @override
  String get orderFilters => 'الفلاتر';

  @override
  String get dateRange => 'نطاق التاريخ';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get assignDriver => 'تعيين سائق';

  @override
  String get updateStatus => 'تحديث الحالة';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get customers => 'العملاء';

  @override
  String get customerDetail => 'تفاصيل العميل';

  @override
  String get totalOrders2 => 'إجمالي الطلبات';

  @override
  String get totalSpent => 'إجمالي الإنفاق';

  @override
  String get adjustPoints => 'تعديل النقاط';

  @override
  String get pointsAdjustment => 'تعديل النقاط';

  @override
  String get adjustmentNote => 'السبب / الملاحظة';

  @override
  String get staff => 'الموظفون';

  @override
  String get addStaff => 'إضافة موظف';

  @override
  String get employeeCode => 'رقم الموظف';

  @override
  String get department => 'القسم';

  @override
  String get hireDate => 'تاريخ التوظيف';

  @override
  String get storeAssignment2 => 'تعيين المتجر';

  @override
  String get role => 'الدور الوظيفي';

  @override
  String get commissions => 'العمولات';

  @override
  String get pendingCommissions => 'معلقة';

  @override
  String get approvedCommissions => 'معتمدة';

  @override
  String get paidCommissions => 'مدفوعة';

  @override
  String get approveCommission => 'اعتماد';

  @override
  String get markPaid => 'تعليم كمدفوع';

  @override
  String get deliveries => 'التوصيلات';

  @override
  String get activeDeliveries => 'النشطة';

  @override
  String get driverName => 'السائق';

  @override
  String get deliveryStatus => 'الحالة';

  @override
  String get trackingInfo => 'معلومات التتبع';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusAssigned => 'معيّن';

  @override
  String get statusPickedUp => 'تم الاستلام';

  @override
  String get statusInTransit => 'في الطريق';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusFailed => 'فشل التوصيل';

  @override
  String get statusReturned => 'مُعاد';

  @override
  String get offers => 'العروض والتخفيضات';

  @override
  String get addOffer => 'إضافة عرض';

  @override
  String get offerName => 'اسم العرض';

  @override
  String get offerDescription => 'الوصف';

  @override
  String get discountType => 'نوع الخصم';

  @override
  String get discountValue => 'قيمة الخصم';

  @override
  String get minOrderValue => 'الحد الأدنى للطلب';

  @override
  String get maxUses => 'الحد الأقصى للاستخدام';

  @override
  String get couponCodeLabel => 'كود الكوبون';

  @override
  String get validFrom => 'صالح من';

  @override
  String get validTo => 'صالح حتى';

  @override
  String get isActive => 'مفعّل';

  @override
  String get restrictions => 'القيود';

  @override
  String get byStore => 'حسب المتجر';

  @override
  String get byCategory => 'حسب الفئة';

  @override
  String get byProduct => 'حسب المنتج';

  @override
  String get saveOffer => 'حفظ العرض';

  @override
  String get returns => 'المرتجعات';

  @override
  String get returnId => 'رقم المرتجع';

  @override
  String get saleReference => 'رقم الطلب';

  @override
  String get approveReturn => 'قبول';

  @override
  String get rejectReturn => 'رفض';

  @override
  String get processRefund => 'معالجة الاسترداد';

  @override
  String get returnStatus => 'الحالة';

  @override
  String get refundTotal => 'إجمالي الاسترداد';

  @override
  String get stores => 'المتاجر';

  @override
  String get addStore => 'إضافة متجر';

  @override
  String get storeName => 'اسم المتجر';

  @override
  String get storeCode => 'رمز المتجر';

  @override
  String get storeCity => 'المدينة';

  @override
  String get storePhone => 'الهاتف';

  @override
  String get storeType => 'النوع';

  @override
  String get storeTypeOnline => 'إلكتروني';

  @override
  String get storeTypePhysical => 'فيزيائي';

  @override
  String get storeTypePos => 'نقطة بيع';

  @override
  String get storeStatus => 'الحالة';

  @override
  String get posTitle => 'نقطة بيع ماركات';

  @override
  String get posShift => 'الوردية';

  @override
  String get posStartShift => 'بدء الوردية';

  @override
  String get posEndShift => 'إنهاء الوردية';

  @override
  String get posTodayRevenue => 'إيرادات اليوم';

  @override
  String get posTodayTransactions => 'معاملات اليوم';

  @override
  String get posSearchProducts => 'ابحث عن منتج، SKU، أو امسح الباركود...';

  @override
  String get posScanBarcode => 'مسح الباركود';

  @override
  String get posCart => 'السلة';

  @override
  String get posClearCart => 'مسح السلة';

  @override
  String get posCustomer => 'العميل';

  @override
  String get posAnonymous => 'زبون عابر';

  @override
  String get posSearchCustomer => 'ابحث بالاسم أو الهاتف';

  @override
  String get posPayment => 'الدفع';

  @override
  String get posCash => 'نقداً';

  @override
  String get posCard => 'بطاقة';

  @override
  String get posLoyalty => 'نقاط الولاء';

  @override
  String get posAmountTendered => 'المبلغ المدفوع';

  @override
  String get posChangeDue => 'المبلغ المتبقي';

  @override
  String get posCardReference => 'رقم مرجع البطاقة';

  @override
  String get posPointsToRedeem => 'النقاط للاستبدال';

  @override
  String get posCompleteSale => 'إتمام البيع';

  @override
  String get posReceipt => 'الفاتورة';

  @override
  String get posPrintReceipt => 'طباعة الفاتورة';

  @override
  String get posNewSale => 'بيع جديد';

  @override
  String get posSalesHistory => 'مبيعات اليوم';

  @override
  String get posReprintReceipt => 'إعادة الطباعة';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusInactive => 'غير نشط';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusPending2 => 'قيد الانتظار';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusProcessing => 'قيد المعالجة';

  @override
  String get statusShipped => 'تم الشحن';

  @override
  String get salePending => 'قيد الانتظار';

  @override
  String get saleConfirmed => 'مؤكد';

  @override
  String get saleProcessing => 'قيد المعالجة';

  @override
  String get saleShipped => 'تم الشحن';

  @override
  String get saleDelivered => 'تم التوصيل';

  @override
  String get saleCancelled => 'ملغى';

  @override
  String get saleCompleted => 'مكتمل';

  @override
  String get paymentPending => 'قيد الانتظار';

  @override
  String get paymentCompleted => 'مكتمل';

  @override
  String get paymentFailed => 'فشل';

  @override
  String get paymentRefunded => 'مسترجع';

  @override
  String get adminDashboard => 'لوحة التحكم';

  @override
  String get adminProducts => 'المنتجات';

  @override
  String get adminOrders => 'الطلبات';

  @override
  String get adminStaff => 'الموظفون';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCategories => 'التصنيفات';

  @override
  String get navCart => 'السلة';

  @override
  String get navWishlist => 'المفضلة';

  @override
  String get navProfile => 'حسابي';

  @override
  String get cartTitle => 'سلة التسوق';

  @override
  String get cartSubtotal => 'المجموع الفرعي';

  @override
  String get checkoutButton => 'الدفع';

  @override
  String get noCategoriesFound => 'لم يتم العثور على تصنيفات';

  @override
  String get orderSuccessTitle => 'تم تأكيد الطلب بنجاح!';

  @override
  String get orderSuccessBody => 'شكراً لطلبك من ماركات.';

  @override
  String get selectColorSizeFirst => 'الرجاء اختيار اللون والمقاس أولاً.';

  @override
  String get addedToCart => 'تمت الإضافة للسلة';

  @override
  String get colorTitle => 'اللون';

  @override
  String get sizeTitle => 'المقاس';

  @override
  String get descriptionTitle => 'الوصف';

  @override
  String get addToCartButton => 'إضافة إلى السلة';

  @override
  String get addressEmpty => 'لم يتم العثور على عناوين';

  @override
  String get defaultLabel => 'الافتراضي';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get orderTotal => 'الإجمالي';

  @override
  String get myLoyaltyBalance => 'رصيد النقاط';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get aboutUs => 'من نحن';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get error => 'حدث خطأ ما';

  @override
  String get networkError => 'تحقق من اتصالك بالإنترنت';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get done => 'تم';

  @override
  String get search => 'بحث';

  @override
  String get clear => 'مسح';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'حسناً';

  @override
  String get submit => 'إرسال';

  @override
  String get select => 'اختر';

  @override
  String get optional => '(اختياري)';

  @override
  String get required => 'مطلوب';

  @override
  String get na => 'لا ينطبق';

  @override
  String get unknown => 'غير معروف';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';
}
