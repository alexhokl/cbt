import 'package:flutter/material.dart';
import 'package:flutter_helper/ui.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'edit_formulation_page.dart';
import 'record_detail_page.dart';
import 'settings_page.dart';

/// FormulationDetailPage shows a formulation in the order of its columns, from
/// the early life experiences down to the behaviours maintaining the problem.
///
/// Empty columns are omitted: a formulation in progress reads as what has been
/// written, not as a form with blanks in it.
class FormulationDetailPage extends StatefulWidget {
  const FormulationDetailPage({
    super.key,
    required this.formulationId,
    this.service,
  });

  final int formulationId;
  final RecordService? service;

  @override
  State<FormulationDetailPage> createState() => _FormulationDetailPageState();
}

class _FormulationDetailPageState extends State<FormulationDetailPage> {
  Formulation? _formulation;
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
      final formulation = await service.getFormulation(widget.formulationId);
      if (!mounted) return;
      setState(() {
        _formulation = formulation;
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
      await service.deleteFormulation(widget.formulationId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on RecordException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _edit(Formulation formulation) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => EditFormulationPage(
          formulation: formulation,
          service: widget.service,
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formulation = _formulation;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (formulation != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(formulation),
            ),
          if (formulation != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: _buildBody(l10n),
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

    final formulation = _formulation!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (label, value) in formulationColumns(l10n))
          RecordField(label: label, value: value(formulation)),
      ],
    );
  }
}

/// The column that stands for a formulation in a listing: its beliefs where
/// written, otherwise its first written column.
String formulationSummary(Formulation formulation, AppLocalizations l10n) {
  if (formulation.beliefs.trim().isNotEmpty) {
    return formulation.beliefs;
  }
  for (final (_, value) in formulationColumns(l10n)) {
    if (value(formulation).trim().isNotEmpty) {
      return value(formulation);
    }
  }
  return '';
}
