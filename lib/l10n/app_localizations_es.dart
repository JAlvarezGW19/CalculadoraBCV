// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Calculadora BCV';

  @override
  String get settings => 'Ajustes';

  @override
  String get general => 'General';

  @override
  String get storageNetwork => 'Almacenamiento y Red';

  @override
  String get storageNetworkSubtitle => 'Gestionar caché y actualizaciones';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsSubtitle => 'Avisar cuando salga nueva tasa';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get information => 'Información';

  @override
  String get aboutApp => 'Acerca de la App';

  @override
  String get aboutAppSubtitle => 'Versión, desarrollador y licencias';

  @override
  String get forceUpdate => 'Forzar Actualización';

  @override
  String get forceUpdateSubtitle => 'Actualizar tasas desde la API';

  @override
  String get clearCache => 'Borrar Caché';

  @override
  String get clearCacheSubtitle => 'Eliminar datos guardados localmente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get updatingRates => 'Actualizando tasas...';

  @override
  String get cacheCleared => 'Caché eliminada';

  @override
  String get developer => 'Desarrollador';

  @override
  String get dataSource => 'Fuente de Datos';

  @override
  String get legalNotice => 'Aviso Legal';

  @override
  String get legalNoticeText =>
      'Esta aplicación NO representa a ninguna entidad gubernamental ni bancaria. No tenemos afiliación con el Banco Central de Venezuela. Los datos son obtenidos a través de una API que consulta la página oficial del BCV. El uso de la información es responsabilidad exclusiva del usuario.';

  @override
  String get openSourceLicenses => 'Licencias de Código Abierto';

  @override
  String get version => 'Versión';

  @override
  String get becomePro => '¡Conviértete en usuario PRO!';

  @override
  String get proUser => '¡Eres Usuario PRO!';

  @override
  String get getPro => 'Activar Funciones PRO (Beta)';

  @override
  String get oneTimePayment => '';

  @override
  String get activateProBetaTitle =>
      '¿Deseas activar las funciones PRO para esta sesión de prueba?';

  @override
  String get activateProBetaAccept => 'Activar';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String get benefitAds => 'Adiós a la publicidad';

  @override
  String get benefitAdsDesc =>
      'Disfruta de una interfaz limpia y sin interrupciones.';

  @override
  String get benefitPdf => 'Exportación Instantánea';

  @override
  String get benefitPdfDesc =>
      'Genera PDFs de tu historial sin ver anuncios de video.';

  @override
  String get benefitSpeed => 'Máxima Velocidad';

  @override
  String get benefitSpeedDesc =>
      'Navegación más fluida y menor consumo de batería.';

  @override
  String get benefitSupport => 'Apoya el proyecto';

  @override
  String get benefitSupportDesc =>
      'Ayúdanos a seguir mejorando la herramienta.';

  @override
  String get usd => 'Dólares';

  @override
  String get eur => 'Euros';

  @override
  String get ves => 'Bolívares';

  @override
  String get history => 'Historial';

  @override
  String get historyRates => 'Historial de Tasas';

  @override
  String get start => 'Inicio';

  @override
  String get end => 'Fin';

  @override
  String get generatePdf => 'Generar PDF';

  @override
  String get watchAd => 'Ver anuncio para desbloquear';

  @override
  String get loadingAd => 'Cargando anuncio...';

  @override
  String get errorAd => 'Error al cargar anuncio';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get officialRate => 'Tasa Oficial';

  @override
  String get customRate => 'Tasa Personalizada';

  @override
  String get convert => 'Convertir';

  @override
  String get rateLabel => 'Tasa';

  @override
  String get priceScanner => 'Escáner de Precios';

  @override
  String get cameraPermissionText =>
      'Esta herramienta utiliza la cámara para detectar precios y convertirlos en tiempo real.\n\nPara funcionar, necesita acceso a la Cámara y a la Galería (para seleccionar imágenes).';

  @override
  String get allowAndContinue => 'Permitir y Continuar';

  @override
  String get whatToScan => '¿Qué vas a escanear?';

  @override
  String get amountUsd => 'USD';

  @override
  String get amountEur => 'EUR';

  @override
  String get amountVes => 'Bs.';

  @override
  String get ratePers => 'Pers.';

  @override
  String get noCustomRates => 'Sin tasas personalizadas';

  @override
  String get noCustomRatesDesc =>
      'Necesitas agregar una tasa personalizada para usar esta función.';

  @override
  String get createRate => 'Crear Tasa';

  @override
  String get chooseRate => 'Elige una tasa';

  @override
  String get newRate => 'Nueva Tasa...';

  @override
  String get convertVesTo => 'Convertir Bolívares a...';

  @override
  String get homeScreen => 'Inicio';

  @override
  String get calculatorScreen => 'Calculadora';

  @override
  String get rateDate => 'Fecha Valor';

  @override
  String get officialRateBcv => 'Tasa Oficial BCV';

  @override
  String get createYourFirstRate => 'Crea tu primera tasa personalizada';

  @override
  String get addCustomRatesDescription =>
      'Agrega tasas de cambios personalizadas para calcular tus conversiones.';

  @override
  String get errorLoadingRate => 'Error cargando tasa';

  @override
  String get unlockPdfTitle => 'Desbloquear Exportación PDF';

  @override
  String get unlockPdfDesc =>
      'Para exportar el historial a PDF, por favor ve un anuncio corto. Esto desbloqueará la función por 24 horas.';

  @override
  String get adNotReady =>
      'El anuncio aún no está listo. Intenta de nuevo en unos segundos.';

  @override
  String get featureUnlocked => '¡Función desbloqueada por 24 horas!';

  @override
  String get pdfHeader => 'Historial de Precios BCV';

  @override
  String get statsPeriod => 'Estadísticas del Periodo';

  @override
  String get copiedClipboard => 'Copiado al portapapeles';

  @override
  String get amountDollars => 'Monto en Dólares';

  @override
  String get amountEuros => 'Monto en Euros';

  @override
  String get amountBolivars => 'Monto en Bolívares';

  @override
  String get amountCustom => 'Monto en';

  @override
  String get shareError => 'Error al compartir';

  @override
  String get pdfError => 'Error al generar PDF';

  @override
  String get viewList => 'Ver Lista';

  @override
  String get viewChart => 'Ver Gráfico';

  @override
  String get noData => 'No hay datos disponibles';

  @override
  String get mean => 'Promedio';

  @override
  String get min => 'Mínimo';

  @override
  String get max => 'Máximo';

  @override
  String get change => 'Cambio';

  @override
  String get rangeWeek => '1 Sem';

  @override
  String get rangeMonth => '1 Mes';

  @override
  String get rangeThreeMonths => '3 Meses';

  @override
  String get rangeYear => '1 Año';

  @override
  String get rangeCustom => 'Personalizado';

  @override
  String get removeAdsLink => 'Quitar anuncios';

  @override
  String get thanksSupport => '¡Gracias por tu apoyo!';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get deactivateProTest => 'Desactivar PRO (Pruebas)';

  @override
  String get deactivateProTitle => 'Desactivar PRO';

  @override
  String get deactivateProMessage =>
      '¿Deseas desactivar el modo PRO? (Solo para pruebas)';

  @override
  String get deactivateProSuccess =>
      'PRO desactivado. Reinicia la app para aplicar cambios.';
}
