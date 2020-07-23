import 'package:get_it/get_it.dart';

/// Сервис локатор приложения, который отвечает за DI всех классов.
/// Для получения класса, необходимо вызвать
/// ```
/// sl<MyClass>();
/// ```
/// указав в качестве MyClass название класса, объект которого необходимо получить
GetIt sl = GetIt.instance;

/// Инициализация локатора всеми зависимости, которые встречаются в приложении
/// Чем ниже находится секция, тем больше зависимостей она использует и наоборот.
Future<void> initServiceLocator() async {
  ;
}
