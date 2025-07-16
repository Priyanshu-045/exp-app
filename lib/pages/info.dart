class Info {
  final int? id;
  final String name;
  final String des;
  final int qty;
  final double amt;

  const Info({
    this.id,
    required this.name,
    required this.des,
    required this.qty,
    required this.amt,
  });
  factory Info.fromMap(Map<String, dynamic> json) => Info(
    id: json['id'],
    name: json['name'],
    des: json['des'],
    qty: json['qty'],
    amt: json['amt'] is int ? json['amt'].toDouble() : json['amt'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'des': des,
      'qty': qty,
      'amt': amt,
      
    };
  }
}
