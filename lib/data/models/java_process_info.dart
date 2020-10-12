class JavaProcessInfo {
  final String appHome;
  final String classpath;
  final String mainClassName;

  const JavaProcessInfo(this.appHome, this.classpath, this.mainClassName)
      : assert(appHome != null),
        assert(classpath != null),
        assert(mainClassName != null);

  factory JavaProcessInfo.fromMap(Map<String, dynamic> data) => JavaProcessInfo(
        data['appHome'],
        data['classpath'],
        data['mainClass'],
      );
}
