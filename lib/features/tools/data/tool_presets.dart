class ImagePreset {
  const ImagePreset({
    required this.id,
    required this.label,
    required this.platform,
    required this.width,
    required this.height,
  });

  final String id;
  final String label;
  final String platform;
  final int width;
  final int height;
}

abstract final class ToolPresets {
  static const socialPresets = <ImagePreset>[
    ImagePreset(id: 'ig-post', label: 'Post', platform: 'Instagram', width: 1080, height: 1080),
    ImagePreset(id: 'ig-story', label: 'Story', platform: 'Instagram', width: 1080, height: 1920),
    ImagePreset(id: 'ig-reel', label: 'Reel Cover', platform: 'Instagram', width: 1080, height: 1920),
    ImagePreset(id: 'fb-post', label: 'Post', platform: 'Facebook', width: 1200, height: 630),
    ImagePreset(id: 'fb-story', label: 'Story', platform: 'Facebook', width: 1080, height: 1920),
    ImagePreset(id: 'li-post', label: 'Post', platform: 'LinkedIn', width: 1200, height: 627),
    ImagePreset(id: 'yt-thumb', label: 'Thumbnail', platform: 'YouTube', width: 1280, height: 720),
    ImagePreset(id: 'wa-status', label: 'Status', platform: 'WhatsApp', width: 1080, height: 1920),
  ];
}
