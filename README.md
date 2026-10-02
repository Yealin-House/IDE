# IDE

High-performance, debloated code editor with Bring-Your-Own-Key (BYOK) AI and integrated browser preview.

[![License: GPL-3.0-or-later](https://img.shields.io/badge/License-GPL--3.0--or--later-blue.svg)](LICENSE-GPL)
[![Rust](https://img.shields.io/badge/Language-Rust-orange.svg)](https://www.rust-lang.org/)

IDE is an open-source code editor engineered for developers who prioritize performance, privacy, and full local control. It provides GPU-accelerated editing, completely eliminates telemetry and cloud sign-in requirements, and enables direct connections to local and remote AI models using your own API credentials.

---

## Features

- Blazing GPU-Accelerated Performance: Built on GPUI and Rust for sub-millisecond input latency and high-refresh-rate rendering.
- Privacy-First and Zero Telemetry: All analytics, usage tracking, and remote telemetry pings are disabled.
- Account-Free Operation: All editor functionality is unlocked locally without mandatory logins, cloud accounts, or walled-garden requirements.
- Bring Your Own Key (BYOK) AI: Connect directly to your choice of language model providers using your own API keys:
  - Anthropic (Claude 3.5 Sonnet, Claude 3 Opus)
  - OpenAI (GPT-4o, o1, etc.)
  - Google AI (Gemini 1.5 Pro, Flash)
  - Local LLMs via Ollama and LM Studio
  - OpenRouter, DeepSeek, Mistral, and AWS Bedrock
- Integrated Browser Tab: Inspect local development servers (such as `http://localhost:3000` or `http://localhost:5173`) directly inside the editor pane. Open it with `alt-b`, `cmd-alt-b`, or `cmd-k b`, or via File → New Browser Tab.
- Clean Local Configuration: Application settings and caches are isolated to `~/.ide/` (macOS) or `~/.config/ide/` (Linux).

---

## Configuration

Configuration is stored in `~/.ide/settings.json` (macOS) or `~/.config/ide/settings.json` (Linux).

### AI Model Providers

Configure model endpoints and authentication directly in `settings.json` or through standard environment variables:

```json
{
  "language_models": {
    "anthropic": {
      "api_url": "https://api.anthropic.com"
    },
    "openai": {
      "api_url": "https://api.openai.com/v1"
    },
    "ollama": {
      "api_url": "http://localhost:11434"
    }
  },
  "edit_predictions": {
    "provider": "ollama"
  }
}
```

Alternatively, set your API keys via environment variables:

```bash
export ANTHROPIC_API_KEY="your-anthropic-key"
export OPENAI_API_KEY="your-openai-key"
export GOOGLE_AI_API_KEY="your-gemini-key"
```

---

## Building from Source

### Prerequisites

- Rust toolchain (stable, edition 2024 compatible)
- macOS: Xcode Command Line Tools
- Linux: standard development packages (`pkg-config`, `libfontconfig1-dev`, `libasound2-dev`, etc.)

### Compilation

```bash
# Clone the repository
git clone https://github.com/Yealin-House/ide.git
cd ide

# Build release binary
cargo build --release --bin ide

# Run IDE
./target/release/ide
```

---

## Legal and Licensing

### License

IDE is free and open-source software licensed under the **GNU General Public License version 3 or later** ([GPL-3.0-or-later](LICENSE-GPL)). Specific supporting crates and libraries are licensed under the **Apache License, Version 2.0** ([LICENSE-APACHE](LICENSE-APACHE)).

### The `partial/` Component

The integrated browser tab and the application branding assets live in the [`partial/`](partial/) git submodule ([source repository](https://github.com/Jaseunda/ide)). This component is written for IDE, is **Copyright © 2026 Jaseunda**, and is licensed under the same **GPL-3.0-or-later** — see [`partial/LICENSE`](partial/LICENSE). It is compiled into and distributed with the editor binary.

### Upstream Attribution

This software is derived from the Zed open-source project, originally created and published by Zed Industries, Inc. We acknowledge and appreciate the contributions of the original authors and the open-source community.

### Trademark Notice

Zed is a trademark of Zed Industries, Inc. This project is an independent fork and is not endorsed by, sponsored by, or affiliated with Zed Industries, Inc.
