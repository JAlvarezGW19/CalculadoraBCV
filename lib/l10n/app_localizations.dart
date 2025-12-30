import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Calculadora BCV'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @storageNetwork.
  ///
  /// In es, this message translates to:
  /// **'Almacenamiento y Red'**
  String get storageNetwork;

  /// No description provided for @storageNetworkSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar caché y actualizaciones'**
  String get storageNetworkSubtitle;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Avisar cuando salga nueva tasa'**
  String get notificationsSubtitle;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In es, this message translates to:
  /// **'Predeterminado del sistema'**
  String get systemDefault;

  /// No description provided for @information.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get information;

  /// No description provided for @aboutApp.
  ///
  /// In es, this message translates to:
  /// **'Acerca de la App'**
  String get aboutApp;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Versión, desarrollador y licencias'**
  String get aboutAppSubtitle;

  /// No description provided for @forceUpdate.
  ///
  /// In es, this message translates to:
  /// **'Forzar Actualización'**
  String get forceUpdate;

  /// No description provided for @forceUpdateSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Actualizar tasas desde la API'**
  String get forceUpdateSubtitle;

  /// No description provided for @clearCache.
  ///
  /// In es, this message translates to:
  /// **'Borrar Caché'**
  String get clearCache;

  /// No description provided for @clearCacheSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar datos guardados localmente'**
  String get clearCacheSubtitle;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @updatingRates.
  ///
  /// In es, this message translates to:
  /// **'Actualizando tasas...'**
  String get updatingRates;

  /// No description provided for @cacheCleared.
  ///
  /// In es, this message translates to:
  /// **'Caché eliminada'**
  String get cacheCleared;

  /// No description provided for @developer.
  ///
  /// In es, this message translates to:
  /// **'Desarrollador'**
  String get developer;

  /// No description provided for @dataSource.
  ///
  /// In es, this message translates to:
  /// **'Fuente de Datos'**
  String get dataSource;

  /// No description provided for @legalNotice.
  ///
  /// In es, this message translates to:
  /// **'Aviso Legal'**
  String get legalNotice;

  /// No description provided for @legalNoticeText.
  ///
  /// In es, this message translates to:
  /// **'Esta aplicación NO representa a ninguna entidad gubernamental ni bancaria. No tenemos afiliación con el Banco Central de Venezuela. Los datos son obtenidos a través de una API que consulta la página oficial del BCV. El uso de la información es responsabilidad exclusiva del usuario.'**
  String get legalNoticeText;

  /// No description provided for @openSourceLicenses.
  ///
  /// In es, this message translates to:
  /// **'Licencias de Código Abierto'**
  String get openSourceLicenses;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @becomePro.
  ///
  /// In es, this message translates to:
  /// **'¡Conviértete en usuario PRO!'**
  String get becomePro;

  /// No description provided for @proUser.
  ///
  /// In es, this message translates to:
  /// **'¡Eres Usuario PRO!'**
  String get proUser;

  /// No description provided for @getPro.
  ///
  /// In es, this message translates to:
  /// **'Activar Funciones PRO (Beta)'**
  String get getPro;

  /// No description provided for @oneTimePayment.
  ///
  /// In es, this message translates to:
  /// **''**
  String get oneTimePayment;

  /// No description provided for @activateProBetaTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas activar las funciones PRO para esta sesión de prueba?'**
  String get activateProBetaTitle;

  /// No description provided for @activateProBetaAccept.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get activateProBetaAccept;

  /// No description provided for @restorePurchases.
  ///
  /// In es, this message translates to:
  /// **'Restaurar Compras'**
  String get restorePurchases;

  /// No description provided for @benefitAds.
  ///
  /// In es, this message translates to:
  /// **'Adiós a la publicidad'**
  String get benefitAds;

  /// No description provided for @benefitAdsDesc.
  ///
  /// In es, this message translates to:
  /// **'Disfruta de una interfaz limpia y sin interrupciones.'**
  String get benefitAdsDesc;

  /// No description provided for @benefitPdf.
  ///
  /// In es, this message translates to:
  /// **'Exportación Instantánea'**
  String get benefitPdf;

  /// No description provided for @benefitPdfDesc.
  ///
  /// In es, this message translates to:
  /// **'Genera PDFs de tu historial sin ver anuncios de video.'**
  String get benefitPdfDesc;

  /// No description provided for @benefitSpeed.
  ///
  /// In es, this message translates to:
  /// **'Máxima Velocidad'**
  String get benefitSpeed;

  /// No description provided for @benefitSpeedDesc.
  ///
  /// In es, this message translates to:
  /// **'Navegación más fluida y menor consumo de batería.'**
  String get benefitSpeedDesc;

  /// No description provided for @benefitSupport.
  ///
  /// In es, this message translates to:
  /// **'Apoya el proyecto'**
  String get benefitSupport;

  /// No description provided for @benefitSupportDesc.
  ///
  /// In es, this message translates to:
  /// **'Ayúdanos a seguir mejorando la herramienta.'**
  String get benefitSupportDesc;

  /// No description provided for @usd.
  ///
  /// In es, this message translates to:
  /// **'Dólares'**
  String get usd;

  /// No description provided for @eur.
  ///
  /// In es, this message translates to:
  /// **'Euros'**
  String get eur;

  /// No description provided for @ves.
  ///
  /// In es, this message translates to:
  /// **'Bolívares'**
  String get ves;

  /// No description provided for @history.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// No description provided for @historyRates.
  ///
  /// In es, this message translates to:
  /// **'Historial de Tasas'**
  String get historyRates;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get start;

  /// No description provided for @end.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get end;

  /// No description provided for @generatePdf.
  ///
  /// In es, this message translates to:
  /// **'Generar PDF'**
  String get generatePdf;

  /// No description provided for @watchAd.
  ///
  /// In es, this message translates to:
  /// **'Ver anuncio para desbloquear'**
  String get watchAd;

  /// No description provided for @loadingAd.
  ///
  /// In es, this message translates to:
  /// **'Cargando anuncio...'**
  String get loadingAd;

  /// No description provided for @errorAd.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar anuncio'**
  String get errorAd;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get tomorrow;

  /// No description provided for @officialRate.
  ///
  /// In es, this message translates to:
  /// **'Tasa Oficial'**
  String get officialRate;

  /// No description provided for @customRate.
  ///
  /// In es, this message translates to:
  /// **'Tasa Personalizada'**
  String get customRate;

  /// No description provided for @convert.
  ///
  /// In es, this message translates to:
  /// **'Convertir'**
  String get convert;

  /// No description provided for @rateLabel.
  ///
  /// In es, this message translates to:
  /// **'Tasa'**
  String get rateLabel;

  /// No description provided for @priceScanner.
  ///
  /// In es, this message translates to:
  /// **'Escáner de Precios'**
  String get priceScanner;

  /// No description provided for @cameraPermissionText.
  ///
  /// In es, this message translates to:
  /// **'Esta herramienta utiliza la cámara para detectar precios y convertirlos en tiempo real.\n\nPara funcionar, necesita acceso a la Cámara y a la Galería (para seleccionar imágenes).'**
  String get cameraPermissionText;

  /// No description provided for @allowAndContinue.
  ///
  /// In es, this message translates to:
  /// **'Permitir y Continuar'**
  String get allowAndContinue;

  /// No description provided for @whatToScan.
  ///
  /// In es, this message translates to:
  /// **'¿Qué vas a escanear?'**
  String get whatToScan;

  /// No description provided for @amountUsd.
  ///
  /// In es, this message translates to:
  /// **'USD'**
  String get amountUsd;

  /// No description provided for @amountEur.
  ///
  /// In es, this message translates to:
  /// **'EUR'**
  String get amountEur;

  /// No description provided for @amountVes.
  ///
  /// In es, this message translates to:
  /// **'Bs.'**
  String get amountVes;

  /// No description provided for @ratePers.
  ///
  /// In es, this message translates to:
  /// **'Pers.'**
  String get ratePers;

  /// No description provided for @noCustomRates.
  ///
  /// In es, this message translates to:
  /// **'Sin tasas personalizadas'**
  String get noCustomRates;

  /// No description provided for @noCustomRatesDesc.
  ///
  /// In es, this message translates to:
  /// **'Necesitas agregar una tasa personalizada para usar esta función.'**
  String get noCustomRatesDesc;

  /// No description provided for @createRate.
  ///
  /// In es, this message translates to:
  /// **'Crear Tasa'**
  String get createRate;

  /// No description provided for @chooseRate.
  ///
  /// In es, this message translates to:
  /// **'Elige una tasa'**
  String get chooseRate;

  /// No description provided for @newRate.
  ///
  /// In es, this message translates to:
  /// **'Nueva Tasa...'**
  String get newRate;

  /// No description provided for @convertVesTo.
  ///
  /// In es, this message translates to:
  /// **'Convertir Bolívares a...'**
  String get convertVesTo;

  /// No description provided for @homeScreen.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeScreen;

  /// No description provided for @calculatorScreen.
  ///
  /// In es, this message translates to:
  /// **'Calculadora'**
  String get calculatorScreen;

  /// No description provided for @rateDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha Valor'**
  String get rateDate;

  /// No description provided for @officialRateBcv.
  ///
  /// In es, this message translates to:
  /// **'Tasa Oficial BCV'**
  String get officialRateBcv;

  /// No description provided for @createYourFirstRate.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera tasa personalizada'**
  String get createYourFirstRate;

  /// No description provided for @addCustomRatesDescription.
  ///
  /// In es, this message translates to:
  /// **'Agrega tasas de cambios personalizadas para calcular tus conversiones.'**
  String get addCustomRatesDescription;

  /// No description provided for @errorLoadingRate.
  ///
  /// In es, this message translates to:
  /// **'Error cargando tasa'**
  String get errorLoadingRate;

  /// No description provided for @unlockPdfTitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear Exportación PDF'**
  String get unlockPdfTitle;

  /// No description provided for @unlockPdfDesc.
  ///
  /// In es, this message translates to:
  /// **'Para exportar el historial a PDF, por favor ve un anuncio corto. Esto desbloqueará la función por 24 horas.'**
  String get unlockPdfDesc;

  /// No description provided for @adNotReady.
  ///
  /// In es, this message translates to:
  /// **'El anuncio aún no está listo. Intenta de nuevo en unos segundos.'**
  String get adNotReady;

  /// No description provided for @featureUnlocked.
  ///
  /// In es, this message translates to:
  /// **'¡Función desbloqueada por 24 horas!'**
  String get featureUnlocked;

  /// No description provided for @pdfHeader.
  ///
  /// In es, this message translates to:
  /// **'Historial de Precios BCV'**
  String get pdfHeader;

  /// No description provided for @statsPeriod.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas del Periodo'**
  String get statsPeriod;

  /// No description provided for @copiedClipboard.
  ///
  /// In es, this message translates to:
  /// **'Copiado al portapapeles'**
  String get copiedClipboard;

  /// No description provided for @amountDollars.
  ///
  /// In es, this message translates to:
  /// **'Monto en Dólares'**
  String get amountDollars;

  /// No description provided for @amountEuros.
  ///
  /// In es, this message translates to:
  /// **'Monto en Euros'**
  String get amountEuros;

  /// No description provided for @amountBolivars.
  ///
  /// In es, this message translates to:
  /// **'Monto en Bolívares'**
  String get amountBolivars;

  /// No description provided for @amountCustom.
  ///
  /// In es, this message translates to:
  /// **'Monto en'**
  String get amountCustom;

  /// No description provided for @shareError.
  ///
  /// In es, this message translates to:
  /// **'Error al compartir'**
  String get shareError;

  /// No description provided for @pdfError.
  ///
  /// In es, this message translates to:
  /// **'Error al generar PDF'**
  String get pdfError;

  /// No description provided for @viewList.
  ///
  /// In es, this message translates to:
  /// **'Ver Lista'**
  String get viewList;

  /// No description provided for @viewChart.
  ///
  /// In es, this message translates to:
  /// **'Ver Gráfico'**
  String get viewChart;

  /// No description provided for @noData.
  ///
  /// In es, this message translates to:
  /// **'No hay datos disponibles'**
  String get noData;

  /// No description provided for @mean.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get mean;

  /// No description provided for @min.
  ///
  /// In es, this message translates to:
  /// **'Mínimo'**
  String get min;

  /// No description provided for @max.
  ///
  /// In es, this message translates to:
  /// **'Máximo'**
  String get max;

  /// No description provided for @change.
  ///
  /// In es, this message translates to:
  /// **'Cambio'**
  String get change;

  /// No description provided for @rangeWeek.
  ///
  /// In es, this message translates to:
  /// **'1 Sem'**
  String get rangeWeek;

  /// No description provided for @rangeMonth.
  ///
  /// In es, this message translates to:
  /// **'1 Mes'**
  String get rangeMonth;

  /// No description provided for @rangeThreeMonths.
  ///
  /// In es, this message translates to:
  /// **'3 Meses'**
  String get rangeThreeMonths;

  /// No description provided for @rangeYear.
  ///
  /// In es, this message translates to:
  /// **'1 Año'**
  String get rangeYear;

  /// No description provided for @rangeCustom.
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get rangeCustom;

  /// No description provided for @removeAdsLink.
  ///
  /// In es, this message translates to:
  /// **'Quitar anuncios'**
  String get removeAdsLink;

  /// No description provided for @thanksSupport.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por tu apoyo!'**
  String get thanksSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacyPolicy;

  /// No description provided for @deactivateProTest.
  ///
  /// In es, this message translates to:
  /// **'Desactivar PRO (Pruebas)'**
  String get deactivateProTest;

  /// No description provided for @deactivateProTitle.
  ///
  /// In es, this message translates to:
  /// **'Desactivar PRO'**
  String get deactivateProTitle;

  /// No description provided for @deactivateProMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas desactivar el modo PRO? (Solo para pruebas)'**
  String get deactivateProMessage;

  /// No description provided for @deactivateProSuccess.
  ///
  /// In es, this message translates to:
  /// **'PRO desactivado. Reinicia la app para aplicar cambios.'**
  String get deactivateProSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'tr',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
