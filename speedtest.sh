#!/bin/sh
# Licensed under GPLv3
# created by "black" on LET, modified by Claude
# please give credit if you plan on using this for your own projects 

fileName="100mb.test"
timeout=2
fifo='yourfile'

do_dd() {
  dd if='/dev/urandom' bs=1M count=10 2>/dev/null > "$fifo"
}

timeout() {
  local timeout_secs=${1:-10}
  shift

  ( 
    "$@" &
    child=$!
    (       
      sleep $timeout_secs
      kill $child 2> /dev/null
    ) &
    wait $child
  )
}
export -f timeout

get_sites() {
  sort -R<<EOM
100.42.19.110;Speedtest from Portland, Oregon, USA [ generously donated by http://bonevm.com ] on a shared 100 Mbps port
23.226.231.112;Speedtest from Seattle, Washington, USA [ generously donated by http://ramnode.com ] on a shared 1 Gbps port
107.150.31.36;Speedtest from Los Angeles, CA, USA [ generously donated by http://maximumvps.net ] on a shared 1 Gbps port
208.67.5.186:10420;Speedtest from Kansas City, MO, USA [ generously donated by http://megavz.com ] on a shared 1 Gbps port
198.50.209.250;Speedtest from Beauharnois, Quebec, Canada [ generously donated by http://mycustomhosting.net ] on a shared 1000 Mbps port in / 500 Mbps port out
168.235.78.99;Speedtest from Los Angeles, California, USA, generously donated by http://ramnode.com on a shared 1 Gbps port
192.210.229.206;Speedtest from Chicago, IL, USA, generously donated by http://vortexservers.com on a shared 1 Gbps port
167.114.135.10;Speedtest from Beauharnois, Quebec, Canada [ generously donated by http://hostnun.net/ ] on a shared 500 Mbps port
192.111.152.114:2020;Speedtest from Lenoir, NC, USA, generously donated by http://megavz.com on a shared 1 Gbps port
162.220.26.107;Speedtest from Dallas, TX, USA, generously donated by http://cloudshards.com on a shared 1 Gbps port
168.235.81.120;Speedtest from New York City, New York, USA generously donated by http://ramnode.com on a shared 1 Gbps port
192.73.235.56;Speedtest from Atlanta, Georgia, USA [ generously donated by http://ramnode.com ] on a shared 1 Gbps port
162.219.26.75:12320;Speedtest from Asheville, NC, USA on a shared 1 Gbps port
107.155.187.129;Speedtest from Jacksonville, FL, USA [ generously donated by http://maximumvps.net ] on a shared 1 Gbps port
speedtest.tele2.net;Speedtest server provided by Tele2
speedtest.ume.sefiber.se;Speedtest server in Umeå, Sweden
speedtest.bahnhof.se;Speedtest server provided by Bahnhof (Sweden)
speedtest.sunet.se;Speedtest server provided by SUNET (Swedish University Network)
speedtest.bredband2.com;Speedtest server provided by Bredband2 (Sweden)
ookla.speedtest.algonquincollege.com;Speedtest server at Algonquin College, Ottawa, Canada
speedtest.eastlink.ca;Speedtest server provided by Eastlink (Canada)
speedtestto.bell.ca;Speedtest server provided by Bell Canada in Toronto
speedtest.telus.com;Speedtest server provided by TELUS (Canada)
speedtest-ntt.nebulacloud.io;Speedtest server hosted by Nebula Cloud on NTT network
lg-tor.fdcservers.net;Looking Glass server in Toronto provided by FDCservers
speedtest.vzwireless.com;Speedtest server provided by Verizon Wireless
speedtest-as5089.stf01.as57976.net;Speedtest server in Stafford, UK
speedtest.zscaler.com;Speedtest server provided by Zscaler
EOM
}

test_speed() {
  local _ADDR _COMMENT _SRV _PORT
  
  _ADDR=${1%%;*}
  _COMMENT=${1##*;}
  
  _SRV=${_ADDR%%:*}
  _PORT=${_ADDR##*:}
  
  [ "$_PORT" = "$_SRV" ] && _PORT=80
  
  echo -n "Testing connection to $_SRV $_PORT"
  if timeout 2 nc -z $_SRV $_PORT >/dev/null 2>&1; then
    echo "...success"
  else
    echo "...failure"
    return 1
  fi
  
  dlspeed=$(curl --connect-timeout $timeout "http://${_SRV}:${_PORT}/$fileName" -w "%{speed_download}" -o /dev/null -s | sed "s/,/./g")
  echo "scale=2; $dlspeed / 131072" | bc | sed "s/$/ Mbit\/sec/;s/^/\tDownload Speed: /"
	
  do_dd &
  ulspeed=$(curl --connect-timeout $timeout -T "$fifo" "http://${_SRV}:${_PORT}/webtests/ul.php" -w "%{speed_upload}" -s -o /dev/null | sed "s/,/./g")
  echo "scale=2; $ulspeed / 131072" | bc | sed "s/$/ Mbit\/sec/;s/^/\tUpload speed: /"
}

PING_DCS="speedtest.atlanta.linode.com speedtest-sfo1.digitalocean.com speedtest.newark.linode.com speedtest-nyc2.digitalocean.com speedtest.fremont.linode.com"

for cmd in curl bc nc; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "This script requires $cmd"
    exit 1
  fi
done

test_latency() {
  for dc in $PING_DCS; do
    PING=$(ping -c4 $dc | awk -F/ '/^round-trip/ {print $5}')
    echo "${dc}: Latency: $PING ms"
  done
}

test_cpu() {
  cpuName=$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^[ \t]*//')
  cpuCount=$(grep -c '^processor' /proc/cpuinfo)
  echo "CPU: $cpuCount x$cpuName"
  echo -n "Time taken to generate PI to 5000 decimal places with a single thread: "
  { time echo "scale=5000; 4*a(1)" | bc -l; } 2>&1 | awk '/real/ {print $2}'
}

test_disk() {
  size=5
  echo "Writing ${size}MB file to disk"
  dd if=/dev/zero of=$$.disktest bs=1M count=$size conv=fdatasync 2>&1 | awk '/copied/ {print $8 " " $9}'
  rm $$.disktest
}

main() {
  [ -e "$fifo" ] && rm -f "$fifo"
  
  for func in $queue; do
    $func
  done

  mkfifo "$fifo"
  echo "-------------Speed test $(date)--------------------"

  get_sites | while read site; do
    test_speed "$site"
  done

  rm -f "$fifo"
}

queue=''
while getopts "lcdv" OPT; do
  case "$OPT" in
    'l') queue="$queue test_latency ";;
    'c') queue="$queue test_cpu ";;
    'd') queue="$queue test_disk ";;
    'v') VERBOSE='true';;
  esac
done

[ -z "$queue" ] && queue="test_latency test_cpu test_disk"

main