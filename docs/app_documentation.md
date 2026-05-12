# Service Providers Application Documentation

## 1. Project Overview
The **Service Providers** application is a platform designed to connect service providers (like plumbers, electricians, cleaners, etc.) with customers in a seamless and secure environment.

## 2. Technical Stack
The app follows **Clean Architecture** principles to ensure scalability and maintainability.

| Component | Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter | Cross-platform UI (iOS, Android, Web, Windows) |
| **State Management** | BLoC (Cubit) | Predictable state flow and layer separation |
| **Authentication** | Firebase Auth | Stable, non-pausing authentication with Google Login support |
| **Database** | Supabase (PostgreSQL) | Robust relational database and real-time capabilities |
| **Crash Reporting** | Firebase Crashlytics | Essential stability monitoring |
| **Analytics** | Firebase Analytics | User behavior and data usage tracking |
| **DI / Routing** | GetIt / AutoRoute | Industry-standard dependency injection and navigation |

## 3. Architectural Rationale

### Hybrid Backend (Firebase + Supabase)
We have chosen a hybrid approach to maximize reliability:
- **Why Firebase Auth?** To avoid the "2-week pause" limitation of the Supabase free tier. Firebase Auth ensures that users can always log in, even if the database project is temporarily inactive.
- **Why Supabase Database?** For its powerful PostgreSQL capabilities, row-level security (RLS), and real-time features which are superior for managing complex service provider listings and schedules.
- **Why Firebase Crashlytics?** It is considered the industry standard for Flutter apps to track bugs and performance issues in real-time.

## 4. Key Features (Planned)
- **Service Provider Registration:** Easy onboarding using Google Login.
- **Profile Management:** Providers can showcase their skills, portfolio, and ratings.
- **Service Discovery:** Customers can search for providers based on category and location.
- **Booking System:** Integrated scheduling between customers and providers.
