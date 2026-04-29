# <img src="assets/images/splash_icon.png" width="40" alt="Agrilo Logo"> Agrilo: AI-Powered Crop Disease Detection

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/) 
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)
[![Riverpod](https://img.shields.io/badge/Riverpod-000000?style=for-the-badge&logo=dart&logoColor=white)](https://riverpod.dev/)

> *Spot pathogens instantly. Track crop vitality. Take action with confidence.*

<div align="center">
  <img src="assets/images/agrilo_demo_darkmode.gif" width="250" alt="Agrilo Dark Mode Demo">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/images/agrilo_demo_lightmode.gif" width="250" alt="Agrilo Light Mode Demo">
</div>

## 🌍 The Problem & The Solution
Crop diseases cost the global agricultural industry billions of dollars annually, often devastating farmers who lack immediate access to plant pathologists. 

**Agrilo** puts an expert agronomist in the farmer's pocket. By leveraging on-device machine learning and a streamlined mobile interface, Agrilo allows users to scan plant leaves in real-time, instantly identifying pathogens and providing actionable treatment recommendations before outbreaks spread.

---

## 🛠 Technical Architecture

Agrilo is engineered for performance, offline-first reliability, and a seamless user experience.

### Core Stack
* **Framework:** Flutter (Dart)
* **State Management:** Riverpod (ConsumerStatefulWidgets & StateProviders)
* **Backend & Auth:** Supabase
* **AI/ML Integration:** TensorFlow Lite (`assets/ml/model_unquant.tflite`)
* **Routing:** GoRouter

### Engineering Highlights & Challenges Solved
As the sole architect of Agrilo, I prioritized building a robust, production-ready codebase over quick hacks:

* **Bulletproof Theming Engine:** Built a custom dynamic Light/Dark mode that handles edge cases natively, utilizing `SystemUiOverlayStyle` and zero-height AppBars to guarantee correct status bar icon contrast across both themes.
* **Camera Lifecycle Management:** Handled complex hardware APIs using `WidgetsBindingObserver`. Built graceful fallback UI systems that catch `CameraAccessDenied` exceptions, preventing infinite loops and seamlessly routing users to OS-level settings for permission recovery.
* **Responsive Layout Constraints:** Mastered Flutter's rendering engine to prevent infinite constraint `RenderFlex` explosions. Utilized `FittedBox`, dynamic `Expanded` widgets, and `ScreenUtil` to ensure the dashboard and data metrics scale perfectly from small Android devices to massive tablets.
* **Stateful Navigation:** Implemented persistent bottom navigation combined with Riverpod state to manage complex cross-screen data passing (e.g., passing AI confidence metrics and image paths from the Scanner to the Results screen).

---

## ✨ Key Features
* **📸 Real-Time Pathogen Scanning:** Point, shoot, and analyze plant health instantly.
* **📊 Diagnostic Log & History:** A persistent database of past scans, tracked crops, and most common risk factors.
* **🌓 Adaptive UI:** A premium, fully custom Light/Dark mode interface designed for high outdoor visibility.
* **🛡️ Bulletproof Input Handling:** Strict UI defenses and data parsing to ensure layout integrity regardless of user input.

---

## 🚀 Getting Started

To run Agrilo locally, follow these steps:

### Prerequisites
* Flutter SDK
* Dart SDK
* A Supabase Project
* Any AI API Keys if applicable

### Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/Shakirullah-builds/Cavista-Agrilo-Mobile.git](https://github.com/Shakirullah-builds/Cavista-Agrilo-Mobile.git)

2. Navigate to the project directory:
   ```bash 
   cd Cavista-Agrilo-Mobile

3. Install dependencies:
   ```bash
   flutter pub get

4. Set up your environment variables:
   * Create a `.env` file in the root directory.
   * Add your Supabase keys and AI endpoints:
   ```bash
   SUPABASE_URL=your_url_here
   SUPABASE_ANON_KEY=your_key_here

5. Run the app
   ```bash
   flutter run

---

### 👨‍💻 About the Developer

I am Shakirullah, a Pure Chemistry undergraduate by day and a Mobile App Developer by night. I am deeply passionate about the intersection of software engineering and real-world utility. When I am not running argentometric titrations in the lab or facilitating mobile dev classes, I am architecting agent-first applications in Flutter.

* [Connect with me on Linkedln](https://www.linkedin.com/in/shakirullah-omotoso-7a8846347?utm_source=share_via&utm_content=profile&utm_medium=member_ios)