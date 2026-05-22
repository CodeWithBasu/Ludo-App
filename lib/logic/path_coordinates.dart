class PathCoordinates {
  /// Maps an absolute position (0-51) to a logical grid coordinate (x, y) where x and y are 0-14.
  static final List<List<int>> mainPath = [
    // Bottom-left path (Red start)
    [1, 6], [2, 6], [3, 6], [4, 6], [5, 6],
    // Up path
    [6, 5], [6, 4], [6, 3], [6, 2], [6, 1], [6, 0],
    // Top turnaround
    [7, 0], [8, 0],
    // Top-right path (Green start)
    [8, 1], [8, 2], [8, 3], [8, 4], [8, 5],
    // Right path
    [9, 6], [10, 6], [11, 6], [12, 6], [13, 6], [14, 6],
    // Right turnaround
    [14, 7], [14, 8],
    // Bottom-right path (Yellow start)
    [13, 8], [12, 8], [11, 8], [10, 8], [9, 8],
    // Down path
    [8, 9], [8, 10], [8, 11], [8, 12], [8, 13], [8, 14],
    // Bottom turnaround
    [7, 14], [6, 14],
    // Bottom-left path (Blue start)
    [6, 13], [6, 12], [6, 11], [6, 10], [6, 9],
    // Left path back to start
    [5, 8], [4, 8], [3, 8], [2, 8], [1, 8], [0, 8],
    // Left turnaround
    [0, 7], [0, 6], // [0,6] is just before index 0 (red start)
  ];

  static final Map<String, List<List<int>>> homePaths = {
    'red': [
      [1, 7], [2, 7], [3, 7], [4, 7], [5, 7], [6, 7] // Home
    ],
    'green': [
      [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6] // Home
    ],
    'yellow': [
      [13, 7], [12, 7], [11, 7], [10, 7], [9, 7], [8, 7] // Home
    ],
    'blue': [
      [7, 13], [7, 12], [7, 11], [7, 10], [7, 9], [7, 8] // Home
    ],
  };

  static final Map<String, List<List<int>>> basePositions = {
    'red': [
      [2, 2], [4, 2], [2, 4], [4, 4]
    ],
    'green': [
      [11, 2], [13, 2], [11, 4], [13, 4]
    ],
    'blue': [
      [2, 11], [4, 11], [2, 13], [4, 13]
    ],
    'yellow': [
      [11, 11], [13, 11], [11, 13], [13, 13]
    ],
  };
}
