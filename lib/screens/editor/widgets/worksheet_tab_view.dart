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

class WorksheetTabView extends StatefulWidget {
  final Worksheet worksheet;
  final bool isActive;
  final int filteredItemsCount;
  final void Function() onSelect;
  final void Function()? onRemove;

  const WorksheetTabView({
    required this.filteredItemsCount,
    required this.worksheet,
    required this.isActive,
    required this.onSelect,
    required this.onRemove,
  });

  @override
  _WorksheetTabViewState createState() => _WorksheetTabViewState();
}

class _WorksheetTabViewState extends State<WorksheetTabView> {
  late TextEditingController _controller;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.worksheet.name);
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
            onTap: widget.onSelect,
            onDoubleTap: () => setState(() {
              _isEditable = true;
            }),
            child: ListTile(
              selected: widget.isActive,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 6.0,
              ),
              leading: widget.filteredItemsCount > 0
                  ? Chip(
                      backgroundColor: Colors.yellow,
                      label: Text(widget.filteredItemsCount.toString()),
                    )
                  : null,
              title: _isEditable
                  ? TextField(
                      maxLines: 1,
                      controller: _controller,
                      onSubmitted: (_) => onEditingDone(),
                    )
                  : Text(widget.worksheet.name!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEditable)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.check),
                      onPressed: onEditingDone,
                    ),
                  if (widget.onRemove != null)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.times),
                      onPressed: widget.onRemove,
                    )
                ],
              ),
            ),
          ),
        ),
      );

  void onEditingDone() => setState(() {
        widget.worksheet.name = _controller.text;
        _isEditable = false;
      });
}
