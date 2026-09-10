import 'dart:async';

import 'package:flutter/material.dart';

import 'presentation/fasting/fasting_protocol_page.dart';
import 'presentation/home/daily_summary_page.dart';
import 'presentation/history/history_page.dart';
import 'presentation/meals/meals_page.dart';
import 'presentation/statistics/statistics_page.dart';
import 'services/auth_service.dart';
import 'services/fasting_service.dart';
import 'services/fasting_timer_service.dart';
import 'services/meal_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();

  await notificationService.initialize();
  await notificationService.requestPermission();

  runApp(
    const MambaFastTrackerApp(),
  );
}

class MambaFastTrackerApp extends StatefulWidget {
  const MambaFastTrackerApp({super.key});

  @override
  State<MambaFastTrackerApp> createState() =>
      _MambaFastTrackerAppState();
}

class _MambaFastTrackerAppState
    extends State<MambaFastTrackerApp> {
  final ThemeService themeService = ThemeService();

  bool isDarkMode = false;
  bool isLoadingTheme = true;

  @override
  void initState() {
    super.initState();

    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedDarkMode =
    await themeService.isDarkMode();

    if (!mounted) {
      return;
    }

    setState(() {
      isDarkMode = savedDarkMode;
      isLoadingTheme = false;
    });
  }

  Future<void> _toggleTheme() async {
    final newValue = !isDarkMode;

    await themeService.setDarkMode(newValue);

    if (!mounted) {
      return;
    }

    setState(() {
      isDarkMode = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingTheme) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Mamba Fast Tracker',
      debugShowCheckedModeBanner: false,
      themeMode:
      isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: InitialPage(
        isDarkMode: isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class InitialPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const InitialPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();

    _checkSession();
  }

  Future<void> _checkSession() async {
    final loggedIn = await authService.isLoggedIn();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) {
          return loggedIn
              ? HomePage(
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          )
              : LoginPage(
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const LoginPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool isLoading = false;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha e-mail e senha.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    final success = await authService.login(
      email,
      password,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'E-mail ou senha inválidos.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode
                ? 'Modo claro'
                : 'Modo escuro',
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.timer,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mamba Fast Tracker',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: emailController,
                    keyboardType:
                    TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                      isLoading ? null : _login,
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Entrar'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterPage(
                                isDarkMode:
                                widget.isDarkMode,
                                onToggleTheme:
                                widget.onToggleTheme,
                              ),
                        ),
                      );
                    },
                    child: const Text(
                      'Criar uma conta',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const RegisterPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {
  final AuthService authService = AuthService();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isLoading = false;

  Future<void> _register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword =
        confirmPasswordController.text;

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos.',
          ),
        ),
      );

      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'As senhas não são iguais.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    final success = await authService.register(
      email,
      password,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Conta criada com sucesso.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível criar a conta. '
                'O e-mail pode já estar cadastrado.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode
                ? 'Modo claro'
                : 'Modo escuro',
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  keyboardType:
                  TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller:
                  confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar senha',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                    isLoading ? null : _register,
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Criar conta',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();

  final FastingService fastingService =
  FastingService();

  final FastingTimerService fastingTimerService =
  FastingTimerService();

  final NotificationService notificationService =
  NotificationService();

  final MealService mealService = MealService();

  Map<String, dynamic>? protocol;
  Map<String, dynamic>? activeFasting;
  Map<String, dynamic>? pausedFasting;

  Timer? timer;

  Duration remaining = Duration.zero;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    final loadedProtocol =
    await fastingService.getProtocol();

    final loadedFasting =
    await fastingTimerService.getActiveFasting();

    final loadedPaused =
    await fastingTimerService.getPausedFasting();

    if (!mounted) {
      return;
    }

    setState(() {
      protocol = loadedProtocol;
      activeFasting = loadedFasting;
      pausedFasting = loadedPaused;
    });

    timer?.cancel();

    if (loadedFasting != null) {
      _updateTimer();

      timer = Timer.periodic(
        const Duration(seconds: 1),
            (_) => _updateTimer(),
      );
    } else if (loadedPaused != null) {
      final seconds =
          (loadedPaused['remaining_seconds'] as int?) ??
              0;

      setState(() {
        remaining = Duration(seconds: seconds);
      });
    } else {
      setState(() {
        remaining = Duration.zero;
      });
    }
  }

  Future<void> _updateTimer() async {
    if (activeFasting == null) {
      return;
    }

    final endTime = DateTime.parse(
      activeFasting!['end_time'].toString(),
    );

    final difference =
    endTime.difference(DateTime.now());

    if (difference <= Duration.zero) {
      timer?.cancel();

      await fastingTimerService.finishFasting();

      if (!mounted) {
        return;
      }

      setState(() {
        activeFasting = null;
        pausedFasting = null;
        remaining = Duration.zero;
      });

      return;
    }

    if (mounted) {
      setState(() {
        remaining = difference;
      });
    }
  }

  Future<void> _startFasting() async {
    if (protocol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primeiro escolha um protocolo de jejum.',
          ),
        ),
      );

      return;
    }

    final fastingHours =
    protocol!['fasting_hours'] as int;

    await fastingTimerService.startFasting(
      fastingHours,
    );

    final fasting =
    await fastingTimerService.getActiveFasting();

    if (fasting == null) {
      return;
    }

    final endTime = DateTime.parse(
      fasting['end_time'].toString(),
    );

    await notificationService
        .showFastingStartedNotification();

    await notificationService
        .scheduleFastingEndNotification(
      endTime,
    );

    timer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      activeFasting = fasting;
      pausedFasting = null;
    });

    _updateTimer();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _updateTimer(),
    );
  }

  Future<void> _pauseFasting() async {
    await fastingTimerService.pauseFasting();

    await notificationService
        .cancelFastingEndNotification();

    timer?.cancel();

    final paused =
    await fastingTimerService.getPausedFasting();

    if (!mounted) {
      return;
    }

    final seconds =
        (paused?['remaining_seconds'] as int?) ?? 0;

    setState(() {
      activeFasting = null;
      pausedFasting = paused;
      remaining = Duration(seconds: seconds);
    });
  }

  Future<void> _resumeFasting() async {
    await fastingTimerService.resumeFasting();

    final fasting =
    await fastingTimerService.getActiveFasting();

    if (fasting == null) {
      return;
    }

    final endTime = DateTime.parse(
      fasting['end_time'].toString(),
    );

    await notificationService
        .scheduleFastingEndNotification(
      endTime,
    );

    timer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      activeFasting = fasting;
      pausedFasting = null;
    });

    _updateTimer();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _updateTimer(),
    );
  }

  Future<void> _finishFasting() async {
    await fastingTimerService.finishFasting();

    await notificationService
        .cancelFastingEndNotification();

    timer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      activeFasting = null;
      pausedFasting = null;
      remaining = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    final hours =
    duration.inHours.toString().padLeft(2, '0');

    final minutes =
    (duration.inMinutes % 60)
        .toString()
        .padLeft(2, '0');

    final seconds =
    (duration.inSeconds % 60)
        .toString()
        .padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  Future<void> _openMeals() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MealsPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _openDailySummary() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DailySummaryPage(),
      ),
    );
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HistoryPage(),
      ),
    );
  }

  Future<void> _openStatistics() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const StatisticsPage(),
      ),
    );
  }

  Future<void> _logout() async {
    await authService.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          isDarkMode: widget.isDarkMode,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
          (route) => false,
    );
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final protocolName =
        protocol?['protocol']?.toString() ??
            'Nenhum protocolo';

    final fastingHours =
        protocol?['fasting_hours']?.toString() ??
            '-';

    final isPaused =
        activeFasting == null &&
            pausedFasting != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mamba Fast Tracker',
        ),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode
                ? 'Modo claro'
                : 'Modo escuro',
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Protocolo atual',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      protocolName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      protocol == null
                          ? 'Configure seu protocolo'
                          : '$fastingHours horas de jejum',
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        await Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (_) =>
                            const FastingProtocolPage(),
                          ),
                        );

                        await _loadData();
                      },
                      child: Text(
                        protocol == null
                            ? 'Escolher protocolo'
                            : 'Alterar protocolo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Jejum',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      activeFasting == null &&
                          pausedFasting == null
                          ? 'Nenhum jejum ativo'
                          : _formatDuration(
                        remaining,
                      ),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isPaused) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Jejum pausado',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (activeFasting == null &&
                        pausedFasting == null)
                      FilledButton.icon(
                        onPressed: _startFasting,
                        icon: const Icon(
                          Icons.play_arrow,
                        ),
                        label: const Text(
                          'Iniciar jejum',
                        ),
                      )
                    else if (isPaused)
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _resumeFasting,
                              icon: const Icon(
                                Icons.play_arrow,
                              ),
                              label: const Text(
                                'Retomar',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _finishFasting,
                              icon: const Icon(
                                Icons.stop,
                              ),
                              label: const Text(
                                'Encerrar',
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _pauseFasting,
                              icon: const Icon(
                                Icons.pause,
                              ),
                              label: const Text(
                                'Pausar',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _finishFasting,
                              icon: const Icon(
                                Icons.stop,
                              ),
                              label: const Text(
                                'Encerrar',
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.restaurant_menu,
                ),
                title: const Text(
                  'Refeições',
                ),
                subtitle: const Text(
                  'Adicionar e acompanhar suas refeições',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: _openMeals,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.today,
                ),
                title: const Text(
                  'Resumo de hoje',
                ),
                subtitle: const Text(
                  'Calorias, jejum e meta diária',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: _openDailySummary,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.history,
                ),
                title: const Text(
                  'Histórico',
                ),
                subtitle: const Text(
                  'Veja seus dias anteriores',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: _openHistory,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.bar_chart,
                ),
                title: const Text(
                  'Estatísticas',
                ),
                subtitle: const Text(
                  'Acompanhe sua evolução',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: _openStatistics,
              ),
            ),
          ],
        ),
      ),
    );
  }
}