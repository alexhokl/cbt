import 'package:flutter/material.dart';
import 'package:flutter_helper/format.dart';

import '../l10n/app_localizations.dart';
import '../proto/record.pb.dart';
import '../services/record_service.dart';
import 'challenge_page.dart';
import 'data_log_detail_page.dart';
import 'edit_data_log_page.dart';
import 'edit_experiment_page.dart';
import 'edit_map_page.dart';
import 'edit_record_page.dart';
import 'experiment_detail_page.dart';
import 'map_detail_page.dart';
import 'record_detail_page.dart';
import 'settings_page.dart';

/// Which listing is showing. The unchallenged tab is the day's work queue,
/// which is the reason the list is tabbed at all rather than one flat feed.
enum RecordView { toChallenge, challenged, maps, experiments, dataLogs }

class RecordList extends StatefulWidget {
  const RecordList({super.key, this.service});

  /// An injected service, used by the tests. Production builds leave this null
  /// and the state builds one from the stored settings.
  final RecordService? service;

  @override
  State<RecordList> createState() => RecordListState();
}

class RecordListState extends State<RecordList> {
  RecordView _view = RecordView.toChallenge;
  List<ThoughtRecord> _records = <ThoughtRecord>[];
  List<MapOfWorry> _maps = <MapOfWorry>[];
  List<BehaviouralExperiment> _experiments = <BehaviouralExperiment>[];
  List<PositiveDataLog> _dataLogs = <PositiveDataLog>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    load();
  }

  void selectView(RecordView view) {
    setState(() => _view = view);
    load();
  }

  Future<RecordService> _service() async =>
      widget.service ?? await BackendConfig.buildService();

  Future<void> load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = await _service();
      if (_view == RecordView.maps) {
        final maps = await service.listMapsOfWorry();
        if (!mounted) return;
        setState(() {
          _maps = maps;
          _loading = false;
        });
        return;
      }
      if (_view == RecordView.experiments) {
        final experiments = await service.listBehaviouralExperiments();
        if (!mounted) return;
        setState(() {
          _experiments = experiments;
          _loading = false;
        });
        return;
      }
      if (_view == RecordView.dataLogs) {
        final dataLogs = await service.listPositiveDataLogs();
        if (!mounted) return;
        setState(() {
          _dataLogs = dataLogs;
          _loading = false;
        });
        return;
      }

      final records = await service.listThoughtRecords(
        challenged: _view == RecordView.challenged,
      );
      if (!mounted) return;
      setState(() {
        _records = records;
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

  Future<void> _create() async {
    final Widget page = switch (_view) {
      RecordView.maps => EditMapPage(service: widget.service),
      RecordView.experiments => EditExperimentPage(service: widget.service),
      RecordView.dataLogs => EditDataLogPage(service: widget.service),
      _ => EditRecordPage(service: widget.service),
    };
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => page));
    await load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'settings') {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
                await load();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'settings',
                child: Text(l10n.menuSettings),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Five segments do not fit every phone width, so the row scrolls
          // rather than squeezing the labels.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<RecordView>(
              segments: [
                ButtonSegment(
                  value: RecordView.toChallenge,
                  label: Text(l10n.tabToChallenge),
                ),
                ButtonSegment(
                  value: RecordView.challenged,
                  label: Text(l10n.tabChallenged),
                ),
                ButtonSegment(
                  value: RecordView.maps,
                  label: Text(l10n.tabMaps),
                ),
                ButtonSegment(
                  value: RecordView.experiments,
                  label: Text(l10n.tabExperiments),
                ),
                ButtonSegment(
                  value: RecordView.dataLogs,
                  label: Text(l10n.tabDataLogs),
                ),
              ],
              selected: <RecordView>{_view},
              onSelectionChanged: (selection) => selectView(selection.first),
            ),
          ),
          Expanded(child: _buildBody(l10n)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        child: const Icon(Icons.add),
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
            FilledButton(onPressed: load, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    if (_view == RecordView.maps) {
      if (_maps.isEmpty) {
        return _emptyState(l10n.emptyMaps);
      }
      return RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          itemCount: _maps.length,
          itemBuilder: (context, index) => _mapTile(_maps[index]),
        ),
      );
    }

    if (_view == RecordView.experiments) {
      if (_experiments.isEmpty) {
        return _emptyState(l10n.emptyExperiments);
      }
      return RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          itemCount: _experiments.length,
          itemBuilder: (context, index) =>
              _experimentTile(_experiments[index], l10n),
        ),
      );
    }

    if (_view == RecordView.dataLogs) {
      if (_dataLogs.isEmpty) {
        return _emptyState(l10n.emptyDataLogs);
      }
      return RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          itemCount: _dataLogs.length,
          itemBuilder: (context, index) => _dataLogTile(_dataLogs[index], l10n),
        ),
      );
    }

    if (_records.isEmpty) {
      return _emptyState(
        _view == RecordView.toChallenge
            ? l10n.emptyToChallenge
            : l10n.emptyChallenged,
      );
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) => _recordTile(_records[index], l10n),
      ),
    );
  }

  Widget _emptyState(String message) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    ),
  );

  Widget _recordTile(ThoughtRecord record, AppLocalizations l10n) {
    return ListTile(
      title: Text(record.event, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${formatEventDate(record.hasOccurredAt() ? record.occurredAt.toDateTime() : null, record.createdAt.toDateTime())}'
        '${strongestFeeling(record.feelings) == null ? '' : '  ·  ${strongestFeeling(record.feelings)}'}',
      ),
      trailing: record.hasChallengedAt()
          ? null
          // The queue exists to be worked through, so the action to do that is
          // one tap away from the listing rather than buried in the detail.
          : IconButton(
              icon: const Icon(Icons.psychology_outlined),
              tooltip: l10n.challenge,
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) =>
                        ChallengePage(record: record, service: widget.service),
                  ),
                );
                await load();
              },
            ),
      onTap: () async {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) =>
                RecordDetailPage(recordId: record.id, service: widget.service),
          ),
        );
        await load();
      },
    );
  }

  Widget _mapTile(MapOfWorry mapOfWorry) {
    return ListTile(
      title: Text(
        mapOfWorry.event,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        formatEventDate(
          mapOfWorry.hasOccurredAt()
              ? mapOfWorry.occurredAt.toDateTime()
              : null,
          mapOfWorry.createdAt.toDateTime(),
        ),
      ),
      leading: mapOfWorry.hasDerivedFromId()
          ? const Icon(Icons.alt_route)
          : const Icon(Icons.account_tree_outlined),
      onTap: () async {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) =>
                MapDetailPage(mapId: mapOfWorry.id, service: widget.service),
          ),
        );
        await load();
      },
    );
  }

  Widget _experimentTile(
    BehaviouralExperiment experiment,
    AppLocalizations l10n,
  ) {
    return ListTile(
      title: Text(
        experiment.plan,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${formatEventDate(experiment.hasOccurredAt() ? experiment.occurredAt.toDateTime() : null, experiment.createdAt.toDateTime())}'
        '  ·  ${experiment.hasCompletedAt() ? l10n.completedOn(formatDate(experiment.completedAt.toDateTime().toLocal())) : l10n.notYetCompleted}',
      ),
      leading: Icon(
        experiment.hasCompletedAt()
            ? Icons.fact_check_outlined
            : Icons.science_outlined,
      ),
      onTap: () async {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ExperimentDetailPage(
              experimentId: experiment.id,
              service: widget.service,
            ),
          ),
        );
        await load();
      },
    );
  }

  Widget _dataLogTile(PositiveDataLog log, AppLocalizations l10n) {
    return ListTile(
      title: Text(log.belief, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (log.ratings.isNotEmpty) beliefRatingLabel(log.ratings.last, l10n),
          l10n.evidenceCount(log.evidence.length),
        ].join('  ·  '),
      ),
      leading: const Icon(Icons.playlist_add_check),
      onTap: () async {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) =>
                DataLogDetailPage(logId: log.id, service: widget.service),
          ),
        );
        await load();
      },
    );
  }
}

/// Renders when an event happened, falling back to when it was written. The
/// fallback is marked so the two are never confused: a record typed days later
/// would otherwise look like it happened that day.
String formatEventDate(DateTime? occurredAt, DateTime createdAt) {
  if (occurredAt != null) {
    return formatDate(occurredAt.toLocal());
  }
  return '~${formatDate(createdAt.toLocal())}';
}

/// Renders the highest rated feeling, which is the one worth showing when only
/// one fits. An unrated feeling never outranks a rated one: a rating is a
/// judgement the user made, and an absent one is not a zero.
String? strongestFeeling(List<Feeling> feelings) {
  if (feelings.isEmpty) {
    return null;
  }

  final sorted = List<Feeling>.from(feelings)
    ..sort((a, b) {
      if (a.hasIntensityBefore() != b.hasIntensityBefore()) {
        return a.hasIntensityBefore() ? -1 : 1;
      }
      if (!a.hasIntensityBefore()) {
        return 0;
      }
      return b.intensityBefore.compareTo(a.intensityBefore);
    });

  final strongest = sorted.first;
  final suffix = sorted.length > 1 ? ' +${sorted.length - 1}' : '';
  if (!strongest.hasIntensityBefore()) {
    return '${strongest.name}$suffix';
  }
  return '${strongest.name} ${strongest.intensityBefore}%$suffix';
}
