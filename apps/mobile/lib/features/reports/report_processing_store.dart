import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/api_client.dart';

/// One foreground stream per signed-in app. Every reconnect uses a fresh
/// authorized snapshot; cursors and report state never persist across accounts.
class ReportProcessingStore extends ChangeNotifier {
  static final instance = ReportProcessingStore();
  ApiClient? _api;
  http.Client? _transport;
  Timer? _retry;
  int _epoch = 0;
  int _attempt = 0;
  bool _running = false;
  String connection = 'offline';
  final Map<String, Map<String, dynamic>> reports = {};
  int get readyCount => reports.values
      .where((r) => r['status'] == 'ready' && r['acknowledgedAt'] == null)
      .length;

  void start(ApiClient api) {
    if (_running) return;
    if (api.accessToken == null) return;
    reports.clear();
    _api = api;
    _running = true;
    _attempt = 0;
    unawaited(_connect(++_epoch));
  }

  void stop() {
    _running = false;
    _epoch++;
    _retry?.cancel();
    _transport?.close();
    reports.clear();
    connection = 'offline';
    notifyListeners();
  }

  void reconcile() {
    final api = _api;
    if (!_running || api == null) return;
    stop();
    start(api);
  }

  Future<void> acknowledge(String id) async {
    final api = _api;
    if (api == null) throw StateError('Not signed in');
    final epoch = _epoch;
    await api.post('v1/reports/processing/$id/acknowledge');
    if (epoch != _epoch) return;
    if (reports[id] == null && _running) {
      reconcile();
      return;
    }
    if (reports[id] != null) {
      reports[id]!['acknowledgedAt'] = DateTime.now().toIso8601String();
    }
    notifyListeners();
  }

  Future<void> _connect(int epoch) async {
    if (!_running || epoch != _epoch) return;
    final api = _api!;
    final transport = http.Client();
    _transport = transport;
    connection = 'connecting';
    notifyListeners();
    try {
      final snapshot = await api.get('v1/reports/processing/snapshot');
      if (epoch != _epoch) return;
      final data = snapshot['data'] as Map<String, dynamic>;
      reports.clear();
      for (final raw in data['reports'] as List) {
        final row = Map<String, dynamic>.from(raw as Map);
        reports[row['reportId'] as String] = row;
      }
      notifyListeners();
      final response = await api.openReportEvents(
        transport,
        data['cursor'] as String,
      );
      if (epoch != _epoch) return;
      connection = 'connected';
      _attempt = 0;
      notifyListeners();
      String event = '';
      final lines = <String>[];
      int size = 0;
      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .timeout(const Duration(seconds: 40))) {
        if (epoch != _epoch) return;
        size += line.length;
        if (size > 1024 * 1024) {
          throw const FormatException('SSE buffer exceeded');
        }
        if (line.isEmpty) {
          if (event == 'report.reset') {
            throw const FormatException('Reset required');
          }
          if (event == 'report.status_changed' && lines.isNotEmpty) {
            final row = Map<String, dynamic>.from(
              jsonDecode(lines.join('\n')) as Map,
            );
            final id = row['reportId'] as String;
            final version = BigInt.parse(row['version'] as String);
            final previous = reports[id];
            final old = previous == null
                ? null
                : BigInt.parse(previous['version'] as String);
            if (old != null && version > old + BigInt.one) {
              throw const FormatException('Version gap');
            }
            if (old == null || version > old) {
              reports[id] = {...?previous, ...row};
              notifyListeners();
            }
          }
          event = '';
          lines.clear();
          size = 0;
        } else if (line.startsWith('event:')) {
          event = line.substring(6).trimLeft();
        } else if (line.startsWith('data:')) {
          lines.add(line.substring(5).replaceFirst(RegExp(r'^ '), ''));
        }
      }
    } on ApiException catch (error) {
      if ([
        'REPORT_ASYNC_DISABLED',
        'AUTH_UNAUTHORIZED',
        'ACCOUNT_SUSPENDED',
      ].contains(error.code)) {
        if (epoch == _epoch) {
          reports.clear();
          connection = 'disabled';
          _running = false;
          notifyListeners();
        }
        return;
      }
    } catch (_) {
      /* Network interruption: snapshot on reconnect. */
    } finally {
      transport.close();
    }
    if (epoch != _epoch || !_running) return;
    connection = 'reconnecting';
    notifyListeners();
    final delay =
        (min(30000, 1000 * pow(2, min(_attempt++, 5))) *
                (0.5 + Random().nextDouble() / 2))
            .toInt();
    _retry = Timer(
      Duration(milliseconds: delay),
      () => unawaited(_connect(epoch)),
    );
  }
}
