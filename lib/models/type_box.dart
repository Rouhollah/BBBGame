class TypeBox {
  double x;
  double y;
  String type;
  TypeBox({this.x, this.y, this.type});

  factory TypeBox.fromJson(Map<String, dynamic> json) {
    return TypeBox(
        x: json['x'].toDouble(), y: json['y'].toDouble(), type: json['type']);
  }
}
