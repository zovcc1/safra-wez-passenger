class WalletTransactionReferenceModel {
  final String type;
  final int? id;

  const WalletTransactionReferenceModel({required this.type, this.id});

  factory WalletTransactionReferenceModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionReferenceModel(
        type: json["type"]?.toString() ?? "",
        id: json["id"] is num ? (json["id"] as num).toInt() : null,
      );
}

class WalletTransactionModel {
  final int transactionId;
  final String type;
  final String amount;
  final String direction;
  final String balanceAfter;
  final String frozenAfter;
  final WalletTransactionReferenceModel? reference;
  final DateTime? createdAt;

  const WalletTransactionModel({
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.direction,
    required this.balanceAfter,
    required this.frozenAfter,
    this.reference,
    this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionModel(
        transactionId: json["transaction_id"] ?? 0,
        type: json["type"]?.toString() ?? "",
        amount: json["amount"]?.toString() ?? "0.00",
        direction: json["direction"]?.toString() ?? "",
        balanceAfter: json["balance_after"]?.toString() ?? "0.00",
        frozenAfter: json["frozen_after"]?.toString() ?? "0.00",
        reference: json["reference"] is Map
            ? WalletTransactionReferenceModel.fromJson(
                Map<String, dynamic>.from(json["reference"]),
              )
            : null,
        createdAt: DateTime.tryParse(
          json["created_at"]?.toString() ?? "",
        )?.toLocal(),
      );
}
