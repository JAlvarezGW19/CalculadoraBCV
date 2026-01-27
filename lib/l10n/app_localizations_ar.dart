// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'حاسبة BCV';

  @override
  String get settings => 'الإعدادات';

  @override
  String get general => 'عام';

  @override
  String get storageNetwork => 'التخزين والشبكة';

  @override
  String get storageNetworkSubtitle => 'إدارة التخزين المؤقت والتحديثات';

  @override
  String get notifications => 'إشعارات';

  @override
  String get notificationsSubtitle => 'إشعار عند توفر سعر جديد';

  @override
  String get language => 'اللغة';

  @override
  String get systemDefault => 'الافتراضي للنظام';

  @override
  String get information => 'معلومات';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get aboutAppSubtitle => 'الإصدار، المطور والتراخيص';

  @override
  String get forceUpdate => 'فرض التحديث';

  @override
  String get forceUpdateSubtitle => 'تحديث الأسعار من API';

  @override
  String get clearCache => 'مسح التخزين المؤقت';

  @override
  String get clearCacheSubtitle => 'حذف البيانات المحفوظة محليًا';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get updatingRates => 'جاري تحديث الأسعار...';

  @override
  String get cacheCleared => 'تم مسح الذاكرة المؤقتة';

  @override
  String get developer => 'المطور';

  @override
  String get dataSource => 'مصدر البيانات';

  @override
  String get legalNotice => 'إشعار قانوني';

  @override
  String get legalNoticeText =>
      'هذا التطبيق لا يمثل أي جهة حكومية أو مصرفية. ليس لدينا أي ارتباط بالبنك المركزي الفنزويلي. يتم الحصول على البيانات عبر API تستعلم من موقع BCV الرسمي. استخدام المعلومات هو مسؤولية المستخدم وحده.';

  @override
  String get openSourceLicenses => 'تراخيص المصدر المفتوح';

  @override
  String get version => 'الإصدار';

  @override
  String get becomePro => 'كن مستخدم PRO!';

  @override
  String get proUser => 'أنت مستخدم PRO!';

  @override
  String get getPro => 'احصل على PRO';

  @override
  String get oneTimePayment => '';

  @override
  String get activateProBetaTitle =>
      'هل تريد تفعيل ميزات PRO لجلسة الاختبار هذه؟';

  @override
  String get activateProBetaAccept => 'تفعيل';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get benefitAds => 'بدون إعلانات';

  @override
  String get benefitAdsDesc => 'استمتع بواجهة نظيفة وبدون انقطاع.';

  @override
  String get benefitPdf => 'تصدير فوري';

  @override
  String get benefitPdfDesc =>
      'أنشئ تقارير PDF للسجل دون مشاهدة إعلانات الفيديو.';

  @override
  String get benefitSpeed => 'سرعة قصوى';

  @override
  String get benefitSpeedDesc => 'تصفح أكثر سلاسة.';

  @override
  String get benefitSupport => 'ادعم المشروع';

  @override
  String get benefitSupportDesc => 'ساعدنا في مواصلة تحسين الأداة.';

  @override
  String get usd => 'دولار';

  @override
  String get eur => 'يورو';

  @override
  String get ves => 'بوليفار';

  @override
  String get history => 'السجل';

  @override
  String get historyRates => 'سجل الأسعار';

  @override
  String get start => 'البداية';

  @override
  String get end => 'النهاية';

  @override
  String get generatePdf => 'إنشاء PDF';

  @override
  String get watchAd => 'شاهد إعلان لفتح الميزة';

  @override
  String get loadingAd => 'جاري تحميل الإعلان...';

  @override
  String get errorAd => 'خطأ في التحميل';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غداً';

  @override
  String get officialRate => 'السعر الرسمي';

  @override
  String get customRate => 'سعر مخصص';

  @override
  String get convert => 'تحويل';

  @override
  String get rateLabel => 'سعر';

  @override
  String get priceScanner => 'ماسح الأسعار';

  @override
  String get cameraPermissionText =>
      'تستخدم هذه الأداة الكاميرا لاكتشاف الأسعار وتحويلها في الوقت الفعلي.\n\nيتطلب الوصول إلى الكاميرا والمعرض.';

  @override
  String get allowAndContinue => 'سماح ومتابعة';

  @override
  String get whatToScan => 'ماذا ستمسح ضوئيًا؟';

  @override
  String get amountUsd => 'USD';

  @override
  String get amountEur => 'EUR';

  @override
  String get amountVes => 'Bs.';

  @override
  String get ratePers => 'مخصص';

  @override
  String get noCustomRates => 'لا توجد أسعار مخصصة';

  @override
  String get noCustomRatesDesc => 'لا توجد أسعار مخصصة';

  @override
  String get createRate => 'إنشاء سعر';

  @override
  String get chooseRate => 'اختر سعرًا';

  @override
  String get newRate => 'سعر جديد...';

  @override
  String get convertVesTo => 'تحويل بوليفار إلى...';

  @override
  String get homeScreen => 'الرئيسية';

  @override
  String get calculatorScreen => 'آلة حاسبة';

  @override
  String get rateDate => 'تاريخ الاستحقاق';

  @override
  String get officialRateBcv => 'سعر BCV الرسمي';

  @override
  String get createYourFirstRate => 'أنشئ سعرك المخصص الأول';

  @override
  String get addCustomRatesDescription => 'أضف أسعار صرف مخصصة لحساب تحويلاتك.';

  @override
  String get errorLoadingRate => 'خطأ في تحميل السعر';

  @override
  String get unlockPdfTitle => 'فتح تصدير PDF';

  @override
  String get unlockPdfDesc =>
      'لتصدير السجل إلى PDF، يرجى مشاهدة إعلان قصير. سيؤدي هذا إلى فتح الميزة لمدة 24 ساعة.';

  @override
  String get adNotReady =>
      'الإعلان ليس جاهزًا بعد. حاول مرة أخرى في غضون ثوان.';

  @override
  String get featureUnlocked => 'تم فتح الميزة لمدة 24 ساعة!';

  @override
  String get pdfHeader => 'تاريخ أسعار BCV';

  @override
  String get statsPeriod => 'إحصائيات الفترة';

  @override
  String get copiedClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get amountDollars => 'المبلغ بالدولار';

  @override
  String get amountEuros => 'المبلغ باليورو';

  @override
  String get amountBolivars => 'المبلغ بالبوليفار';

  @override
  String get amountCustom => 'المبلغ بـ';

  @override
  String get shareError => 'خطأ في المشاركة';

  @override
  String get pdfError => 'خطأ في إنشاء PDF';

  @override
  String get viewList => 'عرض القائمة';

  @override
  String get viewChart => 'عرض الرسم البياني';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get mean => 'متوسط';

  @override
  String get min => 'الحد الأدنى';

  @override
  String get max => 'الحد الأقصى';

  @override
  String get change => 'تغيير';

  @override
  String get rangeWeek => '1 أسبوع';

  @override
  String get rangeMonth => '1 شهر';

  @override
  String get rangeThreeMonths => '3 أشهر';

  @override
  String get rangeYear => '1 سنة';

  @override
  String get rangeCustom => 'مخصص';

  @override
  String get removeAdsLink => 'إزالة الإعلانات';

  @override
  String get thanksSupport => 'شكرا لدعمك!';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get deactivateProTest => 'إلغاء تنشيط PRO (اختبار)';

  @override
  String get deactivateProTitle => 'إلغاء تنشيط PRO';

  @override
  String get deactivateProMessage =>
      'هل تريد إلغاء تنشيط وضع PRO؟ (للاختبار فقط)';

  @override
  String get deactivateProSuccess =>
      'تم إلغاء تنشيط PRO. أعد تشغيل التطبيق لتطبيق التغييرات.';

  @override
  String get pdfCurrency => 'العملة';

  @override
  String get pdfRange => 'النطاق';

  @override
  String get pdfDailyDetails => 'التفاصيل اليومية';

  @override
  String get pdfDate => 'التاريخ';

  @override
  String get pdfRate => 'السعر (Bs)';

  @override
  String get pdfChangePercent => 'التغيير %';

  @override
  String get noInternetConnection =>
      'لا يوجد اتصال بالإنترنت. قد تكون البيانات قديمة.';

  @override
  String get internetRestored => 'تمت استعادة الاتصال.';

  @override
  String get ratesUpdatedSuccess => 'تم تحديث الأسعار بنجاح.';

  @override
  String get rateNameExists => 'السعر بهذا الاسم موجود بالفعل';

  @override
  String get rateNameLabel => 'الاسم (الحد الأقصى 10)';

  @override
  String get rateValueLabel => 'السعر (بوليفار)';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get editRate => 'تعديل السعر';

  @override
  String get selectRate => 'اختيار السعر';

  @override
  String get tutorialOneTitle => 'العملات والتواريخ';

  @override
  String get tutorialOneDesc =>
      'التبديل بين الدولار واليورو والأسعار المخصصة. يمكنك أيضًا التحقق من أسعار اليوم وغدًا.';

  @override
  String get tutorialTwoTitle => 'ترتيب التحويل';

  @override
  String get tutorialTwoDesc =>
      'اضغط هنا لتغيير الترتيب. اكتب بالدولار لرؤية البوليفارات، أو العكس.';

  @override
  String get tutorialThreeTitle => 'المسح الذكي';

  @override
  String get tutorialThreeDesc =>
      'استخدم الكاميرا لاكتشاف الأسعار وتحويلها تلقائيًا في الوقت الفعلي.';

  @override
  String get tutorialSkip => 'تخطي';

  @override
  String get tutorialNext => 'التالي';

  @override
  String get tutorialFinish => 'إنهاء';

  @override
  String get customRatePlaceholder =>
      'هنا يمكنك إضافة أسعار مخصصة مثل Zelle أو Binance أو التحويلات المالية. سنقوم بحساب الفرق مع البنك المركزي الفنزويلي تلقائيًا.';

  @override
  String get shareApp => 'مشاركة التطبيق';

  @override
  String get shareAppSubtitle => 'أوصي به لأصدقائك';

  @override
  String get rateApp => 'قيم التطبيق';

  @override
  String get rateAppSubtitle => 'ادعمنا بـ 5 نجوم';

  @override
  String get moreApps => 'المزيد من التطبيقات';

  @override
  String get moreAppsSubtitle => 'اكتشف أدوات أخرى مفيدة';

  @override
  String get shareMessage =>
      'مرحباً! أوصي بحاسبة BCV. إنها سريعة جداً ودقيقة. حملها من هنا: https://play.google.com/store/apps/details?id=com.juanalvarez.calculadorabcv';

  @override
  String get paymentSettings => 'إدارة المدفوعات';

  @override
  String get noAccounts => 'لا توجد حسابات محفوظة';

  @override
  String get addAccount => 'إضافة حساب';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String deleteAccountContent(Object alias) {
    return 'هل تريد حذف \"$alias\"؟';
  }

  @override
  String get deleteAction => 'حذف';

  @override
  String get newAccount => 'حساب جديد';

  @override
  String get editAccount => 'تعديل الحساب';

  @override
  String get aliasLabel => 'الاسم المستعار (اسم التعريف)';

  @override
  String get bankLabel => 'البنك';

  @override
  String get ciLabel => 'الهوية / RIF';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get accountNumberLabel => 'رقم الحساب (20 رقماً)';

  @override
  String get pagoMovil => 'الدفع عبر الهاتف';

  @override
  String get bankTransfer => 'تحويل بنكي';

  @override
  String get requiredField => 'حقل مطلوب';

  @override
  String get selectBank => 'اختر بنكاً';

  @override
  String get onlyAmount => 'نص فقط / المبلغ';

  @override
  String get configureAccounts => 'إعداد الحسابات';

  @override
  String get configureAccountsDesc => 'أضف بياناتك للمشاركة بسرعة';

  @override
  String get yourAccounts => 'حساباتك';

  @override
  String get manageAccounts => 'إدارة الحسابات';

  @override
  String get transferData => 'بيانات التحويل';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get accountLabel => 'الحساب';

  @override
  String get actionCopy => 'نسخ';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String get paymentAccountsTitle => 'حسابات الدفع';

  @override
  String get paymentAccountsSubtitle =>
      'إدارة بياناتك للدفع عبر الهاتف والتحويل';
}
