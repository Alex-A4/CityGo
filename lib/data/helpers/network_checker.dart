import 'package:connectivity/connectivity.dart';

/// Абстрактный класс для получения информации о том, имеет ли пользователь
/// подключение к сети или нет.
abstract class NetworkChecker {
  Future<bool> get hasInternet;
}

class NetworkCheckerImpl extends NetworkChecker {
  final Connectivity connectivity;

  NetworkCheckerImpl(this.connectivity);

  @override
  Future<bool> get hasInternet async {
    var c = await connectivity.checkConnectivity();
    if (c == ConnectivityResult.none) return false;
    return true;
  }
}
