// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'BCV Rechner';

  @override
  String get settings => 'Einstellungen';

  @override
  String get general => 'Allgemein';

  @override
  String get storageNetwork => 'Speicher & Netzwerk';

  @override
  String get storageNetworkSubtitle => 'Cache und Updates verwalten';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get notificationsSubtitle => 'Benachrichtigen bei neuem Kurs';

  @override
  String get language => 'Sprache';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get information => 'Informationen';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get aboutAppSubtitle => 'Version, Entwickler und Lizenzen';

  @override
  String get forceUpdate => 'Update erzwingen';

  @override
  String get forceUpdateSubtitle => 'Kurse von API aktualisieren';

  @override
  String get clearCache => 'Cache leeren';

  @override
  String get clearCacheSubtitle => 'Lokal gespeicherte Daten löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get updatingRates => 'Kurse werden aktualisiert...';

  @override
  String get cacheCleared => 'Cache geleert';

  @override
  String get developer => 'Entwickler';

  @override
  String get dataSource => 'Datenquelle';

  @override
  String get legalNotice => 'Rechtliche Hinweise';

  @override
  String get legalNoticeText =>
      'Diese App vertritt KEINE Regierungs- oder Bankbehörde. Wir sind nicht mit der Zentralbank von Venezuela verbunden. Die Daten werden über eine API abgerufen, die die offizielle BCV-Website abfragt. Die Nutzung der Informationen liegt in der alleinigen Verantwortung des Benutzers.';

  @override
  String get openSourceLicenses => 'Open-Source-Lizenzen';

  @override
  String get version => 'Version';

  @override
  String get becomePro => 'Werde PRO!';

  @override
  String get proUser => 'Du bist ein PRO-Benutzer!';

  @override
  String get getPro => 'PRO holen für';

  @override
  String get oneTimePayment => '(Einmalige Zahlung auf Lebenszeit)';

  @override
  String get restorePurchases => 'Einkäufe wiederherstellen';

  @override
  String get benefitAds => 'Keine Werbung';

  @override
  String get benefitAdsDesc =>
      'Genieße eine saubere Oberfläche ohne Unterbrechungen.';

  @override
  String get benefitPdf => 'Sofortiger Export';

  @override
  String get benefitPdfDesc => 'Erstelle Verlauf-PDFs ohne Videoanzeigen.';

  @override
  String get benefitSpeed => 'Maximale Geschwindigkeit';

  @override
  String get benefitSpeedDesc =>
      'Flüssigere Navigation und weniger Batterieverbrauch.';

  @override
  String get benefitSupport => 'Projekt unterstützen';

  @override
  String get benefitSupportDesc => 'Hilf uns, das Tool weiter zu verbessern.';

  @override
  String get usd => 'Dollar';

  @override
  String get eur => 'Euro';

  @override
  String get ves => 'Bolivar';

  @override
  String get history => 'Verlauf';

  @override
  String get historyRates => 'Kursverlauf';

  @override
  String get start => 'Start';

  @override
  String get end => 'Ende';

  @override
  String get generatePdf => 'PDF generieren';

  @override
  String get watchAd => 'Werbung ansehen zum Entsperren';

  @override
  String get loadingAd => 'Werbung lädt...';

  @override
  String get errorAd => 'Fehler beim Laden';

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get officialRate => 'Offizieller Kurs';

  @override
  String get customRate => 'Benutzerdef. Kurs';

  @override
  String get convert => 'Konvertieren';

  @override
  String get priceScanner => 'Preisscanner';

  @override
  String get cameraPermissionText =>
      'Dieses Tool nutzt die Kamera, um Preise zu erkennen und umzurechnen.\n\nBenötigt Zugriff auf Kamera und Galerie.';

  @override
  String get allowAndContinue => 'Erlauben und fortfahren';

  @override
  String get whatToScan => 'Was möchtest du scannen?';

  @override
  String get amountUsd => 'Betrag USD';

  @override
  String get amountEur => 'Betrag EUR';

  @override
  String get amountVes => 'Betrag Bs.';

  @override
  String get ratePers => 'Benutzerd.';

  @override
  String get noCustomRates => 'Keine eigenen Kurse';

  @override
  String get noCustomRatesDesc =>
      'Füge einen eigenen Kurs hinzu, um dies zu nutzen.';

  @override
  String get createRate => 'Kurs erstellen';

  @override
  String get chooseRate => 'Kurs wählen';

  @override
  String get newRate => 'Neuer Kurs...';

  @override
  String get convertVesTo => 'Bolivar umrechnen in...';

  @override
  String get homeScreen => 'Home';

  @override
  String get calculatorScreen => 'Rechner';

  @override
  String get rateDate => 'Valutadatum';

  @override
  String get officialRateBcv => 'Offizieller BCV-Kurs';

  @override
  String get createYourFirstRate => 'Erstellen Sie Ihren ersten Kurs';

  @override
  String get addCustomRatesDescription =>
      'Fügen Sie eigene Kurse für Berechnungen hinzu.';

  @override
  String get errorLoadingRate => 'Fehler beim Laden des Kurses';

  @override
  String get unlockPdfTitle => 'PDF-Export entsperren';

  @override
  String get unlockPdfDesc =>
      'Um als PDF zu exportieren, schau dir eine Werbung an. Dies schaltet die Funktion für 24h frei.';

  @override
  String get adNotReady =>
      'Die Werbung ist noch nicht bereit. Versuch es gleich noch einmal.';

  @override
  String get featureUnlocked => 'Funktion für 24 Stunden freigeschaltet!';

  @override
  String get pdfHeader => 'BCV-Preisverlauf';

  @override
  String get statsPeriod => 'Periodenstatistik';

  @override
  String get copiedClipboard => 'In die Zwischenablage kopiert';

  @override
  String get amountDollars => 'Betrag in Dollar';

  @override
  String get amountEuros => 'Betrag in Euro';

  @override
  String get amountBolivars => 'Betrag in Bolivar';

  @override
  String get amountCustom => 'Betrag in';

  @override
  String get shareError => 'Fehler beim Teilen';

  @override
  String get pdfError => 'Fehler beim PDF-Erstellen';

  @override
  String get viewList => 'Liste anzeigen';

  @override
  String get viewChart => 'Diagramm anzeigen';

  @override
  String get noData => 'Keine Daten verfügbar';

  @override
  String get mean => 'Durchschnitt';

  @override
  String get min => 'Minimum';

  @override
  String get max => 'Maximum';

  @override
  String get change => 'Veränderung';

  @override
  String get rangeWeek => '1 Wo';

  @override
  String get rangeMonth => '1 Mon';

  @override
  String get rangeThreeMonths => '3 Mon';

  @override
  String get rangeYear => '1 Jahr';

  @override
  String get rangeCustom => 'Benutzer';
}
