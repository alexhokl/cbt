import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'edit_map_page.dart';
import 'record_detail_page.dart';
import 'settings_page.dart';

/// MapDetailPage shows a map of worry alongside the maps it should be read
/// against.
///
/// The contrast between two readings of the same event is the therapeutic
/// payload of the exercise, so the alternatives are shown here rather than
/// left to a separate screen the user has to think to open.
class MapDetailPage extends StatefulWidget {
  const MapDetailPage({super.key, required this.mapId, this.service});

  final int mapId;
  final RecordService? service;

  @override
  State<MapDetailPage> createState() => _MapDetailPageState();
}

class _MapDetailPageState extends State<MapDetailPage> {
  GetMapOfWorryResponse? _response;
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
      final response = await service.getMapOfWorry(widget.mapId);
      if (!mounted) return;
      setState(() {
        _response = response;
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecordTitle),
        content: Text(l10n.deleteRecordBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final service = await _service();
      await service.deleteMapOfWorry(widget.mapId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on RecordException catch (error) {
      if (!mounted) return;
      // A map that has been reworked cannot be deleted while its alternatives
      // remain; the server says so and the message is shown as it is.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final response = _response;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (response != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => EditMapPage(
                      mapOfWorry: response.map,
                      service: widget.service,
                    ),
                  ),
                );
                await _load();
              },
            ),
          if (response != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: _buildBody(l10n),
      floatingActionButton: response == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => EditMapPage(
                      derivedFrom: response.map,
                      service: widget.service,
                    ),
                  ),
                );
                await _load();
              },
              icon: const Icon(Icons.alt_route),
              label: Text(l10n.createAlternative),
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

    final response = _response!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (response.hasDerivedFrom()) ...[
          _contrastHeader(l10n.theMapThisReworks),
          _mapBody(response.derivedFrom, l10n),
          const Divider(height: 32),
        ],
        _mapBody(response.map, l10n),
        for (final alternative in response.alternatives) ...[
          const Divider(height: 32),
          _contrastHeader(l10n.alternativeReading),
          _mapBody(alternative, l10n),
        ],
      ],
    );
  }

  Widget _contrastHeader(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge),
      );

  Widget _mapBody(MapOfWorry mapOfWorry, AppLocalizations l10n) {
    final format = DateFormat.yMMMd();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecordField(
          label: l10n.fieldWhen,
          value: mapOfWorry.hasOccurredAt()
              ? format.format(mapOfWorry.occurredAt.toDateTime().toLocal())
              : l10n.fieldWhenWritten(
                  format.format(mapOfWorry.createdAt.toDateTime().toLocal()),
                ),
        ),
        RecordField(label: l10n.fieldEvent, value: mapOfWorry.event),
        RecordField(label: l10n.fieldThoughts, value: mapOfWorry.thoughts),
        RecordField(
          label: l10n.fieldMeaning,
          value: mapOfWorry.whatTheseThoughtsMean,
        ),
        RecordField(
          label: l10n.fieldSensations,
          value: mapOfWorry.physicalSensations,
        ),
        if (mapOfWorry.feelings.isNotEmpty) ...[
          Text(l10n.fieldFeelings,
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          for (final feeling in mapOfWorry.feelings)
            Text(
              feeling.hasIntensityBefore()
                  ? '${feeling.name} ${feeling.intensityBefore}%'
                  : feeling.name,
            ),
          const SizedBox(height: 16),
        ],
        RecordField(
          label: l10n.fieldBehaviour,
          value: mapOfWorry.resultantBehaviour,
        ),
      ],
    );
  }
}
