class Payment {
  final String id;
  final DateTime date;
  final String method;
  final double amount;
  final String saleId;

  Payment({
    required this.id,
    required this.date,
    required this.method,
    required this.amount,
    required this.saleId,
  });
}