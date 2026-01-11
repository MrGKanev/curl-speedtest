# curl-speedtest

A modern, secure network benchmark tool for Linux and macOS with multi-provider support and interactive selection.

## Features

- **70+ Speedtest Servers** across 6 continents
- **Interactive Mode** - Menu-driven region and provider selection
- **Auto-Retry** - Automatically tries next server on failure
- **12+ Providers** - Cloudflare, Vultr, Linode, Hetzner, OVH, Leaseweb, and more
- **HTTPS Only** - All connections use encrypted HTTPS
- **Cross-Platform** - Works on macOS (bash 3.2+) and Linux

## Quick Start

**One-liner (download & run interactive mode):**
```bash
curl -sSL https://raw.githubusercontent.com/MrGKanev/curl-speedtest/master/speedtest.sh | bash -s -- -i
```

**Or with wget:**
```bash
wget -qO- https://raw.githubusercontent.com/MrGKanev/curl-speedtest/master/speedtest.sh | bash -s -- -i
```

**Download and keep the script:**
```bash
curl -sSL https://raw.githubusercontent.com/MrGKanev/curl-speedtest/master/speedtest.sh -o speedtest.sh && chmod +x speedtest.sh && ./speedtest.sh -i
```

**Or with wget:**
```bash
wget https://raw.githubusercontent.com/MrGKanev/curl-speedtest/master/speedtest.sh && chmod +x speedtest.sh && ./speedtest.sh -i
```

## Interactive Mode

Run `./speedtest.sh -i` to use the interactive picker:

```
============================================
  Network Speed Test - 2026-01-11 20:30
============================================

Select Region / Continent:

  1) Europe
  2) North America
  3) Asia Pacific
  4) Oceania
  5) South America
  6) Africa & Middle East
  7) All Regions

  0) Back
  9) Exit

Select [0-7 or 9]: 1

Select Provider:

  1) Anexia
  2) BelWue
  3) Cloudflare
  4) Clouvider
  5) Hetzner
  6) Leaseweb
  7) Linode
  8) OVH
  9) Serverius
  10) Tele2
  11) Vultr
  12) All Providers

  0) Back
  9) Exit

Select [0-12 or 9]: 5
```

### Navigation

| Key | Action |
|-----|--------|
| `1-7` | Select option |
| `0` | Go back to previous menu |
| `9` | Exit the program |

### After Tests Complete

```
============================================
Test completed!
============================================

What next?

  1) Test another provider (same region)
  2) Test another region
  9) Exit

Select [1, 2, or 9]:
```

## Auto-Retry on Failure

When a server doesn't respond, the script automatically tries the next one:

```
=== Download Speed Tests ===
Region: Europe
Provider: Hetzner

Testing: Hetzner - Nuremberg, Germany
  Connecting to nbg1-speed.hetzner.com... failed (trying next...)

Testing: Hetzner - Helsinki, Finland
  Connecting to hel1-speed.hetzner.com... failed (trying next...)

Testing: Hetzner - Falkenstein, Germany
  Connecting to speed.hetzner.de... ok
  Download: 245.67 Mbit/s

Completed 1 successful test(s)
```

## Command Line Usage

```bash
./speedtest.sh [OPTIONS]

OPTIONS:
  -i, --interactive   Interactive mode with menus (recommended)
  -d, --download      Run download speed tests only
  -l, --latency       Run latency tests only
  -c, --cpu           Run CPU benchmark only
  -k, --disk          Run disk I/O benchmark only
  -a, --all           Run all tests (default)
  -n NUM              Number of successful tests to run (default: 5)
  -r REGION           Filter by region
  -p PROVIDER         Filter by provider
  -h, --help          Show help message

REGIONS:
  europe, north_america, asia_pacific, oceania, south_america, africa_middle_east, all

EXAMPLES:
  ./speedtest.sh -i                       Interactive mode
  ./speedtest.sh                          Run all tests (random servers)
  ./speedtest.sh -r europe -n 10          Test 10 European servers
  ./speedtest.sh -r asia_pacific -p Vultr Test Vultr servers in Asia
  ./speedtest.sh -d -p Hetzner            Download tests from Hetzner only
```

## Available Providers

| Provider | Regions | Locations |
|----------|---------|-----------|
| Cloudflare | Global | CDN Edge (everywhere) |
| Vultr | All | 20+ locations |
| Linode | All | 10+ locations |
| Hetzner | Europe | Germany, Finland |
| OVH | Europe | France (4 DCs) |
| Leaseweb | Global | Netherlands, Germany, USA, Asia |
| Clouvider | EU/USA | Amsterdam, London, Frankfurt, US |
| Serverius | Europe | Netherlands |
| Anexia | Europe | Austria |
| Tele2 | Europe | Sweden |
| BelWue | Europe | Germany |

## Server Locations

### Europe (30+ servers)
Germany, Netherlands, UK, France, Sweden, Poland, Spain, Austria, Finland

### North America (25+ servers)
USA: New York, Chicago, Los Angeles, Seattle, Atlanta, Miami, Dallas, San Francisco
Canada: Toronto, Montreal

### Asia Pacific (15+ servers)
Singapore, Japan (Tokyo), South Korea (Seoul), India (Mumbai, Delhi, Bengaluru), Hong Kong

### Oceania
Australia: Sydney, Melbourne

### South America
Brazil (Sao Paulo), Chile (Santiago), Colombia (Bogota)

### Africa & Middle East
South Africa (Johannesburg), Israel (Tel Aviv), UAE (Dubai)

## Requirements

- `curl` - For HTTP requests
- `bc` - For calculations
- `ping` - For latency tests (usually pre-installed)

### Install Dependencies

**Debian/Ubuntu:**
```bash
sudo apt install curl bc
```

**RHEL/CentOS/Fedora:**
```bash
sudo dnf install curl bc
```

**macOS:**
```bash
# Usually pre-installed
```

## Security

- All connections use **HTTPS**
- No data uploaded to external servers
- Temporary files automatically cleaned up
- No external dependencies beyond standard Unix tools

## License

GPLv3

## Credits

- Originally created by "black" on LowEndTalk
- Modernized for 2026 with multi-provider support and interactive selection

## Contributing

To add a new speedtest server, open an issue or PR with:
- Server URL (must support HTTPS and have a 100MB test file)
- Provider name
- City and country
