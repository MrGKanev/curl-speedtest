#!/bin/bash
# Licensed under GPLv3
# Originally created by "black" on LET
# Modernized for 2026 with HTTPS support, multi-provider support, and interactive selection
# Compatible with macOS (bash 3.2+) and Linux
# Please give credit if you plan on using this for your own projects

# Configuration
TIMEOUT=10
FIFO_FILE="/tmp/speedtest_upload_$$"
PROVIDERS_FILE="/tmp/speedtest_providers_$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${BLUE}============================================${NC}"
  echo -e "${BLUE}  Network Speed Test - $(date '+%Y-%m-%d %H:%M')${NC}"
  echo -e "${BLUE}============================================${NC}"
}

check_dependencies() {
  local missing=0
  for cmd in curl bc; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo -e "${RED}Error: This script requires '$cmd'${NC}"
      missing=1
    fi
  done
  if [ $missing -eq 1 ]; then
    exit 1
  fi
}

# =============================================================================
# SERVER DATABASE - Organized by Region > Country > Provider
# Format: URL;Provider;City;Country
# =============================================================================

get_servers_europe() {
  cat <<'EOM'
https://speed.cloudflare.com/__down?bytes=104857600;Cloudflare;CDN Edge;Global
https://speed.hetzner.de/100MB.bin;Hetzner;Falkenstein;Germany
https://fsn1-speed.hetzner.com/100MB.bin;Hetzner;Falkenstein;Germany
https://nbg1-speed.hetzner.com/100MB.bin;Hetzner;Nuremberg;Germany
https://hel1-speed.hetzner.com/100MB.bin;Hetzner;Helsinki;Finland
https://proof.ovh.net/files/100Mb.dat;OVH;Roubaix;France
https://gra.proof.ovh.net/files/100Mb.dat;OVH;Gravelines;France
https://sbg.proof.ovh.net/files/100Mb.dat;OVH;Strasbourg;France
https://rbx.proof.ovh.net/files/100Mb.dat;OVH;Roubaix;France
https://speedtest.tele2.net/100MB.zip;Tele2;Stockholm;Sweden
https://fra-de-ping.vultr.com/vultr.com.100MB.bin;Vultr;Frankfurt;Germany
https://ams-nl-ping.vultr.com/vultr.com.100MB.bin;Vultr;Amsterdam;Netherlands
https://lon-gb-ping.vultr.com/vultr.com.100MB.bin;Vultr;London;UK
https://par-fr-ping.vultr.com/vultr.com.100MB.bin;Vultr;Paris;France
https://waw-pl-ping.vultr.com/vultr.com.100MB.bin;Vultr;Warsaw;Poland
https://sto-se-ping.vultr.com/vultr.com.100MB.bin;Vultr;Stockholm;Sweden
https://mad-es-ping.vultr.com/vultr.com.100MB.bin;Vultr;Madrid;Spain
https://speedtest.london.linode.com/100MB-london.bin;Linode;London;UK
https://speedtest.frankfurt.linode.com/100MB-frankfurt.bin;Linode;Frankfurt;Germany
https://ams.speedtest.clouvider.net/cdn/100MB.bin;Clouvider;Amsterdam;Netherlands
https://lon.speedtest.clouvider.net/cdn/100MB.bin;Clouvider;London;UK
https://fra.speedtest.clouvider.net/cdn/100MB.bin;Clouvider;Frankfurt;Germany
https://speedtest.serverius.net/files/100Mb.bin;Serverius;Dronten;Netherlands
https://lg.leaseweb.com/100MB.bin;Leaseweb;Amsterdam;Netherlands
https://mirror.nl.leaseweb.net/speedtest/100mb.bin;Leaseweb;Amsterdam;Netherlands
https://mirror.de.leaseweb.net/speedtest/100mb.bin;Leaseweb;Frankfurt;Germany
https://speedtest.anexia-it.com/100MB.bin;Anexia;Vienna;Austria
https://speedtest.belwue.net/100M;BelWue;Stuttgart;Germany
EOM
}

get_servers_north_america() {
  cat <<'EOM'
https://speed.cloudflare.com/__down?bytes=104857600;Cloudflare;CDN Edge;Global
https://nj-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;New Jersey;USA
https://il-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;Chicago;USA
https://lax-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;Los Angeles;USA
https://sjo-ca-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;Silicon Valley;USA
https://sea-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;Seattle;USA
https://atl-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;Atlanta;USA
https://mia-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;Miami;USA
https://dfw-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;Dallas;USA
https://ord-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;Chicago;USA
https://ewr-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;New Jersey;USA
https://hnl-us-ping.vultr.com/vultr.com.100MB.bin;Vultr;Honolulu;USA
https://speedtest.fremont.linode.com/100MB-fremont.bin;Linode;Fremont;USA
https://speedtest.newark.linode.com/100MB-newark.bin;Linode;Newark;USA
https://speedtest.atlanta.linode.com/100MB-atlanta.bin;Linode;Atlanta;USA
https://speedtest.dallas.linode.com/100MB-dallas.bin;Linode;Dallas;USA
https://la.speedtest.clouvider.net/cdn/100MB.bin;Clouvider;Los Angeles;USA
https://ny.speedtest.clouvider.net/cdn/100MB.bin;Clouvider;New York;USA
https://dal.speedtest.clouvider.net/cdn/100MB.bin;Clouvider;Dallas;USA
https://mirror.us.leaseweb.net/speedtest/100mb.bin;Leaseweb;Washington DC;USA
https://mirror.sfo12.us.leaseweb.net/speedtest/100mb.bin;Leaseweb;San Francisco;USA
https://mirror.dal10.us.leaseweb.net/speedtest/100mb.bin;Leaseweb;Dallas;USA
https://mirror.mia11.us.leaseweb.net/speedtest/100mb.bin;Leaseweb;Miami;USA
EOM
}

get_servers_asia_pacific() {
  cat <<'EOM'
https://speed.cloudflare.com/__down?bytes=104857600;Cloudflare;CDN Edge;Global
https://sgp-ping.vultr.com/vultr.com.100MB.bin;Vultr;Singapore;Singapore
https://hnd-jp-ping.vultr.com/vultr.com.100MB.bin;Vultr;Tokyo;Japan
https://nrt-jp-ping.vultr.com/vultr.com.100MB.bin;Vultr;Tokyo;Japan
https://icn-kr-ping.vultr.com/vultr.com.100MB.bin;Vultr;Seoul;South Korea
https://bom-in-ping.vultr.com/vultr.com.100MB.bin;Vultr;Mumbai;India
https://del-in-ping.vultr.com/vultr.com.100MB.bin;Vultr;Delhi;India
https://blr-in-ping.vultr.com/vultr.com.100MB.bin;Vultr;Bengaluru;India
https://speedtest.singapore.linode.com/100MB-singapore.bin;Linode;Singapore;Singapore
https://speedtest.tokyo2.linode.com/100MB-tokyo2.bin;Linode;Tokyo;Japan
https://speedtest.mumbai1.linode.com/100MB-mumbai.bin;Linode;Mumbai;India
https://lg.hk.leaseweb.net/100MB.bin;Leaseweb;Hong Kong;Hong Kong
https://lg.sgp.leaseweb.net/100MB.bin;Leaseweb;Singapore;Singapore
EOM
}

get_servers_oceania() {
  cat <<'EOM'
https://speed.cloudflare.com/__down?bytes=104857600;Cloudflare;CDN Edge;Global
https://syd-au-ping.vultr.com/vultr.com.100MB.bin;Vultr;Sydney;Australia
https://mel-au-ping.vultr.com/vultr.com.100MB.bin;Vultr;Melbourne;Australia
https://speedtest.syd1.linode.com/100MB-syd.bin;Linode;Sydney;Australia
https://lg.syd.leaseweb.net/100MB.bin;Leaseweb;Sydney;Australia
EOM
}

get_servers_south_america() {
  cat <<'EOM'
https://speed.cloudflare.com/__down?bytes=104857600;Cloudflare;CDN Edge;Global
https://sao-br-ping.vultr.com/vultr.com.100MB.bin;Vultr;Sao Paulo;Brazil
https://scl-cl-ping.vultr.com/vultr.com.100MB.bin;Vultr;Santiago;Chile
https://bog-co-ping.vultr.com/vultr.com.100MB.bin;Vultr;Bogota;Colombia
https://speedtest.saopaulo.linode.com/100MB-saopaulo.bin;Linode;Sao Paulo;Brazil
EOM
}

get_servers_africa_middle_east() {
  cat <<'EOM'
https://speed.cloudflare.com/__down?bytes=104857600;Cloudflare;CDN Edge;Global
https://jnb-za-ping.vultr.com/vultr.com.100MB.bin;Vultr;Johannesburg;South Africa
https://tlv-il-ping.vultr.com/vultr.com.100MB.bin;Vultr;Tel Aviv;Israel
https://speedtest.dubai.linode.com/100MB-dubai.bin;Linode;Dubai;UAE
EOM
}

get_all_servers() {
  get_servers_europe
  get_servers_north_america
  get_servers_asia_pacific
  get_servers_oceania
  get_servers_south_america
  get_servers_africa_middle_east
}

# =============================================================================
# INTERACTIVE MENU SYSTEM (macOS compatible)
# Returns: 0=back, 1-8=selection, 9=exit
# =============================================================================

show_menu() {
  local title="$1"
  shift

  echo -e "\n${BOLD}${CYAN}$title${NC}\n"

  local i=1
  for opt in "$@"; do
    echo -e "  ${YELLOW}$i)${NC} $opt"
    i=$((i + 1))
  done

  echo ""
  echo -e "  ${YELLOW}0)${NC} Back"
  echo -e "  ${YELLOW}9)${NC} Exit"
  echo ""
}

read_choice() {
  local max="$1"
  local choice

  while true; do
    echo -ne "${BOLD}Select [0-$max or 9]:${NC} " >&2
    read -r choice

    # Handle exit
    if [ "$choice" = "9" ]; then
      echo "9"
      return 0
    fi

    # Handle back
    if [ "$choice" = "0" ]; then
      echo "0"
      return 0
    fi

    # Handle valid selection
    if [ -n "$choice" ] && [ "$choice" -ge 1 ] 2>/dev/null && [ "$choice" -le "$max" ] 2>/dev/null; then
      echo "$choice"
      return 0
    fi

    echo -e "${RED}Invalid choice. Enter 1-$max, 0 for back, or 9 to exit${NC}" >&2
  done
}

interactive_region_select() {
  show_menu "Select Region / Continent:" \
    "Europe" \
    "North America" \
    "Asia Pacific" \
    "Oceania" \
    "South America" \
    "Africa & Middle East" \
    "All Regions"

  local choice
  choice=$(read_choice 7)

  case $choice in
    0) SELECTED_REGION="back" ;;
    9) SELECTED_REGION="exit" ;;
    1) SELECTED_REGION="europe" ;;
    2) SELECTED_REGION="north_america" ;;
    3) SELECTED_REGION="asia_pacific" ;;
    4) SELECTED_REGION="oceania" ;;
    5) SELECTED_REGION="south_america" ;;
    6) SELECTED_REGION="africa_middle_east" ;;
    7) SELECTED_REGION="all" ;;
  esac
}

get_providers_for_region() {
  local region="$1"
  local servers=""

  case $region in
    europe)         servers=$(get_servers_europe) ;;
    north_america)  servers=$(get_servers_north_america) ;;
    asia_pacific)   servers=$(get_servers_asia_pacific) ;;
    oceania)        servers=$(get_servers_oceania) ;;
    south_america)  servers=$(get_servers_south_america) ;;
    africa_middle_east) servers=$(get_servers_africa_middle_east) ;;
    all)            servers=$(get_all_servers) ;;
  esac

  echo "$servers" | cut -d';' -f2 | sort -u
}

interactive_provider_select() {
  local region="$1"
  local providers_list
  providers_list=$(get_providers_for_region "$region")

  # Clean up any leftover temp file
  rm -f "$PROVIDERS_FILE"

  # Build menu dynamically
  echo -e "\n${BOLD}${CYAN}Select Provider:${NC}\n"

  local i=1
  echo "$providers_list" | while IFS= read -r provider; do
    if [ -n "$provider" ]; then
      echo "$i:$provider" >> "$PROVIDERS_FILE"
      echo -e "  ${YELLOW}$i)${NC} $provider"
      i=$((i + 1))
    fi
  done

  # Count providers
  local provider_count=0
  if [ -f "$PROVIDERS_FILE" ]; then
    provider_count=$(wc -l < "$PROVIDERS_FILE" | tr -d ' ')
  fi

  local all_option=$((provider_count + 1))
  echo -e "  ${YELLOW}${all_option})${NC} All Providers"
  echo ""
  echo -e "  ${YELLOW}0)${NC} Back"
  echo -e "  ${YELLOW}9)${NC} Exit"
  echo ""

  local choice
  while true; do
    echo -ne "${BOLD}Select [0-${all_option} or 9]:${NC} " >&2
    read -r choice

    if [ "$choice" = "9" ]; then
      rm -f "$PROVIDERS_FILE"
      SELECTED_PROVIDER="exit"
      return
    fi

    if [ "$choice" = "0" ]; then
      rm -f "$PROVIDERS_FILE"
      SELECTED_PROVIDER="back"
      return
    fi

    if [ -n "$choice" ] && [ "$choice" -ge 1 ] 2>/dev/null && [ "$choice" -le "$all_option" ] 2>/dev/null; then
      break
    fi

    echo -e "${RED}Invalid choice. Enter 1-${all_option}, 0 for back, or 9 to exit${NC}" >&2
  done

  if [ "$choice" -eq "$all_option" ]; then
    SELECTED_PROVIDER="all"
  else
    SELECTED_PROVIDER=$(grep "^${choice}:" "$PROVIDERS_FILE" 2>/dev/null | cut -d':' -f2)
  fi

  rm -f "$PROVIDERS_FILE"
}

get_filtered_servers() {
  local region="$1"
  local provider="$2"
  local servers=""

  case $region in
    europe)         servers=$(get_servers_europe) ;;
    north_america)  servers=$(get_servers_north_america) ;;
    asia_pacific)   servers=$(get_servers_asia_pacific) ;;
    oceania)        servers=$(get_servers_oceania) ;;
    south_america)  servers=$(get_servers_south_america) ;;
    africa_middle_east) servers=$(get_servers_africa_middle_east) ;;
    all)            servers=$(get_all_servers) ;;
  esac

  if [ "$provider" = "all" ]; then
    echo "$servers"
  else
    echo "$servers" | grep ";${provider};"
  fi
}

# =============================================================================
# SPEED TEST FUNCTIONS
# =============================================================================

test_download_speed() {
  local url="$1"
  local provider="$2"
  local city="$3"
  local country="$4"
  local server

  server=$(echo "$url" | sed -E 's|https?://([^/]+).*|\1|')

  echo -e "\n${YELLOW}Testing:${NC} ${MAGENTA}$provider${NC} - $city, $country"
  echo -n "  Connecting to $server..."

  if ! curl --connect-timeout 3 -sI "$url" >/dev/null 2>&1; then
    echo -e " ${RED}failed${NC} (trying next...)"
    return 1
  fi
  echo -e " ${GREEN}ok${NC}"

  local dlspeed
  dlspeed=$(curl --connect-timeout "$TIMEOUT" \
    --max-time 30 \
    -L \
    "$url" \
    -w "%{speed_download}" \
    -o /dev/null \
    -s 2>/dev/null | sed "s/,/./g")

  if [ -n "$dlspeed" ] && [ "$dlspeed" != "0" ] && [ "$dlspeed" != "0.000" ]; then
    local mbps
    mbps=$(echo "scale=2; $dlspeed / 131072" | bc 2>/dev/null)
    echo -e "  ${GREEN}Download:${NC} ${BOLD}$mbps Mbit/s${NC}"
    return 0
  else
    echo -e "  ${RED}Download: failed${NC} (trying next...)"
    return 1
  fi
}

test_latency() {
  echo -e "\n${BLUE}=== Latency Tests ===${NC}"

  local servers="speed.cloudflare.com speedtest.tele2.net speed.hetzner.de"

  for server in $servers; do
    echo -n "  $server: "

    local ping_result
    if ping_result=$(ping -c 3 -W 2 "$server" 2>/dev/null | grep -E 'avg|rtt'); then
      local avg
      avg=$(echo "$ping_result" | awk -F'/' '{print $5}')
      echo -e "${GREEN}${avg} ms${NC}"
    else
      echo -e "${RED}timeout${NC}"
    fi
  done
}

test_cpu() {
  echo -e "\n${BLUE}=== CPU Benchmark ===${NC}"

  if [ -f /proc/cpuinfo ]; then
    local cpuName cpuCount
    cpuName=$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^[ \t]*//')
    cpuCount=$(grep -c '^processor' /proc/cpuinfo)
    echo -e "  ${GREEN}CPU:${NC} $cpuCount x $cpuName"
  elif command -v sysctl >/dev/null 2>&1; then
    local cpuBrand
    cpuBrand=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
    echo -e "  ${GREEN}CPU:${NC} $cpuBrand"
  fi

  echo -n "  PI calculation (5000 digits): "
  local start_time end_time elapsed
  start_time=$(date +%s)
  echo "scale=5000; 4*a(1)" | bc -l >/dev/null 2>&1
  end_time=$(date +%s)
  elapsed=$((end_time - start_time))
  echo -e "${GREEN}${elapsed}s${NC}"
}

test_disk() {
  echo -e "\n${BLUE}=== Disk I/O Benchmark ===${NC}"

  local test_size=100
  local test_file="/tmp/speedtest_disk_$$"

  echo "  Writing ${test_size}MB to disk..."

  local write_result
  if [[ "$OSTYPE" == "darwin"* ]]; then
    write_result=$(dd if=/dev/zero of="$test_file" bs=1m count=$test_size 2>&1)
  else
    write_result=$(dd if=/dev/zero of="$test_file" bs=1M count=$test_size conv=fdatasync 2>&1)
  fi
  local write_speed
  write_speed=$(echo "$write_result" | grep -E 'bytes|copied' | awk '{print $(NF-1), $NF}')

  echo -e "  ${GREEN}Write speed:${NC} $write_speed"

  echo "  Reading ${test_size}MB from disk..."

  local read_result
  read_result=$(dd if="$test_file" of=/dev/null bs=1m 2>&1)
  local read_speed
  read_speed=$(echo "$read_result" | grep -E 'bytes|copied' | awk '{print $(NF-1), $NF}')

  echo -e "  ${GREEN}Read speed:${NC} $read_speed"

  rm -f "$test_file"
}

run_download_tests() {
  local region="$1"
  local provider="$2"
  local max_tests="$3"

  echo -e "\n${BLUE}=== Download Speed Tests ===${NC}"

  if [ "$region" != "all" ]; then
    local region_name
    case $region in
      europe)         region_name="Europe" ;;
      north_america)  region_name="North America" ;;
      asia_pacific)   region_name="Asia Pacific" ;;
      oceania)        region_name="Oceania" ;;
      south_america)  region_name="South America" ;;
      africa_middle_east) region_name="Africa & Middle East" ;;
    esac
    echo -e "${CYAN}Region: $region_name${NC}"
  fi

  if [ "$provider" != "all" ]; then
    echo -e "${CYAN}Provider: $provider${NC}"
  fi

  local servers
  servers=$(get_filtered_servers "$region" "$provider")

  # Shuffle servers
  if command -v shuf >/dev/null 2>&1; then
    servers=$(echo "$servers" | shuf)
  elif command -v gshuf >/dev/null 2>&1; then
    servers=$(echo "$servers" | gshuf)
  else
    servers=$(echo "$servers" | awk 'BEGIN{srand()} {print rand()"\t"$0}' | sort -n | cut -f2-)
  fi

  # Save servers to temp file to avoid subshell issues
  local servers_file="/tmp/speedtest_servers_$$"
  echo "$servers" > "$servers_file"

  local success_count=0
  local tried_count=0

  # Try servers until we get enough successful tests
  while IFS=';' read -r url prov city country; do
    if [ -z "$url" ]; then
      continue
    fi

    # Stop if we have enough successful tests
    if [ $success_count -ge "$max_tests" ]; then
      break
    fi

    tried_count=$((tried_count + 1))

    if test_download_speed "$url" "$prov" "$city" "$country"; then
      success_count=$((success_count + 1))
    fi
  done < "$servers_file"

  rm -f "$servers_file"

  if [ $success_count -eq 0 ]; then
    echo -e "\n${RED}No servers responded. Check your network connection.${NC}"
  else
    echo -e "\n${GREEN}Completed $success_count successful test(s)${NC}"
  fi
}

# =============================================================================
# INTERACTIVE LOOP
# =============================================================================

run_interactive_loop() {
  local region=""
  local provider=""

  while true; do
    # Step 1: Select region
    interactive_region_select
    region="$SELECTED_REGION"

    if [ "$region" = "exit" ]; then
      echo -e "\n${GREEN}Goodbye!${NC}"
      exit 0
    fi

    if [ "$region" = "back" ]; then
      # At top level, back means exit
      echo -e "\n${GREEN}Goodbye!${NC}"
      exit 0
    fi

    # Step 2: Select provider
    while true; do
      interactive_provider_select "$region"
      provider="$SELECTED_PROVIDER"

      if [ "$provider" = "exit" ]; then
        echo -e "\n${GREEN}Goodbye!${NC}"
        exit 0
      fi

      if [ "$provider" = "back" ]; then
        # Go back to region selection
        break
      fi

      # Step 3: Run tests
      run_download_tests "$region" "$provider" 5

      echo -e "\n${BLUE}============================================${NC}"
      echo -e "${GREEN}Test completed!${NC}"
      echo -e "${BLUE}============================================${NC}"

      # After tests, show post-test menu
      echo -e "\n${BOLD}${CYAN}What next?${NC}\n"
      echo -e "  ${YELLOW}1)${NC} Test another provider (same region)"
      echo -e "  ${YELLOW}2)${NC} Test another region"
      echo -e "  ${YELLOW}9)${NC} Exit"
      echo ""

      local next_choice
      while true; do
        echo -ne "${BOLD}Select [1, 2, or 9]:${NC} " >&2
        read -r next_choice

        case $next_choice in
          1)
            # Loop back to provider selection
            break
            ;;
          2)
            # Break out to region selection
            break 2
            ;;
          9)
            echo -e "\n${GREEN}Goodbye!${NC}"
            exit 0
            ;;
          *)
            echo -e "${RED}Invalid choice. Enter 1, 2, or 9${NC}" >&2
            ;;
        esac
      done
    done
  done
}

# =============================================================================
# MAIN
# =============================================================================

cleanup() {
  rm -f "$FIFO_FILE" "/tmp/speedtest_disk_$$" "$PROVIDERS_FILE" "/tmp/speedtest_servers_$$" 2>/dev/null
  true
}

show_help() {
  echo -e "${BOLD}Usage:${NC} $0 [OPTIONS]"
  echo ""
  echo -e "${BOLD}Network Speed Test${NC} - A modern benchmark tool with multi-provider support"
  echo ""
  echo -e "${BOLD}OPTIONS:${NC}"
  echo -e "  ${YELLOW}-i, --interactive${NC}   Interactive mode: select region and provider"
  echo -e "  ${YELLOW}-d, --download${NC}      Run download speed tests only"
  echo -e "  ${YELLOW}-l, --latency${NC}       Run latency tests only"
  echo -e "  ${YELLOW}-c, --cpu${NC}           Run CPU benchmark only"
  echo -e "  ${YELLOW}-k, --disk${NC}          Run disk I/O benchmark only"
  echo -e "  ${YELLOW}-a, --all${NC}           Run all tests (default)"
  echo -e "  ${YELLOW}-n NUM${NC}              Number of servers to test (default: 5)"
  echo -e "  ${YELLOW}-r REGION${NC}           Region: europe, north_america, asia_pacific,"
  echo "                      oceania, south_america, africa_middle_east, all"
  echo -e "  ${YELLOW}-p PROVIDER${NC}         Provider filter (e.g., Vultr, Linode, Hetzner)"
  echo -e "  ${YELLOW}-h, --help${NC}          Show this help message"
  echo ""
  echo -e "${BOLD}EXAMPLES:${NC}"
  echo "  $0                     Run all tests with random servers"
  echo "  $0 -i                  Interactive region/provider selection"
  echo "  $0 -r europe -n 10     Test 10 European servers"
  echo "  $0 -r asia_pacific -p Vultr   Test Vultr servers in Asia Pacific"
  echo "  $0 -d -r north_america       Download tests for North America only"
  echo ""
  echo -e "${BOLD}AVAILABLE PROVIDERS:${NC}"
  echo "  Cloudflare, Vultr, Linode, Hetzner, OVH, Leaseweb, Clouvider,"
  echo "  Serverius, Anexia, Tele2, and more"
  echo ""
}

main() {
  trap cleanup EXIT

  check_dependencies

  local run_download=0
  local run_latency=0
  local run_cpu=0
  local run_disk=0
  local num_servers=5
  local interactive=0
  local region="all"
  local provider="all"

  while [ $# -gt 0 ]; do
    case "$1" in
      -i|--interactive) interactive=1 ;;
      -d|--download)    run_download=1 ;;
      -l|--latency)     run_latency=1 ;;
      -c|--cpu)         run_cpu=1 ;;
      -k|--disk)        run_disk=1 ;;
      -a|--all)         run_download=1; run_latency=1; run_cpu=1; run_disk=1 ;;
      -n)               shift; num_servers="$1" ;;
      -r|--region)      shift; region="$1" ;;
      -p|--provider)    shift; provider="$1" ;;
      -h|--help)        show_help; exit 0 ;;
      *)                echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
    shift
  done

  # Interactive mode runs its own loop
  if [ $interactive -eq 1 ]; then
    print_header
    run_interactive_loop
    exit 0
  fi

  # Default: run all tests
  if [ $run_download -eq 0 ] && [ $run_latency -eq 0 ] && [ $run_cpu -eq 0 ] && [ $run_disk -eq 0 ]; then
    run_download=1
    run_latency=1
    run_cpu=1
    run_disk=1
  fi

  print_header

  if [ $run_latency -eq 1 ]; then
    test_latency
  fi

  if [ $run_cpu -eq 1 ]; then
    test_cpu
  fi

  if [ $run_disk -eq 1 ]; then
    test_disk
  fi

  if [ $run_download -eq 1 ]; then
    run_download_tests "$region" "$provider" "$num_servers"
  fi

  echo -e "\n${BLUE}============================================${NC}"
  echo -e "${GREEN}Speed test completed!${NC}"
  echo -e "${BLUE}============================================${NC}"
}

main "$@"
