import 'package:flutter/material.dart';
import 'package:flutter_helper/ui.dart';
import 'package:flutter_helper/format.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'challenge_page.dart';
import 'edit_record_page.dart';
import 'settings_page.dart';

/// RecordDetailPage shows a thought record in full: its columns, the thoughts
/// with the evidence for and biases named in each, and the feelings with their
/// before and after ratings.
///
/// Tapping a thought edits the evidence for it. Evidence is often gathered
/// some time after the thought was written, and adding it does not count as
/// working the record through.
class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({
    super.key,
    required this.recordId,
    this.service,
  });

  final int recordId;
  final RecordService? service;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  ThoughtRecord? _record;
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
      final record = await service.getThoughtRecord(widget.recordId);
      if (!mounted) return;
      setState(() {
        _record = record;
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
      await service.deleteThoughtRecord(widget.recordId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on RecordException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _editEvidence(NegativeThought thought) async {
    final l10n = AppLocalizations.of(context)!;
    final evidence = await showDialog<String>(
      context: context,
      builder: (_) => _EvidenceDialog(initial: thought.evidence, l10n: l10n),
    );

    if (evidence == null || !mounted) {
      return;
    }

    try {
      final service = await _service();
      final record = await service.setThoughtEvidence(thought.id, evidence);
      if (!mounted) return;
      setState(() => _record = record);
    } on RecordException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final record = _record;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (record != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => EditRecordPage(
                      record: record,
                      service: widget.service,
                    ),
                  ),
                );
                await _load();
              },
            ),
          if (record != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: _buildBody(l10n),
      floatingActionButton: record == null || record.hasChallengedAt()
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => ChallengePage(
                      record: record,
                      service: widget.service,
                    ),
                  ),
                );
                await _load();
              },
              icon: const Icon(Icons.psychology_outlined),
              label: Text(l10n.challenge),
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

    final record = _record!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          record.hasChallengedAt()
              ? l10n.challengedOn(formatDate(record.challengedAt.toDateTime().toLocal()))
              : l10n.notYetChallenged,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 16),
        RecordField(
          label: l10n.fieldWhen,
          value: record.hasOccurredAt()
              ? formatDate(record.occurredAt.toDateTime().toLocal())
              : l10n.fieldWhenWritten(
                  formatDate(record.createdAt.toDateTime().toLocal()),
                ),
        ),
        RecordField(label: l10n.fieldEvent, value: record.event),
        if (record.thoughts.isNotEmpty) ...[
          _sectionHeader(l10n.fieldThoughts),
          for (final thought in record.thoughts) _thoughtTile(thought, l10n),
        ],
        if (record.feelings.isNotEmpty) ...[
          _sectionHeader(l10n.fieldFeelings),
          for (final feeling in record.feelings) _feelingTile(feeling, l10n),
        ],
        RecordField(
          label: l10n.fieldAlternativeView,
          value: record.alternativeView,
        ),
        RecordField(
          label: l10n.fieldEvidence,
          value: record.evidenceForAlternative,
        ),
        RecordField(label: l10n.fieldFeelingsNow, value: record.feelingsNow),
      ],
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(label, style: Theme.of(context).textTheme.titleSmall),
      );

  Widget _thoughtTile(NegativeThought thought, AppLocalizations l10n) {
    return Card(
      child: ListTile(
        // The strongest thought is the one worth challenging first, so it is
        // marked rather than left to blend in with the rest.
        leading: thought.isHot
            ? const Icon(Icons.local_fire_department_outlined)
            : const Icon(Icons.circle_outlined),
        title: Text(thought.body),
        // The evidence, when there is any, followed by the judgement. A
        // thought is never both distorted and accurate, so at most one
        // judgement ever shows. Nothing shows while neither has been decided,
        // rather than a blank that would read as an answer.
        subtitle: _thoughtSubtitle(thought, l10n),
        onTap: () => _editEvidence(thought),
        trailing: thought.hasBeliefAfter()
            ? Text(l10n.thoughtBelief(thought.beliefAfter))
            : null,
      ),
    );
  }

  Widget? _thoughtSubtitle(NegativeThought thought, AppLocalizations l10n) {
    final judgement = _thoughtJudgement(thought, l10n);
    if (thought.evidence.isEmpty) {
      return judgement;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.thoughtEvidenceLabel(thought.evidence)),
        ?judgement,
      ],
    );
  }

  Widget? _thoughtJudgement(NegativeThought thought, AppLocalizations l10n) {
    if (thought.biases.isNotEmpty) {
      return Wrap(
        spacing: 6,
        children: [
          for (final bias in thought.biases)
            Chip(
              label: Text(bias.name),
              visualDensity: VisualDensity.compact,
            ),
        ],
      );
    }

    if (thought.isFactual) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          avatar: const Icon(Icons.check, size: 16),
          label: Text(l10n.thoughtFactualBadge),
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    return null;
  }

  Widget _feelingTile(Feeling feeling, AppLocalizations l10n) {
    // Seeing the before and after ratings together is the point of re-rating,
    // so they are shown on one line rather than in separate places.
    final buffer = StringBuffer();
    if (feeling.hasIntensityBefore()) {
      buffer.write('${feeling.intensityBefore}%');
    } else {
      buffer.write(l10n.feelingUnrated);
    }
    if (feeling.hasIntensityAfter()) {
      buffer.write(' → ${feeling.intensityAfter}%');
    }

    return ListTile(
      dense: true,
      title: Text(feeling.name),
      trailing: Text(buffer.toString()),
    );
  }
}

/// _EvidenceDialog edits the evidence for one thought. It owns its controller
/// so the controller outlives the dialog's closing animation, and pops the new
/// text on save or nothing on cancel.
class _EvidenceDialog extends StatefulWidget {
  const _EvidenceDialog({required this.initial, required this.l10n});

  final String initial;
  final AppLocalizations l10n;

  @override
  State<_EvidenceDialog> createState() => _EvidenceDialogState();
}

class _EvidenceDialogState extends State<_EvidenceDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return AlertDialog(
      title: Text(l10n.editThoughtEvidence),
      content: TextField(
        key: const Key('thoughtEvidence'),
        controller: _controller,
        autofocus: true,
        minLines: 3,
        maxLines: 8,
        decoration: InputDecoration(
          hintText: l10n.thoughtEvidence,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// RecordField renders one labelled paragraph, omitting the field entirely
/// when it is empty. A record in progress should read as what has been written
/// so far, not as a form with blanks in it.
class RecordField extends StatelessWidget {
  const RecordField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
