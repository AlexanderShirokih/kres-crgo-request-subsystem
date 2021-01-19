import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:kres_requests2/data/models/employee.dart';
import 'package:sembast/sembast.dart';

/// Data access object for [Employee] objects
class EmployeeDao {
  static const String _employeeStoreName = 'employees';

  // Store for persisting [Employee] objects
  final _employeeStore = intMapStoreFactory.store(_employeeStoreName);

  Future<Database> get _db => AppDatabase.instance.database;

  /// Inserts [Employee] to the storage
  Future<void> insert(Employee employee) async {
    await _employeeStore.add(await _db, employee.toJson());
  }

  /// Updates [Employee] record in the storage
  Future<void> update(Employee employee) async {
    final finder = Finder(filter: Filter.byKey(employee.id));
    await _employeeStore.update(await _db, employee.toJson(), finder: finder);
  }

  /// Deletes [Employee] record from the storage
  Future<void> delete(Employee employee) async {
    final finder = Finder(filter: Filter.byKey(employee.id));
    await _employeeStore.delete(await _db, finder: finder);
  }

  /// Finds all employees persisting in the storage
  Future<List<Employee>> findAll() async {
    final finder = Finder(sortOrders: [SortOrder('name')]);
    final snapshot = await _employeeStore.find(await _db, finder: finder);
    return snapshot
        .map((snap) => Employee.fromJson(snap.value)..id = snap.key)
        .toList();
  }
}
