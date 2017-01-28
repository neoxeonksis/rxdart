import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<num> _getStream() {
  return new Stream<num>.fromIterable(<num>[0, 1, 2, 3]);
}

const List<num> expected = const <num>[0, 1, 2, 3];

void main() {
  test('rx.Observable.onErrorResumeNext', () async {
    int count = 0;

    observable(getErroneousStream())
        .onErrorResumeNext(_getStream())
        .listen(expectAsync1((num result) {
          expect(result, expected[count++]);
        }, count: expected.length));
  });

  test('rx.Observable.onErrorResumeNext.asBroadcastStream', () async {
    Stream<num> stream = observable(getErroneousStream())
        .onErrorResumeNext(_getStream())
        .asBroadcastStream();
    int countA = 0;
    int countB = 0;

    expect(stream.isBroadcast, isTrue);

    stream.listen(expectAsync1((num result) {
      expect(result, expected[countA++]);
    }, count: expected.length));
    stream.listen(expectAsync1((num result) {
      expect(result, expected[countB++]);
    }, count: expected.length));
  });

  test('rx.Observable.onErrorResumeNext.error.shouldThrow', () async {
    Stream<num> observableWithError = observable(getErroneousStream())
        .onErrorResumeNext(getErroneousStream());

    observableWithError.listen((_) {},
        onError: expectAsync2((dynamic e, dynamic s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.onErrorResumeNext.pause.resume', () async {
    StreamSubscription<num> subscription;
    int count = 0;

    subscription = observable(getErroneousStream())
        .onErrorResumeNext(_getStream())
        .listen(expectAsync1((num result) {
      expect(result, expected[count++]);

      if (count == expected.length) {
        subscription.cancel();
      }
    }, count: expected.length));

    subscription.pause();
    subscription.resume();
  });
}
