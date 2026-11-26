import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_api.dart';
import 'details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit(this._api, this._id) : super(const DetailsLoading());
  final ProductApi _api;
  final int _id;

  Future<void> load() async {
    emit(const DetailsLoading());
    try {
      final product = await _api.getProduct(_id);
      if (isClosed) return;
      emit(DetailsLoaded(product));
    } on ApiException catch (e) {
      if (!isClosed) emit(DetailsError(e.message));
    }
  }
}
