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
  String get getPro => 'PRO erhalten';

  @override
  String get oneTimePayment => '';

  @override
  String get activateProBetaTitle =>
      'Möchten Sie die PRO-Funktionen für diese Testsitzung aktivieren?';

  @override
  String get activateProBetaAccept => 'Aktivieren';

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
  String get benefitSpeedDesc => 'Flüssigere Navigation.';

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
  String get rateLabel => 'Kurs';

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
  String get amountUsd => 'USD';

  @override
  String get amountEur => 'EUR';

  @override
  String get amountVes => 'Bs.';

  @override
  String get ratePers => 'Pers.';

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

  @override
  String get removeAdsLink => 'Werbung entfernen';

  @override
  String get thanksSupport => 'Danke für deine Unterstützung!';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get deactivateProTest => 'PRO deaktivieren (Tests)';

  @override
  String get deactivateProTitle => 'PRO deaktivieren';

  @override
  String get deactivateProMessage =>
      'Möchten Sie den PRO-Modus deaktivieren? (Nur für Tests)';

  @override
  String get deactivateProSuccess =>
      'PRO deaktiviert. Starten Sie die App neu, um Änderungen anzuwenden.';

  @override
  String get pdfCurrency => 'Währung';

  @override
  String get pdfRange => 'Bereich';

  @override
  String get pdfDailyDetails => 'Tägliche Details';

  @override
  String get pdfDate => 'Datum';

  @override
  String get pdfRate => 'Kurs (Bs)';

  @override
  String get pdfChangePercent => 'Änd. %';

  @override
  String get noInternetConnection =>
      'Keine Internetverbindung. Daten könnten veraltet sein.';

  @override
  String get internetRestored => 'Verbindung wiederhergestellt.';

  @override
  String get ratesUpdatedSuccess => 'Kurse erfolgreich aktualisiert.';

  @override
  String get rateNameExists => 'Ein Kurs mit diesem Namen existiert bereits';

  @override
  String get rateNameLabel => 'Name (Max. 10)';

  @override
  String get rateValueLabel => 'Kurs (Bolivar)';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get editRate => 'Kurs bearbeiten';

  @override
  String get selectRate => 'Kurs auswählen';

  @override
  String get tutorialOneTitle => 'Währungen und Daten';

  @override
  String get tutorialOneDesc =>
      'Wechseln Sie zwischen Dollar, Euro und benutzerdefinierten Kursen. Sie können auch die Kurse von Heute und Morgen überprüfen.';

  @override
  String get tutorialTwoTitle => 'Umrechnungsreihenfolge';

  @override
  String get tutorialTwoDesc =>
      'Tippen Sie hier, um die Reihenfolge zu ändern. Geben Sie in Dollar ein, um Bolivar zu sehen, oder umgekehrt.';

  @override
  String get tutorialThreeTitle => 'Intelligenter Scan';

  @override
  String get tutorialThreeDesc =>
      'Verwenden Sie die Kamera, um Preise zu erkennen und automatisch in Echtzeit umzurechnen.';

  @override
  String get tutorialSkip => 'Überspringen';

  @override
  String get tutorialNext => 'Weiter';

  @override
  String get tutorialFinish => 'Beenden';

  @override
  String get customRatePlaceholder =>
      'Hier können Sie benutzerdefinierte Kurse wie Zelle, Binance oder Überweisungen hinzufügen. Wir berechnen automatisch die Differenz zum BCV.';

  @override
  String get shareApp => 'App teilen';

  @override
  String get shareAppSubtitle => 'Empfehlen Sie uns weiter';

  @override
  String get rateApp => 'App bewerten';

  @override
  String get rateAppSubtitle => 'Unterstützen Sie uns mit 5 Sternen';

  @override
  String get moreApps => 'Mehr Apps';

  @override
  String get moreAppsSubtitle => 'Entdecken Sie weitere nützliche Tools';

  @override
  String get shareMessage =>
      'Hallo! Ich empfehle den BCV-Rechner. Er ist super schnell und genau. Hier herunterladen: https://play.google.com/store/apps/details?id=com.juanalvarez.calculadorabcv';

  @override
  String get paymentSettings => 'Zahlungsverwaltung';

  @override
  String get noAccounts => 'Keine gespeicherten Konten';

  @override
  String get addAccount => 'Konto hinzufügen';

  @override
  String get deleteAccountTitle => 'Konto löschen';

  @override
  String deleteAccountContent(Object alias) {
    return 'Möchten Sie \"$alias\" löschen?';
  }

  @override
  String get deleteAction => 'Löschen';

  @override
  String get newAccount => 'Neues Konto';

  @override
  String get editAccount => 'Konto bearbeiten';

  @override
  String get aliasLabel => 'Alias (Identifikationsname)';

  @override
  String get bankLabel => 'Bank';

  @override
  String get ciLabel => 'ID / RIF';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get accountNumberLabel => 'Kontonummer (20 Ziffern)';

  @override
  String get pagoMovil => 'Mobiles Bezahlen';

  @override
  String get bankTransfer => 'Überweisung';

  @override
  String get requiredField => 'Pflichtfeld';

  @override
  String get selectBank => 'Bank auswählen';

  @override
  String get onlyAmount => 'Nur Text / Betrag';

  @override
  String get configureAccounts => 'Konten konfigurieren';

  @override
  String get configureAccountsDesc =>
      'Fügen Sie Ihre Daten hinzu, um schnell zu teilen';

  @override
  String get yourAccounts => 'IHRE KONTEN';

  @override
  String get manageAccounts => 'Konten verwalten';

  @override
  String get transferData => 'Überweisungsdaten';

  @override
  String get nameLabel => 'Name';

  @override
  String get accountLabel => 'Konto';

  @override
  String get actionCopy => 'Kopieren';

  @override
  String get actionShare => 'Teilen';

  @override
  String get amountLabel => 'Betrag';

  @override
  String get paymentAccountsTitle => 'Zahlungskonten';

  @override
  String get paymentAccountsSubtitle =>
      'Verwalten Sie Ihre Daten für mobile Zahlung und Überweisung';
}
