class ApiEndpoints {
  ApiEndpoints._();

  /// Base
  static const auth = 'api/auth/';

  // Auth
  static const login = '${auth}login';
  static const refreshToken = '${auth}refreshToken';
  static const checkAuth = '${auth}check-auth';

  // Categories
  static const categories = 'api/categories';
  static String categoryById(String id) => 'api/categories/$id';

  // Locations
  static const locations = 'api/locations';
  static String locationById(String id) => 'api/locations/$id';

  // Areas
  static const areas = 'api/areas';
  static String areaById(String id) => 'api/areas/$id';

  // Assets
  static const assets = 'api/assets';
  static String assetById(String id) => 'api/assets/$id';
}

