import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/bloc/editor/worksheet_creation_mode.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';

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
        icon: Icon(Icons.add),
      );

  Widget _buildExpandedLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddTile(),
          _buildItemTile(
            title: 'Пустой лист заявок',
            tooltip: 'Добавить пустой лист для создания заявок',
            icon: FaIcon(FontAwesomeIcons.file),
            mode: WorksheetCreationMode.empty,
          ),
          _buildItemTile(
            title: 'Импорт из другого документа',
            tooltip: 'Добавить листы из другого документа',
            icon: FaIcon(FontAwesomeIcons.fileImport),
            mode: WorksheetCreationMode.importNative,
          ),
          _buildItemTile(
            title: 'Импорт файла заявок',
            tooltip:
                'Создать новый лист заявок из подготовленного файла Mega-billing',
            icon: FaIcon(FontAwesomeIcons.fileExcel),
            mode: WorksheetCreationMode.import,
          ),
          _buildItemTile(
            title: 'Импорт списка счётчиков',
            tooltip:
                'Создать новый лист заявок из подготовленного списка счётчиков',
            icon: FaIcon(FontAwesomeIcons.table),
            mode: WorksheetCreationMode.importCounters,
          )
        ],
      );

  Widget _buildItemTile({
    required String title,
    String? tooltip,
    required Widget icon,
    WorksheetCreationMode? mode,
  }) {
    Widget _buildListTile() => ListTile(
          trailing: icon,
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

/// Represents page selector card
class WorksheetTabView extends StatefulWidget {
  final WorksheetEditor worksheetEditor;
  final bool isActive;
  final int filteredItemsCount;
  final void Function() onSelect;
  final void Function()? onRemove;

  const WorksheetTabView({
    Key? key,
    required this.filteredItemsCount,
    required this.worksheetEditor,
    required this.isActive,
    required this.onSelect,
    required this.onRemove,
  }) : super(key: key);

  @override
  _WorksheetTabViewState createState() => _WorksheetTabViewState();
}

class _WorksheetTabViewState extends State<WorksheetTabView> {
  late TextEditingController _controller;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.worksheetEditor.current.name);
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
                      onSubmitted: (_) => _onEditingDone(),
                    )
                  : Text(widget.worksheetEditor.current.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEditable)
                    IconButton(
                      icon: Icon(Icons.done),
                      onPressed: _onEditingDone,
                    ),
                  if (_isEditable)
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: _onCancelEditing,
                    ),
                  if (widget.onRemove != null && !_isEditable)
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: widget.onRemove,
                    )
                ],
              ),
            ),
          ),
        ),
      );

  void _onEditingDone() => setState(() {
        widget.worksheetEditor.setName(_controller.text);
        _isEditable = false;
      });

  void _onCancelEditing() => setState(() {
        _controller.text = widget.worksheetEditor.current.name;
        _isEditable = false;
      });
}
