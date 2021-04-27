import 'package:equatable/equatable.dart';

/// Describes info about installed JRE
class JavaInfo extends Equatable {
  /// JRE (JDK) version string
  final String version;

  /// 'java' executable path
  final String execPath;

  const JavaInfo(this.version, this.execPath);

  @override
  List<Object?> get props => [version, execPath];
}
