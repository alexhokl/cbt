import 'package:flutter/material.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'settings_page.dart';

/// A feeling being entered, before it is sent. It is a small mutable holder
/// rather than the wire type so the sliders have somewhere to write.
class FeelingDraft {
  FeelingDraft({this.name = '', this.intensity, this.rated = false});

  String name;
  int? intensity;
  bool rated;
}

/// A thought being entered, before it is sent.
class ThoughtDraft {
  ThoughtDraft({this.body = '', this.isHot = false});

  String body;
  bool isHot;
}

/// EditRecordPage creates a thought record, or edits the columns of one that
/// already exists.
///
/// Only the event is required. A record is normally opened in the moment with
/// little more than that, so nothing else is allowed to block saving.
class EditRecordPage extends StatefulWidget {
  const EditRecordPage({super.key, this.record, this.service});

  final ThoughtRecord? record;
  final RecordService? service;

  @override
  State<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final TextEditingController _eventController = TextEditingController();
  final List<ThoughtDraft> _thoughts = <ThoughtDraft>[];
  final List<FeelingDraft> _feelings = <FeelingDraft>[];

  DateTime? _occurredAt;
  bool _saving = false;
  String? _eventError;

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    if (record != null) {
      _eventController.text = record.event;
      if (record.hasOccurredAt()) {
        _occurredAt = record.occurredAt.toDateTime().toLocal();
      }
    }
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  Future<RecordService> _service() async =>
      widget.service ?? await BackendConfig.buildService();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt ?? now,
      // Events are in the past. Offering future dates would only invite
      // mistyped entries that sort above everything real.
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _occurredAt = picked);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_eventController.text.trim().isEmpty) {
      setState(() => _eventError = l10n.eventRequired);
      return;
    }

    setState(() {
      _saving = true;
      _eventError = null;
    });

    try {
      final service = await _service();
      if (_isEditing) {
        final request = UpdateThoughtRecordRequest()
          ..id = widget.record!.id
          ..event = _eventController.text;
        if (_occurredAt != null) {
          request.occurredAt = timestampFrom(_occurredAt!);
        }
        await service.updateThoughtRecord(request);
      } else {
        final request = CreateThoughtRecordRequest()
          ..event = _eventController.text;
        if (_occurredAt != null) {
          request.occurredAt = timestampFrom(_occurredAt!);
        }
        for (final thought in _thoughts) {
          if (thought.body.trim().isEmpty) {
            continue;
          }
          request.thoughts.add(
            ThoughtInput()
              ..body = thought.body
              ..isHot = thought.isHot,
          );
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
        await service.createThoughtRecord(request);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } on RecordException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final format = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editThoughtRecord : l10n.newThoughtRecord),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _eventController,
            minLines: 3,
            maxLines: 8,
            autofocus: !_isEditing,
            decoration: InputDecoration(
              labelText: l10n.fieldEvent,
              hintText: l10n.fieldEventHint,
              errorText: _eventError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.fieldWhen),
            subtitle: Text(
              _occurredAt == null ? l10n.fieldWhenUnset : format.format(_occurredAt!),
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),

          // Thoughts and feelings are only offered on creation. Changing them
          // afterwards is done from the detail page against the real ids, so
          // that a re-rating can be tied to the feeling it belongs to.
          if (!_isEditing) ...[
            const SizedBox(height: 16),
            Text(l10n.fieldThoughts,
                style: Theme.of(context).textTheme.titleSmall),
            for (var index = 0; index < _thoughts.length; index++)
              _thoughtEditor(index, l10n),
            TextButton.icon(
              onPressed: () => setState(() => _thoughts.add(ThoughtDraft())),
              icon: const Icon(Icons.add),
              label: Text(l10n.addThought),
            ),
            const SizedBox(height: 16),
            Text(l10n.fieldFeelings,
                style: Theme.of(context).textTheme.titleSmall),
            for (var index = 0; index < _feelings.length; index++)
              _feelingEditor(index, l10n),
            TextButton.icon(
              onPressed: () => setState(() => _feelings.add(FeelingDraft())),
              icon: const Icon(Icons.add),
              label: Text(l10n.addFeeling),
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

  Widget _thoughtEditor(int index, AppLocalizations l10n) {
    final draft = _thoughts[index];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => draft.body = value,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l10n.thoughtHint,
                border: const OutlineInputBorder(),
              ),
            ),
            Row(
              children: [
                Expanded(child: Text(l10n.markStrongest)),
                Switch(
                  value: draft.isHot,
                  onChanged: (value) {
                    setState(() {
                      // Only one thought can be the strongest, so marking one
                      // clears the rest rather than letting the server reject
                      // the whole record on save.
                      for (final other in _thoughts) {
                        other.isHot = false;
                      }
                      draft.isHot = value;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _thoughts.removeAt(index)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _feelingEditor(int index, AppLocalizations l10n) {
    final draft = _feelings[index];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => draft.name = value,
                    decoration: InputDecoration(
                      hintText: l10n.feelingNameHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _feelings.removeAt(index)),
                ),
              ],
            ),
            Row(
              children: [
                // Rating stays optional: writing down that you felt ashamed is
                // worth something even when you are in no state to put a
                // number on it.
                Checkbox(
                  value: draft.rated,
                  onChanged: (value) => setState(() {
                    draft.rated = value ?? false;
                    draft.intensity ??= 50;
                  }),
                ),
                Expanded(
                  child: draft.rated
                      ? Slider(
                          value: (draft.intensity ?? 50).toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: '${draft.intensity ?? 50}%',
                          onChanged: (value) => setState(
                              () => draft.intensity = value.round()),
                        )
                      : Text(l10n.feelingUnrated),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Converts a local date to the wire timestamp type.
Timestamp timestampFrom(DateTime value) => Timestamp.fromDateTime(value.toUtc());
