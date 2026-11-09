import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'edit_record_page.dart';
import 'settings_page.dart';

/// CompleteExperimentPage records the second sitting of a behavioural
/// experiment: what actually happened, what was learned, how to build on it,
/// and how each predicted feeling was actually felt.
///
/// The plan and the prediction are shown read only at the top. The exercise is
/// to set what happened against what was predicted, so the prediction must
/// stay as it was written. Editing belongs on the edit page.
class CompleteExperimentPage extends StatefulWidget {
  const CompleteExperimentPage({
    super.key,
    required this.experiment,
    this.service,
  });

  final BehaviouralExperiment experiment;
  final RecordService? service;

  @override
  State<CompleteExperimentPage> createState() => _CompleteExperimentPageState();
}

class _CompleteExperimentPageState extends State<CompleteExperimentPage> {
  final TextEditingController _outcomeController = TextEditingController();
  final TextEditingController _learnedController = TextEditingController();
  final TextEditingController _buildOnController = TextEditingController();

  /// How strongly each predicted feeling was actually felt, keyed by feeling
  /// id. A feeling starts at its predicted rating so an untouched slider
  /// records "as predicted" rather than silently dropping to zero.
  final Map<int, int> _reratings = <int, int>{};

  /// Feelings that were felt but not predicted.
  final List<FeelingDraft> _newFeelings = <FeelingDraft>[];

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _outcomeController.text = widget.experiment.outcome;
    _learnedController.text = widget.experiment.learned;
    _buildOnController.text = widget.experiment.buildOn;
    for (final feeling in widget.experiment.feelings) {
      _reratings[feeling.id] = feeling.hasIntensityAfter()
          ? feeling.intensityAfter
          : (feeling.hasIntensityBefore() ? feeling.intensityBefore : 0);
    }
  }

  @override
  void dispose() {
    _outcomeController.dispose();
    _learnedController.dispose();
    _buildOnController.dispose();
    super.dispose();
  }

  Future<RecordService> _service() async =>
      widget.service ?? await BackendConfig.buildService();

  Future<void> _save() async {
    setState(() => _saving = true);

    final request = CompleteBehaviouralExperimentRequest()
      ..id = widget.experiment.id
      ..outcome = _outcomeController.text
      ..learned = _learnedController.text
      ..buildOn = _buildOnController.text;

    _reratings.forEach((feelingId, intensity) {
      request.feelingReratings.add(
        FeelingRerating()
          ..feelingId = feelingId
          ..intensityAfter = intensity,
      );
    });

    for (final feeling in _newFeelings) {
      if (feeling.name.trim().isEmpty) {
        continue;
      }
      final input = FeelingInput()..name = feeling.name;
      if (feeling.rated && feeling.intensity != null) {
        input.intensity = feeling.intensity!;
      }
      request.newFeelings.add(input);
    }

    try {
      final service = await _service();
      await service.completeBehaviouralExperiment(request);
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
    final experiment = widget.experiment;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.completeTitle(experiment.id))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.completeIntro, style: textTheme.bodyMedium),
          const SizedBox(height: 16),

          // What was planned and predicted, read only.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.fieldPlan, style: textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(experiment.plan),
                  if (experiment.prediction.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(l10n.fieldPrediction, style: textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(experiment.prediction),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(l10n.fieldOutcome, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _prose(_outcomeController, const Key('outcome')),

          if (experiment.feelings.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l10n.completeStepRerate, style: textTheme.titleMedium),
            for (final feeling in experiment.feelings) _feelingRerater(feeling),
          ],

          const SizedBox(height: 24),
          Text(l10n.completeStepNewFeelings, style: textTheme.titleMedium),
          for (var index = 0; index < _newFeelings.length; index++)
            FeelingDraftEditor(
              draft: _newFeelings[index],
              onChanged: () => setState(() {}),
              onRemove: () => setState(() => _newFeelings.removeAt(index)),
            ),
          TextButton.icon(
            onPressed: () => setState(() => _newFeelings.add(FeelingDraft())),
            icon: const Icon(Icons.add),
            label: Text(l10n.addFeeling),
          ),

          const SizedBox(height: 24),
          Text(l10n.fieldLearned, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _prose(_learnedController, const Key('learned')),

          const SizedBox(height: 24),
          Text(l10n.fieldBuildOn, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _prose(_buildOnController, const Key('buildOn')),
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

  Widget _prose(TextEditingController controller, Key key) => TextField(
    key: key,
    controller: controller,
    minLines: 3,
    maxLines: 10,
    decoration: const InputDecoration(border: OutlineInputBorder()),
  );

  Widget _feelingRerater(Feeling feeling) {
    final current = _reratings[feeling.id] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(feeling.name)),
            // The predicted rating stays visible: the difference between the
            // prediction and what was felt is the thing worth seeing.
            if (feeling.hasIntensityBefore())
              Text('${feeling.intensityBefore}% → $current%')
            else
              Text('$current%'),
          ],
        ),
        Slider(
          key: Key('rerate-${feeling.id}'),
          value: current.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          label: '$current%',
          onChanged: (value) =>
              setState(() => _reratings[feeling.id] = value.round()),
        ),
      ],
    );
  }
}
