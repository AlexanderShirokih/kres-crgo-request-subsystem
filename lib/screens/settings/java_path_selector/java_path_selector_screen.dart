import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/settings/java_path_chooser/java_path_chooser_bloc.dart';
import 'package:kres_requests2/screens/bloc.dart';

/// Widget used to select java executable path from filesystem and save them.
class JavaPathChooserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JavaPathChooserBloc(Modular.get(), Modular.get()),
      child: BlocBuilder<JavaPathChooserBloc, BaseState>(
        builder: (BuildContext context, state) {
          if (state is DataState<JavaInfo>) {
            return _buildDataState(context, state.data);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildDataState(BuildContext context, JavaInfo info) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.isOk ? 'Текущий путь к Java:' : 'JVM Не выбрана',
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 12.0),
          Text(info.path),
          const SizedBox(height: 16.0),
          Row(
            children: [
              info.isOk
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8.0),
              Text(info.info),
            ],
          ),
          const SizedBox(height: 12.0),
          _updateJavaButton(context, info.directory),
        ],
      ),
    );
  }

  Widget _updateJavaButton(BuildContext context, String directory) =>
      ElevatedButton(
        onPressed: () => _showJavaPathSelector(directory).then((newPath) {
          if (newPath != null) {
            context.read<JavaPathChooserBloc>().add(UpdateJavaPath(newPath));
          }
        }),
        child: Text('Изменить'),
      );

  Future<String?> _showJavaPathSelector(String initial) {
    return getDirectoryPath(
      initialDirectory: initial,
      confirmButtonText: 'Выбрать',
    );
  }
}
