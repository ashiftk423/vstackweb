import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/pages/admin/admin_login_page.dart';
import 'package:vstackweb/providers/site_content_provider.dart';
import 'package:vstackweb/services/admin_session.dart';
import 'package:vstackweb/services/vstack_content_service.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (!AdminSession.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const AdminLoginPage()),
        );
      });
    }
  }

  VStackContentService? get _svc {
    final provider = context.read<SiteContentProvider>();
    return provider.hasFirebase ? provider.service : null;
  }

  VStackContentService _requireSvc() {
    final s = _svc;
    assert(s != null, 'Firestore service required');
    return s!;
  }

  Future<void> _run(Future<void> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red.shade900),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    AdminSession.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AdminLoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = _svc;
    if (svc == null) {
      return Scaffold(
        backgroundColor: VStackColors.bg,
        appBar: AppBar(title: const Text('VStack Dashboard')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Signed in with Firebase, but Firestore is not connected.\n'
              'Restart with: flutter run -d chrome',
              textAlign: TextAlign.center,
              style: TextStyle(color: VStackColors.muted),
            ),
          ),
        ),
      );
    }

    final content = context.watch<SiteContentProvider>().content;

    return Scaffold(
      backgroundColor: VStackColors.bg,
      appBar: AppBar(
        backgroundColor: VStackColors.surface,
        title: const Text('VStack Dashboard'),
        actions: [
          if (_busy) const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          TextButton(onPressed: _busy ? null : () => _run(svc.seedDemoContent), child: const Text('Seed demo')),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: DefaultTabController(
        length: 6,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'General'),
                Tab(text: 'Capabilities'),
                Tab(text: 'Projects'),
                Tab(text: 'Team'),
                Tab(text: 'Contact'),
                Tab(text: 'Enquiries'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _GeneralTab(settings: content.settings, onSave: (s) => _run(() => svc.saveSettings(s))),
                  _CapabilitiesTab(
                    items: content.capabilities,
                    onAdd: _addCapability,
                    onEdit: _editCapability,
                    onDelete: (id) => _run(() => svc.deleteCapability(id)),
                  ),
                  _ProjectsTab(
                    items: content.projects,
                    onAdd: _addProject,
                    onEdit: _editProject,
                    onDelete: (p) => _run(() => svc.deleteProject(p)),
                  ),
                  _TeamTab(
                    items: content.team,
                    onAdd: _addTeam,
                    onEdit: _editTeam,
                    onDelete: (t) => _run(() => svc.deleteTeamMember(t)),
                  ),
                  _ContactTab(settings: content.settings, onSave: (s) => _run(() => svc.saveSettings(s))),
                  _EnquiriesTab(service: svc),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCapability() async {
    final svc = _requireSvc();
    final doc = await _showCapabilityDialog(context, null);
    if (doc == null) return;
    await _run(() async {
      final id = await svc.createCapability(doc);
      await svc.saveCapability(doc.copyWithId(id));
    });
  }

  Future<void> _editCapability(CapabilityDoc item) async {
    final svc = _requireSvc();
    final doc = await _showCapabilityDialog(context, item);
    if (doc == null) return;
    await _run(() => svc.saveCapability(doc.copyWithId(item.id)));
  }

  Future<void> _addProject() => _editProject(null);
  Future<void> _editProject(ProjectDoc? item) async {
    final svc = _requireSvc();
    final result = await _showProjectDialog(context, svc, item);
    if (result == null) return;
    await _run(() => svc.saveProject(
          item == null ? result : result.copyWithId(item.id),
          previousStoragePath: item != null &&
                  item.imageStoragePath != null &&
                  item.imageStoragePath != result.imageStoragePath
              ? item.imageStoragePath
              : null,
        ));
  }

  Future<void> _addTeam() => _editTeam(null);
  Future<void> _editTeam(TeamDoc? item) async {
    final svc = _requireSvc();
    final result = await _showTeamDialog(context, svc, item);
    if (result == null) return;
    await _run(() => svc.saveTeamMember(
          item == null ? result : result.copyWithId(item.id),
          previousStoragePath: item != null &&
                  item.photoStoragePath != null &&
                  item.photoStoragePath != result.photoStoragePath
              ? item.photoStoragePath
              : null,
        ));
  }
}

extension on CapabilityDoc {
  CapabilityDoc copyWithId(String id) => CapabilityDoc(id: id, title: title, description: description, sortOrder: sortOrder);
}

extension on ProjectDoc {
  ProjectDoc copyWithId(String id) => ProjectDoc(
        id: id,
        title: title,
        category: category,
        description: description,
        tech: tech,
        year: year,
        sortOrder: sortOrder,
        imageUrl: imageUrl,
        imageStoragePath: imageStoragePath,
      );
}

extension on TeamDoc {
  TeamDoc copyWithId(String id) => TeamDoc(
        id: id,
        name: name,
        role: role,
        bio: bio,
        initials: initials,
        isLeadership: isLeadership,
        sortOrder: sortOrder,
        photoUrl: photoUrl,
        photoStoragePath: photoStoragePath,
      );
}

class _GeneralTab extends StatefulWidget {
  const _GeneralTab({required this.settings, required this.onSave});
  final SiteSettings settings;
  final ValueChanged<SiteSettings> onSave;

  @override
  State<_GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<_GeneralTab> {
  late final _badge = TextEditingController(text: widget.settings.heroBadge);
  late final _title = TextEditingController(text: widget.settings.heroTitle);
  late final _sub = TextEditingController(text: widget.settings.heroSubtitle);
  late final _s1v = TextEditingController(text: widget.settings.stat1Value);
  late final _s1l = TextEditingController(text: widget.settings.stat1Label);
  late final _s2v = TextEditingController(text: widget.settings.stat2Value);
  late final _s2l = TextEditingController(text: widget.settings.stat2Label);
  late final _s3v = TextEditingController(text: widget.settings.stat3Value);
  late final _s3l = TextEditingController(text: widget.settings.stat3Label);

  @override
  void dispose() {
    for (final c in [_badge, _title, _sub, _s1v, _s1l, _s2v, _s2l, _s3v, _s3l]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _formList([
      _field(_badge, 'Hero badge'),
      _field(_title, 'Hero title', maxLines: 2),
      _field(_sub, 'Hero subtitle', maxLines: 3),
      _field(_s1v, 'Stat 1 value'),
      _field(_s1l, 'Stat 1 label'),
      _field(_s2v, 'Stat 2 value'),
      _field(_s2l, 'Stat 2 label'),
      _field(_s3v, 'Stat 3 value'),
      _field(_s3l, 'Stat 3 label'),
      FilledButton(
        onPressed: () => widget.onSave(SiteSettings(
          heroBadge: _badge.text,
          heroTitle: _title.text,
          heroSubtitle: _sub.text,
          stat1Value: _s1v.text,
          stat1Label: _s1l.text,
          stat2Value: _s2v.text,
          stat2Label: _s2l.text,
          stat3Value: _s3v.text,
          stat3Label: _s3l.text,
          contactEmail: widget.settings.contactEmail,
          whatsappNumber: widget.settings.whatsappNumber,
          enquiryTypes: widget.settings.enquiryTypes,
        )),
        child: const Text('Save general'),
      ),
    ]);
  }
}

class _ContactTab extends StatefulWidget {
  const _ContactTab({required this.settings, required this.onSave});
  final SiteSettings settings;
  final ValueChanged<SiteSettings> onSave;

  @override
  State<_ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<_ContactTab> {
  late final _email = TextEditingController(text: widget.settings.contactEmail);
  late final _wa = TextEditingController(text: widget.settings.whatsappNumber);
  late final _types = TextEditingController(text: widget.settings.enquiryTypes.join(', '));

  @override
  void dispose() {
    _email.dispose();
    _wa.dispose();
    _types.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _formList([
      _field(_email, 'Contact email'),
      _field(_wa, 'WhatsApp number (country code, no +)'),
      _field(_types, 'Enquiry types (comma separated)'),
      FilledButton(
        onPressed: () => widget.onSave(SiteSettings(
          heroBadge: widget.settings.heroBadge,
          heroTitle: widget.settings.heroTitle,
          heroSubtitle: widget.settings.heroSubtitle,
          stat1Value: widget.settings.stat1Value,
          stat1Label: widget.settings.stat1Label,
          stat2Value: widget.settings.stat2Value,
          stat2Label: widget.settings.stat2Label,
          stat3Value: widget.settings.stat3Value,
          stat3Label: widget.settings.stat3Label,
          contactEmail: _email.text.trim(),
          whatsappNumber: _wa.text.trim(),
          enquiryTypes: _types.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        )),
        child: const Text('Save contact'),
      ),
    ]);
  }
}

class _CapabilitiesTab extends StatelessWidget {
  const _CapabilitiesTab({required this.items, required this.onAdd, required this.onEdit, required this.onDelete});
  final List<CapabilityDoc> items;
  final VoidCallback onAdd;
  final void Function(CapabilityDoc) onEdit;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    return _listTab(
      onAdd: onAdd,
      children: items.map((c) => _AdminTile(
            title: c.title,
            subtitle: c.description,
            onEdit: () => onEdit(c),
            onDelete: () => onDelete(c.id),
          )).toList(),
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab({required this.items, required this.onAdd, required this.onEdit, required this.onDelete});
  final List<ProjectDoc> items;
  final VoidCallback onAdd;
  final void Function(ProjectDoc?) onEdit;
  final void Function(ProjectDoc) onDelete;

  @override
  Widget build(BuildContext context) {
    return _listTab(
      onAdd: onAdd,
      children: items.map((p) => _AdminTile(
            title: p.title,
            subtitle: '${p.category} · ${p.year}',
            imageUrl: p.imageUrl,
            onEdit: () => onEdit(p),
            onDelete: () => onDelete(p),
          )).toList(),
    );
  }
}

class _TeamTab extends StatelessWidget {
  const _TeamTab({required this.items, required this.onAdd, required this.onEdit, required this.onDelete});
  final List<TeamDoc> items;
  final VoidCallback onAdd;
  final void Function(TeamDoc?) onEdit;
  final void Function(TeamDoc) onDelete;

  @override
  Widget build(BuildContext context) {
    return _listTab(
      onAdd: onAdd,
      children: items.map((t) => _AdminTile(
            title: t.name,
            subtitle: t.role,
            imageUrl: t.photoUrl,
            onEdit: () => onEdit(t),
            onDelete: () => onDelete(t),
          )).toList(),
    );
  }
}

class _EnquiriesTab extends StatelessWidget {
  const _EnquiriesTab({required this.service});
  final VStackContentService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: service.watchEnquiries(),
      builder: (context, snap) {
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text('No enquiries yet', style: TextStyle(color: VStackColors.muted)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final e = list[i];
            return Card(
              color: VStackColors.surface,
              child: ListTile(
                title: Text('${e['name']} · ${e['enquiryType']}'),
                subtitle: Text('${e['email']}\n${e['message']}'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

Widget _formList(List<Widget> children) {
  return ListView(
    padding: const EdgeInsets.all(20),
    children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
  );
}

Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
  return TextField(controller: c, maxLines: maxLines, decoration: InputDecoration(labelText: label));
}

Widget _listTab({required VoidCallback onAdd, required List<Widget> children}) {
  return Column(
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add')),
        ),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: children)),
    ],
  );
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: VStackColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imageUrl!, width: 48, height: 48, fit: BoxFit.cover),
              )
            : const Icon(Icons.image_outlined, color: VStackColors.muted),
        title: Text(title),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}

Future<CapabilityDoc?> _showCapabilityDialog(BuildContext context, CapabilityDoc? existing) async {
  final title = TextEditingController(text: existing?.title ?? '');
  final desc = TextEditingController(text: existing?.description ?? '');
  final order = TextEditingController(text: '${existing?.sortOrder ?? 0}');

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? 'Add capability' : 'Edit capability'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
          TextField(controller: order, decoration: const InputDecoration(labelText: 'Sort order'), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
      ],
    ),
  );
  if (ok != true) return null;
  return CapabilityDoc(
    id: existing?.id ?? '',
    title: title.text,
    description: desc.text,
    sortOrder: int.tryParse(order.text) ?? 0,
  );
}

Future<ProjectDoc?> _showProjectDialog(
  BuildContext context,
  VStackContentService svc,
  ProjectDoc? existing,
) async {
  final title = TextEditingController(text: existing?.title ?? '');
  final cat = TextEditingController(text: existing?.category ?? '');
  final desc = TextEditingController(text: existing?.description ?? '');
  final tech = TextEditingController(text: existing?.tech ?? '');
  final year = TextEditingController(text: existing?.year ?? '');
  final order = TextEditingController(text: '${existing?.sortOrder ?? 0}');
  Uint8List? pickedBytes;
  String? pickedName;
  String? imageUrl = existing?.imageUrl;
  String? imagePath = existing?.imageStoragePath;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: Text(existing == null ? 'Add project' : 'Edit project'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(imageUrl, height: 80, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: () async {
                    final r = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                    if (r != null && r.files.single.bytes != null) {
                      setS(() {
                        pickedBytes = r.files.single.bytes;
                        pickedName = r.files.single.name;
                      });
                    }
                  },
                  icon: const Icon(Icons.upload),
                  label: Text(pickedName ?? 'Upload image (replaces old)'),
                ),
                _field(title, 'Title'),
                _field(cat, 'Category'),
                _field(desc, 'Description', maxLines: 3),
                _field(tech, 'Tech stack'),
                _field(year, 'Year'),
                _field(order, 'Sort order'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    ),
  );
  if (ok != true) return null;

  final id = existing?.id ?? const Uuid().v4();
  if (pickedBytes != null && pickedName != null) {
    final up = await svc.uploadProjectImage(
      projectId: id,
      bytes: pickedBytes!,
      fileName: pickedName!,
      oldStoragePath: existing?.imageStoragePath,
    );
    imageUrl = up.url;
    imagePath = up.path;
  }

  return ProjectDoc(
    id: id,
    title: title.text,
    category: cat.text,
    description: desc.text,
    tech: tech.text,
    year: year.text,
    sortOrder: int.tryParse(order.text) ?? 0,
    imageUrl: imageUrl,
    imageStoragePath: imagePath,
  );
}

Future<TeamDoc?> _showTeamDialog(
  BuildContext context,
  VStackContentService svc,
  TeamDoc? existing,
) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final role = TextEditingController(text: existing?.role ?? '');
  final bio = TextEditingController(text: existing?.bio ?? '');
  final initials = TextEditingController(text: existing?.initials ?? '');
  final order = TextEditingController(text: '${existing?.sortOrder ?? 0}');
  var leadership = existing?.isLeadership ?? false;
  Uint8List? pickedBytes;
  String? pickedName;
  String? photoUrl = existing?.photoUrl;
  String? photoPath = existing?.photoStoragePath;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: Text(existing == null ? 'Add team member' : 'Edit team member'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (photoUrl != null)
                  CircleAvatar(backgroundImage: NetworkImage(photoUrl), radius: 36),
                OutlinedButton.icon(
                  onPressed: () async {
                    final r = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                    if (r != null && r.files.single.bytes != null) {
                      setS(() {
                        pickedBytes = r.files.single.bytes;
                        pickedName = r.files.single.name;
                      });
                    }
                  },
                  icon: const Icon(Icons.upload),
                  label: Text(pickedName ?? 'Upload photo'),
                ),
                _field(name, 'Name'),
                _field(role, 'Role'),
                _field(bio, 'Bio', maxLines: 3),
                _field(initials, 'Initials'),
                _field(order, 'Sort order'),
                SwitchListTile(
                  title: const Text('Leadership'),
                  value: leadership,
                  onChanged: (v) => setS(() => leadership = v),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    ),
  );
  if (ok != true) return null;

  final id = existing?.id ?? const Uuid().v4();
  if (pickedBytes != null && pickedName != null) {
    final up = await svc.uploadTeamPhoto(
      memberId: id,
      bytes: pickedBytes!,
      fileName: pickedName!,
      oldStoragePath: existing?.photoStoragePath,
    );
    photoUrl = up.url;
    photoPath = up.path;
  }

  return TeamDoc(
    id: id,
    name: name.text,
    role: role.text,
    bio: bio.text,
    initials: initials.text,
    isLeadership: leadership,
    sortOrder: int.tryParse(order.text) ?? 0,
    photoUrl: photoUrl,
    photoStoragePath: photoPath,
  );
}
