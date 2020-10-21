import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:kres_requests2/models/request_entity.dart';

/// Describes request item with it's additional parameters
class RequestWrapper extends Equatable {
  final RequestEntity request;
  final bool isHighlighted;
  final bool isSelected;
  final int groupIndex;

  const RequestWrapper({
    @required this.request,
    @required this.isHighlighted,
    @required this.isSelected,
    @required this.groupIndex,
  })  : assert(request != null),
        assert(isHighlighted != null),
        assert(isSelected != null),
        assert(groupIndex != null);

  @override
  List<Object> get props => [request, isHighlighted, isSelected, groupIndex];

  RequestWrapper copy({
    RequestEntity request,
    bool isHighlighted,
    bool isSelected,
    int groupIndex,
  }) =>
      RequestWrapper(
        request: request ?? this.request,
        isHighlighted: isHighlighted ?? this.isHighlighted,
        isSelected: isSelected ?? this.isSelected,
        groupIndex: groupIndex ?? this.groupIndex,
      );
}
