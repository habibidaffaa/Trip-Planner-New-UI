import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static final DotEnv _env = DotEnv();

  static Future<void> load() async {
    await _env.load(
      fileName: '.env',
    );
  }

  static Future<String> getKey() async {
    await _env.load(
      fileName: '.env',
    );
    return _env.get('GPT_KEY');
  }

  static String gptKey = _env.get('GPT_KEY');
}
