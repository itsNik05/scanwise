class ScanState {
  final List<String> pages;
  final bool isScanning;
  final bool isAutoCapture;
  final String selectedFilter;

  const ScanState({
    this.pages = const [],
    this.isScanning = false,
    this.isAutoCapture = true,
    this.selectedFilter = 'original',
  });

  ScanState copyWith({
    List<String>? pages,
    bool? isScanning,
    bool? isAutoCapture,
    String? selectedFilter,
  }) {
    return ScanState(
      pages: pages ?? this.pages,
      isScanning: isScanning ?? this.isScanning,
      isAutoCapture: isAutoCapture ?? this.isAutoCapture,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}