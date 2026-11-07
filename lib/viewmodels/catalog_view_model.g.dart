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

String _$homeViewModelHash() => r'324dbd5207e6e561d619bc7f7765f91fcebf05ab';
