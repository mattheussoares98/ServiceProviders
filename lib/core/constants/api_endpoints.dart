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

  // Work Orders
  static const workOrders = 'api/work-orders';
  static String workOrderById(String id) => 'api/work-orders/$id';

  // Tasks
  static const tasks = 'api/tasks';
  static String taskById(String id) => 'api/tasks/$id';

  // Change Requests
  static const changeRequests = 'api/change-requests';
  static String changeRequestById(String id) => 'api/change-requests/$id';

  // History
  static const workOrderHistory = 'api/work-order-history';

  // Checklist Templates
  static const checklistTemplates = 'api/checklist-templates';
  static String checklistTemplateById(String id) =>
      'api/checklist-templates/$id';

  // Checklist Items
  static const checklistItems = 'api/checklist-items';
  static String checklistItemById(String id) => 'api/checklist-items/$id';

  // Storage — Supabase Edge Functions
  //TODO check why is using it here
  static const generatePresignedUrl = 'functions/v1/generate_presigned_url';
}
