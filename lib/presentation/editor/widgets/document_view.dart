import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/service/worksheet_service.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/doc_view/document_bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/editor_view/worksheet_bloc.dart';
import 'package:kres_requests2/presentation/editor/widgets/worksheet_editor_view.dart';
import 'package:kres_requests2/presentation/editor/widgets/worksheet_page_controller.dart';
import 'package:kres_requests2/presentation/editor/worksheet_config_view/worksheet_config_view.dart';
import 'package:kres_requests2/presentation/editor/worksheet_navigation_routes.dart';

/// Widget that displays content of the document.
/// Left side contains a page switcher.
/// Central part contains a list of requests for selected page.
/// Right side contains tab to manage page employees.
class DocumentView extends HookWidget {
  /// Creates document view widget from [Document] and [WorksheetService]
  /// associated with the same document.
  /// Requires [DocumentBloc] and [WorksheetBloc] to be injected.
  const DocumentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isConfigViewOpened = useState(false);

    final AnimationController configViewAnimator =
        useAnimationController(duration: const Duration(milliseconds: 300));

    final Animation<double> configViewWidth =
        CurvedAnimation(parent: configViewAnimator, curve: Curves.easeIn);

    return _buildEditor(
      context,
      configViewWidth,
      configViewAnimator,
      isConfigViewOpened,
    );
  }

  Widget _buildEditor(
    BuildContext context,
    Animation<double> configViewAnimation,
    AnimationController configViewAnimator,
    ValueNotifier isConfigViewOpened,
  ) {
    Widget buildEditor(DocumentInfo info) {
      return IndexedStack(
        index: info.activePosition,
        children: info.all
            .map((worksheet) => BlocProvider<WorksheetBloc>(
                  key: ObjectKey(worksheet),
                  create: (_) => WorksheetBloc(
                    Modular.get<WorksheetService>(),
                    WorksheetNavigationRoutesImpl(
                      context,
                      Modular.get(),
                    ),
                  )..add(SetCurrentWorksheetEvent(worksheet)),
                  child: WorksheetEditorView(
                    filtered: info.filtered[worksheet] ?? const [],
                  ),
                ))
            .toList(),
      );
    }

    return BlocBuilder<DocumentBloc, BaseState>(
      builder: (context, state) {
        if (state is! DataState<DocumentInfo>) {
          return const Center(
            child: Text('No opened document...'),
          );
        }

        return Container(
          color: const Color(0xFFE5E5E5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 285.0,
                color: Colors.white,
                height: double.maxFinite,
                child: const WorksheetsPageController(),
              ),
              Expanded(
                child: SizedBox(
                  height: double.maxFinite,
                  child: buildEditor(state.data),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 10.0),
                  _buildConfigViewSwitcher(
                      configViewAnimator, isConfigViewOpened),
                ],
              ),
              SizeTransition(
                axis: Axis.horizontal,
                sizeFactor: configViewAnimation,
                axisAlignment: 1.0,
                child: Container(
                  width: 420.0,
                  height: double.maxFinite,
                  color: Colors.white,
                  child: const WorksheetConfigView(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfigViewSwitcher(
    AnimationController configViewAnimation,
    ValueNotifier isConfigViewOpened,
  ) =>
      Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
          ),
          color: Colors.white,
        ),
        child: IconButton(
          icon: const Icon(Icons.menu_open),
          onPressed: () {
            final isClosed = !isConfigViewOpened.value;
            isConfigViewOpened.value = isClosed;

            if (isClosed) {
              configViewAnimation.forward();
            } else {
              configViewAnimation.reverse();
            }
          },
        ),
      );
}
