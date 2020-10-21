import 'package:rxdart/rxdart.dart';

import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:kres_requests2/repo/models/request_wrapper.dart';

class DocumentRepository {
  final _requestsSubject =
  BehaviorSubject<Map<Worksheet, List<RequestWrapper>>>();

  /// Closes an internal stream
  void close() => _requestsSubject.close();

  /// Currently editing document
  final Document document;

  /// Current working directory
  String currentDirectory;

  /// A set containing selected requests
  final Set<RequestEntity> _selectionList = {};

  /// Returns count of currently selected requests
  int get selectedCount => _selectionList.length;

  /// Selects all requests on active worksheet
  /// If [group] passed all requests with [group] will be selected and previous
  /// selection resets.
  /// If [group] omitted all whole active worksheet will be selected.
  void selectAllActive({int group}) =>
      _rebuildRequests(() {
        if (group == null) {
          _selectionList.addAll(document.active.requests);
        } else {
          _selectionList.clear();
          _selectionList.addAll(_getAllActiveByGroup(group));
        }
      });

  /// Clears currently selected list
  void clearSelection({bool updateState = true}) =>
      updateState
          ? _rebuildRequests(() => _selectionList.clear())
          : _selectionList.clear();

  /// Selects an item by given [wrapper]
  void setSelected(RequestWrapper wrapper, bool isSelected) =>
      _rebuildRequests(() {
        if (isSelected) {
          _selectionList.add(wrapper.request);
        } else {
          _selectionList.remove(wrapper.request);
        }
      });

  /// Returns selected requests at active worksheet
  List<RequestEntity> get activeSelected =>
      _currentRequests[document.active]
          .where((r) => r.isSelected)
          .map((e) => e.request)
          .toList();

  /// Sets current group attachment of the request [wrapper]
  void setGroup(RequestWrapper wrapper, int group) =>
      _rebuildRequests(() {
        _lastGroupIndex = group;
        if (group > 0) {
          _groupList[wrapper.request] = group;
        } else
          _groupList.remove(wrapper.request);
      });

  /// Map containing all requests attached to non zero group
  final Map<RequestEntity, int> _groupList = {};

  /// Returns index of group that is in selection.
  /// All selected groups should belong to one group type and located at active
  /// worksheet. In other case `null` will returned.
  int get activeSingleSelectedGroup {
    if (_groupList.isEmpty || _selectionList.isEmpty) return null;

    final filtered = _selectionList
        .where((e) => document.active.requests.contains(e))
        .map((e) => _groupList[e])
        .where((e) => e != null)
        .toSet();

    return filtered.length == 1 ? filtered.single : null;
  }

  /// Returns all requests on active worksheet marked by [group]
  Set<RequestEntity> _getAllActiveByGroup(int group) {
    if (_groupList.isEmpty) return {};

    return _groupList.entries
        .where(
          (e) => e.value == group && document.active.requests.contains(e.key),
    )
        .map((e) => e.key)
        .toSet();
  }

  /// The last chosen group index
  int _lastGroupIndex = 0;

  // Returns last chosen group index
  int get lastGroupIndex => _lastGroupIndex;

  /// Map containing currently highlighted elements
  Map<Worksheet, List<RequestEntity>> _highlighted = {};

  /// Clears all flags (group index, selection) on [requests]
  void clearDecoration(List<RequestEntity> requests) =>
      _rebuildRequests(() => _clearDecoration(requests));

  void _clearDecoration(List<RequestEntity> requests) {
    _selectionList.removeAll(requests);
    for (final request in requests)
      _groupList.remove(request);
  }

  /// Replaces request on active worksheet [toRemove] to [toInsertAfter]
  void replaceActive(RequestWrapper toRemove, RequestWrapper toInsertAfter) =>
      _rebuildRequests(() {
        final idx = document.active.requests.indexOf(toInsertAfter.request);
        document.active.requests.remove(toRemove.request);
        document.active.requests.insert(idx, toRemove.request);
      });

  /// Adds new [request] to the document
  void addRequestToActive(RequestEntity request) =>
      _rebuildRequests(() => document.active.requests.add(request));

  /// Replaces [old] request with new [request] only on active request
  void setActiveRequest(RequestWrapper old, RequestEntity request) =>
      _rebuildRequests(() {
        // If previous value was selected then update
        // selection references
        if (_selectionList.contains(old)) {
          _selectionList
            ..remove(old)
            ..add(request);
        }
        final oldGroup = _groupList[old];
        if (oldGroup != null) {
          _groupList.remove(old);
          _groupList[request] = oldGroup;
        }

        final requests = document.active.requests;
        final oldIdx = requests.indexOf(old.request);
        requests[oldIdx] = request;
      });

  /// Removes all [removing] requests from active worksheet
  void removeActiveRequests(List<RequestEntity> removing) =>
      _rebuildRequests(() {
        _clearDecoration(removing);
        for (final request in removing) {
          document.active.requests.remove(request);
        }
      });

  /// Adds an empty worksheet to the document
  void addEmptyWorksheet() =>
      _rebuildRequests(() {
        document.active = document.addEmptyWorksheet();
      });

  /// Removes [worksheet] from document
  void removeWorksheet(Worksheet worksheet) =>
      _rebuildRequests(() {
        document.removeWorksheet(worksheet);
      });

  /// Sets the active worksheet in the document
  set active(Worksheet worksheet) =>
      _rebuildRequests(() {
        document.active = worksheet;
      });

  /// Saves the document to current document save path
  Future save() => document.save();

  /// Sets the current document save path
  set documentSavePath(String savePath) {
    document.savePath =
    path.extension(savePath) != '.json'
        ? File('$savePath.json')
        : File(savePath);
  }

  /// Rebuild requests cache in emits it to the stream
  void rebuildRequests() => _rebuildRequests(() {});

  Map<Worksheet, List<RequestWrapper>> _currentRequests = {};

  /// Returns a stream containing actual requests on document
  Stream<Map<Worksheet, List<RequestWrapper>>> get requests =>
      _requestsSubject.stream;

  /// Returns a stream containing actual requests on *active* worksheet
  Stream<List<RequestWrapper>> get activeRequests =>
      requests.map((entry) => entry[document.active]);

  /// Sets current filter
  /// If [searchText] is `null` filter resets
  void setFilter(String searchText) =>
      _rebuildRequests(() {
        if (searchText == null || searchText.isEmpty) {
          _highlighted = <Worksheet, List<RequestEntity>>{};
          return;
        }

        searchText = searchText.toLowerCase();
        _highlighted = Map.fromIterable(document.worksheets,
            key: (worksheet) => worksheet,
            value: (worksheet) =>
                worksheet.requests.where((RequestEntity request) {
                  return (request.accountId?.toString()?.padLeft(6, '0') ?? '')
                      .contains(searchText) ||
                      request.name.toLowerCase().contains(searchText) ||
                      request.address.toLowerCase().contains(searchText) ||
                      request.counterInfo.toLowerCase().contains(searchText) ||
                      request.additionalInfo.toLowerCase().contains(searchText);
                }).toList());
      });

  void _rebuildRequests(void Function() closure) {
    closure();
    _buildRequestsList();
  }

  void _buildRequestsList() {
    _currentRequests = Map.fromIterable(document.worksheets,
        key: (worksheet) => worksheet,
        value: (worksheet) =>
        _buildRequestsList0(worksheet).toList()
          ..sort((a, b) {
            if (a.isHighlighted) return -1;
            if (b.isHighlighted) return 1;
            return 0;
          }));
    _requestsSubject.add(_currentRequests);
  }

  Iterable<RequestWrapper> _buildRequestsList0(Worksheet worksheet) sync* {
    for (final request in worksheet.requests) {
      yield RequestWrapper(
        request: request,
        isSelected: _selectionList.contains(request),
        isHighlighted: _highlighted[worksheet]?.contains(request) ?? false,
        groupIndex: _groupList[request] ?? 0,
      );
    }
  }

  DocumentRepository(this.document) : assert(document != null) {
    // When we got first subscriber send latest event to it
    _buildRequestsList();
  }
}
