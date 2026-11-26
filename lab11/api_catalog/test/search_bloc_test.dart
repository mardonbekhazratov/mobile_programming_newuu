import 'package:api_catalog/bloc/search_bloc.dart';
import 'package:api_catalog/bloc/search_event.dart';
import 'package:api_catalog/bloc/search_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_api.dart';

void main() {
  blocTest<SearchBloc, SearchState>(
    'SearchSubmitted("phone") emits loading, then results',
    build: () => SearchBloc(fakeApi(pageBody())),
    act: (bloc) => bloc.add(const SearchSubmitted('phone')),
    expect: () => [isA<SearchLoading>(), isA<SearchResults>()],
  );

  blocTest<SearchBloc, SearchState>(
    'SearchSubmitted(" ") emits only idle',
    build: () => SearchBloc(fakeApi(pageBody())),
    act: (bloc) => bloc.add(const SearchSubmitted(' ')),
    expect: () => [isA<SearchIdle>()],
  );
}
