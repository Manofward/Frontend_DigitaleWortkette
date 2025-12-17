class GoldenRatio {
  static const double phi = 1.300;//1.250;//1.618;

  // Base unit for the general size
  static const double base = 16;

  // Typography
  //static double get h1 => base * phi * phi; // ≈ 42
  //static double get h2 => base * phi;       // ≈ 26
  //static double get body => base;            // 16
  //static double get small => base / phi;     // ≈ 10

  static double get h1 => base * phi * phi * phi; // ≈ 42
  static double get h2 => base * phi * phi;       // ≈ 26
  static double get body => base * phi;            // 16
  static double get medium => base;     // ≈ 10
  static double get small => base / phi;

  // Spacing
  static double get xs => base / phi;        // 10
  static double get sm => base;              // 16
  static double get md => base * phi;        // 26
  static double get lg => base * phi * phi;  // 42
}