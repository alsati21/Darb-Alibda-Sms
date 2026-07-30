class SubjectComponent {
  const SubjectComponent({required this.id, required this.name});

  final int id;
  final String name;

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SubjectComponent && other.id == id && other.name == name);

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
