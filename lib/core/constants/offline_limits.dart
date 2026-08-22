/// Internal governance constants for offline-first operations.
library;

/// Maximum duration (in hours) a technician can work offline before receiving advisory warnings.
const int kMaxOfflineDurationHours = 2;

/// Maximum number of queued offline mutations before receiving advisory warnings.
const int kMaxOfflinePendingRequests = 10;

/// Interval frequency of offline actions between advisory alert dialogs once the threshold is breached.
const int kOfflineAlertThrottleFrequency = 3;
