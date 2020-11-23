import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';

import 'package:kres_requests2/models/request_set.dart';
import 'package:kres_requests2/repo/request_set_repository.dart';
import 'package:kres_requests2/screens/common.dart';

class DateTreeView extends StatelessWidget {
  final RequestsSetRepository requestsSetRepository;

  const DateTreeView({
    @required this.requestsSetRepository,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        content: FutureBuilder<List<RequestSet>>(
          future: requestsSetRepository.getAllRequestSets(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildTreeView(context, snapshot.data);
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Не удалось загрузить данные');
            } else {
              return Container(
                width: 128.0,
                height: 128.0,
                child: LoadingView('Загрузка данных'),
              );
            }
          },
        ),
      );

  Widget _buildTreeView(BuildContext context, List<RequestSet> data) {
    final controller = TreeViewController(children: _buildNodes(data));
    return Container(
      width: 400.0,
      height: 600.0,
      child: TreeView(
        controller: controller,
        onNodeTap: (key) {
          Node selectedNode = controller.getNode(key);
          if (selectedNode.hasData) Navigator.pop(context, selectedNode.data);
        },
      ),
    );
  }

  List<Node> _buildNodes(List<RequestSet> data) {
    var nodes = <Node>[];

    for (final item in data) {
      final year = item.date.year.toString();
      final yearKey = '__year__:$year';
      final month = translateMonth(item.date.month);
      final monthKey = '__month__:$month';

      var yearNode =
          nodes.firstWhere((node) => node.key == yearKey, orElse: () => null);
      if (yearNode == null) {
        yearNode = Node(key: yearKey, label: year, children: []);
        nodes.add(yearNode);
      }

      var monthNode = yearNode.children
          .firstWhere((node) => node.key == monthKey, orElse: () => null);
      if (monthNode == null) {
        monthNode = Node(key: monthKey, label: month, children: []);
        yearNode.children.add(monthNode);
      }

      monthNode.children.add(Node(
        key: item.name,
        label: item.name,
        data: item,
      ));
    }

    return nodes;
  }

  static const _months = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь'
  ];

  String translateMonth(int month) {
    return _months[month - 1];
  }
}
