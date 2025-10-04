import React from "react";

export default function App() {
  return (
    <div className="app">
      {/* Background layers */}
      <div className="bg base-gradient" />
      <div className="bg image-overlay" />

      <header className="navbar">
        <nav className="nav-inner">
          <div className="nav-left">
            <a href="#screens" className="nav-link">
              Screens
            </a>
            <a href="#about" className="nav-link">
              About
            </a>
            <a href="#model" className="nav-link">
              Model
            </a>

            <a href="#features" className="nav-link">
              Features
            </a>
            <a href="#install" className="nav-link">
              Install
            </a>
            <a href="#developer" className="nav-link">
              Developer
            </a>
          </div>
          <div className="nav-center">
            <span className="brand">PaddyCare</span>
          </div>
          <div className="nav-right">
            <a className="btn btn-sm glow" href="/downloads/paddycare.apk">
              Download APK
            </a>
          </div>
        </nav>
      </header>

      <main>
        <section className="hero" id="home">
          <div className="hero-card">
            <h1 className="title">
              PaddyCare
              <span className="title-accent">
                {" "}
                • Paddy Leaf Disease Detection
              </span>
            </h1>
            <p className="subtitle">
              Fast, on-device disease detection for healthier crops and smarter
              decisions.
            </p>
            <div className="hero-actions">
              <a
                className="btn btn-lg glow pulse"
                href="/downloads/paddycare.apk"
              >
                Download APK
              </a>
              <a className="btn btn-ghost" href="#screens">
                View Screens
              </a>
            </div>
          </div>
        </section>

        <section className="section" id="screens">
          <h2 className="section-title">Screens</h2>
          <p className="section-desc">
            Explore the core flows: home, capture/analyze, and results with
            guidance tips.
          </p>
          <div className="grid grid-3">
            <figure className="card glass">
              <img src="/src/assets/screens/welcome.png" alt="Home screen" />
              <figcaption>Home</figcaption>
            </figure>
            <figure className="card glass">
              <img
                src="/src/assets/screens/dashboard.png"
                alt="Dashboard screen"
              />
              <figcaption>Dashboard</figcaption>
            </figure>
            <figure className="card glass">
              <img src="/src/assets/screens/disease.png" alt="Results screen" />
              <figcaption>Results</figcaption>
            </figure>
          </div>
        </section>

        <section className="section" id="about">
          <h2 className="section-title">About</h2>
          <p className="section-desc">
            PaddyCare processes leaf images on-device to estimate disease class
            and confidence, helping reduce guesswork in the field.
          </p>
          <ul className="bullets">
            <li>On-device inference for privacy and offline use.</li>
            <li>Lightweight UI with vivid, accessible colors.</li>
            <li>Actionable guidance with confidence indicators.</li>
          </ul>
        </section>

        <section className="section" id="model">
          <h2 className="section-title">Model</h2>
          <p className="section-desc">
            The app runs a mobile-optimized model and outputs class
            probabilities; keep the same signing key for seamless updates of
            APKs.
          </p>
          <div className="card glass callout">
            <h3>Get the App</h3>
            <p>
              Install the latest signed release and allow installs from your
              browser/file manager if prompted.
            </p>
            <a
              className="btn glow"
              href="/src/assets/screens/bg.png"
              download="PaddyCare"
            >
              Download APK
            </a>
          </div>
        </section>
        <section className="section" id="features">
          <h2 className="section-title">Features</h2>
          <p className="section-desc">
            PaddyCare makes plant health monitoring simple, reliable, and
            accessible for farmers and researchers.
          </p>
          <div className="grid grid-3">
            <div className="card glass">
              <h3>📷 Leaf Image Capture</h3>
              <p>
                Snap a photo of your paddy leaves and get instant analysis
                without internet dependency.
              </p>
            </div>
            <div className="card glass">
              <h3>⚡ On-Device AI</h3>
              <p>
                Runs an optimized neural network on your device — no data
                sharing, fully offline.
              </p>
            </div>
            <div className="card glass">
              <h3>🌾 Actionable Guidance</h3>
              <p>
                Shows not just probabilities but also next steps for better crop
                management.
              </p>
            </div>
          </div>
        </section>
        <section className="section" id="install">
          <h2 className="section-title">How to Install</h2>
          <p className="section-desc">
            Follow these quick steps to get PaddyCare running on your Android
            device.
          </p>
          <ol className="bullets">
            <li>
              Click the <b>Download APK</b> button.
            </li>
            <li>Open the downloaded file on your phone.</li>
            <li>Allow installation from browser/file manager if prompted.</li>
            <li>Launch PaddyCare and start scanning leaves!</li>
          </ol>
        </section>
        <section className="section" id="developer">
          <h2 className="section-title">Developer</h2>
          <p className="section-desc">
            This app was designed and developed by <b>Sathiyaseelan S</b>, an
            engineering student passionate about AI in agriculture.
          </p>
          <div className="card glass callout">
            <h3>Get in Touch</h3>
            <p>
              Email:{" "}
              <a href="mailto:sathiyaseelan@gmail.com">
                sathiyaseelan@gmail.com
              </a>
            </p>
            <p>
              GitHub:{" "}
              <a href="https://github.com/sathiyaseelan0712" target="_blank">
                github.com/sathiyaseelan0712
              </a>
            </p>
          </div>
        </section>
      </main>

      <footer className="footer">
        <p>
          © {new Date().getFullYear()} PaddyCare • Developed by Sathiyaseelan S
        </p>
      </footer>
    </div>
  );
}
