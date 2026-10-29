# Homebrew Brewery

Personal Homebrew tap maintained by [MasEDI.Net](https://masedi.net).

## Adding the Tap

To add this tap to your Homebrew installation:

```bash
brew tap joglomedia/brewery
```

---

## Available Packages

### 1. `curl-impersonate` (Formula)

A special build of curl that impersonates major browser TLS and HTTP handshakes (Chrome, Safari, Firefox, and Edge).

#### Installation

```bash
brew install joglomedia/brewery/curl-impersonate
```

#### Usage Examples

```bash
# Using pre-configured browser wrapper scripts
curl_chrome145 https://tls.peet.ws/api/all
curl_safari180 https://tls.peet.ws/api/all

# Using the main binary directly
curl-impersonate --impersonate chrome145 https://tls.peet.ws/api/all
```

---

### 2. `stockbit` (Cask)

Unofficial Homebrew Cask for the Stockbit Desktop App for macOS.

#### Installation

```bash
brew install --cask joglomedia/brewery/stockbit
```

#### Removal

```bash
brew uninstall --cask joglomedia/brewery/stockbit
```
