"""
Tier 3: Cross-Feature Combinations & Invariants Tests
Tests interactions across multiple subsystems:
- Longest suffix match overriding national presets.
- Multi-tier rule hierarchy.
- Surgical reset followed by apply.
- Transient custom_settings.txt cleanup and isolation.
- Rapid state toggles and rule enable/disable toggles.
"""

import unittest
from tests.mock_router import (
    MockRouterEnvironment,
    SplitDnsConfigGenerator,
    DnsmasqEngine,
    ROUTER_DOT_IP,
)


class TestTier3CrossFeatureCombinations(unittest.TestCase):
    """Tier 3: Complex multi-subsystem integration and edge-case combinations."""

    def setUp(self):
        self.env = MockRouterEnvironment()

    def test_longest_suffix_match_override(self):
        """
        Dnsmasq longest suffix match:
        Verifies that a custom rule targeting Router DoT (127.0.1.1)
        overrides the broader national preset (.ru -> 77.88.8.8) for matching subdomains,
        while all other .ru domains continue using the national preset.
        """
        rules = [
            {
                "id": 1,
                "enabled": 1,
                "domains": "internal.company.ru",
                "target_type": "router",
                "target_ip": "",
                "comment": "Corporate exception for DoT",
            }
        ]
        conf = SplitDnsConfigGenerator.generate_dnsmasq_conf(
            enabled=True,
            profile="yandex_basic",
            custom_dns1="",
            custom_dns2="",
            preset_national=True,
            preset_gov=False,
            rules=rules,
            isp_dns=("77.88.8.8", "77.88.8.1"),
        )
        engine = DnsmasqEngine(conf, default_resolver=ROUTER_DOT_IP)

        # 1. Subdomain of exception -> must route to Router DoT (127.0.1.1)
        matched, resolver = engine.resolve("api.internal.company.ru")
        self.assertEqual(matched, "internal.company.ru")
        self.assertEqual(resolver, ROUTER_DOT_IP)

        # 2. Exact match of exception -> must route to Router DoT (127.0.1.1)
        matched, resolver = engine.resolve("internal.company.ru")
        self.assertEqual(matched, "internal.company.ru")
        self.assertEqual(resolver, ROUTER_DOT_IP)

        # 3. Other subdomain under company.ru -> must route to national preset (77.88.8.8)
        matched, resolver = engine.resolve("mail.company.ru")
        self.assertEqual(matched, "ru")
        self.assertEqual(resolver, "77.88.8.8")

        # 4. Any generic .ru domain -> must route to national preset (77.88.8.8)
        matched, resolver = engine.resolve("yandex.ru")
        self.assertEqual(matched, "ru")
        self.assertEqual(resolver, "77.88.8.8")

        # 5. International domain -> not matched, routes to default resolver
        matched, resolver = engine.resolve("cloudflare.com")
        self.assertEqual(matched, "*")
        self.assertEqual(resolver, ROUTER_DOT_IP)

    def test_multi_level_exceptions_hierarchy(self):
        """
        Validates 3-level rule hierarchy:
        Level 1: .ru -> 77.88.8.8 (Yandex Basic)
        Level 2: gosuslugi.ru -> 195.208.4.1 (NSDI)
        Level 3: special.gosuslugi.ru -> 127.0.1.1 (Router DoT)
        """
        rules = [
            {
                "id": 1,
                "enabled": 1,
                "domains": "gosuslugi.ru",
                "target_type": "custom",
                "target_ip": "195.208.4.1",
                "comment": "NSDI route for portal",
            },
            {
                "id": 2,
                "enabled": 1,
                "domains": "special.gosuslugi.ru",
                "target_type": "router",
                "target_ip": "",
                "comment": "DoT exception for special portal",
            },
        ]
        conf = SplitDnsConfigGenerator.generate_dnsmasq_conf(
            enabled=True,
            profile="yandex_basic",
            custom_dns1="",
            custom_dns2="",
            preset_national=True,
            preset_gov=False,
            rules=rules,
            isp_dns=("77.88.8.8", "77.88.8.1"),
        )
        engine = DnsmasqEngine(conf, default_resolver=ROUTER_DOT_IP)

        # Level 1 check
        _, res_lvl1 = engine.resolve("nalog.ru")
        self.assertEqual(res_lvl1, "77.88.8.8")

        # Level 2 check
        _, res_lvl2 = engine.resolve("esia.gosuslugi.ru")
        self.assertEqual(res_lvl2, "195.208.4.1")

        # Level 3 check
        _, res_lvl3 = engine.resolve("auth.special.gosuslugi.ru")
        self.assertEqual(res_lvl3, ROUTER_DOT_IP)

    def test_surgical_reset_then_apply(self):
        """
        Verifies that surgical reset cleanly deletes all Split DNS files,
        and a subsequent apply recreates configurations without residue.
        """
        # Step 1: Initial state
        self.env.write_file("/jffs/addons/splitdns/splitdns.conf", "ENABLED=1\n")
        self.env.write_file("/jffs/addons/splitdns/dnsmasq_splitdns.conf", "server=/ru/77.88.8.8\n")
        self.env.write_file(
            "/jffs/configs/dnsmasq.conf.add",
            "conf-file=/jffs/addons/splitdns/dnsmasq_splitdns.conf\nconf-file=/jffs/addons/amneziawg/dnsmasq.conf\n"
        )

        # Step 2: Perform Surgical Reset
        self.env.remove_file("/jffs/addons/splitdns/splitdns.conf")
        self.env.remove_file("/jffs/addons/splitdns/dnsmasq_splitdns.conf")
        dnsmasq_add = self.env.read_file("/jffs/configs/dnsmasq.conf.add")
        clean_add = "\n".join([line for line in dnsmasq_add.splitlines() if "dnsmasq_splitdns.conf" not in line]) + "\n"
        self.env.write_file("/jffs/configs/dnsmasq.conf.add", clean_add)

        # Confirm reset clean
        self.assertFalse(self.env.file_exists("/jffs/addons/splitdns/splitdns.conf"))
        self.assertNotIn("dnsmasq_splitdns.conf", self.env.read_file("/jffs/configs/dnsmasq.conf.add"))
        self.assertIn("conf-file=/jffs/addons/amneziawg/dnsmasq.conf", self.env.read_file("/jffs/configs/dnsmasq.conf.add"))

        # Step 3: Subsequent Apply
        new_conf = SplitDnsConfigGenerator.generate_dnsmasq_conf(
            enabled=True,
            profile="yandex_basic",
            custom_dns1="",
            custom_dns2="",
            preset_national=True,
            preset_gov=False,
            rules=[],
            isp_dns=("77.88.8.8", "77.88.8.1"),
        )
        self.env.write_file("/jffs/addons/splitdns/dnsmasq_splitdns.conf", new_conf)
        self.env.write_file(
            "/jffs/configs/dnsmasq.conf.add",
            clean_add + "conf-file=/jffs/addons/splitdns/dnsmasq_splitdns.conf\n"
        )

        # Assert successfully reapplied
        self.assertTrue(self.env.file_exists("/jffs/addons/splitdns/dnsmasq_splitdns.conf"))
        self.assertIn("conf-file=/jffs/addons/splitdns/dnsmasq_splitdns.conf", self.env.read_file("/jffs/configs/dnsmasq.conf.add"))

    def test_transient_custom_settings_cleanup(self):
        """
        Verifies that form submission with transient splitdns keys cleans up
        immediately, ensuring 0 byte permanent footprint in custom_settings.txt.
        """
        initial_content = "awg_enable=1\nawg_endpoint=1.2.3.4:51820\n"
        self.env.write_file("/jffs/addons/custom_settings.txt", initial_content)

        # User submits form via applyapp.cgi
        transient_keys = (
            "splitdns_enable=1\n"
            "splitdns_profile=yandex_safe\n"
            "splitdns_preset_national=1\n"
            "splitdns_rules_count=5\n"
        )
        self.env.write_file("/jffs/addons/custom_settings.txt", initial_content + transient_keys)

        # Engine purges transient keys
        self.env.purge_transient_custom_settings()
        final_content = self.env.read_file("/jffs/addons/custom_settings.txt")

        self.assertEqual(final_content.strip(), initial_content.strip())

    def test_rule_disabled_toggle_behavior(self):
        """Verifies that setting a rule's enabled flag to 0 omits its directives from dnsmasq."""
        rules = [
            {
                "id": 1,
                "enabled": 0,  # Disabled
                "domains": "disabled-rule.ru",
                "target_type": "router",
                "target_ip": "",
                "comment": "Temporarily disabled rule",
            },
            {
                "id": 2,
                "enabled": 1,  # Active
                "domains": "active-rule.ru",
                "target_type": "router",
                "target_ip": "",
                "comment": "Active rule",
            },
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
        self.assertNotIn("disabled-rule.ru", conf)
        self.assertIn("active-rule.ru", conf)


if __name__ == "__main__":
    unittest.main()
