// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Calculatrice BCV';

  @override
  String get settings => 'Paramètres';

  @override
  String get general => 'Général';

  @override
  String get storageNetwork => 'Stockage et Réseau';

  @override
  String get storageNetworkSubtitle => 'Gérer le cache et les mises à jour';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle =>
      'Avertir quand un nouveau taux est disponible';

  @override
  String get language => 'Langue';

  @override
  String get systemDefault => 'Défaut du système';

  @override
  String get information => 'Information';

  @override
  String get aboutApp => 'À propos de l\'application';

  @override
  String get aboutAppSubtitle => 'Version, développeur et licences';

  @override
  String get forceUpdate => 'Forcer la mise à jour';

  @override
  String get forceUpdateSubtitle => 'Mettre à jour les taux depuis l\'API';

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get clearCacheSubtitle => 'Supprimer les données locales';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get updatingRates => 'Mise à jour des taux...';

  @override
  String get cacheCleared => 'Cache vidé';

  @override
  String get developer => 'Développeur';

  @override
  String get dataSource => 'Source de données';

  @override
  String get legalNotice => 'Mentions légales';

  @override
  String get legalNoticeText =>
      'Cette application ne représente AUCUNE entité gouvernementale ou bancaire. Nous ne sommes pas affiliés à la Banque Centrale du Venezuela. Les données sont obtenues via une API interrogeant le site officiel de la BCV. L\'utilisation des informations relève de la seule responsabilité de l\'utilisateur.';

  @override
  String get openSourceLicenses => 'Licences Open Source';

  @override
  String get version => 'Version';

  @override
  String get becomePro => 'Devenez utilisateur PRO !';

  @override
  String get proUser => 'Vous êtes utilisateur PRO !';

  @override
  String get getPro => 'Obtenir PRO pour';

  @override
  String get oneTimePayment => '(Paiement unique à vie)';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get benefitAds => 'Pas de publicité';

  @override
  String get benefitAdsDesc =>
      'Profitez d\'une interface propre et sans interruption.';

  @override
  String get benefitPdf => 'Exportation instantanée';

  @override
  String get benefitPdfDesc =>
      'Générez des PDF d\'historique sans regarder de pubs vidéo.';

  @override
  String get benefitSpeed => 'Vitesse maximale';

  @override
  String get benefitSpeedDesc =>
      'Navigation plus fluide et consommation réduite.';

  @override
  String get benefitSupport => 'Soutenir le projet';

  @override
  String get benefitSupportDesc =>
      'Aidez-nous à continuer d\'améliorer l\'outil.';

  @override
  String get usd => 'Dollars';

  @override
  String get eur => 'Euros';

  @override
  String get ves => 'Bolivars';

  @override
  String get history => 'Historique';

  @override
  String get historyRates => 'Historique des taux';

  @override
  String get start => 'Début';

  @override
  String get end => 'Fin';

  @override
  String get generatePdf => 'Générer PDF';

  @override
  String get watchAd => 'Regarder une pub pour débloquer';

  @override
  String get loadingAd => 'Chargement de la publicité...';

  @override
  String get errorAd => 'Erreur de chargement';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get officialRate => 'Taux Officiel';

  @override
  String get customRate => 'Taux Personnalisé';

  @override
  String get convert => 'Convertir';

  @override
  String get priceScanner => 'Scanner de prix';

  @override
  String get cameraPermissionText =>
      'Cet outil utilise la caméra pour détecter les prix et les convertir en temps réel.\n\nNécessite l\'accès à la caméra et à la galerie.';

  @override
  String get allowAndContinue => 'Autoriser et continuer';

  @override
  String get whatToScan => 'Que allez-vous scanner?';

  @override
  String get amountUsd => 'Montant USD';

  @override
  String get amountEur => 'Montant EUR';

  @override
  String get amountVes => 'Montant Bs.';

  @override
  String get ratePers => 'Taux Pers.';

  @override
  String get noCustomRates => 'Aucun taux personnalisé';

  @override
  String get noCustomRatesDesc =>
      'Ajoutez un taux personnalisé pour utiliser cette fonction.';

  @override
  String get createRate => 'Créer Taux';

  @override
  String get chooseRate => 'Choisir un taux';

  @override
  String get newRate => 'Nouveau Taux...';

  @override
  String get convertVesTo => 'Convertir Bolivars en...';

  @override
  String get homeScreen => 'Accueil';

  @override
  String get calculatorScreen => 'Calculatrice';

  @override
  String get rateDate => 'Date de valeur';

  @override
  String get officialRateBcv => 'Taux Officiel BCV';

  @override
  String get createYourFirstRate => 'Créez votre premier taux';

  @override
  String get addCustomRatesDescription =>
      'Ajoutez des taux personnalisés pour vos conversions.';

  @override
  String get errorLoadingRate => 'Erreur de chargement du taux';

  @override
  String get unlockPdfTitle => 'Débloquer l\'export PDF';

  @override
  String get unlockPdfDesc =>
      'Pour exporter en PDF, regardez une courte pub. Cela débloquera la fonction pour 24h.';

  @override
  String get adNotReady =>
      'La pub n\'est pas encore prête. Réessayez dans quelques secondes.';

  @override
  String get featureUnlocked => 'Fonctionnalité débloquée pour 24 heures !';

  @override
  String get pdfHeader => 'Historique des prix BCV';

  @override
  String get statsPeriod => 'Statistiques de la Période';

  @override
  String get copiedClipboard => 'Copié dans le presse-papiers';

  @override
  String get amountDollars => 'Montant en Dollars';

  @override
  String get amountEuros => 'Montant en Euros';

  @override
  String get amountBolivars => 'Montant en Bolivars';

  @override
  String get amountCustom => 'Montant en';

  @override
  String get shareError => 'Erreur de partage';

  @override
  String get pdfError => 'Erreur de génération PDF';

  @override
  String get viewList => 'Voir Liste';

  @override
  String get viewChart => 'Voir Graphique';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get mean => 'Moyenne';

  @override
  String get min => 'Minimum';

  @override
  String get max => 'Maximum';

  @override
  String get change => 'Variation';

  @override
  String get rangeWeek => '1 Sem';

  @override
  String get rangeMonth => '1 Mois';

  @override
  String get rangeThreeMonths => '3 Mois';

  @override
  String get rangeYear => '1 An';

  @override
  String get rangeCustom => 'Perso';

  @override
  String get removeAdsLink => 'Supprimer les pubs';

  @override
  String get thanksSupport => 'Merci pour votre soutien !';
}
