# rea (network)

What: how a program or device talks - an app's API, a LAN device's protocol, a game's netcode, a daemon's socket.
How: look at who it talks to, capture one action at a time, read it as a format, replay one message against the real
service before claiming to understand it. Only his own apps and devices, on his own network (`rea` boundaries).

## 0. Who talks to whom, without capturing

```sh
ss -tupn                               # sockets and the owning process; -l for listeners
ss -tn state established '( dport = :443 )'
lsof -i -a -p PID                      # one program's sockets
scripts/trace-summary -r CMD...        # connect() targets and files, from strace; no capture needed
```

For a local service the answer is often a Unix socket or D-Bus: `ss -xlp`, `busctl --user monitor` (`software`).

## 1. Capture

Packages here: `tcpdump`, `wireshark-cli` (gives `tshark`), `mitmproxy`, `scapy` (`python-scapy`), `socat`, `nmap`.

```sh
sudo tcpdump -nn -i any -s0 -w re/cap.pcap 'host 192.168.1.50 and not port 22'    # filter at capture: small files
tshark -r re/cap.pcap -q -z conv,tcp                                              # flows: who, how many bytes
tshark -r re/cap.pcap -q -z io,phs                                                # protocol hierarchy
tshark -r re/cap.pcap -Y 'udp.port == 5000' -T fields -e frame.time_relative -e ip.src -e udp.length -e data.data
tshark -r re/cap.pcap -q -z follow,tcp,ascii,0                                    # one TCP stream as text
```

Rules for a useful capture: one action per capture file (`login.pcap`, `set-volume-10.pcap`, `set-volume-50.pcap`);
write down the clock time of the action; capture on a quiet network or filter by the device's address. His `sniff`
gives a one-screen summary of a capture.

## 2. Classify what you see

| Looks like | Do |
|---|---|
| TLS (starts `16 03 01`, port 443) | the content is encrypted: use the app's own debug log, or a proxy (section 3) |
| HTTP, JSON, XML, protobuf over HTTP | `web`; `tshark -Y http.request -T fields -e http.request.method -e http.host -e http.request.uri` |
| WebSocket | the handshake is HTTP with `Upgrade: websocket`; the frames after it are in the browser devtools Network tab or `tshark -Y websocket` |
| mDNS / SSDP / DHCP | discovery: `tshark -Y 'mdns or ssdp'` gives the service names and ports the device announces |
| UDP with a small fixed size | a binary protocol, probably one struct per datagram: `formats` |
| TCP with printable commands | a text protocol: you can type it by hand with `nc HOST PORT` or `socat - TCP:HOST:PORT` |
| TCP with length prefixes | framed binary: first 2 or 4 bytes equal the rest of the message length |

## 3. HTTPS from his own apps

- Best first: the app's own verbose log or a `--debug` flag (`software`), and the browser devtools for a web app.
- `mitmproxy` (or `mitmdump -w re/flows.mitm`) on a port; point one throwaway profile or process at it
  (`HTTPS_PROXY=http://127.0.0.1:8080 curl ...`); install its CA only into that profile, never the system store.
  Apps with certificate pinning refuse it: that is an answer too (note it, take another route).
- `SSLKEYLOGFILE=re/keys.log` for browsers and curl-like clients: then `tshark -o tls.keylog_file:re/keys.log` decrypts
  the capture without a proxy and the traffic stays unmodified.

## 4. Read a binary protocol

1. Split the capture into messages (per datagram for UDP, per frame for TCP; `fieldscan` on one message per file, or
   the `-T fields -e data.data` column).
2. Group by length and by the first byte(s): those are message types. Count each type; the common one is usually the
   heartbeat or the data update.
3. For each type, the `formats` method across messages: which bytes are constant, which vary together with the
   one thing you changed. Sequence numbers count up by one; timestamps drift steadily; checksums change with
   everything.
4. The state machine: who speaks first, what the reply to each type is, what a keep-alive looks like, how it
   ends (FIN, a goodbye message, a timeout). Draw it as a table: `state | message | next state`.
5. Bluetooth LE and USB are the same method on other capture tools: `btmon -w`, `usbmon` with Wireshark; the
   service and characteristic list from `bluetoothctl` (`gatt` menu) is the protocol's "API".

## 5. Replay before claiming

Send one captured request to the real service and check the answer matches the capture:

```sh
printf 'GET /status HTTP/1.0\r\n\r\n' | nc 192.168.1.50 80
python3 - <<'PY'
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.settimeout(1)
s.sendto(bytes.fromhex('a1 02 00 0a'), ('192.168.1.50', 5000)); print(s.recvfrom(2048))
PY
```

Then change one field, and see the device react (a volume step, an LED). A field is understood when changing it
does what the spec says. Do not replay anything that can change state you cannot undo (firmware update, factory
reset, payment) - read those messages, do not send them.

## 6. Result

`docs/PROTOCOL.md`: transport and port, framing, a table of message types (id, direction, fields with offset, size,
meaning), the state machine, one captured example per type in hex, the open questions. Then a client: a bash
wrapper around `nc` for text protocols, a small Python or C client for binary ones (`bash-everything`, `spec`).
Auth tokens and device serial numbers in the example captures are replaced before anything is committed
(`publish-anything`).
