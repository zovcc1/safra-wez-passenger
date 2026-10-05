/// المبالغ سلاسل عشرية من الخادم، تُبقى String ولا تُحوَّل إلى double.
class WalletModel {
  final String currency;
  final String balance;
  final String frozenBalance;
  final String totalBalance;
  final DateTime? updatedAt;

  const WalletModel({
    required this.currency,
    required this.balance,
    required this.frozenBalance,
    required this.totalBalance,
    this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    currency: json["currency"]?.toString() ?? "",
    balance: json["balance"]?.toString() ?? "0.00",
    frozenBalance: json["frozen_balance"]?.toString() ?? "0.00",
    totalBalance: json["total_balance"]?.toString() ?? "0.00",
    updatedAt: DateTime.tryParse(
      json["updated_at"]?.toString() ?? "",
    )?.toLocal(),
  );
}
