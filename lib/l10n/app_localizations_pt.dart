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
  String get getPro => 'Obter PRO';

  @override
  String get oneTimePayment => '';

  @override
  String get activateProBetaTitle =>
      'Deseja ativar os recursos PRO para esta sessão de teste?';

  @override
  String get activateProBetaAccept => 'Ativar';

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
  String get benefitSpeedDesc => 'Navegação mais fluida.';

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
  String get rateLabel => 'Taxa';

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
  String get amountUsd => 'USD';

  @override
  String get amountEur => 'EUR';

  @override
  String get amountVes => 'Bs.';

  @override
  String get ratePers => 'Pers.';

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

  @override
  String get removeAdsLink => 'Remover Anúncios';

  @override
  String get thanksSupport => 'Obrigado pelo seu apoio!';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get deactivateProTest => 'Desativar PRO (Testes)';

  @override
  String get deactivateProTitle => 'Desativar PRO';

  @override
  String get deactivateProMessage =>
      'Deseja desativar o modo PRO? (Apenas para testes)';

  @override
  String get deactivateProSuccess =>
      'PRO desativado. Reinicie o app para aplicar alterações.';

  @override
  String get pdfCurrency => 'Moeda';

  @override
  String get pdfRange => 'Intervalo';

  @override
  String get pdfDailyDetails => 'Detalhes Diários (Crono. Inverso)';

  @override
  String get pdfDate => 'Data';

  @override
  String get pdfRate => 'Taxa (Bs)';

  @override
  String get pdfChangePercent => 'Variação %';

  @override
  String get noInternetConnection =>
      'Sem conexão com a internet. Os dados podem estar desatualizados.';

  @override
  String get internetRestored => 'Conexão restaurada.';

  @override
  String get ratesUpdatedSuccess => 'Taxas atualizadas com sucesso.';

  @override
  String get rateNameExists => 'Já existe uma taxa com esse nome';

  @override
  String get rateNameLabel => 'Nome (Máx. 10)';

  @override
  String get rateValueLabel => 'Taxa (Bolívares)';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get editRate => 'Editar Taxa';

  @override
  String get selectRate => 'Selecionar taxa';

  @override
  String get tutorialOneTitle => 'Moedas e Datas';

  @override
  String get tutorialOneDesc =>
      'Alterne entre Dólar, Euro e taxas personalizadas. Consulte também as taxas de Hoje e Amanhã.';

  @override
  String get tutorialTwoTitle => 'Ordem de Conversão';

  @override
  String get tutorialTwoDesc =>
      'Toque aqui para mudar a ordem. Digite em Dólares para ver Bolívares ou vice-versa.';

  @override
  String get tutorialThreeTitle => 'Scanner Inteligente';

  @override
  String get tutorialThreeDesc =>
      'Use a câmera para detectar preços e convertê-los automaticamente em tempo real.';

  @override
  String get tutorialSkip => 'Pular';

  @override
  String get tutorialNext => 'Próximo';

  @override
  String get tutorialFinish => 'Concluir';

  @override
  String get customRatePlaceholder =>
      'Aqui você pode adicionar taxas personalizadas como Zelle, Binance ou Remessas. Calcularemos automaticamente a diferença com o BCV.';

  @override
  String get shareApp => 'Compartilhar App';

  @override
  String get shareAppSubtitle => 'Recomende aos seus amigos';

  @override
  String get rateApp => 'Avaliar App';

  @override
  String get rateAppSubtitle => 'Apoie-nos com 5 estrelas';

  @override
  String get moreApps => 'Mais Apps';

  @override
  String get moreAppsSubtitle => 'Descubra outras ferramentas úteis';

  @override
  String get shareMessage =>
      'Olá! Recomendo a Calculadora BCV. É super rápida e precisa. Baixe aqui: https://play.google.com/store/apps/details?id=com.juanalvarez.calculadorabcv';

  @override
  String get paymentSettings => 'Gerenciamento de Pagamentos';

  @override
  String get noAccounts => 'Nenhuma conta salva';

  @override
  String get addAccount => 'Adicionar Conta';

  @override
  String get deleteAccountTitle => 'Excluir Conta';

  @override
  String deleteAccountContent(Object alias) {
    return 'Deseja excluir \"$alias\"?';
  }

  @override
  String get deleteAction => 'Excluir';

  @override
  String get newAccount => 'Nova Conta';

  @override
  String get editAccount => 'Editar Conta';

  @override
  String get aliasLabel => 'Apelido (Nome de Identificação)';

  @override
  String get bankLabel => 'Banco';

  @override
  String get ciLabel => 'ID / RIF';

  @override
  String get phoneLabel => 'Telefone';

  @override
  String get accountNumberLabel => 'Número da Conta (20 dígitos)';

  @override
  String get pagoMovil => 'Pagamento Móvel';

  @override
  String get bankTransfer => 'Transferência';

  @override
  String get requiredField => 'Campo obrigatório';

  @override
  String get selectBank => 'Selecione um banco';

  @override
  String get onlyAmount => 'Apenas Texto / Valor';

  @override
  String get configureAccounts => 'Configurar Contas';

  @override
  String get configureAccountsDesc =>
      'Adicione seus dados para compartilhar rápido';

  @override
  String get yourAccounts => 'SUAS CONTAS';

  @override
  String get manageAccounts => 'Gerenciar Contas';

  @override
  String get transferData => 'Dados de Transferência';

  @override
  String get nameLabel => 'Nome';

  @override
  String get accountLabel => 'Conta';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionShare => 'Compartilhar';

  @override
  String get amountLabel => 'Valor';

  @override
  String get paymentAccountsTitle => 'Contas de Pagamento';

  @override
  String get paymentAccountsSubtitle =>
      'Gerencie seus dados para pagamento móvel e transferência';
}
