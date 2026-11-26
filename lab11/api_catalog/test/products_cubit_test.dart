import 'package:api_catalog/cubit/products_cubit.dart';
import 'package:api_catalog/cubit/products_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_api.dart';

void main() {
  blocTest<ProductsCubit, ProductsState>(
    'load emits loading, then loaded',
    build: () => ProductsCubit(fakeApi(pageBody())),
    act: (cubit) => cubit.load(),
    expect: () => [isA<ProductsLoading>(), isA<ProductsLoaded>()],
  );

  blocTest<ProductsCubit, ProductsState>(
    'load emits loading, then error when the server fails',
    build: () => ProductsCubit(fakeApi('Internal error', status: 500)),
    act: (cubit) => cubit.load(),
    expect: () => [isA<ProductsLoading>(), isA<ProductsError>()],
  );
}
