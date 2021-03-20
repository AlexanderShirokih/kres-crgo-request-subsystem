import 'package:kres_requests2/data/editor/request_module.dart';
import 'package:kres_requests2/data/settings/employee_module.dart';
import 'package:kres_requests2/data/settings/request_type_module.dart';
import 'package:kres_requests2/models/document.dart';

/// DI Module that contains submodules for worksheet editor
class WorksheetEditorModule {
  final RequestModule requestModule;
  final RequestTypeModule requestTypeModule;
  final EmployeeModule employeeModule;
  final Document targetDocument;

  const WorksheetEditorModule({
    required this.requestTypeModule,
    required this.requestModule,
    required this.employeeModule,
    required this.targetDocument,
  });
}
