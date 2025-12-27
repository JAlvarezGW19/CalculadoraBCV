// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'BCV 계산기';

  @override
  String get settings => '설정';

  @override
  String get general => '일반';

  @override
  String get storageNetwork => '저장 공간 및 네트워크';

  @override
  String get storageNetworkSubtitle => '캐시 및 업데이트 관리';

  @override
  String get notifications => '알림';

  @override
  String get notificationsSubtitle => '새로운 환율이 나오면 알림';

  @override
  String get language => '언어';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get information => '정보';

  @override
  String get aboutApp => '앱 정보';

  @override
  String get aboutAppSubtitle => '버전, 개발자 및 라이선스';

  @override
  String get forceUpdate => '강제 업데이트';

  @override
  String get forceUpdateSubtitle => 'API에서 환율 업데이트';

  @override
  String get clearCache => '캐시 지우기';

  @override
  String get clearCacheSubtitle => '로컬 데이터 삭제';

  @override
  String get cancel => '취소';

  @override
  String get close => '닫기';

  @override
  String get updatingRates => '환율 업데이트 중...';

  @override
  String get cacheCleared => '캐시 삭제됨';

  @override
  String get developer => '개발자';

  @override
  String get dataSource => '데이터 출처';

  @override
  String get legalNotice => '법적 고지';

  @override
  String get legalNoticeText =>
      '이 애플리케이션은 정부나 은행 기관을 대표하지 않습니다. 베네수엘라 중앙은행(BCV)과 제휴하지 않았습니다. 데이터는 BCV 공식 웹사이트를 조회하는 API를 통해 얻습니다. 정보 사용에 대한 책임은 사용자에게 있습니다.';

  @override
  String get openSourceLicenses => '오픈 소스 라이선스';

  @override
  String get version => '버전';

  @override
  String get becomePro => 'PRO 사용자가 되세요!';

  @override
  String get proUser => '당신은 PRO 사용자입니다!';

  @override
  String get getPro => 'PRO 기능 활성화 (베타)';

  @override
  String get oneTimePayment => '';

  @override
  String get activateProBetaTitle => '이 테스트 세션에 대해 PRO 기능을 활성화하시겠습니까?';

  @override
  String get activateProBetaAccept => '활성화';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get benefitAds => '광고 없음';

  @override
  String get benefitAdsDesc => '방해 없는 깔끔한 인터페이스를 즐기세요.';

  @override
  String get benefitPdf => '즉시 내보내기';

  @override
  String get benefitPdfDesc => '동영상 광고 시청 없이 기록 PDF를 생성하세요.';

  @override
  String get benefitSpeed => '최고 속도';

  @override
  String get benefitSpeedDesc => '더 부드러운 탐색과 배터리 소모 감소.';

  @override
  String get benefitSupport => '프로젝트 후원';

  @override
  String get benefitSupportDesc => '도구를 지속적으로 개선할 수 있도록 도와주세요.';

  @override
  String get usd => '달러';

  @override
  String get eur => '유로';

  @override
  String get ves => '볼리바르';

  @override
  String get history => '기록';

  @override
  String get historyRates => '환율 기록';

  @override
  String get start => '시작';

  @override
  String get end => '종료';

  @override
  String get generatePdf => 'PDF 생성';

  @override
  String get watchAd => '광고 보고 잠금 해제';

  @override
  String get loadingAd => '광고 로딩 중...';

  @override
  String get errorAd => '로딩 오류';

  @override
  String get today => '오늘';

  @override
  String get tomorrow => '내일';

  @override
  String get officialRate => '공식 환율';

  @override
  String get customRate => '사용자 지정 환율';

  @override
  String get convert => '변환';

  @override
  String get priceScanner => '가격 스캐너';

  @override
  String get cameraPermissionText =>
      '이 도구는 카메라를 사용하여 가격을 감지하고 실시간으로 변환합니다.\n\n카메라 및 갤러리 액세스가 필요합니다.';

  @override
  String get allowAndContinue => '허용 및 계속';

  @override
  String get whatToScan => '무엇을 스캔하시겠습니까?';

  @override
  String get amountUsd => 'USD 금액';

  @override
  String get amountEur => 'EUR 금액';

  @override
  String get amountVes => 'Bs. 금액';

  @override
  String get ratePers => '사용자 지정';

  @override
  String get noCustomRates => '사용자 지정 환율 없음';

  @override
  String get noCustomRatesDesc => '이 기능을 사용하려면 사용자 지정 환율을 추가하세요.';

  @override
  String get createRate => '환율 생성';

  @override
  String get chooseRate => '환율 선택';

  @override
  String get newRate => '새 환율...';

  @override
  String get convertVesTo => '볼리바르 변환...';

  @override
  String get homeScreen => '홈';

  @override
  String get calculatorScreen => '계산기';

  @override
  String get rateDate => '기준일';

  @override
  String get officialRateBcv => 'BCV 공식 환율';

  @override
  String get createYourFirstRate => '첫 번째 사용자 지정 환율 생성';

  @override
  String get addCustomRatesDescription => '환산 계산을 위해 사용자 지정 환율을 추가하세요.';

  @override
  String get errorLoadingRate => '환율 로딩 오류';

  @override
  String get unlockPdfTitle => 'PDF 내보내기 잠금 해제';

  @override
  String get unlockPdfDesc => 'PDF로 내보내려면 짧은 광고를 시청하세요. 24시간 동안 기능이 잠금 해제됩니다.';

  @override
  String get adNotReady => '광고가 아직 준비되지 않았습니다. 몇 초 후에 다시 시도하세요.';

  @override
  String get featureUnlocked => '기능이 24시간 동안 잠금 해제되었습니다!';

  @override
  String get pdfHeader => 'BCV 가격 기록';

  @override
  String get statsPeriod => '기간 통계';

  @override
  String get copiedClipboard => '클립보드에 복사됨';

  @override
  String get amountDollars => '달러 금액';

  @override
  String get amountEuros => '유로 금액';

  @override
  String get amountBolivars => '볼리바르 금액';

  @override
  String get amountCustom => '금액';

  @override
  String get shareError => '공유 오류';

  @override
  String get pdfError => 'PDF 생성 오류';

  @override
  String get viewList => '목록 보기';

  @override
  String get viewChart => '차트 보기';

  @override
  String get noData => '데이터 없음';

  @override
  String get mean => '평균';

  @override
  String get min => '최소';

  @override
  String get max => '최대';

  @override
  String get change => '변동';

  @override
  String get rangeWeek => '1주';

  @override
  String get rangeMonth => '1개월';

  @override
  String get rangeThreeMonths => '3개월';

  @override
  String get rangeYear => '1년';

  @override
  String get rangeCustom => '맞춤';

  @override
  String get removeAdsLink => '광고 제거';

  @override
  String get thanksSupport => '지원해 주셔서 감사합니다!';
}
