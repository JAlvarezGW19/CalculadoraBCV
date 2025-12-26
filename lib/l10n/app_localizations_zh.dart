// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'BCV 计算器';

  @override
  String get settings => '设置';

  @override
  String get general => '常规';

  @override
  String get storageNetwork => '存储与网络';

  @override
  String get storageNetworkSubtitle => '管理缓存和更新';

  @override
  String get notifications => '通知';

  @override
  String get notificationsSubtitle => '新汇率可用时通知';

  @override
  String get language => '语言';

  @override
  String get systemDefault => '系统默认';

  @override
  String get information => '信息';

  @override
  String get aboutApp => '关于应用';

  @override
  String get aboutAppSubtitle => '版本、开发者和许可';

  @override
  String get forceUpdate => '强制更新';

  @override
  String get forceUpdateSubtitle => '从 API 更新汇率';

  @override
  String get clearCache => '清除缓存';

  @override
  String get clearCacheSubtitle => '删除本地存储的数据';

  @override
  String get cancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get updatingRates => '正在更新汇率...';

  @override
  String get cacheCleared => '缓存已清除';

  @override
  String get developer => '开发者';

  @override
  String get dataSource => '数据来源';

  @override
  String get legalNotice => '法律声明';

  @override
  String get legalNoticeText =>
      '此应用程序不代表任何政府或银行实体。我们与委内瑞拉中央银行没有关联。数据通过查询 BCV 官方网站的 API 获取。信息的使用由用户自行承担责任。';

  @override
  String get openSourceLicenses => '开源许可证';

  @override
  String get version => '版本';

  @override
  String get becomePro => '成为 PRO 用户！';

  @override
  String get proUser => '您是 PRO 用户！';

  @override
  String get getPro => '获取 PRO 仅需';

  @override
  String get oneTimePayment => '（终身一次性付款）';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get benefitAds => '无广告';

  @override
  String get benefitAdsDesc => '享受干净无干扰的界面。';

  @override
  String get benefitPdf => '即时导出';

  @override
  String get benefitPdfDesc => '无需观看视频广告即可生成历史 PDF。';

  @override
  String get benefitSpeed => '极速体验';

  @override
  String get benefitSpeedDesc => '更流畅的导航和更低的电池消耗。';

  @override
  String get benefitSupport => '支持项目';

  @override
  String get benefitSupportDesc => '帮助我们持续改进工具。';

  @override
  String get usd => '美元';

  @override
  String get eur => '欧元';

  @override
  String get ves => '玻利瓦尔';

  @override
  String get history => '历史记录';

  @override
  String get historyRates => '汇率历史';

  @override
  String get start => '开始';

  @override
  String get end => '结束';

  @override
  String get generatePdf => '生成 PDF';

  @override
  String get watchAd => '观看广告以解锁';

  @override
  String get loadingAd => '加载广告中...';

  @override
  String get errorAd => '加载错误';

  @override
  String get today => '今天';

  @override
  String get tomorrow => '明天';

  @override
  String get officialRate => '官方汇率';

  @override
  String get customRate => '自定义汇率';

  @override
  String get convert => '转换';

  @override
  String get priceScanner => '价格扫描仪';

  @override
  String get cameraPermissionText => '此工具使用相机检测价格并实时转换。\n\n需要相机和图库访问权限。';

  @override
  String get allowAndContinue => '允许并继续';

  @override
  String get whatToScan => '你要扫描什么？';

  @override
  String get amountUsd => 'USD 金额';

  @override
  String get amountEur => 'EUR 金额';

  @override
  String get amountVes => 'Bs. 金额';

  @override
  String get ratePers => '自定义';

  @override
  String get noCustomRates => '无自定义汇率';

  @override
  String get noCustomRatesDesc => '需要添加自定义汇率才能使用此功能。';

  @override
  String get createRate => '创建汇率';

  @override
  String get chooseRate => '选择汇率';

  @override
  String get newRate => '新汇率...';

  @override
  String get convertVesTo => '玻利瓦尔兑换为...';

  @override
  String get homeScreen => '首页';

  @override
  String get calculatorScreen => '计算器';

  @override
  String get rateDate => '起息日';

  @override
  String get officialRateBcv => 'BCV 官方汇率';

  @override
  String get createYourFirstRate => '创建您的第一个汇率';

  @override
  String get addCustomRatesDescription => '添加自定义汇率以计算转换。';

  @override
  String get errorLoadingRate => '加载汇率错误';

  @override
  String get unlockPdfTitle => '解锁 PDF 导出';

  @override
  String get unlockPdfDesc => '要导出 PDF，请观看简短广告。这将解锁该功能 24 小时。';

  @override
  String get adNotReady => '广告尚未准备好。请几秒钟后再试。';

  @override
  String get featureUnlocked => '功能已解锁 24 小时！';

  @override
  String get pdfHeader => 'BCV 价格历史';

  @override
  String get statsPeriod => '期间统计';

  @override
  String get copiedClipboard => '已复制到剪贴板';

  @override
  String get amountDollars => '美元金额';

  @override
  String get amountEuros => '欧元金额';

  @override
  String get amountBolivars => '玻利瓦尔金额';

  @override
  String get amountCustom => '金额';

  @override
  String get shareError => '分享错误';

  @override
  String get pdfError => '生成 PDF 错误';

  @override
  String get viewList => '查看列表';

  @override
  String get viewChart => '查看图表';

  @override
  String get noData => '无可用数据';

  @override
  String get mean => '平均';

  @override
  String get min => '最小';

  @override
  String get max => '最大';

  @override
  String get change => '变化';

  @override
  String get rangeWeek => '1周';

  @override
  String get rangeMonth => '1月';

  @override
  String get rangeThreeMonths => '3月';

  @override
  String get rangeYear => '1年';

  @override
  String get rangeCustom => '自定义';
}
