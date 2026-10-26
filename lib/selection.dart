/// What the user opened, in the 2D pictures or in the 3D view.
class ViewerSelection {
  const ViewerSelection({
    required this.key,
    required this.name,
    required this.layer,
    required this.whole,
    this.partId,
  });

  /// Text key, for example "heart".
  final String key;

  /// Anatomical name of the piece that was tapped (English).
  final String name;
  final String layer;

  /// True when the whole organ or bone group is selected, false when a single
  /// piece (one muscle, one artery, ...) is selected.
  final bool whole;
  final String? partId;
}
