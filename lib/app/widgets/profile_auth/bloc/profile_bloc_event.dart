import 'package:city_go/domain/entities/profile/user.dart';
import 'package:equatable/equatable.dart';

/// Абстрактное событие профиля
abstract class ProfileEvent extends Equatable {}

/// Событие для попытки совершить авторизацию через внешние источники.
/// Поле [user] должно быть создано на уровне выше, когда производится попытка
/// авторизации.
/// Регистрация равносильна авторизации через внешний источник.
class ProfileAuthExternalEvent extends ProfileEvent {
  final ExternalUser user;

  ProfileAuthExternalEvent(this.user);

  @override
  List<Object> get props => [user];
}

/// Событие для попытки совершить регистрацию через наш сервер.
class ProfileAuthInternalEvent extends ProfileEvent {
  final String userName;
  final String password;

  ProfileAuthInternalEvent(this.userName, this.password);

  @override
  List<Object> get props => [userName, password];
}

/// Пользователь пытается совершить авторизацию через наш сервер
class ProfileLogInEvent extends ProfileEvent {
  final String userName;
  final String password;

  ProfileLogInEvent(this.userName, this.password);

  @override
  List<Object> get props => [userName, password];
}

/// Пользователь пытается сменить аккаунт (разлогиниться)
class ProfileLogoutEvent extends ProfileEvent {
  @override
  List<Object> get props => [];
}

/// Пользователь нажимает кнопку "есть аккаунт" и пытается авторизоваться
class ProfileGoToLoginEvent extends ProfileEvent {
  @override
  List<Object> get props => [];
}

/// Пользователь нажимает кнопку "создать аккаунт"
class ProfileGoToAuthEvent extends ProfileEvent {
  @override
  List<Object> get props => [];
}
