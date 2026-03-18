// test/controllers/search_controller_test.dart
//
// Tests for MarcatSearchController.search()
// Run with: flutter test test/controllers/search_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/search_controller.dart';
import 'package:marcat/models/product_model.dart';
import 'package:marcat/models/enums.dart';
import 'package:marcat/controllers/product_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake ProductController — only overrides fetchProducts
// ─────────────────────────────────────────────────────────────────────────────

class _FakeProductController extends GetxController
    implements ProductController {
  List<ProductModel> _fakeResults = [];

  void setFakeResults(List<ProductModel> results) {
    _fakeResults = results;
  }

  @override
  Future<(List<ProductModel>, int)> fetchProducts({
    int page = 0,
    int pageSize = 20,
    String? query,
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    int? storeId,
    String sortBy = 'created_at',
    bool ascending = false,
    bool updateState = true,
  }) async {
    return (_fakeResults, _fakeResults.length);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late _FakeProductController fakeProductCtrl;
  late MarcatSearchController ctrl;

  setUp(() {
    Get.reset();
    fakeProductCtrl = _FakeProductController();
    Get.put<ProductController>(fakeProductCtrl);
    ctrl = MarcatSearchController();
    Get.put(ctrl);
  });

  tearDown(() {
    ctrl.onClose();
    Get.reset();
  });

  group('MarcatSearchController.search()', () {
    test('empty query clears results and resets hasSearched', () async {
      // Pre-populate state as if a search already ran.
      ctrl.results.add(_fakeProduct(1, 'Blue Shirt'));
      ctrl.hasSearched.value = true;

      await ctrl.search('');

      expect(ctrl.results, isEmpty);
      expect(ctrl.hasSearched.value, isFalse);
      expect(ctrl.isSearching.value, isFalse);
      expect(ctrl.query.value, '');
    });

    test('non-empty query sets hasSearched=true and populates results',
        () async {
      fakeProductCtrl.setFakeResults([_fakeProduct(1, 'Linen Blazer')]);

      await ctrl.search('blazer');

      expect(ctrl.hasSearched.value, isTrue);
      expect(ctrl.results, hasLength(1));
      expect(ctrl.results.first.name, 'Linen Blazer');
      expect(ctrl.isLoading.value, isFalse);
    });

    test('whitespace-only query is treated as empty', () async {
      ctrl.results.add(_fakeProduct(1, 'Some Product'));
      ctrl.hasSearched.value = true;

      await ctrl.search('   ');

      expect(ctrl.results, isEmpty);
      expect(ctrl.hasSearched.value, isFalse);
    });
  });

  group('MarcatSearchController.clear()', () {
    test('resets all observable state', () async {
      fakeProductCtrl.setFakeResults([_fakeProduct(1, 'T-Shirt')]);
      await ctrl.search('shirt');
      ctrl.textController.text = 'shirt';

      ctrl.clear();

      expect(ctrl.textController.text, '');
      expect(ctrl.query.value, '');
      expect(ctrl.results, isEmpty);
      expect(ctrl.hasSearched.value, isFalse);
      expect(ctrl.isSearching.value, isFalse);
    });
  });
}

// ── Helpers ──────────────────────────────────────────────────────────────────

ProductModel _fakeProduct(int id, String name) {
  final now = DateTime(2024, 1, 1);
  return ProductModel(
    id: id,
    name: name,
    sku: 'SKU-$id',
    basePrice: 10.0,
    status: ProductStatus.active,
    createdAt: now,
    updatedAt: now,
  );
}
