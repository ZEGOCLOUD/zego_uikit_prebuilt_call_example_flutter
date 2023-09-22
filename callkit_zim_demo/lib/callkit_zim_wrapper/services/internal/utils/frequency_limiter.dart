import 'dart:async';

class FrequencyLimiter<T> {
  bool isCalling = false;
  final Duration duration;
  FrequencyLimiter(this.duration);

  T run(T fallback, T Function() method) {
    if (isCalling) return fallback;
    isCalling = true;
    Timer(duration, () {
      isCalling = false;
    });
    return method.call();
  }
}
