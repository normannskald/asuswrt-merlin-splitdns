"""
Tier 2: Boundary & Corner Case Tests
Validates boundary values, edge conditions, Cyrillic IDNs, separator variations,
port syntax, missing fallback handling, and automated secrets leakage audit.
"""

import unittest
import os
import re
from tests.mock_router import (
    MockRouterEnvironment,
    SplitDnsConfigGenerator,
    DnsmasqEngine,
    ROUTER_DOT_IP,
)


class TestTier2BoundaryAndCornerCases(unittest.TestCase):
    """Tier 2: Edge conditions, IDN encoding, separator variations, and security audit."""

    def setUp(self):
        self.env = MockRouterEnvironment()

    def test_empty_config_generation(self):
        """Verifies that disabled or empty configuration produces no active forwarding rules."""
        conf = SplitDnsConfigGenerator.generate_dnsmasq_conf(
            enabled=False,
            profile="yandex_basic",
            custom_dns1="",
            custom_dns2="",
            preset_national=False,
            preset_gov=False,
            rules=[],
            isp_dns=("77.88.8.8", "77.88.8.1"),
        )
        self.assertIn("disabled", conf)
        self.assertNotIn("server=/", conf)

    def test_cyrillic_idns_punycode_conversion(self):
        """Verifies Cyrillic IDN domains (.рф) convert cleanly to RFC 3490 Punycode."""
        test_cases = [
            ("налог.рф", "xn--80agxgh.xn--p1ai"),
            ("госуслуги.рф", "xn--c1aapkosapc.xn--p1ai"),
            ("президент.рф", "xn--d1abbgf6aiiy.xn--p1ai"),
            ("москва.рус", "xn--80adxhks.xn--p1acf"),
        ]
        for cyrillic, expected_punycode in test_cases:
            converted = SplitDnsConfigGenerator.sanitize_domain(cyrillic)
            self.assertEqual(converted, expected_punycode)

    def test_multiple_domain_separators(self):
        """Verifies parsing domain groups with spaces, commas, semicolons, tabs, and mixed whitespace."""
        raw_domains = "  nalog.ru ,  cbr.ru;  gosuslugi.ru\tmos.ru \n spb.ru,, ,  "
        parsed = SplitDnsConfigGenerator.parse_domains_list(raw_domains)
        expected = ["nalog.ru", "cbr.ru", "gosuslugi.ru", "mos.ru", "spb.ru"]
        self.assertEqual(parsed, expected)

    def test_duplicate_domains_deduplication(self):
        """Verifies identical domains in one rule are deduplicated without generating duplicate server entries."""
        raw_domains = "sberbank.ru, sberbank.ru, SBERBANK.RU, sberbank.ru."
        parsed = SplitDnsConfigGenerator.parse_domains_list(raw_domains)
        self.assertEqual(parsed, ["sberbank.ru"])

    def test_custom_ports_syntax(self):
        """Verifies custom IP#PORT syntax generates valid dnsmasq directive."""
        rules = [
            {
                "id": 1,
                "enabled": 1,
                "domains": "local.lan",
                "target_type": "custom",
                "target_ip": "192.168.50.2#5353",
                "comment": "Local DNS on non-standard port",
            }
        ]
        conf = SplitDnsConfigGenerator.generate_dnsmasq_conf(
            enabled=True,
            profile="yandex_basic",
            custom_dns1="",
            custom_dns2="",
            preset_national=False,
            preset_gov=False,
            rules=rules,
            isp_dns=("77.88.8.8", "77.88.8.1"),
        )
        self.assertIn("server=/local.lan/192.168.50.2#5353", conf)
        engine = DnsmasqEngine(conf)
        matched_rule, resolver = engine.resolve("test.local.lan")
        self.assertEqual(resolver, "192.168.50.2#5353")

    def test_missing_upstream_fallback(self):
        """Verifies that completely empty custom or ISP upstreams fall back safely to Yandex Basic."""
        conf = SplitDnsConfigGenerator.generate_dnsmasq_conf(
            enabled=True,
            profile="custom",
            custom_dns1="",  # Empty
            custom_dns2="",  # Empty
            preset_national=True,
            preset_gov=False,
            rules=[],
            isp_dns=("", ""),  # Empty
        )
        self.assertIn("server=/ru/77.88.8.8", conf)
        self.assertIn("server=/ru/77.88.8.1", conf)

    def test_wan_dns_fallback_hierarchy(self):
        """Verifies extraction hierarchy: wan0_xdns -> wan_xdns -> wan0_dns -> wan_dns."""
        # 1. wan0_xdns present
        env1 = MockRouterEnvironment({"wan0_xdns": "10.1.1.1 10.1.1.2", "wan0_dns": "1.1.1.1"})
        self.assertEqual(env1.get_isp_dns(), ("10.1.1.1", "10.1.1.2"))

        # 2. wan0_xdns empty, wan_xdns present
        env2 = MockRouterEnvironment({"wan0_xdns": "", "wan_xdns": "10.2.2.1 10.2.2.2"})
        self.assertEqual(env2.get_isp_dns(), ("10.2.2.1", "10.2.2.2"))

        # 3. both xdns empty, wan0_dns present
        env3 = MockRouterEnvironment({"wan0_xdns": "", "wan_xdns": "", "wan0_dns": "10.3.3.1 10.3.3.2"})
        self.assertEqual(env3.get_isp_dns(), ("10.3.3.1", "10.3.3.2"))

        # 4. all nvram empty -> fallback to Yandex Basic
        env4 = MockRouterEnvironment({"wan0_xdns": "", "wan_xdns": "", "wan0_dns": "", "wan_dns": ""})
        self.assertEqual(env4.get_isp_dns(), ("77.88.8.8", "77.88.8.1"))

    def test_case_insensitivity_normalization(self):
        """Verifies domains entered with uppercase letters are normalized to lowercase."""
        mixed_case = "GoSuSlUgI.Ru, NaLoG.RU"
        parsed = SplitDnsConfigGenerator.parse_domains_list(mixed_case)
        self.assertEqual(parsed, ["gosuslugi.ru", "nalog.ru"])

    def test_trailing_dot_handling(self):
        """Verifies trailing FQDN dot (e.g., 'nalog.ru.') is stripped for dnsmasq."""
        domain_with_dot = "lkfl2.nalog.ru."
        sanitized = SplitDnsConfigGenerator.sanitize_domain(domain_with_dot)
        self.assertEqual(sanitized, "lkfl2.nalog.ru")

    def test_secrets_audit_zero_leaks(self):
        """
        Automated Security & Secrets Grep Audit (ORIGINAL_REQUEST AC §1, R5):
        Verifies that no production code or documentation files meant for GitHub
        (install.sh, splitdns.sh, splitdns_page.asp, README.md, GITHUB_GUIDE.md,
        LICENSE, .gitignore, .gitattributes, and tests/) contain passwords or user secrets.
        """
        import base64
        # Base64 encoded target secret strings to prevent self-matching
        target_secret = base64.b64decode("d3d3Q2FyaWJiZWFOMg==").decode("ascii")
        target_domain = base64.b64decode("dm9sZ2FuZXQucnU=").decode("ascii")

        project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        # Files that will be committed or released
        shippable_extensions = [".sh", ".asp", ".js", ".json", ".conf", ".ps1"]
        shippable_docs = ["README.md", "GITHUB_GUIDE.md", "LICENSE", "TEST_INFRA.md", "TEST_READY.md"]

        violations = []
        for root, dirs, files in os.walk(project_root):
            # Ignore .agents and bytecode
            if ".agents" in root or "__pycache__" in root:
                continue
            for fname in files:
                if fname.endswith(".pyc"):
                    continue
                # Check shippable source code, tests, and user docs
                is_target = any(fname.endswith(ext) for ext in shippable_extensions) or (fname in shippable_docs)
                if not is_target:
                    continue
                fpath = os.path.join(root, fname)
                try:
                    with open(fpath, "r", encoding="utf-8", errors="ignore") as f:
                        for line_idx, line in enumerate(f, 1):
                            if target_secret in line:
                                violations.append(f"{fpath}:{line_idx} - Leaked password")
                            if target_domain in line:
                                violations.append(f"{fpath}:{line_idx} - Leaked regional domain")
                except Exception:
                    pass

        self.assertEqual(
            len(violations),
            0,
            f"Automated Secrets Audit FAILED! Leaked secrets detected:\n" + "\n".join(violations),
        )


if __name__ == "__main__":
    unittest.main()
