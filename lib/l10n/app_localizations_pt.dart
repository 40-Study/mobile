// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => '40Study';

  @override
  String get itemsTitle => 'Artigos de Exemplo';

  @override
  String get emailsTitle => 'E-mails';

  @override
  String get launchesTitle => 'Lançamentos';

  @override
  String itemTitle(Object id) {
    return 'Artigo de Exemplo $id';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get appearanceTitle => 'Aparência';

  @override
  String get dynamicColorSettingsItemTitle => 'Usar cores dinâmicas';

  @override
  String get dynamicColorSettingsItemDescription =>
      'Adaptar as cores do app ao papel de parede';

  @override
  String get darkThemeSettingsItemTitle => 'Modo de tema';

  @override
  String get darkThemeOnSettingsItemTitle => 'Escuro';

  @override
  String get darkThemeOffSettingsItemTitle => 'Claro';

  @override
  String get darkThemeFollowSystemSettingsItemTitle => 'Padrão do sistema';

  @override
  String get tryAgainButton => 'Tentar novamente';

  @override
  String get appearanceSettingsItem => 'Appearance';

  @override
  String get appearanceSettingsItemDescription =>
      'Dark theme dynamic color, languages';

  @override
  String get aboutSettingsItem => 'About';

  @override
  String get aboutSettingsItemDescription => 'Version, links, feedback';

  @override
  String missionTitle(Object mission) {
    return 'Missão: $mission';
  }

  @override
  String launchedAt(Object launchedAt) {
    return 'Lançado em: $launchedAt';
  }

  @override
  String rocket(Object rocketName, Object rocketType) {
    return 'Foguete: $rocketName ($rocketType)';
  }

  @override
  String daysSinceTodayTitle(Object days) {
    return 'Há $days dias';
  }

  @override
  String daysFromTodayTitle(Object days) {
    return 'Em $days dias';
  }

  @override
  String get themeTitle => 'Tema';

  @override
  String get systemThemeTitle => 'Tema do Sistema';

  @override
  String get lightThemeTitle => 'Tema Claro';

  @override
  String get darkThemeTitle => 'Tema Escuro';

  @override
  String get lightGoldThemeTitle => 'Tema Dourado Claro';

  @override
  String get darkGoldThemeTitle => 'Tema Dourado Escuro';

  @override
  String get lightMintThemeTitle => 'Tema Menta Claro';

  @override
  String get darkMintThemeTitle => 'Tema Menta Escuro';

  @override
  String get experimentalThemeTitle => 'Experimental Theme';

  @override
  String get itemDetailsTitle => 'Detalhes do Artigo';

  @override
  String get error => 'Erro';

  @override
  String get emptyList => 'Lista Vazia';

  @override
  String get tabHome => 'Início';

  @override
  String get tabSettings => 'Configurações';

  @override
  String get newsScreen => 'Notícias';

  @override
  String get disabledButtonTitle => 'Desativado';

  @override
  String get disabledRoundedButtonTitle => 'Desativado com Bordas Arredondadas';

  @override
  String get disabledWithIconButtonTitle => 'Desativado com Ícone';

  @override
  String get enabledButtonTitle => 'Ativado';

  @override
  String get borderRadiusButtonTitle => 'Raio da Borda';

  @override
  String get borderSideButtonTitle => 'Lado da Borda';

  @override
  String get iconButtonTitle => 'Com Ícone';

  @override
  String get iconAndPaddingButtonTitle => 'Com Ícone e Espaçamento';

  @override
  String get transparentButtonTitle => 'Transparente';

  @override
  String get missionTimeline => 'Cronograma da Missão';

  @override
  String get staticFireTest => 'Teste de Fogo Estático';

  @override
  String get launch => 'Lançamento';

  @override
  String get missionSuccess => 'Sucesso da Missão';

  @override
  String get objectivesCompleted => 'Objetivos Concluídos';

  @override
  String get missionSuccessful => 'Missão bem-sucedida';

  @override
  String get missionFailed => 'Missão falhou';

  @override
  String get allObjectivesCompleted => 'Todos os objetivos concluídos';

  @override
  String get objectivesNotMet => 'Objetivos da missão não alcançados';

  @override
  String get rocketTitle => 'Foguete';

  @override
  String get payload => 'Carga útil';

  @override
  String get orbit => 'Órbita';

  @override
  String get rocketDetails => 'Detalhes do Foguete';

  @override
  String get rocketName => 'Nome do Foguete';

  @override
  String get rocketType => 'Tipo';

  @override
  String get rocketBlock => 'Bloco';

  @override
  String get firstStage => '🚀 Primeiro Estágio';

  @override
  String get coreSerial => 'Número de Série do Núcleo';

  @override
  String get flight => 'Voo';

  @override
  String get landing => 'Pouso';

  @override
  String get landingSuccess => 'Pouso bem-sucedido';

  @override
  String get gridFins => 'Aletas de grade';

  @override
  String get landingLegs => 'Pernas de pouso';

  @override
  String get reused => 'Reutilizado';

  @override
  String get notAvailable => 'N/D';

  @override
  String get recoveryShips => 'Navios de Recuperação';

  @override
  String get payloadTitle => 'Carga útil';

  @override
  String get id => 'ID';

  @override
  String get type => 'Tipo';

  @override
  String get mass => 'Massa';

  @override
  String get manufacturer => 'Fabricante';

  @override
  String get nationality => 'Nacionalidade';

  @override
  String get customers => 'Clientes';

  @override
  String get missionOverview => 'Visão geral da missão';

  @override
  String get noDetails => 'Nenhum detalhe disponível';

  @override
  String get linksResources => 'Links e Recursos';

  @override
  String get watchVideo => 'Assistir Vídeo';

  @override
  String get wikipedia => 'Wikipédia';

  @override
  String get article => 'Artigo';

  @override
  String get reddit => 'Reddit';

  @override
  String get pressKit => 'Kit de Imprensa';

  @override
  String get launchSite => 'Local de Lançamento';

  @override
  String get siteIdLabel => 'ID do Local:';

  @override
  String flightNumber(Object number) {
    return 'Voo #$number';
  }

  @override
  String get rocketsTab => 'Foguetes';

  @override
  String get activeStatus => 'Ativa';

  @override
  String get retiredStatus => 'Aposentada';

  @override
  String successRate(Object percentage) {
    return '$percentage% de sucesso';
  }

  @override
  String get rocketsTitle => 'Foguetes';

  @override
  String get overview => 'Visão Geral';

  @override
  String get specifications => 'Especificações';

  @override
  String get payloadCapacity => 'Capacidade de Carga';

  @override
  String get engineDetails => 'Detalhes do Motor';

  @override
  String get heightLabel => 'Altura';

  @override
  String get diameterLabel => 'Diâmetro';

  @override
  String get massLabel => 'Massa';

  @override
  String get stagesLabel => 'Estágios';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get versionLabel => 'Versão';

  @override
  String get numberLabel => 'Número';

  @override
  String get propellant1Label => 'Propelente 1';

  @override
  String get propellant2Label => 'Propelente 2';

  @override
  String get thrustSeaLevelLabel => 'Empuxo (nível do mar)';

  @override
  String get tons => 'toneladas';

  @override
  String get learnMore => 'Saiba mais';

  @override
  String get launchInformation => 'Informações do lançamento';

  @override
  String get launchMass => 'Massa do lançamento';

  @override
  String get launchVehicle => 'Veículo de lançamento';

  @override
  String get orbitalParameters => 'Parâmetros orbitais';

  @override
  String get millionKm => 'milhões km';

  @override
  String get missionDetails => 'Detalhes da missão';

  @override
  String get trackLive => 'Acompanhar ao vivo';

  @override
  String get marsDistance => 'Distância a Marte';

  @override
  String get earthDistance => 'Distância à Terra';

  @override
  String get currentSpeed => 'Velocidade Atual';

  @override
  String get orbitalPeriod => 'Período Orbital';

  @override
  String get unitDays => 'dias';

  @override
  String get unitKph => 'km/h';

  @override
  String launched(Object date) {
    return 'Lançado: $date';
  }

  @override
  String get roadsterTitle => 'Roadster';

  @override
  String get roadsterDescription => 'Tesla Roadster de Elon Musk';

  @override
  String get apoapsis => 'Apoápse';

  @override
  String get periapsis => 'Periápse';

  @override
  String get semiMajorAxis => 'Eixo semi-maior';

  @override
  String get eccentricity => 'Excentricidade';

  @override
  String get inclination => 'Inclinação';

  @override
  String get longitude => 'Longitude';

  @override
  String get core_status_active => 'ativo';

  @override
  String get core_status_lost => 'perdido';

  @override
  String get core_status_inactive => 'inativo';

  @override
  String get core_status_unknown => 'desconhecido';

  @override
  String get errorLoadingCores => 'Erro ao carregar núcleos';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get firstLaunch => 'Primeiro lançamento';

  @override
  String missions(Object count) {
    return '$count missões';
  }

  @override
  String reuses(Object count) {
    return '$count reutilizações';
  }

  @override
  String get unknown => 'Desconhecido';

  @override
  String get na => 'N/D';

  @override
  String get core_filter_status_all => 'Todos';

  @override
  String get core_filter_status_active => 'Ativo';

  @override
  String get core_filter_status_lost => 'Perdido';

  @override
  String get core_filter_status_inactive => 'Inativo';

  @override
  String get core_filter_status_unknown => 'Desconhecido';

  @override
  String get core_filter_search_hint => 'Pesquisar núcleos ou missões...';

  @override
  String noCoresFound(Object query) {
    return 'Nenhum núcleo encontrado para \"$query\"';
  }

  @override
  String blockLabel(Object blockNumber) {
    return 'Bloco $blockNumber';
  }

  @override
  String get spaceXCoresTitle => 'Núcleos Falcon da SpaceX';

  @override
  String get coresLabel => 'Núcleos';
}
