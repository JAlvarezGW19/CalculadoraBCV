// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Калькулятор BCV';

  @override
  String get settings => 'Настройки';

  @override
  String get general => 'Общие';

  @override
  String get storageNetwork => 'Память и сеть';

  @override
  String get storageNetworkSubtitle => 'Управление кэшем и обновлениями';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsSubtitle => 'Уведомлять о новом курсе';

  @override
  String get language => 'Язык';

  @override
  String get systemDefault => 'Системный по умолчанию';

  @override
  String get information => 'Информация';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get aboutAppSubtitle => 'Версия, разработчик и лицензии';

  @override
  String get forceUpdate => 'Обновить принудительно';

  @override
  String get forceUpdateSubtitle => 'Обновить курсы через API';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get clearCacheSubtitle => 'Удалить локальные данные';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get updatingRates => 'Обновление курсов...';

  @override
  String get cacheCleared => 'Кэш очищен';

  @override
  String get developer => 'Разработчик';

  @override
  String get dataSource => 'Источник данных';

  @override
  String get legalNotice => 'Правовое уведомление';

  @override
  String get legalNoticeText =>
      'Это приложение НЕ представляет собой государственную или банковскую структуру. Мы не связаны с Центральным банком Венесуэлы. Данные получены через API с официального сайта BCV. Ответственность за использование информации лежит на пользователе.';

  @override
  String get openSourceLicenses => 'Лицензии ПО';

  @override
  String get version => 'Версия';

  @override
  String get becomePro => 'Стать PRO!';

  @override
  String get proUser => 'Вы PRO пользователь!';

  @override
  String get getPro => 'Купить PRO за';

  @override
  String get oneTimePayment => '(Единовременный платеж)';

  @override
  String get restorePurchases => 'Восстановить';

  @override
  String get benefitAds => 'Без рекламы';

  @override
  String get benefitAdsDesc => 'Чистый интерфейс без отвлекающих факторов.';

  @override
  String get benefitPdf => 'Мгновенный экспорт';

  @override
  String get benefitPdfDesc => 'PDF без просмотра видеорекламы.';

  @override
  String get benefitSpeed => 'Макс. скорость';

  @override
  String get benefitSpeedDesc => 'Плавная навигация и экономия заряда.';

  @override
  String get benefitSupport => 'Поддержать проект';

  @override
  String get benefitSupportDesc => 'Помогите нам улучшать инструмент.';

  @override
  String get usd => 'Доллары';

  @override
  String get eur => 'Евро';

  @override
  String get ves => 'Боливары';

  @override
  String get history => 'История';

  @override
  String get historyRates => 'История курсов';

  @override
  String get start => 'Начало';

  @override
  String get end => 'Конец';

  @override
  String get generatePdf => 'Создать PDF';

  @override
  String get watchAd => 'Смотреть рекламу для разблокировки';

  @override
  String get loadingAd => 'Загрузка...';

  @override
  String get errorAd => 'Ошибка';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get officialRate => 'Офиц. курс';

  @override
  String get customRate => 'Свой курс';

  @override
  String get convert => 'Конвертировать';

  @override
  String get priceScanner => 'Сканер цен';

  @override
  String get cameraPermissionText =>
      'Этот инструмент использует камеру для определения цен и конвертации.\n\nТребуется доступ к камере и галерее.';

  @override
  String get allowAndContinue => 'Разрешить и продолжить';

  @override
  String get whatToScan => 'Что сканируем?';

  @override
  String get amountUsd => 'Сумма USD';

  @override
  String get amountEur => 'Сумма EUR';

  @override
  String get amountVes => 'Сумма Bs.';

  @override
  String get ratePers => 'Свой курс';

  @override
  String get noCustomRates => 'Нет своих курсов';

  @override
  String get noCustomRatesDesc =>
      'Добавьте свой курс для использования функции.';

  @override
  String get createRate => 'Создать курс';

  @override
  String get chooseRate => 'Выберите курс';

  @override
  String get newRate => 'Новый курс...';

  @override
  String get convertVesTo => 'Конвертировать Боливары в...';

  @override
  String get homeScreen => 'Главная';

  @override
  String get calculatorScreen => 'Калькулятор';

  @override
  String get rateDate => 'Дата курса';

  @override
  String get officialRateBcv => 'Офиц. курс BCV';

  @override
  String get createYourFirstRate => 'Создайте свой первый курс';

  @override
  String get addCustomRatesDescription => 'Добавьте свои курсы для расчетов.';

  @override
  String get errorLoadingRate => 'Ошибка загрузки курса';

  @override
  String get unlockPdfTitle => 'Разблокировать PDF';

  @override
  String get unlockPdfDesc =>
      'Чтобы экспортировать в PDF, посмотрите рекламу. Это разблокирует функцию на 24 часа.';

  @override
  String get adNotReady =>
      'Реклама еще не готова. Попробуйте через несколько секунд.';

  @override
  String get featureUnlocked => 'Функция разблокирована на 24 часа!';

  @override
  String get pdfHeader => 'История цен BCV';

  @override
  String get statsPeriod => 'Статистика за период';

  @override
  String get copiedClipboard => 'Скопировано в буфер обмена';

  @override
  String get amountDollars => 'Сумма в долларах';

  @override
  String get amountEuros => 'Сумма в евро';

  @override
  String get amountBolivars => 'Сумма в боливарах';

  @override
  String get amountCustom => 'Сумма в';

  @override
  String get shareError => 'Ошибка при отправке';

  @override
  String get pdfError => 'Ошибка создания PDF';

  @override
  String get viewList => 'Списком';

  @override
  String get viewChart => 'График';

  @override
  String get noData => 'Нет данных';

  @override
  String get mean => 'Среднее';

  @override
  String get min => 'Мин.';

  @override
  String get max => 'Макс.';

  @override
  String get change => 'Изм.';

  @override
  String get rangeWeek => '1 Нед';

  @override
  String get rangeMonth => '1 Мес';

  @override
  String get rangeThreeMonths => '3 Мес';

  @override
  String get rangeYear => '1 Год';

  @override
  String get rangeCustom => 'Свой';

  @override
  String get removeAdsLink => 'Убрать рекламу';

  @override
  String get thanksSupport => 'Спасибо за поддержку!';
}
