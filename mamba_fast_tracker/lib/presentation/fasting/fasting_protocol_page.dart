import 'package:flutter/material.dart';

import '../../services/fasting_service.dart';

class FastingProtocolPage extends StatefulWidget {
  const FastingProtocolPage({super.key});

  @override
  State<FastingProtocolPage> createState() =>
      _FastingProtocolPageState();
}

class _FastingProtocolPageState
    extends State<FastingProtocolPage> {
  final FastingService fastingService = FastingService();

  String selectedProtocol = '16:8';

  final TextEditingController fastingHoursController =
  TextEditingController();

  final TextEditingController eatingHoursController =
  TextEditingController();

  final List<Map<String, dynamic>> protocols = [
    {
      'name': '12:12',
      'fastingHours': 12,
      'eatingHours': 12,
      'description':
      '12 horas de jejum e 12 horas para alimentação.',
    },
    {
      'name': '16:8',
      'fastingHours': 16,
      'eatingHours': 8,
      'description':
      '16 horas de jejum e 8 horas para alimentação.',
    },
    {
      'name': '18:6',
      'fastingHours': 18,
      'eatingHours': 6,
      'description':
      '18 horas de jejum e 6 horas para alimentação.',
    },
    {
      'name': 'Personalizado',
      'fastingHours': 0,
      'eatingHours': 0,
      'description':
      'Escolha a duração do seu jejum.',
    },
  ];

  Future<void> confirmProtocol() async {
    int fastingHours;
    int eatingHours;

    if (selectedProtocol == 'Personalizado') {
      fastingHours =
          int.tryParse(fastingHoursController.text) ?? 0;

      eatingHours =
          int.tryParse(eatingHoursController.text) ?? 0;

      if (fastingHours <= 0 || eatingHours <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Informe as horas de jejum e alimentação.',
            ),
          ),
        );

        return;
      }
    } else {
      final selected = protocols.firstWhere(
            (protocol) =>
        protocol['name'] == selectedProtocol,
      );

      fastingHours =
      selected['fastingHours'] as int;

      eatingHours =
      selected['eatingHours'] as int;
    }

    await fastingService.saveProtocol(
      protocol: selectedProtocol,
      fastingHours: fastingHours,
      eatingHours: eatingHours,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Protocolo $selectedProtocol salvo com sucesso!',
        ),
      ),
    );

    Navigator.pop(context, selectedProtocol);
  }

  @override
  void dispose() {
    fastingHoursController.dispose();
    eatingHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocolo de jejum'),
      ),
      body: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Escolha seu protocolo',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Selecione por quanto tempo você deseja fazer o jejum.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 24),

          RadioGroup<String>(
            groupValue: selectedProtocol,
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedProtocol = value;
              });
            },
            child: Column(
              children: protocols.map(
                    (protocol) {
                  final name =
                  protocol['name'] as String;

                  final fastingHours =
                  protocol['fastingHours'] as int;

                  final eatingHours =
                  protocol['eatingHours'] as int;

                  final description =
                  protocol['description'] as String;

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: name,
                            contentPadding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(description),

                                if (fastingHours > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '$fastingHours horas de jejum • '
                                        '$eatingHours horas de alimentação',
                                  ),
                                ],
                              ],
                            ),
                          ),

                          if (selectedProtocol ==
                              'Personalizado' &&
                              name == 'Personalizado')
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                16,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 8),

                                  TextField(
                                    controller:
                                    fastingHoursController,
                                    keyboardType:
                                    TextInputType.number,
                                    decoration:
                                    const InputDecoration(
                                      labelText:
                                      'Horas de jejum',
                                      hintText: 'Ex: 14',
                                      border:
                                      OutlineInputBorder(),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  TextField(
                                    controller:
                                    eatingHoursController,
                                    keyboardType:
                                    TextInputType.number,
                                    decoration:
                                    const InputDecoration(
                                      labelText:
                                      'Horas de alimentação',
                                      hintText: 'Ex: 10',
                                      border:
                                      OutlineInputBorder(),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  const Align(
                                    alignment:
                                    Alignment.centerLeft,
                                    child: Text(
                                      'Exemplo: 14 horas de jejum e 10 horas para alimentação.',
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),

          const SizedBox(height: 4),

          SizedBox(
            height: 50,
            width: double.infinity,
            child: FilledButton(
              onPressed: confirmProtocol,
              child: const Text(
                'Confirmar protocolo',
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}