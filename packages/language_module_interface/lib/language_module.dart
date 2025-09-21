import 'models.dart';

abstract class LanguageModule {
  Future<LanguageModuleData> load();
}
