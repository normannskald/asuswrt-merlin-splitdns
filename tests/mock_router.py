"""
Asuswrt-Merlin Split DNS Mock Router Simulator
Simulates the Asuswrt-Merlin firmware environment, BusyBox ash helpers,
dnsmasq configuration generation, longest suffix match DNS resolution,
storage boundaries, and dynamic slot allocation.
"""

import os
import re
import json
import idna
import ipaddress
from typing import Dict, List, Optional, Tuple, Any

# Standard National TLDs and aliases according to specification
NATIONAL_ZONES = [
    "ru",
    "xn--p1ai",  # .рф
    "su",
    "xn--80adxhks",  # .москва
    "xn--p1acf",  # .рус
    "tatar",
    "xn--d1acj3b",  # .дети
]

# Standard Russian Government and Socially Significant domains
GOV_SERVICES_DOMAINS = [
    "gosuslugi.ru",
    "esia.gosuslugi.ru",
    "gu-st.ru",
    "gov.ru",
    "government.ru",
    "kremlin.ru",
    "duma.gov.ru",
    "duma.ru",
    "council.gov.ru",
    "sudrf.ru",
    "genproc.gov.ru",
    "nalog.ru",
    "nalog.gov.ru",
    "lkfl2.nalog.ru",
    "cbr.ru",
    "minfin.gov.ru",
    "economy.gov.ru",
    "fas.gov.ru",
    "customs.gov.ru",
    "customs.ru",
    "rosreestr.gov.ru",
    "rosreestr.ru",
    "zakupki.gov.ru",
    "gost.ru",
    "sfr.gov.ru",
    "pfr.gov.ru",
    "fss.ru",
    "rospotrebnadzor.ru",
    "edu.ru",
    "minobrnauki.gov.ru",
    "rosminzdrav.ru",
    "mvd.ru",
    "mvd.gov.ru",
    "mchs.gov.ru",
    "fssp.gov.ru",
    "mos.ru",
    "mosreg.ru",
    "spb.ru",
    "gov.spb.ru",
    "emias.info",
    "rzd.ru",
    "ticket.rzd.ru",
    "pass.rzd.ru",
    "pochta.ru",
    "aeroflot.ru",
    "digital.gov.ru",
    "rkn.gov.ru",
    "nspk.ru",
    "mironline.ru",
    "sberbank.ru",
    "sber.ru",
    "vtb.ru",
    "tinkoff.ru",
    "tbank.ru",
    "alfabank.ru",
    "gazprombank.ru",
    "psbank.ru",
    "rshb.ru",
    "uc-osnovanie.ru",
    "e-trust.gosuslugi.ru",
]

# Upstream DNS Profiles mapping
DNS_PROFILES = {
    "yandex_basic": ("77.88.8.8", "77.88.8.1"),
    "yandex_safe": ("77.88.8.88", "77.88.8.2"),
    "yandex_family": ("77.88.8.7", "77.88.8.3"),
    "nsdi": ("195.208.4.1", "195.208.5.1"),
}

ROUTER_DOT_IP = "127.0.1.1"
SPLITDNS_UI_MARKER = "<!-- AS_SPLITDNS_UI_PAGE -->"
MENUTREE_SPLITDNS_START = "/* SPLITDNS_TAB_START */"
MENUTREE_SPLITDNS_END = "/* SPLITDNS_TAB_END */"


class MockNVRAM:
    """Simulates Asuswrt-Merlin NVRAM storage."""

    def __init__(self, initial_values: Optional[Dict[str, str]] = None):
        self._store: Dict[str, str] = {
            "preferred_lang": "RU",
            "wan0_xdns": "",
            "wan0_dns": "1.1.1.1 1.0.0.1",
            "wan_xdns": "",
            "wan_dns": "1.1.1.1 1.0.0.1",
            "wan0_proto": "dhcp",
            "dnspriv_enable": "1",
            "productid": "RT-AX56U",
            "firmver": "3.0.0.4",
            "buildno": "388.8",
            "extendno": "4",
        }
        if initial_values:
            self._store.update(initial_values)

    def get(self, key: str, default: str = "") -> str:
        return self._store.get(key, default)

    def set(self, key: str, val: str) -> None:
        self._store[key] = str(val)

    def unset(self, key: str) -> None:
        self._store.pop(key, None)


class MockRouterEnvironment:
    """
    Virtual router filesystem and system environment.
    Provides mock implementation of JFFS partition, NVRAM, helper.sh,
    menuTree.js, custom_settings.txt (with 8KB overflow guard),
    and dnsmasq configuration generation and testing.
    """

    def __init__(self, nvram_overrides: Optional[Dict[str, str]] = None):
        self.nvram = MockNVRAM(nvram_overrides)
        self.files: Dict[str, str] = {}
        self.dnsmasq_running = True
        self.dnsmasq_pid = 1234
        self.setup_default_system_files()

    def setup_default_system_files(self) -> None:
        # Prepopulate existing addons on router (AmneziaWG occupying user1 and user2)
        self.files["/www/user/user1.asp"] = "<!-- AMNEZIAWG_CLIENT -->\n<html>AmneziaWG Client</html>"
        self.files["/www/user/user2.asp"] = "<!-- AMNEZIAWG_SERVER -->\n<html>AmneziaWG Server</html>"

        # Prepopulate /jffs/addons/custom_settings.txt with AmneziaWG settings
        self.files["/jffs/addons/custom_settings.txt"] = (
            "awg_enable=1\n"
            "awg_client_ip=10.0.0.2\n"
            "awg_endpoint=198.51.100.1:51820\n"
        )

        # Prepopulate /jffs/scripts/dnsmasq.postconf with AmneziaWG hook
        self.files["/jffs/scripts/dnsmasq.postconf"] = (
            "#!/bin/sh\n"
            "# amneziawg postconf\n"
            "if [ -f /jffs/addons/amneziawg/dnsmasq.conf ]; then\n"
            "    pc_append 'conf-file=/jffs/addons/amneziawg/dnsmasq.conf' \"$1\"\n"
            "fi\n"
        )

        # Prepopulate /jffs/configs/dnsmasq.conf.add
        self.files["/jffs/configs/dnsmasq.conf.add"] = (
            "# Existing dnsmasq configuration\n"
        )

        # Prepopulate /tmp/menuTree.js with Asuswrt-Merlin tabs and AmneziaWG
        self.files["/tmp/menuTree.js"] = (
            'var menuTree = [\n'
            '  {tabName: "menu_WAN", tabs: [\n'
            '    {url: "Advanced_WAN_Content.asp", tabName: "Internet Connection"},\n'
            '    {url: "Advanced_PortTrigger_Content.asp", tabName: "Port Trigger"}\n'
            '  ]},\n'
            '  {tabName: "menu_VPN", tabs: [\n'
            '    /* AWG_WIDGET_START */ {url: "user1.asp", tabName: "AmneziaWG"}, /* AWG_WIDGET_END */\n'
            '    {url: "user2.asp", tabName: "AmneziaWG Server"}\n'
            '  ]}\n'
            '];\n'
        )

    def write_file(self, path: str, content: str) -> None:
        # Enforce 8 KB limit on /jffs/addons/custom_settings.txt
        if path == "/jffs/addons/custom_settings.txt":
            byte_len = len(content.encode("utf-8"))
            if byte_len > 8192:
                raise OverflowError(
                    f"custom_settings.txt overflow: {byte_len} bytes exceeds 8192 bytes limit!"
                )
        self.files[path] = content

    def read_file(self, path: str) -> Optional[str]:
        return self.files.get(path)

    def file_exists(self, path: str) -> bool:
        return path in self.files

    def remove_file(self, path: str) -> bool:
        if path in self.files:
            del self.files[path]
            return True
        return False

    # helper.sh dynamic slot discovery simulation
    def am_get_webui_page(self, new_page_content: str) -> str:
        """
        Simulates /usr/sbin/helper.sh am_get_webui_page:
        1. Strips any existing pages containing the unique Split DNS marker.
        2. Loops user1.asp .. user20.asp to find matching content or first free slot.
        """
        # First clean up stale Split DNS pages
        for i in range(1, 21):
            page_path = f"/www/user/user{i}.asp"
            content = self.read_file(page_path)
            if content and SPLITDNS_UI_MARKER in content:
                self.remove_file(page_path)

        # Now allocate free slot
        for i in range(1, 21):
            page_path = f"/www/user/user{i}.asp"
            content = self.read_file(page_path)
            if content is None:
                return f"user{i}.asp"
            if content == new_page_content:
                return f"user{i}.asp"
        return "none"

    # menuTree.js patching simulation
    def patch_menu_tree(self, slot: str) -> None:
        """
        Patches /tmp/menuTree.js to add Split DNS to menu_WAN under mutex lock.
        Preserves existing tabs like AmneziaWG and XrayUI.
        """
        content = self.read_file("/tmp/menuTree.js") or ""
        # Strip old markers
        clean_pattern = rf"{re.escape(MENUTREE_SPLITDNS_START)}.*?{re.escape(MENUTREE_SPLITDNS_END)}"
        content = re.sub(clean_pattern, "", content, flags=re.DOTALL)

        # Insert new tab after Advanced_WAN_Content.asp
        target_tab = '{url: "Advanced_WAN_Content.asp", tabName: "Internet Connection"},'
        new_tab = (
            f'{MENUTREE_SPLITDNS_START} {{url: "{slot}", tabName: "Split DNS"}}, '
            f'{MENUTREE_SPLITDNS_END}'
        )

        if target_tab in content:
            content = content.replace(target_tab, f"{target_tab}\n    {new_tab}")
        else:
            # Fallback insert into menu_WAN
            content = content.replace(
                '{tabName: "menu_WAN", tabs: [',
                f'{{tabName: "menu_WAN", tabs: [\n    {new_tab},'
            )
        self.write_file("/tmp/menuTree.js", content)

    def unpatch_menu_tree(self) -> None:
        """Removes Split DNS tab from /tmp/menuTree.js."""
        content = self.read_file("/tmp/menuTree.js") or ""
        clean_pattern = rf"\s*{re.escape(MENUTREE_SPLITDNS_START)}.*?{re.escape(MENUTREE_SPLITDNS_END)}\s*,?"
        content = re.sub(clean_pattern, "", content, flags=re.DOTALL)
        self.write_file("/tmp/menuTree.js", content)

    # WAN DNS resolution simulation
    def get_isp_dns(self) -> Tuple[str, str]:
        xdns = self.nvram.get("wan0_xdns") or self.nvram.get("wan_xdns")
        if not xdns:
            xdns = self.nvram.get("wan0_dns") or self.nvram.get("wan_dns")
        parts = xdns.split() if xdns else []
        dns1 = parts[0] if len(parts) > 0 else "77.88.8.8"
        dns2 = parts[1] if len(parts) > 1 else "77.88.8.1"
        return dns1, dns2

    # Clean transient custom_settings.txt
    def purge_transient_custom_settings(self) -> None:
        content = self.read_file("/jffs/addons/custom_settings.txt") or ""
        lines = [line for line in content.splitlines() if not line.startswith("splitdns_")]
        self.write_file("/jffs/addons/custom_settings.txt", "\n".join(lines) + ("\n" if lines else ""))


class SplitDnsConfigGenerator:
    """
    Simulates rules parsing and dnsmasq_splitdns.conf file generation.
    Strictly follows PROJECT.md interface contracts.
    """

    @staticmethod
    def sanitize_domain(domain_str: str) -> str:
        """Sanitizes domain, rejects shell metacharacters, normalizes Cyrillic IDN to Punycode."""
        # Reject shell metacharacters immediately
        if any(c in domain_str for c in ";&|`$<>(){}[]\"'\n\r\\"):
            return ""
        cleaned = domain_str.strip().lower().rstrip(".")
        if not cleaned:
            return ""
        try:
            # Try punycode encoding if contains non-ascii
            encoded = idna.encode(cleaned).decode("ascii")
            # Must strictly match hostname characters
            if not re.match(r"^[a-zA-Z0-9\.\-_]+$", encoded):
                return ""
            return encoded
        except Exception:
            if re.match(r"^[a-zA-Z0-9\.\-_]+$", cleaned):
                return cleaned
            return ""

    @classmethod
    def parse_domains_list(cls, domains_raw: str) -> List[str]:
        """Parses domain list separated by comma, space, semicolon, or newline."""
        raw_items = re.split(r"[\s,;]+", domains_raw.strip())
        results = []
        for item in raw_items:
            sanitized = cls.sanitize_domain(item)
            if sanitized and sanitized not in results:
                results.append(sanitized)
        return results

    @classmethod
    def generate_dnsmasq_conf(
        cls,
        enabled: bool,
        profile: str,
        custom_dns1: str,
        custom_dns2: str,
        preset_national: bool,
        preset_gov: bool,
        rules: List[Dict[str, Any]],
        isp_dns: Tuple[str, str],
    ) -> str:
        """
        Generates the content for /jffs/addons/splitdns/dnsmasq_splitdns.conf
        Rules format: server=/<domain>/<upstream_ip> (no @ifname)
        """
        if not enabled:
            return "# Split DNS is disabled\n"

        # Determine profile upstreams
        if profile in DNS_PROFILES:
            upstreams = list(DNS_PROFILES[profile])
        elif profile == "isp":
            upstreams = list(isp_dns)
        elif profile == "custom":
            upstreams = [dns for dns in (custom_dns1.strip(), custom_dns2.strip()) if dns]
            if not upstreams:
                upstreams = ["77.88.8.8", "77.88.8.1"]
        else:
            upstreams = ["77.88.8.8", "77.88.8.1"]

        lines = [
            "# --- Generated by Asuswrt-Merlin Split DNS ---",
            f"# Profile: {profile}",
            f"# Upstreams: {', '.join(upstreams)}",
            "",
        ]

        # 1. Preset National Zones
        if preset_national:
            lines.append("# Preset: National Domain Zones")
            for zone in NATIONAL_ZONES:
                for upstream in upstreams:
                    lines.append(f"server=/{zone}/{upstream}")
            lines.append("")

        # 2. Preset Russian Government & Social Services
        if preset_gov:
            lines.append("# Preset: Russian Government & Social Services")
            for gov_domain in GOV_SERVICES_DOMAINS:
                sanitized = cls.sanitize_domain(gov_domain)
                for upstream in upstreams:
                    lines.append(f"server=/{sanitized}/{upstream}")
            lines.append("")

        # 3. Custom User Rules
        if rules:
            lines.append("# Custom User Rules & Exceptions")
            for rule in rules:
                if not rule.get("enabled", 1):
                    continue
                domains = cls.parse_domains_list(rule.get("domains", ""))
                target_type = rule.get("target_type", "profile")
                target_ip = rule.get("target_ip", "").strip()

                if target_type == "router":
                    rule_upstreams = [ROUTER_DOT_IP]
                elif target_type == "custom" and target_ip:
                    rule_upstreams = [target_ip]
                else:
                    rule_upstreams = upstreams

                for d in domains:
                    for u in rule_upstreams:
                        lines.append(f"server=/{d}/{u}")
            lines.append("")

        return "\n".join(lines)


class DnsmasqEngine:
    """
    Simulates dnsmasq configuration parser and resolver.
    Evaluates queries via longest suffix match as defined by RFC/dnsmasq.
    """

    def __init__(self, conf_content: str, default_resolver: str = ROUTER_DOT_IP):
        self.rules: List[Tuple[str, str]] = []  # (domain_suffix, target_resolver)
        self.default_resolver = default_resolver
        self.load_config(conf_content)

    def load_config(self, conf_content: str) -> None:
        self.rules = []
        for line in conf_content.splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            # dnsmasq server directive: server=/domain/ip
            match = re.match(r"^server=/([^/]+)/([^/]+)$", line)
            if match:
                domain = match.group(1).lower()
                target = match.group(2)
                # Validate target is IPv4 with optional #port
                ip_part = target
                if "#" in target:
                    parts = target.split("#", 1)
                    ip_part = parts[0]
                    port_str = parts[1]
                    if not (port_str.isdigit() and 1 <= int(port_str) <= 65535):
                        raise ValueError(f"Invalid port in directive: {target}")
                try:
                    ipaddress.IPv4Address(ip_part)
                except ValueError:
                    raise ValueError(f"Invalid IPv4 address in directive: {target}")
                self.rules.append((domain, target))
            else:
                raise ValueError(f"Invalid dnsmasq directive syntax: {line}")

    def test_syntax(self) -> bool:
        """Simulates dnsmasq --test syntax validation."""
        return True

    def resolve(self, query_domain: str) -> Tuple[str, str]:
        """
        Resolves domain using longest suffix matching.
        Returns: (matched_domain_rule, assigned_upstream)
        """
        sanitized = SplitDnsConfigGenerator.sanitize_domain(query_domain)
        parts = sanitized.split(".")

        best_match_domain = ""
        best_match_length = -1
        best_match_ips: List[str] = []

        # Iterate over all suffixes of query domain
        for i in range(len(parts)):
            suffix = ".".join(parts[i:])
            for rule_domain, rule_ip in self.rules:
                if rule_domain == suffix:
                    suffix_len = len(suffix)
                    if suffix_len > best_match_length:
                        best_match_length = suffix_len
                        best_match_domain = suffix
                        best_match_ips = [rule_ip]
                    elif suffix_len == best_match_length and suffix == best_match_domain:
                        if rule_ip not in best_match_ips:
                            best_match_ips.append(rule_ip)

        if best_match_domain:
            return best_match_domain, best_match_ips[0]
        return "*", self.default_resolver
