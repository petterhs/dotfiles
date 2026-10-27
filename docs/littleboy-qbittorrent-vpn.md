# qBittorrent on Proton (littleboy)

Torrent traffic from qBittorrent leaves through Proton. Tailscale, Caddy, and the rest of littleboy keep the normal default route. littleboy stays `192.168.68.58`.

`192.168.15.1` is not on the home LAN. It is the qBittorrent end of a virtual cable that exists only inside littleboy. The host end is `192.168.15.5`. The dashboard URL stays `http://qb.lab.hoem.tech`.

## 1. Proton config into sops

On a machine that can decrypt `secrets/secrets.yaml` (littleboy, fatman, or no-kon-lx-016):

1. Proton account → Downloads → WireGuard.
2. Pick a server marked **P2P**, enable **NAT-PMP**, download the `.conf`.
3. The file must include `DNS=` and `Endpoint=`. Do not commit the raw file.

```bash
./scripts/setup-proton-wireguard.sh /path/to/proton.conf
```

Then deploy:

```bash
sudo nixos-rebuild switch --flake .#littleboy
```

`nixos-rebuild` fails until that secret exists, because the namespace service reads it at startup.

## 2. Download clients

qBittorrent no longer shares the host loopback. Point download clients at the namespace address, port `8080`:

| App | Host |
|---|---|
| Sonarr | `192.168.15.1` |
| Radarr | `192.168.15.1` |
| ReadMeABook | `http://192.168.15.1:8080` |
| Home Assistant qBittorrent integration | `192.168.15.1` |

Use the WebUI username and password. “Bypass authentication for clients on localhost” does not apply to `192.168.15.1`.

In qBittorrent, the WebUI listen address must be all interfaces (the default), not `127.0.0.1`.

## 3. Check

On littleboy, the host address should still be your home IP. qBittorrent’s namespace should be a Proton IP:

```bash
curl -4 ifconfig.me
sudo ip netns exec proton curl -4 ifconfig.me
```

From a phone on Tailscale, `http://qb.lab.hoem.tech` should still open.

qBittorrent's "run on torrent finished" hook calls Home Assistant at `192.168.68.58`. That LAN address is the one exception allowed out of the namespace without going through Proton.
