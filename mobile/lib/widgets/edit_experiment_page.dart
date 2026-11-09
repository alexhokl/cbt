import 'package:flutter/material.dart';
import 'package:flutter_helper/format.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'edit_record_page.dart';
import 'settings_page.dart';

/// EditExperimentPage creates a behavioural experiment, or edits the columns
/// of one that already exists.
///
/// A new experiment is written before it is carried out, so creating one asks
/// only for the plan, the prediction and the feelings predicted. What actually
/// happened is written up on the completion page. Editing shows every column,
/// so a write-up can be corrected without marking the experiment again.
class EditExperimentPage extends StatefulWidget {
  const EditExperimentPage({super.key, this.experiment, this.service});

  final BehaviouralExperiment? experiment;
  final RecordService? service;

  @override
  State<EditExperimentPage> createState() => _EditExperimentPageState();
}

class _EditExperimentPageState extends State<EditExperimentPage> {
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _predictionController = TextEditingController();
  final TextEditingController _outcomeController = TextEditingController();
  final TextEditingController _learnedController = TextEditingController();
  final TextEditingController _buildOnController = TextEditingController();
  final List<FeelingDraft> _feelings = <FeelingDraft>[];

  DateTime? _occurredAt;
  bool _saving = false;
  String? _planError;

  bool get _isEditing => widget.experiment != null;

  @override
  void initState() {
    super.initState();
    final experiment = widget.experiment;
    if (experiment != null) {
      _planController.text = experiment.plan;
      _predictionController.text = experiment.prediction;
      _outcomeController.text = experiment.outcome;
      _learnedController.text = experiment.learned;
      _buildOnController.text = experiment.buildOn;
      if (experiment.hasOccurredAt()) {
        _occurredAt = experiment.occurredAt.toDateTime().toLocal();
      }
    }
  }

  @override
  void dispose() {
    _planController.dispose();
    _predictionController.dispose();
    _outcomeController.dispose();
    _learnedController.dispose();
    _buildOnController.dispose();
    super.dispose();
  }

  Future<RecordService> _service() async =>
      widget.service ?? await BackendConfig.buildService();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt ?? now,
      // Unlike an event, an experiment is usually planned ahead, so the
      // coming year is offered as well as the past.
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (picked != null) {
      setState(() => _occurredAt = picked);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_planController.text.trim().isEmpty) {
      setState(() => _planError = l10n.planRequired);
      return;
    }

    setState(() {
      _saving = true;
      _planError = null;
    });

    try {
      final service = await _service();
      if (_isEditing) {
        final request = UpdateBehaviouralExperimentRequest()
          ..id = widget.experiment!.id
          ..plan = _planController.text
          ..prediction = _predictionController.text
          ..outcome = _outcomeController.text
          ..learned = _learnedController.text
          ..buildOn = _buildOnController.text;
        if (_occurredAt != null) {
          request.occurredAt = timestampFrom(_occurredAt!);
        }
        await service.updateBehaviouralExperiment(request);
      } else {
        final request = CreateBehaviouralExperimentRequest()
          ..plan = _planController.text
          ..prediction = _predictionController.text;
        if (_occurredAt != null) {
          request.occurredAt = timestampFrom(_occurredAt!);
        }
        for (final feeling in _feelings) {
          if (feeling.name.trim().isEmpty) {
            continue;
          }
          final input = FeelingInput()..name = feeling.name;
          if (feeling.rated && feeling.intensity != null) {
            input.intensity = feeling.intensity!;
          }
          request.feelings.add(input);
        }
        await service.createBehaviouralExperiment(request);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editExperiment : l10n.newExperiment),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // The fields follow the columns of the exercise, in order, so the
          // form reads the way the method is taught.
          _field(
            _planController,
            l10n.fieldPlan,
            key: const Key('plan'),
            error: _planError,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.fieldExperimentWhen),
            subtitle: Text(
              _occurredAt == null
                  ? l10n.fieldWhenUnset
                  : formatDate(_occurredAt!),
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          _field(
            _predictionController,
            l10n.fieldPrediction,
            key: const Key('prediction'),
          ),
          if (!_isEditing) ...[
            Text(
              l10n.fieldPredictedFeelings,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (var index = 0; index < _feelings.length; index++)
              FeelingDraftEditor(
                draft: _feelings[index],
                onChanged: () => setState(() {}),
                onRemove: () => setState(() => _feelings.removeAt(index)),
              ),
            TextButton.icon(
              onPressed: () => setState(() => _feelings.add(FeelingDraft())),
              icon: const Icon(Icons.add),
              label: Text(l10n.addFeeling),
            ),
          ],
          if (_isEditing) ...[
            _field(
              _outcomeController,
              l10n.fieldOutcome,
              key: const Key('outcome'),
            ),
            _field(
              _learnedController,
              l10n.fieldLearned,
              key: const Key('learned'),
            ),
            _field(
              _buildOnController,
              l10n.fieldBuildOn,
              key: const Key('buildOn'),
            ),
          ],
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

  Widget _field(
    TextEditingController controller,
    String label, {
    Key? key,
    String? error,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      key: key,
      controller: controller,
      minLines: 2,
      maxLines: 6,
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
