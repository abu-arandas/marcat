# 🛍️ Marcat Retail Management System

&#x20; &#x20;

A modern, multi-store retail management platform built with ❤️ using Flutter and Firebase. Empower retailers to streamline operations, manage inventory, and gain actionable insights across multiple locations.

---

## 📖 Table of Contents

- [🌟 Key Features](#-key-features)
- [📸 UI Previews](#-ui-previews)
- [🛠 Tech Stack](#-tech-stack)
- [🏗 System Architecture](#-system-architecture)
- [🛣 Roadmap](#-roadmap)
- [🚀 Getting Started](#-getting-started)
- [🔧 Deployment](#-deployment)
- [🗄 Data Model](#-data-model)
- [🧩 Contributing](#-contributing)
- [❓ FAQ](#-faq)
- [📜 License](#-license)
- [📬 Contact](#-contact)

---

## 🌟 Key Features

| Module             | Highlights                                                                                                        |
| ------------------ | ----------------------------------------------------------------------------------------------------------------- |
| 💻 Point of Sale   | - Offline-first operations- Barcode & QR scanning- Custom receipt templates- Multi-payment (cash, card, wallet)   |
| 📦 Inventory       | - Variant-level tracking- Low-stock auto-reorder- Supplier catalogs & orders- Transfer between stores             |
| 👥 Team Management | - Granular role-based ACL- Shift scheduling & clock-in/out- Performance leaderboards- Mobile time clocks          |
| 📊 Analytics       | - Real-time sales dashboards- Custom report builder- Trend forecasting- Customer segmentation & behavior insights |
| 🔔 Notifications   | - Instant low-stock alerts- Price change & promotion notifications- Scheduled reminders- Security & audit logs    |

---

## 📸 UI Previews

> More screenshots available in the `docs/` directory.

---

## 🛠 Tech Stack

- **Frontend:** Flutter & Dart (with Riverpod, GoRouter)
- **Backend:** Firebase (Auth, Firestore, Functions, Storage, Hosting)
- **DevOps:** GitHub Actions (CI/CD), Fastlane (iOS releases)
- **Monitoring & Analytics:** Firebase Crashlytics, Google Analytics for Firebase

---

## 🏗 System Architecture

```plaintext
+----------------------+
|      Flutter App     |
| - POS Module         |
| - Inventory Module   |
| - Analytics Module   |
+----------------------+
          │
          ▼
+----------------------+
|  Firebase Services   |
| - Firestore          |
| - Auth               |
| - Functions          |
| - Storage            |
| - Hosting            |
| - Crashlytics        |
+----------------------+
```

----------------------+      +-------------------+      +-------------------+      +----------------+
|      Flutter App     | <--> | Firebase Services | <--> | Third-Party APIs  | <--> | Mobile Devices  |
| - POS Module         |      | - Firestore       |      | - Payment Gateways|      | (iOS, Android)  |
| - Inventory Module   |      | - Auth            |      | - Notification    |      +----------------+
| - Analytics Module
|      | - Functions       |      |   Providers       |
+----------------------+      +-------------------+      +-------------------+
```

---

## 🛣 Roadmap

- **v1.1.0**: Multi-currency support, advanced discount rules, dark mode
- **v1.2.0**: Loyalty & rewards program, integration with major e-commerce platforms
- **v2.0.0**: Desktop & web client, open API & plugin architecture

Contributions and feedback shape our roadmap. See [ISSUES](https://github.com/abu-arandas/marcat/issues) for ongoing items.

---

## 🚀 Getting Started

### Prerequisites

- **Flutter:** 3.13 or above
- **Firebase CLI:** 12.4.0 or above

### Installation

```bash
# Clone the repository with submodules
git clone --recursive https://github.com/abu-arandas/marcat.git
cd marcat

# Install Flutter dependencies
flutter pub get

# Install Cloud Functions dependencies
cd functions && npm ci && cd ..
```

### Configuration

```bash
# Link to your Firebase project
firebase use --add

# Initialize required Firebase services
firebase init auth firestore functions storage hosting extensions
```

---

## 🔧 Deployment

### Backend Services

```bash
# Deploy Cloud Functions, Firestore rules, Hosting, and Extensions
firebase deploy --only functions,firestore,hosting,extensions
```

### Mobile Apps

```bash
# Android: build App Bundle for Play Store
flutter build appbundle --release

# iOS: release via Fastlane
cd ios && fastlane release
```

---

## 🗄 Data Model

```dart
class Product {
  String id;
  String name;
  String category;
  List<Variant> variants;
  DateTime createdAt;
}

class Variant {
  String id;
  String color;
  List<String> images;
  List<SizeOption> sizes;
}

class SizeOption {
  String size;
  double price;
  int stock;
}
```

---



## 🧩 Contributing

We welcome contributions! Please read our [CONTRIBUTING.md](./CONTRIBUTING.md) and adhere to the following:

1. Fork the repo & create a feature branch (`git checkout -b feature/awesome-feature`)
2. Write clear, test-covered code
3. Ensure build & lint checks pass via GitHub Actions
4. Submit a pull request and participate in review discussions

---

## ❓ FAQ

**Q:** Can I use Marcat for a single store?
**A:** Yes! Simply configure one store in the dashboard settings.

**Q:** How do I migrate my existing POS data?
**A:** Use the CSV import feature under Inventory → Import, or script via Firestore APIs.

**Q:** Is there support for custom themes?
**A:** Theming is under development (v1.1 roadmap).

---

## 📜 License

Distributed under the MIT License. See [LICENSE](./LICENSE) for details.

---

## 📬 Contact

- **Website:** [https://marcat.io](https://marcat.io)
- **Email:** [support@marcat.io](mailto\:support@marcat.io)
- **Issues:** [https://github.com/abu-arandas/marcat/issues](https://github.com/abu-arandas/marcat/issues)

Made with ✨ by Retail Experts, for Retail Experts

