import 'package:flutter/material.dart';
import 'package:flutter_helper/format.dart';
import 'package:flutter_helper/ui.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'complete_experiment_page.dart';
import 'edit_experiment_page.dart';
import 'record_detail_page.dart';
import 'settings_page.dart';

/// ExperimentDetailPage shows a behavioural experiment in the order of its
/// columns. Feelings sit between the prediction and what actually happened, so
/// each predicted rating is read beside how the feeling was actually felt.
///
/// Empty columns are omitted: an experiment still to be carried out reads as
/// what has been written, not as a form with blanks in it.
class ExperimentDetailPage extends StatefulWidget {
  const ExperimentDetailPage({
    super.key,
    required this.experimentId,
    this.service,
  });

  final int experimentId;
  final RecordService? service;

  @override
  State<ExperimentDetailPage> createState() => _ExperimentDetailPageState();
}

class _ExperimentDetailPageState extends State<ExperimentDetailPage> {
  BehaviouralExperiment? _experiment;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<RecordService> _service() async =>
      widget.service ?? await BackendConfig.buildService();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = await _service();
      final experiment = await service.getBehaviouralExperiment(
        widget.experimentId,
      );
      if (!mounted) return;
      setState(() {
        _experiment = experiment;
        _loading = false;
      });
    } on RecordException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await confirmDialog(
      context,
      title: l10n.deleteRecordTitle,
      message: l10n.deleteRecordBody,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );

    if (!confirmed || !mounted) {
      return;
    }

    try {
      final service = await _service();
      await service.deleteBehaviouralExperiment(widget.experimentId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on RecordException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => page));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final experiment = _experiment;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (experiment != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _open(
                EditExperimentPage(
                  experiment: experiment,
                  service: widget.service,
                ),
              ),
            ),
          if (experiment != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: _buildBody(l10n),
      floatingActionButton: experiment == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _open(
                CompleteExperimentPage(
                  experiment: experiment,
                  service: widget.service,
                ),
              ),
              icon: const Icon(Icons.fact_check_outlined),
              label: Text(l10n.completeExperiment),
            ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.loadFailed),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    final experiment = _experiment!;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          experiment.hasCompletedAt()
              ? l10n.completedOn(
                  formatDate(experiment.completedAt.toDateTime().toLocal()),
                )
              : l10n.notYetCompleted,
          style: textTheme.labelLarge,
        ),
        const SizedBox(height: 16),
        RecordField(
          label: l10n.fieldExperimentWhen,
          value: experiment.hasOccurredAt()
              ? formatDate(experiment.occurredAt.toDateTime().toLocal())
              : l10n.fieldWhenWritten(
                  formatDate(experiment.createdAt.toDateTime().toLocal()),
                ),
        ),
        RecordField(label: l10n.fieldPlan, value: experiment.plan),
        RecordField(label: l10n.fieldPrediction, value: experiment.prediction),
        if (experiment.feelings.isNotEmpty) ...[
          Text(l10n.fieldFeelings, style: textTheme.labelMedium),
          const SizedBox(height: 4),
          for (final feeling in experiment.feelings)
            Text(experimentFeelingLabel(feeling, l10n)),
          const SizedBox(height: 16),
        ],
        RecordField(label: l10n.fieldOutcome, value: experiment.outcome),
        RecordField(label: l10n.fieldLearned, value: experiment.learned),
        RecordField(label: l10n.fieldBuildOn, value: experiment.buildOn),
        // Leaves room above the floating button so the last column is never
        // hidden beneath it.
        const SizedBox(height: 72),
      ],
    );
  }
}

/// Renders a feeling with its predicted rating and, once the experiment has
/// been written up, how strongly it was actually felt.
String experimentFeelingLabel(Feeling feeling, AppLocalizations l10n) {
  final before = feeling.hasIntensityBefore()
      ? '${feeling.intensityBefore}%'
      : l10n.feelingUnrated;
  if (!feeling.hasIntensityAfter()) {
    return '${feeling.name}: $before';
  }
  return '${feeling.name}: $before → ${feeling.intensityAfter}%';
}
