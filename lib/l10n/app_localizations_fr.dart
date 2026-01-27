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
  String get getPro => 'Obtenir PRO';

  @override
  String get oneTimePayment => '';

  @override
  String get activateProBetaTitle =>
      'Voulez-vous activer les fonctions PRO pour cette session de test ?';

  @override
  String get activateProBetaAccept => 'Activer';

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
  String get benefitSpeedDesc => 'Navigation plus fluide.';

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
  String get tomorrow => 'Dem.';

  @override
  String get officialRate => 'Taux Officiel';

  @override
  String get customRate => 'Taux Personnalisé';

  @override
  String get convert => 'Convertir';

  @override
  String get rateLabel => 'Taux';

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
  String get amountUsd => 'USD';

  @override
  String get amountEur => 'EUR';

  @override
  String get amountVes => 'Bs.';

  @override
  String get ratePers => 'Pers.';

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

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get deactivateProTest => 'Désactiver PRO (Tests)';

  @override
  String get deactivateProTitle => 'Désactiver PRO';

  @override
  String get deactivateProMessage =>
      'Voulez-vous désactiver le mode PRO? (Tests uniquement)';

  @override
  String get deactivateProSuccess =>
      'PRO désactivé. Redémarrez l\'app pour appliquer les changements.';

  @override
  String get pdfCurrency => 'Devise';

  @override
  String get pdfRange => 'Intervalle';

  @override
  String get pdfDailyDetails => 'Détails Quotidiens';

  @override
  String get pdfDate => 'Date';

  @override
  String get pdfRate => 'Taux (Bs)';

  @override
  String get pdfChangePercent => 'Chang. %';

  @override
  String get noInternetConnection =>
      'Pas de connexion internet. Les données peuvent être obsolètes.';

  @override
  String get internetRestored => 'Connexion rétablie.';

  @override
  String get ratesUpdatedSuccess => 'Taux mis à jour avec succès.';

  @override
  String get rateNameExists => 'Un taux avec ce nom existe déjà';

  @override
  String get rateNameLabel => 'Nom (Max 10)';

  @override
  String get rateValueLabel => 'Taux (Bolivars)';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get editRate => 'Modifier le taux';

  @override
  String get selectRate => 'Sélectionner le taux';

  @override
  String get tutorialOneTitle => 'Devises et Dates';

  @override
  String get tutorialOneDesc =>
      'Alternez entre Dollar, Euro et taux personnalisés. Consultez aussi les taux d\'Aujourd\'hui et de Demain.';

  @override
  String get tutorialTwoTitle => 'Ordre de Conversion';

  @override
  String get tutorialTwoDesc =>
      'Touchez ici pour changer l\'ordre. Tapez en Dollars pour voir les Bolivars, ou vice versa.';

  @override
  String get tutorialThreeTitle => 'Scanner Intelligent';

  @override
  String get tutorialThreeDesc =>
      'Utilisez la caméra pour détecter les prix et les convertir automatiquement en temps réel.';

  @override
  String get tutorialSkip => 'Passer';

  @override
  String get tutorialNext => 'Suivant';

  @override
  String get tutorialFinish => 'Terminer';

  @override
  String get customRatePlaceholder =>
      'Ici, vous pouvez ajouter des taux personnalisés comme Zelle, Binance ou les transferts de fonds. Nous calculerons automatiquement la différence avec la BCV.';

  @override
  String get shareApp => 'Partager l\'App';

  @override
  String get shareAppSubtitle => 'Recommandez à vos amis';

  @override
  String get rateApp => 'Noter l\'App';

  @override
  String get rateAppSubtitle => 'Soutenez-nous avec 5 étoiles';

  @override
  String get moreApps => 'Plus d\'Apps';

  @override
  String get moreAppsSubtitle => 'Découvrez d\'autres outils utiles';

  @override
  String get shareMessage =>
      'Bonjour! Je recommande la Calculatrice BCV. Elle est super rapide et précise. Téléchargez-la ici: https://play.google.com/store/apps/details?id=com.juanalvarez.calculadorabcv';

  @override
  String get paymentSettings => 'Gestion des Paiements';

  @override
  String get noAccounts => 'Aucun compte enregistré';

  @override
  String get addAccount => 'Ajouter un compte';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String deleteAccountContent(Object alias) {
    return 'Voulez-vous supprimer \"$alias\" ?';
  }

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get newAccount => 'Nouveau compte';

  @override
  String get editAccount => 'Modifier le compte';

  @override
  String get aliasLabel => 'Alias (Nom d\'identification)';

  @override
  String get bankLabel => 'Banque';

  @override
  String get ciLabel => 'ID / RIF';

  @override
  String get phoneLabel => 'Téléphone';

  @override
  String get accountNumberLabel => 'Numéro de compte (20 chiffres)';

  @override
  String get pagoMovil => 'Paiement Mobile';

  @override
  String get bankTransfer => 'Virement';

  @override
  String get requiredField => 'Champ obligatoire';

  @override
  String get selectBank => 'Sélectionnez une banque';

  @override
  String get onlyAmount => 'Texte uniquement / Montant';

  @override
  String get configureAccounts => 'Configurer les comptes';

  @override
  String get configureAccountsDesc =>
      'Ajoutez vos données pour partager rapidement';

  @override
  String get yourAccounts => 'VOS COMPTES';

  @override
  String get manageAccounts => 'Gérer les comptes';

  @override
  String get transferData => 'Données de virement';

  @override
  String get nameLabel => 'Nom';

  @override
  String get accountLabel => 'Compte';

  @override
  String get actionCopy => 'Copier';

  @override
  String get actionShare => 'Partager';

  @override
  String get amountLabel => 'Montant';

  @override
  String get paymentAccountsTitle => 'Comptes de Paiement';

  @override
  String get paymentAccountsSubtitle =>
      'Gérez vos données pour le paiement mobile et le virement';

  @override
  String get accountDigitsHelper => 'Doit comporter 20 chiffres';

  @override
  String accountDigitsCount(Object count) {
    return '$count/20 chiffres';
  }

  @override
  String get accountDigitsExact => 'Doit comporter exactement 20 chiffres';

  @override
  String aliasAlreadyExists(Object alias) {
    return 'L\'alias « $alias » existe déjà';
  }

  @override
  String pagoMovilAlreadyExists(Object name) {
    return 'Ce compte de paiement mobile existe déjà sous le nom « $name »';
  }

  @override
  String bankAccountAlreadyExists(Object name) {
    return 'Ce compte bancaire existe déjà sous le nom « $name »';
  }
}
