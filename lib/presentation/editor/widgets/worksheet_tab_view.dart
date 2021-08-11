import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/presentation/bloc/editor/worksheet_config_view/worksheet_config_bloc.dart';

/// Widget that provides a way to create new worksheet of certain type
class AddNewWorkSheetTabView extends HookWidget {
  final void Function() onAddPressed;

  const AddNewWorkSheetTabView(this.onAddPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Card(
        elevation: 5.0,
        child: _buildItemTile(
          onTap: onAddPressed,
          title: 'Добавить',
          tooltip: 'Добавить пустой лист для создания заявок',
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildItemTile({
    String? tooltip,
    required String title,
    required Widget icon,
    required void Function() onTap,
  }) {
    Widget _buildListTile() => ListTile(
          trailing: icon,
          title: Text(title),
          onTap: onTap,
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
class WorksheetTabView extends HookWidget {
  final bool isActive;
  final Worksheet worksheet;
  final int filteredItemsCount;
  final void Function() onSelect;
  final void Function()? onRemove;

  const WorksheetTabView({
    Key? key,
    required this.worksheet,
    required this.filteredItemsCount,
    required this.isActive,
    required this.onSelect,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: worksheet.name);
    final isEditable = useState(false);

    void _onEditingDone() {
      isEditable.value = false;
      context
          .read<WorksheetConfigBloc>()
          .add(UpdateNameEvent(controller.text, worksheet));
    }

    void _onCancelEditing() {
      controller.text = worksheet.name;
      isEditable.value = false;
    }

    return SizedBox(
      width: double.maxFinite,
      child: Card(
        elevation: 5.0,
        child: GestureDetector(
          onTap: onSelect,
          onDoubleTap: () => isEditable.value = true,
          child: ListTile(
            selected: isActive,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6.0,
              vertical: 6.0,
            ),
            leading: filteredItemsCount > 0
                ? Chip(
                    backgroundColor: Colors.yellow,
                    label: Text(filteredItemsCount.toString()),
                  )
                : null,
            title: isEditable.value
                ? TextField(
                    maxLines: 1,
                    controller: controller,
                    onSubmitted: (_) => _onEditingDone(),
                  )
                : Text(worksheet.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEditable.value)
                  IconButton(
                    icon: const Icon(Icons.done),
                    onPressed: _onEditingDone,
                  ),
                if (isEditable.value)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _onCancelEditing,
                  ),
                if (onRemove != null && !isEditable.value)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onRemove,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
