import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'settings_page.dart';

/// The columns of a formulation in the order the exercise is written, each
/// with its label and how to read it from a stored formulation. The edit and
/// detail pages share it so the two always agree.
List<(String, String Function(Formulation))> formulationColumns(
  AppLocalizations l10n,
) => [
  (l10n.fieldEarlyExperiences, (f) => f.earlyExperiences),
  (l10n.fieldBeliefs, (f) => f.beliefs),
  (l10n.fieldAssumptions, (f) => f.assumptions),
  (l10n.fieldRulesForLiving, (f) => f.rulesForLiving),
  (l10n.fieldFormulationEvents, (f) => f.events),
  (l10n.fieldMaintainingThoughts, (f) => f.thoughts),
  (l10n.fieldMaintainingBehaviours, (f) => f.behaviours),
];

/// EditFormulationPage creates a formulation, or edits one that already
/// exists.
///
/// A formulation can be worked out forwards from the early experiences or
/// backwards from the thoughts and behaviours, so no single field is
/// required; only an entirely blank formulation is refused.
class EditFormulationPage extends StatefulWidget {
  const EditFormulationPage({super.key, this.formulation, this.service});

  final Formulation? formulation;
  final RecordService? service;

  @override
  State<EditFormulationPage> createState() => _EditFormulationPageState();
}

class _EditFormulationPageState extends State<EditFormulationPage> {
  // One controller per column, in the order of formulationColumns.
  final List<TextEditingController> _controllers = List.generate(
    7,
    (_) => TextEditingController(),
  );

  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.formulation != null;

  @override
  void initState() {
    super.initState();
    final formulation = widget.formulation;
    if (formulation != null) {
      final values = [
        formulation.earlyExperiences,
        formulation.beliefs,
        formulation.assumptions,
        formulation.rulesForLiving,
        formulation.events,
        formulation.thoughts,
        formulation.behaviours,
      ];
      for (var index = 0; index < values.length; index++) {
        _controllers[index].text = values[index];
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<RecordService> _service() async =>
      widget.service ?? await BackendConfig.buildService();

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_controllers.every((controller) => controller.text.trim().isEmpty)) {
      setState(() => _error = l10n.formulationRequired);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final text = _controllers.map((controller) => controller.text).toList();
    try {
      final service = await _service();
      if (_isEditing) {
        await service.updateFormulation(
          UpdateFormulationRequest()
            ..id = widget.formulation!.id
            ..earlyExperiences = text[0]
            ..beliefs = text[1]
            ..assumptions = text[2]
            ..rulesForLiving = text[3]
            ..events = text[4]
            ..thoughts = text[5]
            ..behaviours = text[6],
        );
      } else {
        await service.createFormulation(
          CreateFormulationRequest()
            ..earlyExperiences = text[0]
            ..beliefs = text[1]
            ..assumptions = text[2]
            ..rulesForLiving = text[3]
            ..events = text[4]
            ..thoughts = text[5]
            ..behaviours = text[6],
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } on RecordException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final columns = formulationColumns(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editFormulation : l10n.newFormulation),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.formulationIntro),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
          ],
          // The fields follow the columns of the exercise, in order, so the
          // form reads from the early experiences down to the behaviours.
          for (var index = 0; index < columns.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                key: Key('formulation-$index'),
                controller: _controllers[index],
                minLines: 2,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: columns[index].$1,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(l10n.save),
        ),
      ),
    );
  }
}
