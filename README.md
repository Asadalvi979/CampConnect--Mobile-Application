# CampConnect

**A university community and collaboration platform built with Flutter.**

CampConnect brings students, senior students, alumni, and administrators together in one place. It is designed to support academic collaboration, mentorship, knowledge sharing, campus communities, and communication within a university environment.

> **Current release: Frontend preview.** This repository contains the Flutter frontend, UI/UX assets, and project documentation. The application currently runs with local mock data and in-memory state. Backend services, APIs, database integration, and persistent storage have not been implemented.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Objectives](#objectives)
- [User Roles](#user-roles)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Application Architecture](#application-architecture)
- [Getting Started](#getting-started)
- [Running Tests and Analysis](#running-tests-and-analysis)
- [Admin Preview](#admin-preview)
- [Project Documentation](#project-documentation)
- [Repository Structure](#repository-structure)
- [Current Scope and Limitations](#current-scope-and-limitations)
- [Planned Development](#planned-development)
- [Contributors](#contributors)

## Project Overview

University communities often rely on disconnected channels for academic help, mentorship, project partners, learning resources, and announcements. CampConnect is intended to bring these activities into a unified university-focused platform.

The application is being developed as a modular Flutter project. Its interface is organized around distinct features and role-based experiences, with shared application infrastructure and reusable UI components.

## Objectives

- Make academic collaboration and peer support easier.
- Help students discover and connect with mentors.
- Provide spaces for university communities and discussions.
- Support project collaboration and resource sharing.
- Give students and alumni a place to communicate according to platform access rules.
- Provide administrators with tools to manage users, resources, and announcements.

## User Roles

| Role | Description |
| --- | --- |
| **Student** | Uses the platform for academic collaboration, communities, resources, mentorship discovery, and communication. |
| **Senior** | A specialized student role with additional senior-guidance and mentorship capabilities. |
| **Alumni** | Participates in the university community and provides mentorship and career guidance. |
| **Admin** | Manages users, resource moderation, and campus announcements through the Admin Panel. |

## Features

The frontend is divided into the following modules:

| Module | Included screens and capabilities |
| --- | --- |
| **Authentication** | Splash, login, student registration, OTP, forgot password, and Admin login preview. |
| **Home Dashboard** | Role-based dashboard experiences for Students, Seniors, and Alumni. |
| **User Profile** | My Profile, public profile, profile editing, and settings. |
| **Community & Discussions** | University communities and discussion experiences. |
| **Mentorship** | Mentor discovery and mentorship request/management screens. |
| **Project Collaboration** | Project discovery and collaboration interfaces. |
| **Messaging** | Conversation and message interfaces with mock attachment previews. |
| **Resources** | Resource discovery, upload previews, and moderation-status experiences. |
| **Notifications & Announcements** | In-app notification previews and announcement management. |
| **Admin Panel** | Responsive administration dashboard, user management, resource moderation, and announcement management. |

The frontend preview reflects the intended access rules for friendship-based and mentorship-based communication. These rules are represented in the UI/mock behavior only; they are not enforced by a production backend.

## Technology Stack

| Technology | Purpose |
| --- | --- |
| **Flutter** | Cross-platform application UI |
| **Dart** | Application programming language |
| **Material Design** | UI components and visual system |
| **Git & GitHub** | Version control and source-code hosting |
| **GitHub Actions** | Automated Flutter analysis and test workflow |
| **Draw.io** | System and software design diagrams |
| **MariaDB** | Planned database technology; not integrated yet |

## Application Architecture

The approved high-level design follows a **Client–Server, Three-Tier Architecture**:

1. **Presentation layer:** Flutter mobile application.
2. **Application layer:** Backend API and business logic (framework not selected yet).
3. **Data layer:** MariaDB database (planned).

The intended integrations also include an OTP service and file storage provider. These backend integrations are future work and are not part of the current frontend preview.

See the [System Architecture Diagram](Design/CampConnect_System_Architecture.drawio).

## Getting Started

### Prerequisites

- Flutter SDK compatible with the Dart SDK constraint in `pubspec.yaml`.
- Android Studio, VS Code, or another Flutter-compatible IDE.
- An emulator, connected device, or supported desktop/browser target.

Install Flutter by following the [official Flutter installation guide](https://docs.flutter.dev/get-started/install).

### Clone the repository

```bash
git clone https://github.com/Asadalvi979/CampConnect--Mobile-Application.git
cd CampConnect--Mobile-Application
```

### Install dependencies

```bash
flutter pub get
```

### Run the application

```bash
flutter run
```

Choose an available device or target when prompted. Platform-specific setup may be required for Android, iOS, Web, Linux, macOS, or Windows.

## Running Tests and Analysis

Run the automated Flutter tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

A GitHub Actions workflow is configured in `.github/workflows/flutter.yml` to run dependency installation, static analysis, and tests on pushes and pull requests targeting the `main` branch.

## Admin Preview

The Admin Login screen is available for demonstrating the Admin Panel. Use these **mock-only** credentials:

| Field | Preview value |
| --- | --- |
| Email | `admin@campconnect.com` |
| Password | `Admin123` |

These credentials are hardcoded for local frontend demonstration. They do not provide real authentication or secure access control. Do not use them for a production deployment.

## Project Documentation

The repository includes the project's requirements and design materials:

| Document | Location |
| --- | --- |
| Software Requirements Specification (SRS) | [SRS document](Documentation/SRS/CampConnect_SRS_v1.0.docx) |
| System Architecture | [Architecture diagram](Design/CampConnect_System_Architecture.drawio) |
| Entity Relationship Diagram (ERD) | [ERD folder](Documentation/ERD/) |
| Use Case Diagrams | [Use Case folder](Documentation/UseCases/) |
| Sequence Diagrams | [Sequence diagram folder](Design/SequenceDiagrams/) |
| UI/UX Designs and Assets | [UI/UX folder](Design/UI%20and%20UX/) |

## Repository Structure

```text
CampConnect--Mobile-Application/
├── .github/
│   └── workflows/          # GitHub Actions workflow
├── Design/                 # UI/UX assets and design diagrams
├── Documentation/           # SRS, ERD, and use case documents
├── android/                # Android platform project
├── ios/                    # iOS platform project
├── lib/
│   ├── core/               # Shared app infrastructure and styling
│   └── features/           # Feature-based application modules
├── linux/                  # Linux platform project
├── macos/                  # macOS platform project
├── test/                   # Flutter tests
├── web/                    # Web platform project
├── windows/                # Windows platform project
├── pubspec.yaml            # Dependencies and Flutter configuration
└── README.md
```

## Current Scope and Limitations

This release focuses on the frontend and UI/UX demonstration.

- Screens use local mock data and in-memory state.
- No backend API or server-side business logic is connected.
- No live database or persistent storage is configured.
- Login, registration, OTP, and Admin access are previews, not real authentication.
- Messaging and attachment behavior are demonstrations; no live message delivery or remote file transfer is implemented.
- Mock changes may reset when the application restarts.

Do not treat preview data or actions as real university records or production functionality.

## Planned Development

The next development phase is expected to cover backend planning and implementation, including:

- Backend framework and API design.
- Secure authentication with university identity verification and email OTP.
- Database integration with MariaDB.
- Server-side authorization and business-rule enforcement.
- File storage and resource moderation integration.
- Production messaging and notification services.

Backend framework, OTP provider, file storage provider, and hosting decisions are still pending. They will be selected before backend implementation begins.

## Contributors

Developed by students of **Riphah International University**.

| Name | CMS Number |
| --- | --- |
| **Asadullah Sadiq** | F24-BSSE-0044 |
| **Muhammad Tayyab** | F24-BSSE-0079 |
| **Muhammad Bilal** | F24-BSSE-0083 |

---

<p align="center">
  <strong>CampConnect</strong><br>
  Connecting students, seniors, and alumni through collaboration.
</p>
