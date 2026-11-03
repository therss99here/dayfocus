class BrainDumpContent {
  final String deltaJson;
  const BrainDumpContent({required this.deltaJson});

  static const empty = BrainDumpContent(deltaJson: '[{"insert":"\\n"}]');
}
