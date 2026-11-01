# CampConnect

CampConnect is a Flutter application for university students, senior students,
and alumni to collaborate on academic work, find mentors, participate in
communities, share resources, and communicate.

This repository contains the frontend application and its project design and
requirements documents. The application uses local mock data for previews;
administrative and account actions do not communicate with a backend.

## Features

- Role-based Student, Senior, Alumni, and Admin preview experiences
- Dashboard, profile, and account settings
- Communities, discussions, and project collaboration
- Mentorship discovery and requests
- Messaging interface
- Resource library and Admin resource moderation
- Notifications and announcement management
- Responsive Admin Panel for desktop and mobile layouts
- Admin login preview for demonstrating Admin-only screens

## Technology

- Flutter and Dart
- Material Design
- In-memory mock data; no backend or persistent storage

## Getting started

Install the Flutter SDK for your platform, then from the repository root run:

```sh
flutter pub get
flutter run
```

To run the tests and static analysis:

```sh
flutter test
flutter analyze
```

Flutter platform-specific setup may be required to run on Android, iOS, Web,
Linux, macOS, or Windows. See the [Flutter installation
guide](https://docs.flutter.dev/get-started/install) for details.

## Admin preview

Open **Admin Login** from the regular login screen. The following mock
credentials are for frontend demonstration only and do not authenticate a real
account:

| Field | Preview value |
| --- | --- |
| Email | `admin@campconnect.com` |
| Password | `Admin123` |

All preview state resets when the application restarts. Do not use these
credentials as a production authentication mechanism.

## Project documentation

Design diagrams and requirements are included in the repository:

- [System architecture](Design/CampConnect_System_Architecture.drawio)
- [Sequence diagrams](Design/SequanceDiagram/)
- [UI/UX assets](Design/UI%20and%20UX/)
- [Entity relationship diagrams](Documentaion/ERD/)
- [Software requirements specification](Documentaion/SRS/CampConnect_SRS_v1.0.docx)
- [Use case diagrams](Documentaion/UseCase%20Diagram/)

## Project structure

```text
lib/
  core/                   Shared theme and app infrastructure
  features/               Authentication and application modules
test/                     Flutter widget and module tests
Design/                   UI assets and design diagrams
Documentaion/             SRS, ERD, and use case documentation
```

## Scope

CampConnect is currently a frontend demonstration project. It does not include
server-side authentication, APIs, a database, or durable storage. Local mock
actions should not be interpreted as changes to real university accounts or
content.
