import 'package:flutter/material.dart';

import '../../services/meal_service.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  final MealService mealService = MealService();

  List<Map<String, dynamic>> meals = [];
  int todayCalories = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final loadedMeals = await mealService.getMeals();
    final calories = await mealService.getTodayCalories();

    if (!mounted) {
      return;
    }

    setState(() {
      meals = loadedMeals;
      todayCalories = calories;
      isLoading = false;
    });
  }

  String _formatMealTime(String value) {
    final dateTime = DateTime.parse(value);

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute =
    dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _openMealForm({
    Map<String, dynamic>? meal,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MealFormPage(
          meal: meal,
          mealService: mealService,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadMeals();
    }
  }

  Future<void> _deleteMeal(
      Map<String, dynamic> meal,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Excluir refeição',
          ),
          content: Text(
            'Deseja realmente excluir "${meal['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await mealService.deleteMeal(
      meal['id'] as int,
    );

    if (!mounted) {
      return;
    }

    await _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas refeições',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openMealForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadMeals,
        child: meals.isEmpty
            ? ListView(
          children: [
            const SizedBox(height: 120),
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Nenhuma refeição cadastrada.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                'Toque em "Adicionar" para registrar sua primeira refeição.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Calorias de hoje',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$todayCalories kcal',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Refeições',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...meals.map(
                  (meal) {
                return Card(
                  margin:
                  const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: ListTile(
                    leading:
                    const CircleAvatar(
                      child: Icon(
                        Icons.restaurant,
                      ),
                    ),
                    title: Text(
                      meal['name'].toString(),
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${_formatMealTime(meal['meal_time'].toString())} • ${meal['calories']} kcal',
                    ),
                    trailing:
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openMealForm(
                            meal: meal,
                          );
                        }

                        if (value == 'delete') {
                          _deleteMeal(meal);
                        }
                      },
                      itemBuilder:
                          (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Editar',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Excluir',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class MealFormPage extends StatefulWidget {
  final Map<String, dynamic>? meal;
  final MealService mealService;

  const MealFormPage({
    super.key,
    this.meal,
    required this.mealService,
  });

  @override
  State<MealFormPage> createState() => _MealFormPageState();
}

class _MealFormPageState extends State<MealFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController caloriesController;

  bool isSaving = false;

  bool get isEditing => widget.meal != null;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.meal?['name']?.toString() ?? '',
    );

    caloriesController = TextEditingController(
      text: widget.meal?['calories']?.toString() ?? '',
    );
  }

  Future<void> _saveMeal() async {
    final name = nameController.text.trim();

    final calories = int.tryParse(
      caloriesController.text.trim(),
    );

    if (name.isEmpty ||
        calories == null ||
        calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informe o nome e uma quantidade válida de calorias.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      if (isEditing) {
        await widget.mealService.updateMeal(
          id: widget.meal!['id'] as int,
          name: name,
          calories: calories,
        );
      } else {
        await widget.mealService.addMeal(
          name: name,
          calories: calories,
        );
      }

      if (!mounted) {
        return;
      }

      FocusScope.of(context).unfocus();

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar refeição: $e',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    caloriesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Editar refeição'
              : 'Nova refeição',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Nome da refeição',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Ex: Almoço',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Calorias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Ex: 500',
                suffixText: 'kcal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: FilledButton(
                onPressed:
                isSaving ? null : _saveMeal,
                child: isSaving
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  isEditing
                      ? 'Salvar alterações'
                      : 'Adicionar refeição',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}