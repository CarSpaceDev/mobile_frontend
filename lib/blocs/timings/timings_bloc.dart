import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'timings_event.dart';
part 'timings_state.dart';

class TimingsBloc extends Bloc<TimingsEvent, TimingsState> {
  TimingsBloc() : super(TimingsInitial());
  Map<TimingsType, DateTime> timings = Map<TimingsType, DateTime>();
  Map<TimingsType, String> result = Map<TimingsType, String>();
  @override
  Stream<TimingsState> mapEventToState(
    TimingsEvent event,
  ) async* {
    if (event is StartTest) {
      print("STARTING TEST ${event.type}");
      timings.putIfAbsent(event.type, () => DateTime.now());
    }
    if (event is EndTest) {
      print("ENDING TEST ${event.type}");
      result.putIfAbsent(event.type, () {
        return "${DateTime.now().millisecondsSinceEpoch - timings[event.type].millisecondsSinceEpoch} ms";
      });
      add(GetResults());
    }
    if (event is GetResults) {
      print("TIMINGS RESULT");
      print("++++++++++++++++");
      print(result);
      print("++++++++++++++++");
    }
  }
}
