class StringStack {
  final List<String> _stack = [];

  // Push
  void push(String value) {
    _stack.add(value);
  }

  // Pop
  String? pop() {
    if (_stack.isEmpty) return null;
    return _stack.removeLast();
  }

  // Peek (top element)
  String? peek() {
    if (_stack.isEmpty) return null;
    return _stack.last;
  }

  // Check empty
  bool get isEmpty => _stack.isEmpty;

  // Size
  int get size => _stack.length;

  @override
  String toString() => _stack.toString();
}