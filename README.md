# Mamba Fast Tracker

Aplicativo mobile desenvolvido em Flutter para acompanhamento de jejum intermitente, refeições, consumo diário de calorias e histórico de evolução.

O projeto foi desenvolvido como desafio técnico para a Mamba Growth, com foco em funcionalidade, estabilidade, persistência dos dados e uma experiência simples para o usuário.

## Funcionalidades

* Cadastro e login com e-mail e senha
* Persistência da sessão do usuário
* Senhas armazenadas utilizando hash SHA-256
* Protocolos de jejum:

  * 12:12
  * 16:8
  * 18:6
  * Personalizado
* Cronômetro de jejum
* Pausar, retomar e encerrar jejum
* Persistência do estado do jejum
* Recuperação do cronômetro após fechar e reabrir o aplicativo
* Notificação ao iniciar o jejum
* Notificação automática ao finalizar o jejum
* Cadastro de refeições
* Registro automático do horário da refeição
* Edição e exclusão de refeições
* Cálculo das calorias consumidas no dia
* Resumo diário
* Cálculo do tempo total de jejum
* Verificação do cumprimento da meta de jejum
* Histórico de dias anteriores
* Estatísticas semanais
* Modo claro e modo escuro
* Persistência da preferência de tema
* Funcionamento offline

## Tecnologias

* Flutter
* Dart
* SQLite
* sqflite
* flutter_local_notifications
* timezone
* fl_chart
* crypto

## Estrutura do projeto

```text
lib/
├── database/
│   └── database_helper.dart
│
├── presentation/
│   ├── fasting/
│   ├── history/
│   ├── home/
│   ├── meals/
│   └── statistics/
│
├── services/
│   ├── auth_service.dart
│   ├── daily_summary_service.dart
│   ├── fasting_service.dart
│   ├── fasting_timer_service.dart
│   ├── history_service.dart
│   ├── meal_service.dart
│   ├── notification_service.dart
│   ├── statistics_service.dart
│   └── theme_service.dart
│
└── main.dart
```

A pasta `presentation` concentra as telas e interações com o usuário.

A pasta `services` concentra as regras de negócio da aplicação.

A pasta `database` é responsável pela persistência e acesso ao SQLite.

## Persistência de dados

O aplicativo utiliza SQLite através do pacote `sqflite`.

Os principais dados persistidos são:

* Usuários
* Sessão de login
* Protocolo de jejum
* Sessões de jejum
* Estado de pausa do jejum
* Tempo acumulado de jejum
* Refeições
* Configuração do modo claro/escuro

O banco possui controle de versão e migrations para permitir a evolução da estrutura sem perder os dados existentes.

## Decisões técnicas

### SQLite

O SQLite foi escolhido para atender ao requisito de persistência local e permitir que o aplicativo funcione sem depender de uma conexão com a internet.

### Persistência do jejum

O cronômetro não depende apenas de um `Timer` em memória.

O horário de início, término, estado e tempo acumulado são armazenados no banco de dados.

Dessa forma, ao fechar e abrir novamente o aplicativo, o estado do jejum pode ser recuperado corretamente.

### Pausar e retomar

Ao pausar o jejum, o tempo restante é armazenado no SQLite.

Ao retomar, o aplicativo calcula um novo horário de término com base no tempo restante.

O tempo dos diferentes períodos também é acumulado para permitir o cálculo do tempo total de jejum.

### Notificações

Foi utilizado `flutter_local_notifications` para implementar:

* Notificação de início do jejum
* Notificação agendada para o término
* Cancelamento da notificação quando o jejum é pausado ou encerrado

### Autenticação

A autenticação foi implementada localmente utilizando SQLite.

As senhas não são armazenadas em texto puro. Antes de serem persistidas, passam por SHA-256.

> Para uma aplicação de produção, seria recomendável utilizar um algoritmo específico para armazenamento de senhas, como Argon2 ou bcrypt, com salt adequado.

### Dark Mode

O aplicativo possui modo claro e modo escuro.

A preferência do usuário também é persistida no SQLite, permitindo que o tema escolhido seja mantido após o fechamento e reabertura do aplicativo.

## Testes realizados

Foram realizados testes manuais das principais funcionalidades:

* Cadastro de usuário
* Login
* Persistência da sessão
* Seleção de protocolo
* Início do jejum
* Pausa do jejum
* Retomada do jejum
* Encerramento do jejum
* Fechamento e reabertura durante o jejum
* Persistência do cronômetro
* Notificação de início
* Notificação de término
* Controle de notificações duplicadas
* Cadastro de refeições
* Edição de refeições
* Exclusão de refeições
* Cálculo de calorias
* Resumo diário
* Histórico
* Estatísticas
* Modo escuro
* Persistência da preferência de tema

Também foram executados:

```bash
flutter analyze
```

e:

```bash
flutter test
```

Os dois comandos foram executados sem erros.

## Como executar

### Pré-requisitos

* Flutter
* Dart
* Android Studio
* Android SDK
* Emulador Android ou dispositivo físico

### Instalação

Clone o projeto:

```bash
git clone https://github.com/Hirynnn/desafio-MambaGrowth.git
```

Entre na pasta do projeto:

```bash
cd desafio-MambaGrowth
```

Instale as dependências:

```bash
flutter pub get
```

Execute o aplicativo:

```bash
flutter run
```

Para verificar problemas no código:

```bash
flutter analyze
```

Para executar os testes:

```bash
flutter test
```

## Gerar APK

Para gerar uma versão de release:

```bash
flutter build apk --release
```

O APK será gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## APK

A versão `v1.0.0` do aplicativo está disponível na GitHub Release:

[Baixar Mamba Fast Tracker v1.0.0](https://github.com/Hirynnn/desafio-MambaGrowth/releases/tag/v1.0.0)

## Possíveis melhorias

Algumas melhorias que poderiam ser implementadas em uma próxima versão:

* Utilizar Argon2 ou bcrypt para armazenamento de senhas
* Ampliar a cobertura de testes unitários
* Criar uma camada de Repository mais completa
* Adicionar uma solução dedicada de gerenciamento de estado
* Adicionar Firebase Analytics
* Adicionar Crashlytics
* Implementar CI/CD
* Adicionar metas personalizadas de calorias
* Permitir edição manual da data e horário das refeições
* Adicionar novos tipos de gráficos
* Implementar backup e sincronização dos dados em nuvem
* Publicar o aplicativo na Play Store

## Trade-offs

O projeto foi desenvolvido priorizando as funcionalidades solicitadas no desafio e a estabilidade da aplicação.

Algumas soluções foram mantidas simples para evitar complexidade desnecessária dentro do escopo do desafio.

A persistência local foi priorizada em relação a um backend, pois o aplicativo não exige sincronização entre dispositivos para atender aos requisitos propostos.

A autenticação também foi implementada localmente para manter o aplicativo independente de serviços externos.

## Tempo de desenvolvimento

**Aproximadamente 15 horas.**

## Considerações finais

O objetivo principal do projeto foi desenvolver uma aplicação funcional e estável para acompanhamento de jejum e alimentação.

Durante o desenvolvimento, foram priorizados os pontos considerados mais críticos para a experiência do usuário, principalmente a persistência dos dados, o controle do cronômetro, as notificações, o cálculo do tempo de jejum e a recuperação correta do estado após o fechamento do aplicativo.

O projeto também recebeu recursos adicionais, como estatísticas semanais, funcionamento offline e modo escuro persistente.
