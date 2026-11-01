/// Replace this catalog with each project's release notes.
class AppRelease {
  const AppRelease({required this.version, required this.title, required this.notes});
  final String version;
  final String title;
  final List<String> notes;

  static const releases = [
    AppRelease(
      version: '1.0.0',
      title: 'Initial release',
      notes: ['Welcome to the first release.'],
    ),
  ];
}
