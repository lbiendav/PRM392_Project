// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeCategoryViewModel)
final homeCategoryViewModelProvider = HomeCategoryViewModelProvider._();

final class HomeCategoryViewModelProvider
    extends $NotifierProvider<HomeCategoryViewModel, String> {
  HomeCategoryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeCategoryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeCategoryViewModelHash();

  @$internal
  @override
  HomeCategoryViewModel create() => HomeCategoryViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$homeCategoryViewModelHash() =>
    r'988843f10b691bb36ed7d4332f89566197708283';

abstract class _$HomeCategoryViewModel extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CategoryMenuViewModel)
final categoryMenuViewModelProvider = CategoryMenuViewModelFamily._();

final class CategoryMenuViewModelProvider
    extends $NotifierProvider<CategoryMenuViewModel, CategoryMenuState> {
  CategoryMenuViewModelProvider._({
    required CategoryMenuViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryMenuViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryMenuViewModelHash();

  @override
  String toString() {
    return r'categoryMenuViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryMenuViewModel create() => CategoryMenuViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryMenuState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryMenuState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryMenuViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryMenuViewModelHash() =>
    r'c025be46ab274c5a2e1790c61baf1d81952c4d6c';

final class CategoryMenuViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryMenuViewModel,
          CategoryMenuState,
          CategoryMenuState,
          CategoryMenuState,
          String
        > {
  CategoryMenuViewModelFamily._()
    : super(
        retry: null,
        name: r'categoryMenuViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryMenuViewModelProvider call(String initialCategory) =>
      CategoryMenuViewModelProvider._(argument: initialCategory, from: this);

  @override
  String toString() => r'categoryMenuViewModelProvider';
}

abstract class _$CategoryMenuViewModel extends $Notifier<CategoryMenuState> {
  late final _$args = ref.$arg as String;
  String get initialCategory => _$args;

  CategoryMenuState build(String initialCategory);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CategoryMenuState, CategoryMenuState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategoryMenuState, CategoryMenuState>,
              CategoryMenuState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(homeViewModel)
final homeViewModelProvider = HomeViewModelProvider._();

final class HomeViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<HomeData>,
          AsyncValue<HomeData>,
          AsyncValue<HomeData>
        >
    with $Provider<AsyncValue<HomeData>> {
  HomeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeViewModelHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<HomeData>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<HomeData> create(Ref ref) {
    return homeViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<HomeData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<HomeData>>(value),
    );
  }
}

String _$homeViewModelHash() => r'c1be4c29c38fef315bce810c105c29e991393972';

@ProviderFor(categoryMenuProducts)
final categoryMenuProductsProvider = CategoryMenuProductsFamily._();

final class CategoryMenuProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductModel>>,
          AsyncValue<List<ProductModel>>,
          AsyncValue<List<ProductModel>>
        >
    with $Provider<AsyncValue<List<ProductModel>>> {
  CategoryMenuProductsProvider._({
    required CategoryMenuProductsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryMenuProductsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryMenuProductsHash();

  @override
  String toString() {
    return r'categoryMenuProductsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<ProductModel>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<ProductModel>> create(Ref ref) {
    final argument = this.argument as String;
    return categoryMenuProducts(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ProductModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<ProductModel>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryMenuProductsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryMenuProductsHash() =>
    r'bfafd6302ddd59945e7ca9072cd8037e91bb5ff8';

final class CategoryMenuProductsFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<ProductModel>>, String> {
  CategoryMenuProductsFamily._()
    : super(
        retry: null,
        name: r'categoryMenuProductsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryMenuProductsProvider call(String initialCategory) =>
      CategoryMenuProductsProvider._(argument: initialCategory, from: this);

  @override
  String toString() => r'categoryMenuProductsProvider';
}

@ProviderFor(SearchViewModel)
final searchViewModelProvider = SearchViewModelProvider._();

final class SearchViewModelProvider
    extends $NotifierProvider<SearchViewModel, SearchState> {
  SearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchViewModelHash();

  @$internal
  @override
  SearchViewModel create() => SearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchViewModelHash() => r'22213273ec08f058dcbc6ee4353997b114dbae53';

abstract class _$SearchViewModel extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsProvider._();

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductModel>>,
          AsyncValue<List<ProductModel>>,
          AsyncValue<List<ProductModel>>
        >
    with $Provider<AsyncValue<List<ProductModel>>> {
  SearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<ProductModel>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<ProductModel>> create(Ref ref) {
    return searchResults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ProductModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<ProductModel>>>(
        value,
      ),
    );
  }
}

String _$searchResultsHash() => r'7194c956fd375538a9277c061e554c00e6021795';

@ProviderFor(BranchViewModel)
final branchViewModelProvider = BranchViewModelProvider._();

final class BranchViewModelProvider
    extends $NotifierProvider<BranchViewModel, BranchListState> {
  BranchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchViewModelHash();

  @$internal
  @override
  BranchViewModel create() => BranchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BranchListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BranchListState>(value),
    );
  }
}

String _$branchViewModelHash() => r'131fec7ba8b8e802a8843cf274ede27a14dcae7a';

abstract class _$BranchViewModel extends $Notifier<BranchListState> {
  BranchListState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BranchListState, BranchListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BranchListState, BranchListState>,
              BranchListState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(visibleBranches)
final visibleBranchesProvider = VisibleBranchesProvider._();

final class VisibleBranchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BranchModel>>,
          AsyncValue<List<BranchModel>>,
          AsyncValue<List<BranchModel>>
        >
    with $Provider<AsyncValue<List<BranchModel>>> {
  VisibleBranchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleBranchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleBranchesHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<BranchModel>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<BranchModel>> create(Ref ref) {
    return visibleBranches(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<BranchModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<BranchModel>>>(
        value,
      ),
    );
  }
}

String _$visibleBranchesHash() => r'f7b81caab2899e1491436acf2a33649ba4a12f05';

@ProviderFor(selectedBranch)
final selectedBranchProvider = SelectedBranchProvider._();

final class SelectedBranchProvider
    extends
        $FunctionalProvider<
          AsyncValue<BranchModel?>,
          BranchModel?,
          FutureOr<BranchModel?>
        >
    with $FutureModifier<BranchModel?>, $FutureProvider<BranchModel?> {
  SelectedBranchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedBranchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedBranchHash();

  @$internal
  @override
  $FutureProviderElement<BranchModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BranchModel?> create(Ref ref) {
    return selectedBranch(ref);
  }
}

String _$selectedBranchHash() => r'1b29471ca6d21551b81abaa3590e8308c5cb3df1';
