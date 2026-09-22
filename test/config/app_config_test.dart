import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('TestAppConfig has default support email', () {
      const config = TestAppConfig();
      expect(config.supportEmail, 'contact@soarescodes.com.br');
    });

    test('TestAppConfig allows overriding support email', () {
      const config = TestAppConfig(supportEmail: 'custom@domain.com');
      expect(config.supportEmail, 'custom@domain.com');
    });

    test('AppConfig flavors read default or fallback email safely', () {
      dotenv.loadFromString(
        envString:
            'SUPABASE_URL=https://sb.co\nSUPABASE_BASE_URL=https://app.co',
      );

      final prod = AppConfigProd();
      expect(prod.supportEmail, AppConfig.defaultSupportEmail);
      expect(prod.flavor, Flavor.production);

      final stg = AppConfigStg();
      expect(stg.supportEmail, AppConfig.defaultSupportEmail);
      expect(stg.flavor, Flavor.staging);

      final dev = AppConfigDev();
      expect(dev.supportEmail, AppConfig.defaultSupportEmail);
      expect(dev.flavor, Flavor.development);
    });

    test('AppConfig flavors respect SUPPORT_EMAIL from environment', () {
      dotenv.loadFromString(
        envString:
            'SUPABASE_URL=https://sb.co\nSUPABASE_BASE_URL=https://app.co\nSUPPORT_EMAIL=custom@test.com',
      );

      final prod = AppConfigProd();
      expect(prod.supportEmail, 'custom@test.com');
    });
  });
}
