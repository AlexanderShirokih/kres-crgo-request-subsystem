import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:mocktail/mocktail.dart';

/// Mocked [Document]
// ignore: must_be_immutable
class DocumentMock extends Mock implements Document {}

/// Mocked [Worksheet]
// ignore: must_be_immutable
class WorksheetMock extends Mock implements Worksheet {}

/// Mocked [Request]
// ignore: must_be_immutable
class RequestMock extends Mock implements Request {}

class NavigatorMock extends Mock implements IModularNavigator {}
