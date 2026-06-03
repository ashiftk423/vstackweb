/// Isolated namespace — does not touch portfolio collections or storage paths.
abstract final class VStackFirebasePaths {
  static const String firestoreRoot = 'vstackweb';
  static const String storageRoot = 'vstackweb_media';

  static const String settings = '$firestoreRoot/settings/site';
  static const String projects = '$firestoreRoot/projects';
  static const String team = '$firestoreRoot/team';
  static const String capabilities = '$firestoreRoot/capabilities';
  static const String enquiries = '$firestoreRoot/enquiries';

  static String projectImage(String projectId, String fileName) =>
      '$storageRoot/projects/$projectId/$fileName';

  static String teamPhoto(String memberId, String fileName) =>
      '$storageRoot/team/$memberId/$fileName';
}
