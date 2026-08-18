import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProService extends ChangeNotifier {
  ProService._();

  static final ProService instance = ProService._();
  static const productId = 'pro';

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  ProductDetails? _product;
  bool _initialized = false;
  bool _isPro = false;
  bool _loading = false;

  bool get isPro => _isPro;
  bool get loading => _loading;
  ProductDetails? get product => _product;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchases,
    );
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) return;
      final response = await InAppPurchase.instance.queryProductDetails({
        productId,
      });
      _product = response.productDetails.firstOrNull;
      await InAppPurchase.instance.restorePurchases();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> buyPro() async {
    final productDetails = _product;
    if (productDetails == null) return false;
    return InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: productDetails),
    );
  }

  Future<void> restore() => InAppPurchase.instance.restorePurchases();

  void _handlePurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _isPro = true;
        notifyListeners();
      }
      if (purchase.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
