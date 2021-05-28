part of 'worksheet_editor_bloc.dart';

/// Base state for [WorksheetEditorBloc]
@sealed
abstract class WorksheetEditorState extends Equatable {
  const WorksheetEditorState._();
}

/// Initial state used before worksheet data is ready
class WorksheetInitialState extends WorksheetEditorState {
  const WorksheetInitialState() : super._();

  @override
  List<Object?> get props => [];
}

/// State used to show the worksheet data
class WorksheetDataState extends WorksheetEditorState {
  /// A list of request entities
  final List<RequestEntity> requests;

  final Map<RequestEntity, int> groupList;

  /// Index of the last used group
  final int lastGroupIndex;

  /// Returns `true` if worksheet has no requests
  bool get isEmpty => requests.isEmpty;

  /// Current worksheet
  final Worksheet worksheet;

  /// Current document
  final Document document;

  const WorksheetDataState({
    required this.document,
    required this.requests,
    required this.worksheet,
    this.groupList = const {},
    this.lastGroupIndex = 0,
  }) : super._();

  /// Filers requests related to a one group
  Set<RequestEntity> getAllByGroup(int group) {
    if (groupList.isEmpty) return {};

    return groupList.entries
        .where((e) => e.value == group)
        .map((e) => e.key)
        .toSet();
  }

  @override
  List<Object?> get props => [groupList, requests, worksheet, document];

  /// Returns index of group associated with the [request]
  int getGroup(RequestEntity request) {
    return groupList.isNotEmpty ? groupList[request] ?? 0 : 0;
  }

  /// Returns `true` if [request] is highlighted
  bool getIsHighlighted(RequestEntity request) {
    // TODO: Implement highlighting
    // highlighted != null &&
    //     highlighted!.contains(request),
    return false;
  }

  /// Creates a deep copy with customizable params
  WorksheetDataState copyWith({
    List<RequestEntity>? requests,
    Map<RequestEntity, int>? groupList,
    int? lastGroupIndex,
    Worksheet? worksheet,
    Document? document,
  }) =>
      WorksheetDataState(
        document: document ?? this.document,
        worksheet: worksheet ?? this.worksheet,
        requests: requests ?? this.requests,
        groupList: groupList ?? this.groupList,
        lastGroupIndex: lastGroupIndex ?? this.lastGroupIndex,
      );
}

/// State used when selection mode is on
class WorksheetSelectionState extends WorksheetDataState {
  /// Set of the all checked requests
  final Set<RequestEntity> selectionList;

  /// Returns count of selected requests
  int get selectedCount => selectionList.fold(0, (prev, val) => prev + 1);

  /// Returns index of the group if all selected items belongs to one group
  int get singleGroupIndex {
    if (groupList.isEmpty) {
      return 0;
    }

    final filtered = selectionList
        .map((e) => groupList[e])
        .where((e) => e != null)
        .cast<int>()
        .toSet();

    return filtered.length == 1 ? filtered.single : 0;
  }

  /// Creates selection state based on [WorksheetDataState]
  WorksheetSelectionState(this.selectionList, WorksheetDataState baseState)
      : super(
          requests: baseState.requests,
          groupList: baseState.groupList,
          lastGroupIndex: baseState.lastGroupIndex,
          worksheet: baseState.worksheet,
          document: baseState.document,
        );

  @override
  List<Object?> get props => [selectionList, ...super.props];

  /// Returns `true` if the [request] is in selection
  bool getIsSelected(RequestEntity request) => selectionList.contains(request);
}
