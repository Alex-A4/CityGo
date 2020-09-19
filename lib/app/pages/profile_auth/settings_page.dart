import 'package:city_go/app/general_widgets/city_checkbox.dart';
import 'package:city_go/app/general_widgets/custom_appbar.dart';
import 'package:city_go/app/general_widgets/drop_down.dart';
import 'package:city_go/app/widgets/profile_auth/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

/// Экран настроек
class SettingsPage extends StatelessWidget {
  final ProfileBloc bloc;
  final Profile profile;

  SettingsPage({Key key, @required this.bloc, @required this.profile})
      : assert(bloc != null && profile != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.subtitle1;
    return Scaffold(
      appBar: CityAppBar(title: Text(context.localization(PROFILE_WORD))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CityDropDown(
            head: Text(context.localization(NOTIFICATION_WORD), style: style),
            onTap: () {
              print('NOTIFICATION');
            },
          ),
          LocaleSelector(),
          CityDropDown(
            head: Text(context.localization(TRAINING_WORD), style: style),
            onTap: () {
              print('TRAINING');
            },
          ),
          Expanded(child: Container()),
          CityDropDown(
            head: Text(context.localization(CHANGE_PROFILE), style: style),
            onTap: () => bloc.add(ProfileLogoutEvent()),
          ),
        ],
      ),
    );
  }
}

class LocaleSelector extends StatelessWidget {
  LocaleSelector({Key key}) : super(key: key);

  final Map<String, String> localeMap = {
    supportedLocales[0]: 'Русский',
    supportedLocales[1]: 'English',
  };

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.subtitle1;
    return CityDropDown(
      head: Text(context.localization(LANGUAGE_WORD), style: style),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: CityGroupRadioBox(
          values: supportedLocales,
          initValue: context.locale,
          onChanged: (l) {
            LocalizationBuilder.setLocale(context, Locale(l));
          },
          titles: supportedLocales.map((l) => Text(localeMap[l])).toList(),
        ),
      ),
    );
  }
}
