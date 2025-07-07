// duration
const Duration zero = Duration.zero;
const Duration oneMinute = Duration(minutes: 1);
const Duration twoMinute = Duration(minutes: 2);
const Duration thrMinute = Duration(minutes: 3);
const Duration oneSecond = Duration(seconds: 1);
const Duration twoSecond = Duration(seconds: 2);
const Duration thrSecond = Duration(seconds: 3);
const Duration fivSecond = Duration(seconds: 5);
const Duration oneMilliSecond = Duration(milliseconds: 100);
const Duration twoMilliSecond = Duration(milliseconds: 200);
const Duration thrMilliSecond = Duration(milliseconds: 300);
const Duration fivMilliSecond = Duration(milliseconds: 500);
const Duration oneMicroSecond = Duration(microseconds: 100);
const Duration twoMicroSecond = Duration(microseconds: 200);
const Duration thrMicroSecond = Duration(microseconds: 300);
const Duration fivMicroSecond = Duration(microseconds: 500);

Future oneSecondDelay(void Function() action) =>
    Future.delayed(oneSecond, action);
Future twoSecondDelay(void Function() action) =>
    Future.delayed(twoSecond, action);
Future thrSecondDelay(void Function() action) =>
    Future.delayed(thrSecond, action);