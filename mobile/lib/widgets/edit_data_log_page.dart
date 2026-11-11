import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'settings_page.dart';

/// EditDataLogPage creates a positive data log, or rewords the beliefs of one
/// that already exists.
///
/// Creating a log asks for both beliefs, how strongly each is believed, and
/// any evidence already to hand. Editing changes only the wording: ratings
/// are added from the detail page so the earlier ones are kept, and evidence
/// is added there one row at a time.
class EditDataLogPage extends StatefulWidget {
  const EditDataLogPage({super.key, this.log, this.service});

  final PositiveDataLog? log;
  final RecordService? service;

  @override
  State<EditDataLogPage> createState() => _EditDataLogPageState();
}

class _EditDataLogPageState extends State<EditDataLogPage> {
  final TextEditingController _beliefController = TextEditingController();
  final TextEditingController _alternativeController = TextEditingController();
  final List<TextEditingController> _evidence = <TextEditingController>[];

  // A rating stays null until its slider is moved, so a belief the user did
  // not rate is never sent as zero.
  int? _beliefPercent;
  int? _alternativePercent;
  bool _saving = false;
  String? _beliefError;

  bool get _isEditing => widget.log != null;

  @override
  void initState() {
    super.initState();
    final log = widget.log;
    if (log != null) {
      _beliefController.text = log.belief;
      _alternativeController.text = log.alternativeBelief;
    }
  }

  @override
  void dispose() {
    _beliefController.dispose();
    _alternativeController.dispose();
    for (final controller in _evidence) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<RecordService> _service() async =>
      widget.service ?? await BackendConfig.buildService();

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_beliefController.text.trim().isEmpty) {
      setState(() => _beliefError = l10n.beliefRequired);
      return;
    }

    setState(() {
      _saving = true;
      _beliefError = null;
    });

    try {
      final service = await _service();
      if (_isEditing) {
        await service.updatePositiveDataLog(
          UpdatePositiveDataLogRequest()
            ..id = widget.log!.id
            ..belief = _beliefController.text
            ..alternativeBelief = _alternativeController.text,
        );
      } else {
        final request = CreatePositiveDataLogRequest()
          ..belief = _beliefController.text
          ..alternativeBelief = _alternativeController.text;
        if (_beliefPercent != null) {
          request.beliefPercent = _beliefPercent!;
        }
        if (_alternativePercent != null) {
          request.alternativePercent = _alternativePercent!;
        }
        for (final controller in _evidence) {
          if (controller.text.trim().isEmpty) {
            continue;
          }
          request.evidence.add(DataLogEvidenceInput()..body = controller.text);
        }
        await service.createPositiveDataLog(request);
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
        title: Text(_isEditing ? l10n.editDataLog : l10n.newDataLog),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // The fields follow the columns of the log, in order: each belief
          // is followed by how strongly it is believed.
          _field(
            _beliefController,
            l10n.fieldBelief,
            key: const Key('belief'),
            error: _beliefError,
          ),
          if (!_isEditing)
            PercentSlider(
              key: const Key('believeBelief'),
              label: l10n.fieldBelieveBelief,
              value: _beliefPercent,
              onChanged: (value) => setState(() => _beliefPercent = value),
            ),
          _field(
            _alternativeController,
            l10n.fieldAlternativeBelief,
            key: const Key('alternativeBelief'),
          ),
          if (!_isEditing) ...[
            PercentSlider(
              key: const Key('believeAlternative'),
              label: l10n.fieldBelieveAlternative,
              value: _alternativePercent,
              onChanged: (value) => setState(() => _alternativePercent = value),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.fieldDataLogEvidence,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < _evidence.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: Key('evidence-$index'),
                        controller: _evidence[index],
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          setState(() => _evidence.removeAt(index).dispose()),
                    ),
                  ],
                ),
              ),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _evidence.add(TextEditingController())),
              icon: const Icon(Icons.add),
              label: Text(l10n.addEvidence),
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

/// PercentSlider rates a belief from 0 to 100. The value is null until the
/// slider is first moved and is shown as not rated, because an absent rating
/// is not a zero.
class PercentSlider extends StatelessWidget {
  const PercentSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(value == null ? l10n.feelingUnrated : '$value%'),
          ],
        ),
        Slider(
          value: (value ?? 0).toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          label: '${value ?? 0}%',
          onChanged: (changed) => onChanged(changed.round()),
        ),
      ],
    );
  }
}
