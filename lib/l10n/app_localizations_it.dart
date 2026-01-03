// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Calcolatrice BCV';

  @override
  String get settings => 'Impostaz.';

  @override
  String get general => 'Generale';

  @override
  String get storageNetwork => 'Archiviazione e Rete';

  @override
  String get storageNetworkSubtitle => 'Gestisci cache e aggiornamenti';

  @override
  String get notifications => 'Notifiche';

  @override
  String get notificationsSubtitle =>
      'Avvisa quando è disponibile un nuovo tasso';

  @override
  String get language => 'Lingua';

  @override
  String get systemDefault => 'Predefinito di sistema';

  @override
  String get information => 'Informazioni';

  @override
  String get aboutApp => 'Informazioni sull\'App';

  @override
  String get aboutAppSubtitle => 'Versione, sviluppatore e licenze';

  @override
  String get forceUpdate => 'Forza Aggiornamento';

  @override
  String get forceUpdateSubtitle => 'Aggiorna tassi dall\'API';

  @override
  String get clearCache => 'Cancella Cache';

  @override
  String get clearCacheSubtitle => 'Elimina dati salvati localmente';

  @override
  String get cancel => 'Annulla';

  @override
  String get close => 'Chiudi';

  @override
  String get updatingRates => 'Aggiornamento tassi...';

  @override
  String get cacheCleared => 'Cache cancellata';

  @override
  String get developer => 'Sviluppatore';

  @override
  String get dataSource => 'Fonte Dati';

  @override
  String get legalNotice => 'Avviso Legale';

  @override
  String get legalNoticeText =>
      'Questa applicazione NON rappresenta alcuna entità governativa o bancaria. Non siamo affiliati alla Banca Centrale del Venezuela. I dati sono ottenuti tramite un\'API che consulta il sito ufficiale della BCV. L\'uso delle informazioni è di esclusiva responsabilità dell\'utente.';

  @override
  String get openSourceLicenses => 'Licenze Open Source';

  @override
  String get version => 'Versione';

  @override
  String get becomePro => 'Diventa PRO!';

  @override
  String get proUser => 'Sei un Utente PRO!';

  @override
  String get getPro => 'Attiva Funzioni PRO (Beta)';

  @override
  String get oneTimePayment => '';

  @override
  String get activateProBetaTitle =>
      'Vuoi attivare le funzioni PRO per questa sessione di test?';

  @override
  String get activateProBetaAccept => 'Attiva';

  @override
  String get restorePurchases => 'Ripristina Acquisti';

  @override
  String get benefitAds => 'Niente pubblicità';

  @override
  String get benefitAdsDesc =>
      'Goditi un\'interfaccia pulita e senza interruzioni.';

  @override
  String get benefitPdf => 'Esportazione Istantanea';

  @override
  String get benefitPdfDesc =>
      'Genera PDF della cronologia senza guardare video pubblicitari.';

  @override
  String get benefitSpeed => 'Massima Velocità';

  @override
  String get benefitSpeedDesc =>
      'Navigazione più fluida e minor consumo di batteria.';

  @override
  String get benefitSupport => 'Supporta il progetto';

  @override
  String get benefitSupportDesc =>
      'Aiutaci a continuare a migliorare lo strumento.';

  @override
  String get usd => 'Dollari';

  @override
  String get eur => 'Euro';

  @override
  String get ves => 'Bolivar';

  @override
  String get history => 'Cronologia';

  @override
  String get historyRates => 'Cronologia Tassi';

  @override
  String get start => 'Inizio';

  @override
  String get end => 'Fine';

  @override
  String get generatePdf => 'Genera PDF';

  @override
  String get watchAd => 'Guarda pubblicità per sbloccare';

  @override
  String get loadingAd => 'Caricamento pubblicità...';

  @override
  String get errorAd => 'Errore caricamento';

  @override
  String get today => 'Oggi';

  @override
  String get tomorrow => 'Domani';

  @override
  String get officialRate => 'Tasso Ufficiale';

  @override
  String get customRate => 'Tasso Personalizzato';

  @override
  String get convert => 'Converti';

  @override
  String get rateLabel => 'Tasso';

  @override
  String get priceScanner => 'Scanner Prezzi';

  @override
  String get cameraPermissionText =>
      'Questo strumento usa la fotocamera per rilevare i prezzi e convertirli in tempo reale.\n\nRichiede accesso a Fotocamera e Galleria.';

  @override
  String get allowAndContinue => 'Consenti e Continua';

  @override
  String get whatToScan => 'Cosa vuoi scansionare?';

  @override
  String get amountUsd => 'USD';

  @override
  String get amountEur => 'EUR';

  @override
  String get amountVes => 'Bs.';

  @override
  String get ratePers => 'Pers.';

  @override
  String get noCustomRates => 'Nessun tasso personalizzato';

  @override
  String get noCustomRatesDesc =>
      'Aggiungi un tasso per usare questa funzione.';

  @override
  String get createRate => 'Crea Tasso';

  @override
  String get chooseRate => 'Scegli un tasso';

  @override
  String get newRate => 'Nuovo Tasso...';

  @override
  String get convertVesTo => 'Converti Bolivar in...';

  @override
  String get homeScreen => 'Home';

  @override
  String get calculatorScreen => 'Calcolatrice';

  @override
  String get rateDate => 'Data Valuta';

  @override
  String get officialRateBcv => 'Tasso Ufficiale BCV';

  @override
  String get createYourFirstRate => 'Crea il tuo primo tasso';

  @override
  String get addCustomRatesDescription =>
      'Aggiungi tassi personalizzati per i calcoli.';

  @override
  String get errorLoadingRate => 'Errore caricamento tasso';

  @override
  String get unlockPdfTitle => 'Sblocca Export PDF';

  @override
  String get unlockPdfDesc =>
      'Per esportare in PDF, guarda una pubblicità. Sbloccherà la funzione per 24 ore.';

  @override
  String get adNotReady =>
      'La pubblicità non è ancora pronta. Riprova tra qualche secondo.';

  @override
  String get featureUnlocked => 'Funzione sbloccata per 24 ore!';

  @override
  String get pdfHeader => 'Cronologia Prezzi BCV';

  @override
  String get statsPeriod => 'Statistiche del Periodo';

  @override
  String get copiedClipboard => 'Copiato negli appunti';

  @override
  String get amountDollars => 'Importo in Dollari';

  @override
  String get amountEuros => 'Importo in Euro';

  @override
  String get amountBolivars => 'Importo in Bolivar';

  @override
  String get amountCustom => 'Importo in';

  @override
  String get shareError => 'Errore condivisione';

  @override
  String get pdfError => 'Errore generazione PDF';

  @override
  String get viewList => 'Vedi Lista';

  @override
  String get viewChart => 'Vedi Grafico';

  @override
  String get noData => 'Nessun dato disponibile';

  @override
  String get mean => 'Media';

  @override
  String get min => 'Minimo';

  @override
  String get max => 'Massimo';

  @override
  String get change => 'Variazione';

  @override
  String get rangeWeek => '1 Sett';

  @override
  String get rangeMonth => '1 Mese';

  @override
  String get rangeThreeMonths => '3 Mesi';

  @override
  String get rangeYear => '1 Anno';

  @override
  String get rangeCustom => 'Person';

  @override
  String get removeAdsLink => 'Rimuovi pubblicità';

  @override
  String get thanksSupport => 'Grazie per il tuo supporto!';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get deactivateProTest => 'Disattiva PRO (Test)';

  @override
  String get deactivateProTitle => 'Disattiva PRO';

  @override
  String get deactivateProMessage =>
      'Vuoi disattivare la modalità PRO? (Solo per test)';

  @override
  String get deactivateProSuccess =>
      'PRO disattivato. Riavvia l\'app per applicare le modifiche.';

  @override
  String get pdfCurrency => 'Valuta';

  @override
  String get pdfRange => 'Intervallo';

  @override
  String get pdfDailyDetails => 'Dettagli Giornalieri';

  @override
  String get pdfDate => 'Data';

  @override
  String get pdfRate => 'Tasso (Bs)';

  @override
  String get pdfChangePercent => 'Var. %';

  @override
  String get noInternetConnection =>
      'Nessuna connessione internet. I dati potrebbero essere obsoleti.';

  @override
  String get internetRestored => 'Connessione ripristinata.';

  @override
  String get ratesUpdatedSuccess => 'Tassi aggiornati con successo.';
}
