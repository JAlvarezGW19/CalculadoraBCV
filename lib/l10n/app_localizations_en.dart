// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BCV Calculator';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get storageNetwork => 'Storage & Network';

  @override
  String get storageNetworkSubtitle => 'Manage cache and updates';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Notify when new rate is available';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get information => 'Information';

  @override
  String get aboutApp => 'About the App';

  @override
  String get aboutAppSubtitle => 'Version, developer and licenses';

  @override
  String get forceUpdate => 'Force Update';

  @override
  String get forceUpdateSubtitle => 'Update rates from API';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheSubtitle => 'Delete locally stored data';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get updatingRates => 'Updating rates...';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get developer => 'Developer';

  @override
  String get dataSource => 'Data Source';

  @override
  String get legalNotice => 'Legal Notice';

  @override
  String get legalNoticeText =>
      'This application does NOT represent any government or banking entity. We are not affiliated with the Central Bank of Venezuela. Data is obtained via an API querying the official BCV website. Use of information is the sole responsibility of the user.';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get version => 'Version';

  @override
  String get becomePro => 'Become a PRO user!';

  @override
  String get proUser => 'You are a PRO User!';

  @override
  String get getPro => 'Get PRO';

  @override
  String get oneTimePayment => '';

  @override
  String get activateProBetaTitle =>
      'Do you want to activate PRO features for this test session?';

  @override
  String get activateProBetaAccept => 'Activate';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get benefitAds => 'No Ads';

  @override
  String get benefitAdsDesc => 'Enjoy a clean, interruption-free interface.';

  @override
  String get benefitPdf => 'Instant Export';

  @override
  String get benefitPdfDesc =>
      'Generate history PDFs without watching video ads.';

  @override
  String get benefitSpeed => 'Max Speed';

  @override
  String get benefitSpeedDesc => 'Smoother navigation.';

  @override
  String get benefitSupport => 'Support the project';

  @override
  String get benefitSupportDesc => 'Help us continue improving the tool.';

  @override
  String get usd => 'Dollars';

  @override
  String get eur => 'Euros';

  @override
  String get ves => 'Bolivars';

  @override
  String get history => 'History';

  @override
  String get historyRates => 'Rate History';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get watchAd => 'Watch ad to unlock';

  @override
  String get loadingAd => 'Loading ad...';

  @override
  String get errorAd => 'Error loading ad';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get officialRate => 'Official Rate';

  @override
  String get customRate => 'Custom Rate';

  @override
  String get convert => 'Convert';

  @override
  String get rateLabel => 'Rate';

  @override
  String get priceScanner => 'Price Scanner';

  @override
  String get cameraPermissionText =>
      'This tool uses the camera to detect prices and convert them in real time.\n\nTo function, it needs access to Camera and Gallery (to pick images).';

  @override
  String get allowAndContinue => 'Allow and Continue';

  @override
  String get whatToScan => 'What will you scan?';

  @override
  String get amountUsd => 'USD';

  @override
  String get amountEur => 'EUR';

  @override
  String get amountVes => 'Bs.';

  @override
  String get ratePers => 'Cust.';

  @override
  String get noCustomRates => 'No custom rates';

  @override
  String get noCustomRatesDesc =>
      'You need to add a custom rate to use this feature.';

  @override
  String get createRate => 'Create Rate';

  @override
  String get chooseRate => 'Choose a rate';

  @override
  String get newRate => 'New Rate...';

  @override
  String get convertVesTo => 'Convert Bolivars to...';

  @override
  String get homeScreen => 'Home';

  @override
  String get calculatorScreen => 'Calculator';

  @override
  String get rateDate => 'Value Date';

  @override
  String get officialRateBcv => 'Official BCV Rate';

  @override
  String get createYourFirstRate => 'Create your first custom rate';

  @override
  String get addCustomRatesDescription =>
      'Add custom exchange rates to calculate your conversions.';

  @override
  String get errorLoadingRate => 'Error loading rate';

  @override
  String get unlockPdfTitle => 'Unlock PDF Export';

  @override
  String get unlockPdfDesc =>
      'To export history to PDF, please watch a short ad. This will unlock the feature for 24 hours.';

  @override
  String get adNotReady =>
      'The ad is not ready yet. Try again in a few seconds.';

  @override
  String get featureUnlocked => 'Feature unlocked for 24 hours!';

  @override
  String get pdfHeader => 'BCV Price History';

  @override
  String get statsPeriod => 'Period Statistics';

  @override
  String get copiedClipboard => 'Copied to clipboard';

  @override
  String get amountDollars => 'Amount in Dollars';

  @override
  String get amountEuros => 'Amount in Euros';

  @override
  String get amountBolivars => 'Amount in Bolivars';

  @override
  String get amountCustom => 'Amount in';

  @override
  String get shareError => 'Error sharing';

  @override
  String get pdfError => 'Error generating PDF';

  @override
  String get viewList => 'View List';

  @override
  String get viewChart => 'View Chart';

  @override
  String get noData => 'No data available';

  @override
  String get mean => 'Average';

  @override
  String get min => 'Minimum';

  @override
  String get max => 'Maximum';

  @override
  String get change => 'Change';

  @override
  String get rangeWeek => '1 Wk';

  @override
  String get rangeMonth => '1 Mo';

  @override
  String get rangeThreeMonths => '3 Mos';

  @override
  String get rangeYear => '1 Yr';

  @override
  String get rangeCustom => 'Custom';

  @override
  String get removeAdsLink => 'Remove Ads';

  @override
  String get thanksSupport => 'Thanks for your support!';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get deactivateProTest => 'Deactivate PRO (Testing)';

  @override
  String get deactivateProTitle => 'Deactivate PRO';

  @override
  String get deactivateProMessage =>
      'Do you want to deactivate PRO mode? (Testing only)';

  @override
  String get deactivateProSuccess =>
      'PRO deactivated. Restart the app to apply changes.';

  @override
  String get pdfCurrency => 'Currency';

  @override
  String get pdfRange => 'Range';

  @override
  String get pdfDailyDetails => 'Daily Details (Reverse Chronological)';

  @override
  String get pdfDate => 'Date';

  @override
  String get pdfRate => 'Rate (Bs)';

  @override
  String get pdfChangePercent => 'Change %';

  @override
  String get noInternetConnection =>
      'No internet connection. Data may be outdated.';

  @override
  String get internetRestored => 'Connection restored.';

  @override
  String get ratesUpdatedSuccess => 'Rates updated successfully.';

  @override
  String get rateNameExists => 'A rate with this name already exists';

  @override
  String get rateNameLabel => 'Name (Max 10)';

  @override
  String get rateValueLabel => 'Rate (Bolivars)';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get editRate => 'Edit Rate';

  @override
  String get selectRate => 'Select rate';

  @override
  String get tutorialOneTitle => 'Currencies and Dates';

  @override
  String get tutorialOneDesc =>
      'Switch between Dollar, Euro and Custom rates. You can also check Today\'s and Tomorrow\'s rates.';

  @override
  String get tutorialTwoTitle => 'Conversion Order';

  @override
  String get tutorialTwoDesc =>
      'Tap here to change the order. Type in Dollars to see Bolivars, or vice versa.';

  @override
  String get tutorialThreeTitle => 'Smart Scan';

  @override
  String get tutorialThreeDesc =>
      'Use the camera to detect prices and convert them automatically in real-time.';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialFinish => 'Finish';

  @override
  String get customRatePlaceholder =>
      'Here you can add custom rates like Zelle, Binance or Remittances. We will automatically calculate the difference with the BCV.';

  @override
  String get shareApp => 'Share App';

  @override
  String get shareAppSubtitle => 'Recommend to your friends';

  @override
  String get rateApp => 'Rate App';

  @override
  String get rateAppSubtitle => 'Support us with 5 stars';

  @override
  String get moreApps => 'More Apps';

  @override
  String get moreAppsSubtitle => 'Discover other useful tools';

  @override
  String get shareMessage =>
      'Hello! I recommend the BCV Calculator. It is super fast and accurate. Download it here: https://play.google.com/store/apps/details?id=com.juanalvarez.calculadorabcv';

  @override
  String get paymentSettings => 'Payment Management';

  @override
  String get noAccounts => 'No saved accounts';

  @override
  String get addAccount => 'Add Account';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String deleteAccountContent(Object alias) {
    return 'Do you want to delete \"$alias\"?';
  }

  @override
  String get deleteAction => 'Delete';

  @override
  String get newAccount => 'New Account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get aliasLabel => 'Alias (Identity Name)';

  @override
  String get bankLabel => 'Bank';

  @override
  String get ciLabel => 'ID / RIF';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get accountNumberLabel => 'Account Number (20 digits)';

  @override
  String get pagoMovil => 'Mobile Payment';

  @override
  String get bankTransfer => 'Transfer';

  @override
  String get requiredField => 'Required field';

  @override
  String get selectBank => 'Select a bank';

  @override
  String get onlyAmount => 'Text Only / Amount';

  @override
  String get configureAccounts => 'Configure Accounts';

  @override
  String get configureAccountsDesc => 'Add your data to share fast';

  @override
  String get yourAccounts => 'YOUR ACCOUNTS';

  @override
  String get manageAccounts => 'Manage Accounts';

  @override
  String get transferData => 'Transfer Data';

  @override
  String get nameLabel => 'Name';

  @override
  String get accountLabel => 'Account';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionShare => 'Share';

  @override
  String get amountLabel => 'Amount';

  @override
  String get paymentAccountsTitle => 'Payment Accounts';

  @override
  String get paymentAccountsSubtitle =>
      'Manage your data for mobile payment and transfer';
}
