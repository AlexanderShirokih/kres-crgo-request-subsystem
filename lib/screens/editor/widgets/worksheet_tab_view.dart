import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/bloc/worksheets/worksheet_creation_mode.dart';
import 'package:kres_requests2/models/worksheet.dart';

/// Widget that provides way to create new worksheet of certain type
class AddNewWorkSheetTabView extends StatefulWidget {
  final void Function(WorksheetCreationMode) onAddPressed;

  const AddNewWorkSheetTabView(this.onAddPressed);

  @override
  _AddNewWorkSheetTabViewState createState() => _AddNewWorkSheetTabViewState();
}

class _AddNewWorkSheetTabViewState extends State<AddNewWorkSheetTabView> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Card(
        elevation: 5.0,
        child: _isExpanded ? _buildExpandedLayout() : _buildAddTile(),
      ),
    );
  }

  Widget _buildAddTile() => _buildItemTile(
        title: 'Добавить',
        tooltip: _isExpanded ? null : 'Добавить новый лист',
        icon: FontAwesomeIcons.plus,
      );

  Widget _buildExpandedLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddTile(),
          _buildItemTile(
            title: 'Пустой лист заявок',
            tooltip: 'Добавить пустой лист для создания заявок',
            icon: FontAwesomeIcons.file,
            mode: WorksheetCreationMode.empty,
          ),
          _buildItemTile(
            title: 'Импорт из другого документа',
            tooltip: 'Добавить листы из другого документа',
            icon: FontAwesomeIcons.fileImport,
            mode: WorksheetCreationMode.importNative,
          ),
          _buildItemTile(
            title: 'Импорт файла заявок',
            tooltip:
                'Создать новый лист заявок из подготовленного файла Mega-billing',
            icon: FontAwesomeIcons.fileExcel,
            mode: WorksheetCreationMode.import,
          ),
          _buildItemTile(
            title: 'Импорт списка счётчиков',
            tooltip:
                'Создать новый лист заявок из подготовленного списка счётчиков',
            icon: FontAwesomeIcons.table,
            mode: WorksheetCreationMode.importCounters,
          )
        ],
      );

  Widget _buildItemTile({
    required String title,
    String? tooltip,
    required IconData icon,
    WorksheetCreationMode? mode,
  }) {
    Widget _buildListTile() => ListTile(
          trailing: FaIcon(icon),
          title: Text(title),
          onTap: () => setState(() {
            _isExpanded = !_isExpanded;
            if (mode != null) {
              widget.onAddPressed(mode);
              _isExpanded = false;
            }
          }),
        );

    return tooltip == null
        ? _buildListTile()
        : Tooltip(
            message: tooltip,
            child: _buildListTile(),
          );
  }
}

class WorkSheetTabView extends StatefulWidget {
  final Worksheet worksheet;
  final bool isActive;
  final int filteredItemsCount;
  final void Function() onSelect;
  final void Function()? onRemove;

  const WorkSheetTabView({
    required this.filteredItemsCount,
    required this.worksheet,
    required this.isActive,
    required this.onSelect,
    required this.onRemove,
  });

  @override
  _WorkSheetTabViewState createState() => _WorkSheetTabViewState();
}

class _WorkSheetTabViewState extends State<WorkSheetTabView> {
  late TextEditingController _controller;
  bool _isEditable = false;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.worksheet.name);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: double.maxFinite,
        child: Card(
          elevation: 5.0,
          child: GestureDetector(
            onDoubleTap: () => setState(() {
              _isEditable = true;
            }),
            child: ListTile(
              selected: widget.isActive,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 6.0,
              ),
              onTap: widget.onSelect,
              leading: widget.filteredItemsCount > 0
                  ? Chip(
                      backgroundColor: Colors.yellow,
                      label: Text(widget.filteredItemsCount.toString()),
                    )
                  : null,
              title: _isEditable
                  ? TextField(
                      controller: _controller,
                      onSubmitted: (text) => setState(() {
                        widget.worksheet.name = text;
                        _isEditable = false;
                      }),
                    )
                  : Text(widget.worksheet.name!),
              trailing: widget.onRemove != null
                  ? IconButton(
                      icon: FaIcon(FontAwesomeIcons.times),
                      onPressed: widget.onRemove,
                    )
                  : null,
            ),
          ),
        ),
      );
}
