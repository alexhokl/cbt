import 'package:flutter/material.dart';
import 'package:flutter_helper/format.dart';
import 'package:flutter_helper/ui.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'edit_data_log_page.dart';
import 'edit_record_page.dart';
import 'record_detail_page.dart';
import 'record_list.dart';
import 'settings_page.dart';

/// DataLogDetailPage shows a positive data log: both beliefs, every rating
/// with its date, oldest first, and the evidence gathered so far.
///
/// A log is returned to rather than written once, so the two things done on a
/// return are on this page: adding a row of evidence, and rating both beliefs
/// again. A new rating is added beside the earlier ones, never in place of
/// them. The ratings are shown as given; nothing is derived from them.
class DataLogDetailPage extends StatefulWidget {
  const DataLogDetailPage({super.key, required this.logId, this.service});

  final int logId;
  final RecordService? service;

  @override
  State<DataLogDetailPage> createState() => _DataLogDetailPageState();
}

class _DataLogDetailPageState extends State<DataLogDetailPage> {
  PositiveDataLog? _log;
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
      final log = await service.getPositiveDataLog(widget.logId);
      if (!mounted) return;
      setState(() {
        _log = log;
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

  /// Runs a change that returns the updated log, showing it on success and
  /// the server's message on failure.
  Future<void> _apply(
    Future<PositiveDataLog> Function(RecordService service) change,
  ) async {
    try {
      final service = await _service();
      final log = await change(service);
      if (!mounted) return;
      setState(() => _log = log);
    } on RecordException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
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
      await service.deletePositiveDataLog(widget.logId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on RecordException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _deleteEvidence(DataLogEvidence evidence) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await confirmDialog(
      context,
      title: l10n.deleteEvidenceTitle,
      message: l10n.deleteEvidenceBody,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (!confirmed || !mounted) {
      return;
    }

    await _apply((service) => service.deleteDataLogEvidence(evidence.id));
  }

  Future<void> _addEvidence() async {
    final input = await showDialog<DataLogEvidenceInput>(
      context: context,
      builder: (_) => const _AddEvidenceDialog(),
    );
    if (input == null || !mounted) {
      return;
    }

    await _apply((service) => service.addDataLogEvidence(widget.logId, input));
  }

  Future<void> _rateAgain() async {
    final request = await showDialog<RateBeliefsRequest>(
      context: context,
      builder: (_) => const _RateBeliefsDialog(),
    );
    if (request == null || !mounted) {
      return;
    }

    request.logId = widget.logId;
    await _apply((service) => service.rateBeliefs(request));
  }

  Future<void> _edit(PositiveDataLog log) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => EditDataLogPage(log: log, service: widget.service),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final log = _log;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (log != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(log),
            ),
          if (log != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: _buildBody(l10n),
      floatingActionButton: log == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _addEvidence,
              icon: const Icon(Icons.add),
              label: Text(l10n.addEvidence),
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

    final log = _log!;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RecordField(label: l10n.fieldBelief, value: log.belief),
        RecordField(
          label: l10n.fieldAlternativeBelief,
          value: log.alternativeBelief,
        ),
        Text(l10n.fieldBeliefRatings, style: textTheme.labelMedium),
        const SizedBox(height: 4),
        for (final rating in log.ratings)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${formatDate(rating.ratedAt.toDateTime().toLocal())}  '
              '${beliefRatingLabel(rating, l10n)}',
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _rateAgain,
            icon: const Icon(Icons.tune),
            label: Text(l10n.rateAgain),
          ),
        ),
        const SizedBox(height: 16),
        if (log.evidence.isNotEmpty) ...[
          Text(l10n.fieldDataLogEvidence, style: textTheme.labelMedium),
          for (final evidence in log.evidence)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(evidence.body),
              subtitle: Text(
                formatEventDate(
                  evidence.hasNotedAt() ? evidence.notedAt.toDateTime() : null,
                  evidence.createdAt.toDateTime(),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteEvidence(evidence),
              ),
            ),
        ],
        // Leaves room above the floating button so the last row is never
        // hidden beneath it.
        const SizedBox(height: 72),
      ],
    );
  }
}

/// Renders one rating of both beliefs exactly as it was given. A belief left
/// unrated at that sitting is shown as not rated, never as zero.
String beliefRatingLabel(BeliefRating rating, AppLocalizations l10n) {
  final belief = rating.hasBeliefPercent()
      ? '${rating.beliefPercent}%'
      : l10n.feelingUnrated;
  final alternative = rating.hasAlternativePercent()
      ? '${rating.alternativePercent}%'
      : l10n.feelingUnrated;
  return l10n.beliefRatingLine(belief, alternative);
}

/// Asks for a row of evidence and, optionally, when it happened.
class _AddEvidenceDialog extends StatefulWidget {
  const _AddEvidenceDialog();

  @override
  State<_AddEvidenceDialog> createState() => _AddEvidenceDialogState();
}

class _AddEvidenceDialogState extends State<_AddEvidenceDialog> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _notedAt;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _notedAt ?? now,
      // Evidence is something that has already happened.
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _notedAt = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.addEvidence),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('newEvidence'),
            controller: _controller,
            autofocus: true,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.fieldEvidenceWhen),
            subtitle: Text(
              _notedAt == null ? l10n.fieldWhenUnset : formatDate(_notedAt!),
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_controller.text.trim().isEmpty) {
              return;
            }
            final input = DataLogEvidenceInput()..body = _controller.text;
            if (_notedAt != null) {
              input.notedAt = timestampFrom(_notedAt!);
            }
            Navigator.of(context).pop(input);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// Asks how strongly each belief is believed now. Either may be left unrated,
/// but not both.
class _RateBeliefsDialog extends StatefulWidget {
  const _RateBeliefsDialog();

  @override
  State<_RateBeliefsDialog> createState() => _RateBeliefsDialogState();
}

class _RateBeliefsDialogState extends State<_RateBeliefsDialog> {
  int? _beliefPercent;
  int? _alternativePercent;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.rateAgainTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PercentSlider(
            key: const Key('rerateBelief'),
            label: l10n.fieldBelieveBelief,
            value: _beliefPercent,
            onChanged: (value) => setState(() => _beliefPercent = value),
          ),
          PercentSlider(
            key: const Key('rerateAlternative'),
            label: l10n.fieldBelieveAlternative,
            value: _alternativePercent,
            onChanged: (value) => setState(() => _alternativePercent = value),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_beliefPercent == null && _alternativePercent == null) {
              setState(() => _error = l10n.ratingRequired);
              return;
            }
            final request = RateBeliefsRequest();
            if (_beliefPercent != null) {
              request.beliefPercent = _beliefPercent!;
            }
            if (_alternativePercent != null) {
              request.alternativePercent = _alternativePercent!;
            }
            Navigator.of(context).pop(request);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
