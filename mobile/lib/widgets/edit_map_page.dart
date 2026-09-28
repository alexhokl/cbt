import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'settings_page.dart';

/// EditMapPage creates a map of worry, or edits the columns of one that
/// already exists.
///
/// Setting [derivedFrom] starts an alternative reading of an existing map. The
/// original is shown alongside the fields while writing, because the point of
/// the exercise is to answer the first reading rather than to write a fresh
/// one from nothing.
class EditMapPage extends StatefulWidget {
  const EditMapPage({
    super.key,
    this.mapOfWorry,
    this.derivedFrom,
    this.service,
  });

  final MapOfWorry? mapOfWorry;
  final MapOfWorry? derivedFrom;
  final RecordService? service;

  @override
  State<EditMapPage> createState() => _EditMapPageState();
}

class _EditMapPageState extends State<EditMapPage> {
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _thoughtsController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _sensationsController = TextEditingController();
  final TextEditingController _behaviourController = TextEditingController();

  DateTime? _occurredAt;
  bool _saving = false;
  String? _eventError;

  bool get _isEditing => widget.mapOfWorry != null;

  @override
  void initState() {
    super.initState();
    final mapOfWorry = widget.mapOfWorry;
    if (mapOfWorry != null) {
      _eventController.text = mapOfWorry.event;
      _thoughtsController.text = mapOfWorry.thoughts;
      _meaningController.text = mapOfWorry.whatTheseThoughtsMean;
      _sensationsController.text = mapOfWorry.physicalSensations;
      _behaviourController.text = mapOfWorry.resultantBehaviour;
      if (mapOfWorry.hasOccurredAt()) {
        _occurredAt = mapOfWorry.occurredAt.toDateTime().toLocal();
      }
    } else if (widget.derivedFrom != null) {
      // An alternative is a rereading of the same event, so the event carries
      // over. Everything else is deliberately left blank: copying the original
      // thoughts would defeat the purpose.
      _eventController.text = widget.derivedFrom!.event;
      if (widget.derivedFrom!.hasOccurredAt()) {
        _occurredAt = widget.derivedFrom!.occurredAt.toDateTime().toLocal();
      }
    }
  }

  @override
  void dispose() {
    _eventController.dispose();
    _thoughtsController.dispose();
    _meaningController.dispose();
    _sensationsController.dispose();
    _behaviourController.dispose();
    super.dispose();
  }

  Future<RecordService> _service() async =>
      widget.service ?? await BackendConfig.buildService();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt ?? now,
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
        final request = UpdateMapOfWorryRequest()
          ..id = widget.mapOfWorry!.id
          ..event = _eventController.text
          ..thoughts = _thoughtsController.text
          ..whatTheseThoughtsMean = _meaningController.text
          ..physicalSensations = _sensationsController.text
          ..resultantBehaviour = _behaviourController.text;
        if (_occurredAt != null) {
          request.occurredAt = Timestamp.fromDateTime(_occurredAt!.toUtc());
        }
        await service.updateMapOfWorry(request);
      } else {
        final request = CreateMapOfWorryRequest()
          ..event = _eventController.text
          ..thoughts = _thoughtsController.text
          ..whatTheseThoughtsMean = _meaningController.text
          ..physicalSensations = _sensationsController.text
          ..resultantBehaviour = _behaviourController.text;
        if (_occurredAt != null) {
          request.occurredAt = Timestamp.fromDateTime(_occurredAt!.toUtc());
        }
        if (widget.derivedFrom != null) {
          request.derivedFromId = widget.derivedFrom!.id;
        }
        await service.createMapOfWorry(request);
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
    final origin = widget.derivedFrom;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editMapOfWorry : l10n.newMapOfWorry),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (origin != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.theMapThisReworks,
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 8),
                    if (origin.thoughts.isNotEmpty) Text(origin.thoughts),
                    if (origin.resultantBehaviour.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(origin.resultantBehaviour),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _field(_eventController, l10n.fieldEvent,
              hint: l10n.fieldEventHint, error: _eventError),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.fieldWhen),
            subtitle: Text(_occurredAt == null
                ? l10n.fieldWhenUnset
                : format.format(_occurredAt!)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          // The fields follow the chain the exercise traces, in order, so the
          // form reads the way the method is taught.
          _field(_thoughtsController, l10n.fieldThoughts),
          _field(_meaningController, l10n.fieldMeaning),
          _field(_sensationsController, l10n.fieldSensations),
          _field(_behaviourController, l10n.fieldBehaviour),
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
    String? hint,
    String? error,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: error,
            border: const OutlineInputBorder(),
          ),
        ),
      );
}
