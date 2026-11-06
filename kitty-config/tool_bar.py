"""Custom kitty tab bar: Capsule style, Arch logo, last-folder titles, transparent bar, VPN-aware IP."""

import fcntl
import socket
import struct
import time
from datetime import datetime

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

# Colors
BAR_BG = None           # None = default background (follows terminal opacity)
TAB_BG = 0x2A1D47       # Inactive capsule background (dark violet)
TAB_FG = 0xB9A6E8       # Inactive text color (soft lavender)
ACTIVE_BG = 0xD7B8FF    # Active capsule background (whitish purple)
ACTIVE_FG = 0x120A21    # Active text color (matches terminal background)
TEXT = 0xD7CAEF         # General text color (matches terminal foreground)
ACCENT = 0xD7B8FF       # Arch logo
VPN_COLOR = 0xE9DDFF    # IP color when tun0 is up (pale lavender)
NOVPN_COLOR = 0xFFC4C4  # IP color when tun0 is down (whitish red)
VPN_IFACE = "tun0"

# True: IP next to the logo on the left. False: IP on the right, next to the clock.
IP_ON_LEFT = False

ICON_ARCH = "\uf303"
ICON_WIFI = "\uf1eb"
ICON_CLOCK = "\uf017"
CAP_L = "\ue0b6"
CAP_R = "\ue0b4"

_ip_cache = {"t": 0.0, "v": "offline"}
_timer = None


def local_ip() -> str:
    """Default-route IPv4 address, cached for 10 seconds. A UDP connect sends no packets."""
    now = time.monotonic()
    if now - _ip_cache["t"] < 10:
        return _ip_cache["v"]
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.connect(("10.255.255.255", 1))
        value = sock.getsockname()[0]
    except OSError:
        value = "offline"
    finally:
        sock.close()
    _ip_cache["t"] = now
    _ip_cache["v"] = value
    return value


def iface_ip(name: str):
    """IPv4 of a specific interface (SIOCGIFADDR), or None if it's missing or has no address."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        packed = struct.pack("256s", name[:15].encode())
        return socket.inet_ntoa(fcntl.ioctl(sock.fileno(), 0x8915, packed)[20:24])
    except OSError:
        return None
    finally:
        sock.close()


def net_status():
    """(ip, color): tun0 IP in cyan when the VPN is up, normal IP in whitish red otherwise."""
    vpn = iface_ip(VPN_IFACE)
    if vpn:
        return vpn, VPN_COLOR
    return local_ip(), NOVPN_COLOR


def _redraw(timer_id) -> None:
    """Keeps the clock and VPN state fresh by marking the tab bar dirty."""
    boss = get_boss()
    manager = boss.active_tab_manager if boss else None
    if manager is not None:
        manager.mark_tab_bar_dirty()


def _set(screen: Screen, fg: int, bg, bold: bool = False) -> None:
    screen.cursor.fg = as_rgb(fg)
    screen.cursor.bg = 0 if bg is None else as_rgb(bg)   # 0 = default bg
    screen.cursor.bold = bold


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global _timer
    if _timer is None:
        _timer = add_timer(_redraw, 5.0, True)

    # Arch logo at the start of the bar
    if index == 1:
        _set(screen, ACCENT, BAR_BG, True)
        screen.draw(f"  {ICON_ARCH}  ")
        if IP_ON_LEFT:
            ip, color = net_status()
            _set(screen, color, BAR_BG)
            screen.draw(f"{ICON_WIFI} {ip}   ")

    if tab.is_active:
        bg, fg, bold = ACTIVE_BG, ACTIVE_FG, True
    else:
        bg, fg, bold = TAB_BG, TAB_FG, False

    # Left cap
    _set(screen, bg, BAR_BG)
    screen.draw(CAP_L)

    # Tab body: program name, or last folder when idle
    _set(screen, fg, bg, bold)
    title = tab.title.strip().split(" ")[0].rstrip("/")
    title = title.split("/")[-1] or title
    room = max(max_title_length - 5, 4)
    if len(title) > room:
        title = title[: room - 1] + "\u2026"
    screen.draw(f"{index}⎪{title}")

    # Right cap + gap between tabs
    _set(screen, bg, BAR_BG)
    screen.draw(CAP_R)
    _set(screen, TEXT, BAR_BG)
    screen.draw(" ")

    # Status widgets on the right
    if is_last:
        now = datetime.now()
        clock = f"  {ICON_CLOCK} {now:%H:%M}  "
        ip, color = net_status()
        net = "" if IP_ON_LEFT else f"  {ICON_WIFI}  {ip}"

        pad = screen.columns - screen.cursor.x - len(net) - len(clock)
        if pad > 0:
            _set(screen, TEXT, BAR_BG)
            screen.draw(" " * pad)
            if net:
                _set(screen, color, BAR_BG)
                screen.draw(net)
            _set(screen, TEXT, BAR_BG)
            screen.draw(clock)
        screen.cursor.bold = False

    return screen.cursor.x
