🛍️ Marcat Retail Management System
A full-featured retail management solution for a multi-store clothing brand, built with Flutter and backed by Firebase.

📖 Overview
Marcat centralizes:

POS System: In-store sales with offline support

Inventory Management: Track stock per product variant (color & size)

Employee & Role Management: Store-specific staff with gated permissions

Sales Analytics: Real-time dashboards by store, product, and seller

Customer CRM & Loyalty: Profiles, purchase history, and points

Notifications & Alerts: Low-stock emails and push messages

Admin Dashboard: Web-based management interface

CI/CD & App Distribution: Automated testing and releases

✨ Features
Multi-Tenant Authentication
Secure each store as a standalone tenant in one Firebase project 
Firebase

Offline-First Data
Cloud Firestore caches active data locally; reads/writes sync when online 
Firebase

Modular Cloud Functions
Organize business logic into multiple codebases via firebase.json 
Firebase

Secure Asset Storage
Cloud Storage rules enforce path-based access for images and files 
Firebase

Reliable Push Notifications
FCM delivers messages even if devices are temporarily offline 
Firebase

Automated Email Triggers
Use the Firestore Trigger Email extension to notify managers about low stock 
Firebase

Global Web Hosting
Deploy the Admin Dashboard to Firebase Hosting’s CDN with one CLI command 
Firebase

Seamless CI/CD Releases
Integrate Firebase App Distribution with GitHub Actions or Fastlane 
Firebase

Role-Based Security
Firestore Security Rules validate custom claims for fine-grained permissions 
Firebase

Performance Best Practices
Set minimum Cloud Functions instances to mitigate cold starts 
Firebase

🏗️ System Architecture
scss
Copy
Edit
[ Flutter App ] ←→ [ Firebase Services ]
                     ├─ Auth (multi-tenant)
                     ├─ Firestore (data + offline)
                     ├─ Storage (assets)
                     ├─ Functions (logic)
                     ├─ FCM (notifications)
                     ├─ Extensions (email, resizing)
                     ├─ Hosting (Admin web)
                     └─ App Distribution (CI/CD)
🔧 Setup & Deployment
Clone Repo

bash
Copy
Edit
git clone https://github.com/abu-arandas/marcat.git
cd marcat-firebase
Initialize Firebase

bash
Copy
Edit
firebase login
firebase init auth,firestore,functions,hosting,storage,extensions,appdistribution
Configure Multi-Tenancy

Enable Identity Platform in GCP.

Install Dependencies

Functions:

bash
Copy
Edit
cd functions
npm install
Flutter App:

bash
Copy
Edit
cd ../app
flutter pub get
Deploy Services

bash
Copy
Edit
firebase deploy --only auth,firestore,storage,functions,hosting
Distribute Mobile Builds

bash
Copy
Edit
# Via Firebase CLI
firebase appdistribution:distribute build/app.apk \
  --app <APP_ID> --groups "QA Testers"
📐 Data Modeling
swift
Copy
Edit
Variants include color, size, sku, and price.

Inventory docs track quantity.

Sales subcollections record transaction metadata.

🔒 Security & Access Control
Firestore Rules (example):

js
Copy
Edit
Firebase

🔄 Offline Support & Sync
Firestore’s local cache serves reads/writes offline by default 
Firebase
.

Sync resumes automatically on reconnect; clients use last-write-wins conflict resolution.

🤝 Contributing
Fork the repository

Create a branch: git checkout -b feature/your-feature

Commit changes: git commit -m "Add awesome feature"

Push: git push origin feature/your-feature

Open a PR

📝 License
MIT License. See LICENSE for details.

📞 Support
For questions or enterprise integration, contact the Marcat Dev Team at e00arandas@gmail.com.