import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/Lot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'lot_repo_event.dart';
part 'lot_repo_state.dart';

class LotRepoBloc extends Bloc<LotRepoEvent, LotRepoState> {
  LotRepoBloc() : super(LotRepoInitial());
  StreamSubscription<QuerySnapshot> lots;

  @override
  Stream<LotRepoState> mapEventToState(
    LotRepoEvent event,
  ) async* {
    if (event is InitializeLotRepo) {
      print("INITIALIZING LOT REPO");
      lots = FirebaseFirestore.instance
          .collection("lots")
          .where("partnerId", isEqualTo: event.uid)
          .snapshots()
          .listen((result) {
        List<Lot> temp = [];
        for (QueryDocumentSnapshot r in result.docs) {
          print(r.data());
          temp.add(Lot.fromDoc(r));
        }
        add(UpdateLotRepo(lots: temp));
      });
    }
    if (event is UpdateLotRepo) {
      print("UPDATING LOTS");
      yield LotsReady(lots: event.lots);
    }
    if (event is DisposeLotRepo) {
      print("LotRepoCalledDispose");
      await lots.cancel();
    }
  }
}
