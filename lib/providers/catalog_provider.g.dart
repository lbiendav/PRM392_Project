// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productRepository)
final productRepositoryProvider = ProductRepositoryProvider._();

final class ProductRepositoryProvider
    extends
        $FunctionalProvider<
          ProductRepository,
          ProductRepository,
          ProductRepository
        >
    with $Provider<ProductRepository> {
  ProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'ef4ed8e8522495c1d47aada2f9dc0384e3e79d87';

@ProviderFor(productList)
final productListProvider = ProductListProvider._();

final class ProductListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductModel>>,
          List<ProductModel>,
          Stream<List<ProductModel>>
        >
    with
        $FutureModifier<List<ProductModel>>,
        $StreamProvider<List<ProductModel>> {
  ProductListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productListHash();

  @$internal
  @override
  $StreamProviderElement<List<ProductModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProductModel>> create(Ref ref) {
    return productList(ref);
  }
}

String _$productListHash() => r'9e8661c7023ed5f8c91201cf553e737a08283e15';

@ProviderFor(branchRepository)
final branchRepositoryProvider = BranchRepositoryProvider._();

final class BranchRepositoryProvider
    extends
        $FunctionalProvider<
          BranchRepository,
          BranchRepository,
          BranchRepository
        >
    with $Provider<BranchRepository> {
  BranchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchRepositoryHash();

  @$internal
  @override
  $ProviderElement<BranchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BranchRepository create(Ref ref) {
    return branchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BranchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BranchRepository>(value),
    );
  }
}

String _$branchRepositoryHash() => r'24be12b1ee51f506c7df6b39ea4f8e3f0fd67235';

@ProviderFor(branchList)
final branchListProvider = BranchListProvider._();

final class BranchListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BranchModel>>,
          List<BranchModel>,
          Stream<List<BranchModel>>
        >
    with
        $FutureModifier<List<BranchModel>>,
        $StreamProvider<List<BranchModel>> {
  BranchListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchListHash();

  @$internal
  @override
  $StreamProviderElement<List<BranchModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BranchModel>> create(Ref ref) {
    return branchList(ref);
  }
}

String _$branchListHash() => r'3b1990d06f15fb3509da2dde6f3cb9c1bd3af1ef';

@ProviderFor(catalogPreferencesRepository)
final catalogPreferencesRepositoryProvider =
    CatalogPreferencesRepositoryProvider._();

final class CatalogPreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          CatalogPreferencesRepository,
          CatalogPreferencesRepository,
          CatalogPreferencesRepository
        >
    with $Provider<CatalogPreferencesRepository> {
  CatalogPreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogPreferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogPreferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<CatalogPreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogPreferencesRepository create(Ref ref) {
    return catalogPreferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogPreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogPreferencesRepository>(value),
    );
  }
}

String _$catalogPreferencesRepositoryHash() =>
    r'785985c4e6ff17193677ce5f2ca06a46e3ae7f68';

@ProviderFor(storeContactRepository)
final storeContactRepositoryProvider = StoreContactRepositoryProvider._();

final class StoreContactRepositoryProvider
    extends
        $FunctionalProvider<
          StoreContactRepository,
          StoreContactRepository,
          StoreContactRepository
        >
    with $Provider<StoreContactRepository> {
  StoreContactRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeContactRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeContactRepositoryHash();

  @$internal
  @override
  $ProviderElement<StoreContactRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StoreContactRepository create(Ref ref) {
    return storeContactRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreContactRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreContactRepository>(value),
    );
  }
}

String _$storeContactRepositoryHash() =>
    r'ce355fdb154d7610c66fd834aff172d45e5f71de';

@ProviderFor(searchHistory)
final searchHistoryProvider = SearchHistoryProvider._();

final class SearchHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  SearchHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return searchHistory(ref);
  }
}

String _$searchHistoryHash() => r'0f8ac2ebc26b0a90d5d1c01cd8eb4906f397c8f4';

@ProviderFor(catalogClock)
final catalogClockProvider = CatalogClockProvider._();

final class CatalogClockProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  CatalogClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogClockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogClockHash();

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    return catalogClock(ref);
  }
}

String _$catalogClockHash() => r'35505693db6a1160e5d1fc6ceb04395591d515dd';
