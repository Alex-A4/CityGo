import 'dart:convert' show json;

import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:city_go/domain/repositories/profile/profile_repository.dart';
import 'package:hive/hive.dart';

export 'package:city_go/domain/repositories/profile/profile_repository.dart';

/// Реализация репозитория, который читает и сохраняет профиль
class ProfileRepositoryImpl extends ProfileRepository {
  static const kProfile = 'profile';
  final HiveInterface hive;

  ProfileRepositoryImpl({required this.hive});

  @override
  Future<Profile> readProfile() async {
    var box = await hive.openBox(kProfile);
    var data = box.get(kProfile);
    if (data == null) return Profile.empty();

    var j = json.decode(data);
    return Profile.fromJson(j);
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    var box = await hive.openBox(kProfile);
    await box.put(kProfile, json.encode(profile.toJson()));
  }
}
