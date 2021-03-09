import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:equatable/equatable.dart';

/// Абстрактное состояние профиля
abstract class ProfileState extends Equatable {}

/// Пользователь авторизован и показывается окно профиля
class ProfileAuthenticatedState extends ProfileState {
  final Profile profile;

  ProfileAuthenticatedState(this.profile);

  @override
  List<Object> get props => [profile];
}

/// Пользователь не авторизован и показывается окно авторизации.
/// Когда пользователь пытается разлогиниться, должно появляться это же состояние.
class ProfileNeedAuthState extends ProfileState {
  final String? errorCode;

  ProfileNeedAuthState({this.errorCode});

  @override
  List<Object?> get props => [errorCode];
}

/// Пользователь не авторизован, но у него есть аккаунт и он хочет войти.
/// Показывает кнопку входа вместо регистрации
class ProfileNeedLoginState extends ProfileState {
  final String? errorCode;

  ProfileNeedLoginState({this.errorCode});

  @override
  List<Object?> get props => [errorCode];
}
