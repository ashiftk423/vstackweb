import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:vstackweb/firebase/vstack_firebase_paths.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/services/vstack_storage_service.dart';

class VStackContentService {
  VStackContentService({
    required FirebaseFirestore firestore,
    required VStackStorageService storage,
    FirebaseAuth? auth,
  })  : _db = firestore,
        _storage = storage,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final VStackStorageService _storage;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  DocumentReference<Map<String, dynamic>> get _settingsRef =>
      _db.doc(VStackFirebasePaths.settings);

  Stream<SiteContent> watchSiteContent() {
    late final StreamController<SiteContent> controller;
    final subs = <StreamSubscription<dynamic>>[];

    Future<void> emit() async {
      if (controller.isClosed) return;
      controller.add(await loadSiteContent());
    }

    controller = StreamController<SiteContent>(
      onListen: () async {
        await emit();
        subs.add(_settingsRef.snapshots().listen((_) => emit()));
        subs.add(_db.collection(VStackFirebasePaths.projects).snapshots().listen((_) => emit()));
        subs.add(_db.collection(VStackFirebasePaths.team).snapshots().listen((_) => emit()));
        subs.add(_db.collection(VStackFirebasePaths.capabilities).snapshots().listen((_) => emit()));
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );
    return controller.stream;
  }

  Future<SiteContent> loadSiteContent() async {
    final settingsSnap = await _settingsRef.get();
    final settings = settingsSnap.exists
        ? SiteSettings.fromMap(settingsSnap.data()!)
        : SiteSettings.defaults();

    final projects = await _loadCollection(
      VStackFirebasePaths.projects,
      ProjectDoc.fromMap,
    );
    final team = await _loadCollection(
      VStackFirebasePaths.team,
      TeamDoc.fromMap,
    );
    final capabilities = await _loadCollection(
      VStackFirebasePaths.capabilities,
      CapabilityDoc.fromMap,
    );

    final hasData = settingsSnap.exists || projects.isNotEmpty;
    if (!hasData) return SiteContent.defaults();

    return SiteContent(
      settings: settings,
      projects: projects,
      team: team,
      capabilities: capabilities,
      fromFirebase: true,
    );
  }

  Future<List<T>> _loadCollection<T>(
    String path,
    T Function(String id, Map<String, dynamic> m) fromMap,
  ) async {
    final snap = await _db.collection(path).orderBy('sortOrder').get();
    return snap.docs.map((d) => fromMap(d.id, d.data())).toList();
  }

  Future<void> saveSettings(SiteSettings settings) async {
    await _settingsRef.set(settings.toMap(), SetOptions(merge: true));
  }

  Future<void> saveProject(ProjectDoc doc, {String? previousStoragePath}) async {
    await _storage.deletePath(previousStoragePath);
    await _db.collection(VStackFirebasePaths.projects).doc(doc.id).set(doc.toMap());
  }

  Future<String> createProject(ProjectDoc doc) async {
    final id = doc.id.isEmpty ? _uuid.v4() : doc.id;
    await _db.collection(VStackFirebasePaths.projects).doc(id).set(doc.toMap());
    return id;
  }

  Future<void> deleteProject(ProjectDoc doc) async {
    await _storage.deletePath(doc.imageStoragePath);
    await _db.collection(VStackFirebasePaths.projects).doc(doc.id).delete();
  }

  Future<void> saveTeamMember(TeamDoc doc, {String? previousStoragePath}) async {
    await _storage.deletePath(previousStoragePath);
    await _db.collection(VStackFirebasePaths.team).doc(doc.id).set(doc.toMap());
  }

  Future<String> createTeamMember(TeamDoc doc) async {
    final id = doc.id.isEmpty ? _uuid.v4() : doc.id;
    await _db.collection(VStackFirebasePaths.team).doc(id).set(doc.toMap());
    return id;
  }

  Future<void> deleteTeamMember(TeamDoc doc) async {
    await _storage.deletePath(doc.photoStoragePath);
    await _db.collection(VStackFirebasePaths.team).doc(doc.id).delete();
  }

  Future<void> saveCapability(CapabilityDoc doc) async {
    await _db.collection(VStackFirebasePaths.capabilities).doc(doc.id).set(doc.toMap());
  }

  Future<String> createCapability(CapabilityDoc doc) async {
    final id = doc.id.isEmpty ? _uuid.v4() : doc.id;
    await _db.collection(VStackFirebasePaths.capabilities).doc(id).set(doc.toMap());
    return id;
  }

  Future<void> deleteCapability(String id) async {
    await _db.collection(VStackFirebasePaths.capabilities).doc(id).delete();
  }

  Future<({String url, String path})> uploadProjectImage({
    required String projectId,
    required Uint8List bytes,
    required String fileName,
    String? oldStoragePath,
  }) async {
    await _storage.deletePath(oldStoragePath);
    final path = VStackFirebasePaths.projectImage(projectId, fileName);
    return _storage.upload(
      storagePath: path,
      bytes: bytes,
      contentType: _mime(fileName),
    );
  }

  Future<({String url, String path})> uploadTeamPhoto({
    required String memberId,
    required Uint8List bytes,
    required String fileName,
    String? oldStoragePath,
  }) async {
    await _storage.deletePath(oldStoragePath);
    final path = VStackFirebasePaths.teamPhoto(memberId, fileName);
    return _storage.upload(
      storagePath: path,
      bytes: bytes,
      contentType: _mime(fileName),
    );
  }

  Future<void> submitEnquiry({
    required String name,
    required String email,
    required String message,
    required String enquiryType,
  }) async {
    await _db.collection(VStackFirebasePaths.enquiries).add({
      'name': name,
      'email': email,
      'message': message,
      'enquiryType': enquiryType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchEnquiries() {
    return _db
        .collection(VStackFirebasePaths.enquiries)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Future<void> seedDemoContent() async {
    final defaults = SiteContent.defaults();
    await saveSettings(defaults.settings);
    for (final p in defaults.projects) {
      final id = _uuid.v4();
      await createProject(ProjectDoc(
        id: id,
        title: p.title,
        category: p.category,
        description: p.description,
        tech: p.tech,
        year: p.year,
        sortOrder: p.sortOrder,
      ));
    }
    for (final t in defaults.team) {
      final id = _uuid.v4();
      await createTeamMember(TeamDoc(
        id: id,
        name: t.name,
        role: t.role,
        bio: t.bio,
        initials: t.initials,
        isLeadership: t.isLeadership,
        sortOrder: t.sortOrder,
      ));
    }
    for (final c in defaults.capabilities) {
      await createCapability(CapabilityDoc(
        id: _uuid.v4(),
        title: c.title,
        description: c.description,
        sortOrder: c.sortOrder,
      ));
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  String _mime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
