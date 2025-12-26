// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Calculadora BCV';

  @override
  String get settings => 'Configurações';

  @override
  String get general => 'Geral';

  @override
  String get storageNetwork => 'Armazenamento e Rede';

  @override
  String get storageNetworkSubtitle => 'Gerenciar cache e atualizações';

  @override
  String get notifications => 'Notificações';

  @override
  String get notificationsSubtitle => 'Avisar quando houver nova taxa';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Padrão do sistema';

  @override
  String get information => 'Informações';

  @override
  String get aboutApp => 'Sobre o App';

  @override
  String get aboutAppSubtitle => 'Versão, desenvolvedor e licenças';

  @override
  String get forceUpdate => 'Forçar Atualização';

  @override
  String get forceUpdateSubtitle => 'Atualizar taxas da API';

  @override
  String get clearCache => 'Limpar Cache';

  @override
  String get clearCacheSubtitle => 'Excluir dados armazenados localmente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Fechar';

  @override
  String get updatingRates => 'Atualizando taxas...';

  @override
  String get cacheCleared => 'Cache limpo';

  @override
  String get developer => 'Desenvolvedor';

  @override
  String get dataSource => 'Fonte de Dados';

  @override
  String get legalNotice => 'Aviso Legal';

  @override
  String get legalNoticeText =>
      'Este aplicativo NÃO representa nenhuma entidade governamental ou bancária. Não temos afiliação com o Banco Central da Venezuela. Os dados são obtidos por meio de uma API que consulta o site oficial do BCV. O uso das informações é de responsabilidade exclusiva do usuário.';

  @override
  String get openSourceLicenses => 'Licenças de Código Aberto';

  @override
  String get version => 'Versão';

  @override
  String get becomePro => 'Torne-se PRO!';

  @override
  String get proUser => 'Você é um Usuário PRO!';

  @override
  String get getPro => 'Obter PRO por';

  @override
  String get oneTimePayment => '(Pagamento único vitalício)';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String get benefitAds => 'Sem anúncios';

  @override
  String get benefitAdsDesc =>
      'Desfrute de uma interface limpa e sem interrupções.';

  @override
  String get benefitPdf => 'Exportação Instantânea';

  @override
  String get benefitPdfDesc =>
      'Gere PDFs do seu histórico sem assistir anúncios.';

  @override
  String get benefitSpeed => 'Velocidade Máxima';

  @override
  String get benefitSpeedDesc =>
      'Navegação mais fluida e menor consumo de bateria.';

  @override
  String get benefitSupport => 'Apoie o projeto';

  @override
  String get benefitSupportDesc =>
      'Ajude-nos a continuar melhorando a ferramenta.';

  @override
  String get usd => 'Dólares';

  @override
  String get eur => 'Euros';

  @override
  String get ves => 'Bolívares';

  @override
  String get history => 'Histórico';

  @override
  String get historyRates => 'Histórico de Taxas';

  @override
  String get start => 'Início';

  @override
  String get end => 'Fim';

  @override
  String get generatePdf => 'Gerar PDF';

  @override
  String get watchAd => 'Assista ao anúncio para desbloquear';

  @override
  String get loadingAd => 'Carregando anúncio...';

  @override
  String get errorAd => 'Erro ao carregar anúncio';

  @override
  String get today => 'Hoje';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get officialRate => 'Taxa Oficial';

  @override
  String get customRate => 'Taxa Personalizada';

  @override
  String get convert => 'Converter';

  @override
  String get priceScanner => 'Scanner de Preços';

  @override
  String get cameraPermissionText =>
      'Esta ferramenta usa a câmera para detectar preços e convertê-los em tempo real.\n\nRequer acesso à Câmera e Galeria.';

  @override
  String get allowAndContinue => 'Permitir e Continuar';

  @override
  String get whatToScan => 'O que você vai escanear?';

  @override
  String get amountUsd => 'Valor USD';

  @override
  String get amountEur => 'Valor EUR';

  @override
  String get amountVes => 'Valor Bs.';

  @override
  String get ratePers => 'Taxa Pers.';

  @override
  String get noCustomRates => 'Sem taxas personalizadas';

  @override
  String get noCustomRatesDesc =>
      'Adicione uma taxa personalizada para usar este recurso.';

  @override
  String get createRate => 'Criar Taxa';

  @override
  String get chooseRate => 'Escolha uma taxa';

  @override
  String get newRate => 'Nova Taxa...';

  @override
  String get convertVesTo => 'Converter Bolívares para...';

  @override
  String get homeScreen => 'Início';

  @override
  String get calculatorScreen => 'Calculadora';

  @override
  String get rateDate => 'Data Valor';

  @override
  String get officialRateBcv => 'Taxa Oficial BCV';

  @override
  String get createYourFirstRate => 'Crie sua primeira taxa';

  @override
  String get addCustomRatesDescription =>
      'Adicione taxas personalizadas para calcular conversões.';

  @override
  String get errorLoadingRate => 'Erro ao carregar taxa';

  @override
  String get unlockPdfTitle => 'Desbloquear Exportação PDF';

  @override
  String get unlockPdfDesc =>
      'Para exportar para PDF, assista a um anúncio. Isso desbloqueará o recurso por 24h.';

  @override
  String get adNotReady =>
      'O anúncio ainda não está pronto. Tente novamente em alguns segundos.';

  @override
  String get featureUnlocked => 'Recurso desbloqueado por 24 horas!';

  @override
  String get pdfHeader => 'Histórico de Preços BCV';

  @override
  String get statsPeriod => 'Estatísticas do Período';

  @override
  String get copiedClipboard => 'Copiado para a área de transferência';

  @override
  String get amountDollars => 'Valor em Dólares';

  @override
  String get amountEuros => 'Valor em Euros';

  @override
  String get amountBolivars => 'Valor em Bolívares';

  @override
  String get amountCustom => 'Valor em';

  @override
  String get shareError => 'Erro ao compartilhar';

  @override
  String get pdfError => 'Erro ao gerar PDF';

  @override
  String get viewList => 'Ver Lista';

  @override
  String get viewChart => 'Ver Gráfico';

  @override
  String get noData => 'Sem dados disponíveis';

  @override
  String get mean => 'Média';

  @override
  String get min => 'Mínimo';

  @override
  String get max => 'Máximo';

  @override
  String get change => 'Variação';

  @override
  String get rangeWeek => '1 Sem';

  @override
  String get rangeMonth => '1 Mês';

  @override
  String get rangeThreeMonths => '3 Meses';

  @override
  String get rangeYear => '1 Ano';

  @override
  String get rangeCustom => 'Adoc';
}
