double dot(List<double> a, List<double> b) {
  assert(a.length == b.length);

  double dot = 0.0;
  for (int i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
  }

  return dot;
}
