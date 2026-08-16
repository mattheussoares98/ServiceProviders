# Business Rules — ServiceProviders Project

This document establishes the official domain and business logic rules across the application.

---

## 1. Work Order Pause & Conclusion Lifecycle

Work order pauses and completion requests are tracked in `work_order_pause_requests` (a separate history table) and synchronize the main `work_orders` status automatically.

### Rule Matrix

| Rule | Action | User Has Permission? | Resulting Work Order Status | Pause Request Row Status | Review Behavior |
|---|---|---|---|---|---|
| **1: Pending Pause** | Request Pause | ❌ No (`managePendingRequests` denied or provider mode) | **`onHold`** | `pending` | Reviewing does **NOT** alter the work order status (remains `onHold`). Only updates responsibility/reason. |
| **2: Direct Pause** | Request Pause | ✅ Yes (`managePendingRequests` granted & internal mode) | **`onHold`** | `approved` | Direct approval; no pending request is left. |
| **3: Pending Completion** | Request Completion | ❌ No (`managePendingRequests` denied or provider mode) | **`pendingConclusionApproval`** | `pending` | **Accept:** changes status to `completed` and sets `completedAt`.<br>**Reject:** changes status back to `inProgress`. |
| **4: Direct Completion** | Request Completion | ✅ Yes (`managePendingRequests` granted & internal mode) | **`completed`** | `approved` | Direct conclusion; no pending completion is left. |

---

## 2. Pause Responsibility & SLA Impact

- **Responsibility Classification:**
  - `contractor`: Pause is attributed to contractor delay.
  - `provider`: Pause is attributed to service provider.
  - `both`: Shared responsibility.
- **SLA Calculation:**
  - Pending pause requests remain saved in `work_order_pause_requests` for accurate responsibility attribution.
  - Pausing the work order immediately changes the work order status to `onHold` to halt the active clock.
  - When the supervisor/admin reviews the pending pause, they designate the `responsibility` without having to change the work order status again.
- **Locking & Blocking:**
  - When a work order has status `pendingConclusionApproval`, it cannot be manually switched to other statuses via dropdowns until the pending conclusion request is reviewed (approved or rejected).
