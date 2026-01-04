// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'BCV電卓';

  @override
  String get settings => '設定';

  @override
  String get general => '一般';

  @override
  String get storageNetwork => 'ストレージとネットワーク';

  @override
  String get storageNetworkSubtitle => 'キャッシュと更新の管理';

  @override
  String get notifications => '通知';

  @override
  String get notificationsSubtitle => '新しいレートが利用可能なときに通知';

  @override
  String get language => '言語';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get information => '情報';

  @override
  String get aboutApp => 'アプリについて';

  @override
  String get aboutAppSubtitle => 'バージョン、開発者、ライセンス';

  @override
  String get forceUpdate => '強制更新';

  @override
  String get forceUpdateSubtitle => 'APIからレートを更新';

  @override
  String get clearCache => 'キャッシュをクリア';

  @override
  String get clearCacheSubtitle => 'ローカルデータを削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => '閉じる';

  @override
  String get updatingRates => 'レートを更新中...';

  @override
  String get cacheCleared => 'キャッシュを消去しました';

  @override
  String get developer => '開発者';

  @override
  String get dataSource => 'データソース';

  @override
  String get legalNotice => '法的通知';

  @override
  String get legalNoticeText =>
      'このアプリケーションは政府や銀行機関を代表するものではありません。ベネズエラ中央銀行（BCV）とは提携していません。データはBCV公式サイトを照会するAPIを通じて取得されます。情報の利用はユーザー自身の責任となります。';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get version => 'バージョン';

  @override
  String get becomePro => 'PROユーザーになろう！';

  @override
  String get proUser => 'あなたはPROユーザーです！';

  @override
  String get getPro => 'PRO機能を有効化（ベータ）';

  @override
  String get oneTimePayment => '';

  @override
  String get activateProBetaTitle => 'このテストセッションでPRO機能を有効にしますか？';

  @override
  String get activateProBetaAccept => '有効にする';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get benefitAds => '広告なし';

  @override
  String get benefitAdsDesc => '中断のないクリーンなインターフェースをお楽しみください。';

  @override
  String get benefitPdf => '即時エクスポート';

  @override
  String get benefitPdfDesc => '動画広告を見ずに履歴PDFを作成できます。';

  @override
  String get benefitSpeed => '最高速度';

  @override
  String get benefitSpeedDesc => 'よりスムーズな操作とバッテリー消費の削減。';

  @override
  String get benefitSupport => 'プロジェクトを支援';

  @override
  String get benefitSupportDesc => 'ツールの改善にご協力ください。';

  @override
  String get usd => 'ドル';

  @override
  String get eur => 'ユーロ';

  @override
  String get ves => 'ボリバル';

  @override
  String get history => '履歴';

  @override
  String get historyRates => 'レート履歴';

  @override
  String get start => '開始';

  @override
  String get end => '終了';

  @override
  String get generatePdf => 'PDF生成';

  @override
  String get watchAd => '広告を見てロック解除';

  @override
  String get loadingAd => '広告読み込み中...';

  @override
  String get errorAd => '読み込みエラー';

  @override
  String get today => '今日';

  @override
  String get tomorrow => '明日';

  @override
  String get officialRate => '公式レート';

  @override
  String get customRate => 'カスタムレート';

  @override
  String get convert => '変換';

  @override
  String get rateLabel => 'レート';

  @override
  String get priceScanner => '価格スキャナー';

  @override
  String get cameraPermissionText =>
      'このツールはカメラを使用して価格を検出し、リアルタイムで変換します。\n\nカメラとギャラリーへのアクセスが必要です。';

  @override
  String get allowAndContinue => '許可して続行';

  @override
  String get whatToScan => '何をスキャンしますか？';

  @override
  String get amountUsd => 'USD';

  @override
  String get amountEur => 'EUR';

  @override
  String get amountVes => 'Bs.';

  @override
  String get ratePers => 'カスタム';

  @override
  String get noCustomRates => 'カスタムレートなし';

  @override
  String get noCustomRatesDesc => 'この機能を使用するにはカスタムレートを追加してください。';

  @override
  String get createRate => 'レート作成';

  @override
  String get chooseRate => 'レートを選択';

  @override
  String get newRate => '新しいレート...';

  @override
  String get convertVesTo => 'ボリバルを変換...';

  @override
  String get homeScreen => 'ホーム';

  @override
  String get calculatorScreen => '電卓';

  @override
  String get rateDate => '評価日';

  @override
  String get officialRateBcv => 'BCV公式レート';

  @override
  String get createYourFirstRate => '最初のカスタムレートを作成';

  @override
  String get addCustomRatesDescription => '変換計算用にカスタムレートを追加します。';

  @override
  String get errorLoadingRate => 'レートの読み込みエラー';

  @override
  String get unlockPdfTitle => 'PDFエクスポートを解除';

  @override
  String get unlockPdfDesc => 'PDFにエクスポートするには、短い広告をご覧ください。24時間機能が解放されます。';

  @override
  String get adNotReady => '広告の準備ができていません。数秒後にもう一度お試しください。';

  @override
  String get featureUnlocked => '機能が24時間解放されました！';

  @override
  String get pdfHeader => 'BCV価格履歴';

  @override
  String get statsPeriod => '期間統計';

  @override
  String get copiedClipboard => 'クリップボードにコピーしました';

  @override
  String get amountDollars => 'ドルの金額';

  @override
  String get amountEuros => 'ユーロの金額';

  @override
  String get amountBolivars => 'ボリバルの金額';

  @override
  String get amountCustom => '金額';

  @override
  String get shareError => '共有エラー';

  @override
  String get pdfError => 'PDF生成エラー';

  @override
  String get viewList => 'リスト表示';

  @override
  String get viewChart => 'チャート表示';

  @override
  String get noData => 'データなし';

  @override
  String get mean => '平均';

  @override
  String get min => '最小';

  @override
  String get max => '最大';

  @override
  String get change => '変化';

  @override
  String get rangeWeek => '1週間';

  @override
  String get rangeMonth => '1ヶ月';

  @override
  String get rangeThreeMonths => '3개월';

  @override
  String get rangeYear => '1年';

  @override
  String get rangeCustom => 'カスタム';

  @override
  String get removeAdsLink => '広告を削除';

  @override
  String get thanksSupport => 'ご支援ありがとうございます！';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get deactivateProTest => 'PROを無効化 (テスト)';

  @override
  String get deactivateProTitle => 'PROを無効化';

  @override
  String get deactivateProMessage => 'PROモードを無効化しますか？ (テストのみ)';

  @override
  String get deactivateProSuccess => 'PROが無効化されました。変更を適用するにはアプリを再起動してください。';

  @override
  String get pdfCurrency => '通貨';

  @override
  String get pdfRange => '範囲';

  @override
  String get pdfDailyDetails => '日次詳細';

  @override
  String get pdfDate => '日付';

  @override
  String get pdfRate => 'レート (Bs)';

  @override
  String get pdfChangePercent => '変動 %';

  @override
  String get noInternetConnection => 'インターネット接続がありません。データが古い可能性があります。';

  @override
  String get internetRestored => '接続が復元されました。';

  @override
  String get ratesUpdatedSuccess => 'レートが正常に更新されました。';

  @override
  String get rateNameExists => 'この名前のレートは既に存在します';

  @override
  String get rateNameLabel => '名前 (最大10文字)';

  @override
  String get rateValueLabel => 'レート (ボリバル)';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get editRate => 'レートを編集';

  @override
  String get selectRate => 'レートを選択';
}
