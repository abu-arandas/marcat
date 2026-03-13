# Marcat — Multi-Store Men's Clothing Platform

> A full-featured Flutter e-commerce & retail management platform built for the Jordanian market, supporting both online shopping and in-store Point of Sale (POS) operations across multiple clothing stores.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Screens & Roles](#screens--roles)
- [Getting Started](#getting-started)
- [Environment Setup](#environment-setup)
- [Database](#database)
- [Localization](#localization)
- [Assets & Fonts](#assets--fonts)

---

## Overview

**Marcat** is a cross-platform Flutter application that powers a multi-store men's clothing brand in Jordan. It combines a customer-facing online storefront with a full admin panel and a in-store Point of Sale (POS) terminal — all backed by [Supabase](https://supabase.com/) as the backend.

---

## Features

### 🛍️ Customer Storefront
- Browse products by category (Men, Women, Kids), new arrivals, and sale items
- Full product detail page with image gallery, color/size variants, and stock indicator
- Search products with real-time filtering
- Add to cart & wishlist (requires authentication)
- Multi-step checkout with address selection and delivery options
- Order history with status tracking (pending → paid → shipped → delivered)
- Return requests with status flow (requested → approved → refunded/rejected)
- Loyalty program with tiers: **Bronze → Silver → Gold → Platinum**
- Profile management with saved addresses

### 🔐 Authentication
- Email/password login and registration
- Forgot password flow
- Auth-guarded routes (cart, checkout, wishlist, profile, admin)

### 🖥️ Admin Panel
- Dashboard with sales analytics (powered by `fl_chart`)
- Product management: create, edit, manage variants (colors, sizes, images), offers, and inventory
- Order management with detailed view and status updates
- Staff management: add/manage salespeople and store managers
- Commission tracking for staff
- Store and brand management
- QR code scanning via `mobile_scanner`

### 📟 POS Terminal
- Dedicated in-store point of sale screen
- Staff login with PIN authentication
- Product lookup and cart management for walk-in customers
- In-store sales recorded separately from online orders (`SaleChannel.pos`)

### 🚚 Delivery Management
- Driver role with dedicated delivery screens
- Delivery status tracking: pending → out for delivery → delivered / failed

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter ≥ 3.10 / Dart ≥ 3.0 |
| State Management | [GetX](https://pub.dev/packages/get) |
| Backend / Database | [Supabase](https://supabase.com/) (PostgreSQL + Auth + Storage) |
| UI Components | [flutter_bootstrap5](https://pub.dev/packages/flutter_bootstrap5) |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) |
| Forms | [reactive_forms](https://pub.dev/packages/reactive_forms) |
| PDF & Printing | [pdf](https://pub.dev/packages/pdf) + [printing](https://pub.dev/packages/printing) |
| Image Handling | [cached_network_image](https://pub.dev/packages/cached_network_image), [image_picker](https://pub.dev/packages/image_picker), [photo_view](https://pub.dev/packages/photo_view) |
| Barcode / QR | [mobile_scanner](https://pub.dev/packages/mobile_scanner) |
| Storage | [shared_preferences](https://pub.dev/packages/shared_preferences), [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) |
| Localization | `flutter_localizations` + ARB files |
| Environment | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) |
| Code Generation | [freezed](https://pub.dev/packages/freezed), [json_serializable](https://pub.dev/packages/json_serializable) |

---

## Architecture

Marcat follows a **controller-first** architecture using GetX. All business logic resides in controllers, which communicate directly with Supabase — there are no intermediate repository classes.

```
UI (Views)  ──→  Controllers  ──→  Supabase (PostgreSQL / Auth / Storage)
                     ↑
               GetX Bindings
              (InitialBinding)
```

### Controllers

| Controller | Responsibility |
|---|---|
| `AuthController` | Auth state, Supabase session, role detection |
| `ProductController` | Products, categories, brands, wishlist, offers |
| `CartController` | Cart (persisted via SharedPreferences), orders, returns |
| `AccountController` | Profile, customer data, addresses, loyalty |
| `AdminController` | Staff, commissions, stores, inventory |
| `DeliveryController` | Deliveries and delivery status |
| `SearchController` | Real-time product search (delegates to ProductController) |
| `LocaleController` | App language (English / Arabic) |

---

## Project Structure

```
marcat/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── controllers/                 # GetX controllers (business logic)
│   ├── models/                      # Data models + enums
│   ├── views/
│   │   ├── auth/                    # Login, Register, Forgot Password
│   │   ├── customer/                # Storefront screens
│   │   ├── admin/                   # Admin panel screens
│   │   │   ├── dashboard/
│   │   │   ├── products/
│   │   │   ├── orders/
│   │   │   ├── staff/
│   │   │   └── settings/
│   │   ├── pos/                     # POS terminal screens
│   │   └── shared/                  # Shared widgets
│   ├── core/
│   │   ├── bindings/                # GetX dependency injection
│   │   ├── constants/               # Theme, Supabase keys, etc.
│   │   ├── router/                  # App routes & auth guards
│   │   ├── extensions/              # Dart extensions
│   │   ├── errors/                  # Error types
│   │   └── utils/                   # Helpers
│   └── l10n/                        # ARB localization files
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/                       # PlayfairDisplay, IBMPlexSansArabic, IBMPlexMono
├── sql/
│   ├── database.sql                 # Full PostgreSQL schema
│   └── seed.sql                     # Seed data for development
├── .env                             # Local environment variables (git-ignored)
└── pubspec.yaml
```

---

## Screens & Roles

The app uses **5 user roles** mapped directly to PostgreSQL ENUMs:

| Role | Access |
|---|---|
| `customer` | Storefront, cart, checkout, orders, wishlist, profile |
| `admin` | Full admin panel + storefront |
| `store_manager` | Admin panel scoped to their store |
| `salesperson` | POS terminal |
| `driver` | Delivery screens |

### Route Map

| Area | Routes |
|---|---|
| Auth | `/auth/login`, `/auth/register`, `/auth/forgot-password` |
| Storefront | `/app/home`, `/app/shop`, `/app/product/:id`, `/app/category/:id`, `/app/cart`, `/app/checkout`, `/app/wishlist` |
| Account | `/app/profile`, `/app/profile/orders`, `/app/profile/orders/:id` |
| Admin | `/admin/dashboard`, `/admin/products/create`, `/admin/products/:id/edit`, `/admin/orders/:id`, `/admin/staff/add` |
| POS | `/pos/auth`, `/pos/terminal` |

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.10.0
- Dart ≥ 3.0.0
- A [Supabase](https://supabase.com/) project with the schema applied

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-org/marcat.git
cd marcat

# 2. Install Flutter dependencies
flutter pub get

# 3. Run code generation (Freezed + JSON serializable)
dart run build_runner build --delete-conflicting-outputs

# 4. Set up your environment file (see below)
cp .env.example .env

# 5. Run the app
flutter run
```

---

## Environment Setup

Create a `.env` file in the project root (this file is git-ignored):

```env
SUPABASE_URL=YOUR_SUPABASE_URL_HERE
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY_HERE
```

You can find these values in your Supabase project under **Settings → API**.

> ⚠️ **Never commit your `.env` file.** It is already listed in `.gitignore`.

---

## Database

The full PostgreSQL schema is in [`sql/database.sql`](sql/database.sql).  
Development seed data is in [`sql/seed.sql`](sql/seed.sql).

To apply the schema to a new Supabase project:

1. Go to your Supabase project → **SQL Editor**
2. Paste and run `sql/database.sql`
3. _(Optional)_ Paste and run `sql/seed.sql` to populate test data

### Key Tables

| Table | Description |
|---|---|
| `users` | Auth users with role assignment |
| `stores` | Store branches |
| `products` | Products with variants (colors, sizes) |
| `inventory` | Per-store stock levels |
| `sales` / `sale_items` | Orders (online & POS) |
| `deliveries` | Delivery records per order |
| `returns` / `return_items` | Return request tracking |
| `loyalty_transactions` | Customer loyalty points log |
| `commissions` | Staff commission records |
| `offers` | Promotional offers linked to products |
| `wishlists` | Customer wishlist items |
| `customer_addresses` | Saved delivery addresses |

---

## Localization

The app supports **English** and **Arabic** out of the box, with RTL layout handled automatically.

ARB translation files live in `lib/l10n/`. To add or update translations:

1. Edit `lib/l10n/app_en.arb` (English) and `lib/l10n/app_ar.arb` (Arabic)
2. Run `flutter gen-l10n` or `flutter pub get` (generation is automatic via `l10n.yaml`)

The `LocaleController` persists the user's language preference and rebuilds the app on change.

---

## Assets & Fonts

Three custom font families are bundled:

| Font | Usage |
|---|---|
| **PlayfairDisplay** | Display headings, brand name |
| **IBMPlexSansArabic** | Arabic body text (Regular, Medium, Bold) |
| **IBMPlexMono** | Monospace / code elements |

Image and icon assets are placed in `assets/images/` and `assets/icons/` respectively.

---

## License

This project is proprietary software. All rights reserved.
