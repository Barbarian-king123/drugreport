# 🛡️ DrugReport (SafeReport)

> A secure, privacy-first incident reporting and verification platform empowering citizens to report suspected narcotics activity anonymously and providing law enforcement officers with real-time incident verification tools.

🌐 **Live Web App:** [https://barbarian-king123.github.io/drugreport/](https://barbarian-king123.github.io/drugreport/)

---

## 🌟 Key Features

### 👤 Citizen Portal
- **Anonymous Incident Reporting:** Submit incidents with description, geolocation, and media attachments without disclosing personal identity.
- **Cryptographic Reporter Tokens:** Anonymous UUID-based tokens decouple reports from user identities in Firestore, guaranteeing safety from retaliation.
- **Dynamic Trust Score System:**
  - Reports marked **Verified** by officers reward **+5 Trust Points**.
  - False or malicious reports penalize **-20 Trust Points**.
  - Community standings: *Excellent (80-100)*, *Good (50-79)*, *Warning (20-49)*, and *Restricted (0-19)*.
- **Live Interactive Map:** Visualizes nearby incident hotspots with OpenStreetMap tiles, GPS centering, and pin details.
- **Evidence Vault:** Secure photo and video attachment uploads powered by Firebase Storage.

### 👮 Law Enforcement Officer Dashboard
- **Case Investigation Feed:** Real-time stream of incoming citizen reports categorized by status (`submitted`, `investigating`, `fineIssued`, `closed`).
- **One-Tap Verification & Audit:** Officers can update report verdicts (`Verified`, `Investigating`, `Fabricated`).
- **Structured Reason Codes:** Tagging a report as *Fabricated* requires standard reason codes (e.g., reused media, metadata contradiction, admission) to eliminate bias.
- **Department Credentials Sign-In:** Dedicated officer login with Badge ID and department passcodes, alongside quick-demo bypass for evaluation.

---

## 🏗️ Architecture & Tech Stack

| Component | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev) (v3.44+ / Web, Android, iOS, Windows) |
| **Language** | [Dart](https://dart.dev) (v3.12+) |
| **Authentication** | Firebase Authentication (Phone SMS OTP & Anonymous Auth) |
| **Database** | Cloud Firestore (Real-time streams, atomic batches) |
| **Storage** | Firebase Cloud Storage |
| **Mapping** | `flutter_map` + `latlong2` (OpenStreetMap tiles — no paid API keys required) |
| **Geolocation** | `geolocator` |
| **Hosting** | GitHub Pages + Automated GitHub Actions CI/CD |

---

## 🚀 Getting Started Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.44.0`)
- Git

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Barbarian-king123/drugreport.git
   cd drugreport
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Run unit & smoke tests:**
   ```bash
   flutter test
   ```

4. **Launch on Chrome / Web:**
   ```bash
   flutter run -d chrome
   ```

5. **Run on connected Mobile/Desktop device:**
   ```bash
   flutter run
   ```

---

## 🌐 GitHub Pages Deployment

The repository includes a ready-to-run GitHub Actions workflow (`.github/workflows/deploy.yml`).

### Automatic Deployment via GitHub Actions
Whenever you push changes to the `main` branch, the workflow automatically builds the Flutter Web app and publishes it to GitHub Pages.

To enable GitHub Pages in your repository:
1. Go to **Settings > Pages** on your GitHub repository.
2. Under **Build and deployment > Source**, select **GitHub Actions**.
3. Push to `main` or trigger the workflow manually from the **Actions** tab.
4. Your application will be live at:
   ```
   https://barbarian-king123.github.io/drugreport/
   ```

### Manual Build & Local Deploy (Optional)
To build the web bundle locally:
```bash
flutter build web --release --base-href "/drugreport/"
```
The compiled static assets will be in `build/web/`.

---

## 🔐 Firebase Configuration Note for Web

To allow Firebase Phone and Anonymous Authentication on GitHub Pages:
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Select your project: `drugreport-87e04`.
3. Navigate to **Authentication > Settings > Authorized domains**.
4. Click **Add domain** and add:
   ```
   barbarian-king123.github.io
   ```

---

## 🧪 Demo Credentials for Testing & Grading

- **Citizen Test Mode:** Use any standard phone number with OTP `123456`, or click **Quick Citizen Login**.
- **Officer Portal Test Mode:**
  - **Badge ID:** `BADGE-101`
  - **Passcode:** `OFFICER123`
  - Or click **Quick Officer Login** on the login screen.

---

## 📄 License
This project is developed for community safety and incident awareness. All rights reserved.
