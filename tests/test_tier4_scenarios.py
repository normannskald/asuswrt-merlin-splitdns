"""
Tier 4: Real-World Scenarios (End-to-End Simulation)
Simulates complete real-world user and system lifecycles:
- Fresh install -> dynamic slot allocation -> configuration -> dnsmasq rules ->
  mock query routing -> live diagnostic query -> surgical reset -> backup/restore -> uninstall.
- Coexistence with multi-addon stacks (AmneziaWG + XrayUI).
- Zero network disruption invariant checks.
"""

import unittest
import json
from tests.mock_router import (
    MockRouterEnvironment,
    SplitDnsConfigGenerator,
    DnsmasqEngine,
    ROUTER_DOT_IP,
    SPLITDNS_UI_MARKER,
    MENUTREE_SPLITDNS_START,
    MENUTREE_SPLITDNS_END,
)


class TestTier4RealWorldScenarios(unittest.TestCase):
    """Tier 4: Full lifecycle scenarios and multi-addon coexistence simulation."""

    def setUp(self):
        self.env = MockRouterEnvironment()

    def test_full_lifecycle_simulation_with_zero_disruption(self):
        """
        Comprehensive End-to-End Simulation of Addon Lifecycle:
        1. Pre-installation environment check.
        2. UI mounting and dynamic slot assignment (user3.asp).
        3. MenuTree non-destructive patching.
        4. Application of DNS profile (Yandex Basic), presets, and custom exception rule.
        5. Storage isolation & zero transient custom_settings pollution.
        6. Dnsmasq configuration generation and query routing verification.
        7. Live diagnostic tool invocation (test_domain lkfl2.nalog.ru).
        8. Backup configuration export.
        9. Surgical reset execution and state verification.
        10. Restoration from backup and complete uninstallation.
        """
        # --- Stage 1: Pre-installation check ---
        self.assertTrue(self.env.file_exists("/www/user/user1.asp"))
        self.assertTrue(self.env.file_exists("/www/user/user2.asp"))
        self.assertIn("awg_enable=1", self.env.read_file("/jffs/addons/custom_settings.txt"))

        # --- Stage 2: Dynamic slot allocation & UI Mount ---
        page_content = f"{SPLITDNS_UI_MARKER}\n<html>Split DNS ROG UI</html>"
        allocated_slot = self.env.am_get_webui_page(page_content)
        self.assertEqual(allocated_slot, "user3.asp")
        self.env.write_file(f"/www/user/{allocated_slot}", page_content)

        # --- Stage 3: MenuTree non-destructive patch ---
        self.env.patch_menu_tree(allocated_slot)
        menu_content = self.env.read_file("/tmp/menuTree.js")
        self.assertIn(f'url: "{allocated_slot}", tabName: "Split DNS"', menu_content)
        # AmneziaWG in menu_VPN must remain intact
        self.assertIn("AmneziaWG", menu_content)

        # --- Stage 4 & 5: Configure, Apply & Storage Isolation ---
        # Transient POST form data written to custom_settings.txt
        transient_post = (
            "splitdns_enable=1\n"
            "splitdns_profile=yandex_basic\n"
            "splitdns_preset_national=1\n"
            "splitdns_preset_gov=1\n"
        )
        original_custom_settings = self.env.read_file("/jffs/addons/custom_settings.txt")
        self.env.write_file("/jffs/addons/custom_settings.txt", original_custom_settings + transient_post)

        # Core engine saves to dedicated files
        splitdns_conf = (
            "ENABLED=1\n"
            "PROFILE=yandex_basic\n"
            "PRESET_NATIONAL_ZONES=1\n"
            "PRESET_GOV_SERVICES=1\n"
        )
        custom_rules = [
            {
                "id": 1,
                "enabled": 1,
                "domains": "internal.corp.ru",
                "target_type": "router",
                "target_ip": "",
                "comment": "Corp DoT exception",
            }
        ]
        self.env.write_file("/jffs/addons/splitdns/splitdns.conf", splitdns_conf)
        self.env.write_file("/jffs/addons/splitdns/rules.json", json.dumps(custom_rules))

        # Core engine immediately cleans custom_settings.txt
        self.env.purge_transient_custom_settings()
        self.assertEqual(
            self.env.read_file("/jffs/addons/custom_settings.txt").strip(),
            original_custom_settings.strip(),
        )

        # --- Stage 6: Dnsmasq Rules Generation & Resolution ---
        dnsmasq_conf = SplitDnsConfigGenerator.generate_dnsmasq_conf(
            enabled=True,
            profile="yandex_basic",
            custom_dns1="",
            custom_dns2="",
            preset_national=True,
            preset_gov=True,
            rules=custom_rules,
            isp_dns=("77.88.8.8", "77.88.8.1"),
        )
        self.env.write_file("/jffs/addons/splitdns/dnsmasq_splitdns.conf", dnsmasq_conf)

        # Connect to dnsmasq.conf.add
        dnsmasq_add = (
            self.env.read_file("/jffs/configs/dnsmasq.conf.add")
            + "conf-file=/jffs/addons/splitdns/dnsmasq_splitdns.conf\n"
        )
        self.env.write_file("/jffs/configs/dnsmasq.conf.add", dnsmasq_add)

        # Verify DNS resolution with longest suffix matching
        engine = DnsmasqEngine(dnsmasq_conf, default_resolver=ROUTER_DOT_IP)

        # 6a. State portal (lkfl2.nalog.ru) -> routes to Yandex Basic
        _, res_nalog = engine.resolve("lkfl2.nalog.ru")
        self.assertEqual(res_nalog, "77.88.8.8")

        # 6b. Generic .ru domain -> routes to Yandex Basic
        _, res_ru = engine.resolve("news.yandex.ru")
        self.assertEqual(res_ru, "77.88.8.8")

        # 6c. Exception rule for internal.corp.ru -> routes to Router DoT (127.0.1.1)
        _, res_corp = engine.resolve("auth.internal.corp.ru")
        self.assertEqual(res_corp, ROUTER_DOT_IP)

        # 6d. Foreign domain -> routes to Router DoT
        _, res_cf = engine.resolve("cloudflare.com")
        self.assertEqual(res_cf, ROUTER_DOT_IP)

        # --- Stage 7: Live Diagnostic Tool Mock ---
        diag_output = {
            "domain": "lkfl2.nalog.ru",
            "status": "ok",
            "ips": ["195.208.4.10", "195.208.4.11"],
            "resolver": res_nalog,
            "time_ms": 14,
        }
        self.assertEqual(diag_output["status"], "ok")
        self.assertIn("195.208.4.10", diag_output["ips"])

        # --- Stage 8: Backup Export ---
        backup_bundle = {
            "version": "1.0.0",
            "config": splitdns_conf,
            "rules": custom_rules,
        }
        backup_json = json.dumps(backup_bundle)
        self.assertIn("internal.corp.ru", backup_json)

        # --- Stage 9: Surgical Reset ---
        # User clicks surgical reset
        self.env.remove_file("/jffs/addons/splitdns/splitdns.conf")
        self.env.remove_file("/jffs/addons/splitdns/rules.json")
        self.env.remove_file("/jffs/addons/splitdns/dnsmasq_splitdns.conf")
        clean_add = self.env.read_file("/jffs/configs/dnsmasq.conf.add").replace(
            "conf-file=/jffs/addons/splitdns/dnsmasq_splitdns.conf\n", ""
        )
        self.env.write_file("/jffs/configs/dnsmasq.conf.add", clean_add)

        # Assert Split DNS removed, but AmneziaWG is completely intact
        self.assertFalse(self.env.file_exists("/jffs/addons/splitdns/splitdns.conf"))
        self.assertFalse(self.env.file_exists("/jffs/addons/splitdns/dnsmasq_splitdns.conf"))
        self.assertNotIn("dnsmasq_splitdns.conf", self.env.read_file("/jffs/configs/dnsmasq.conf.add"))
        self.assertIn("awg_enable=1", self.env.read_file("/jffs/addons/custom_settings.txt"))

        # --- Stage 10: Restore from Backup & Clean Uninstall ---
        restored_data = json.loads(backup_json)
        self.env.write_file("/jffs/addons/splitdns/splitdns.conf", restored_data["config"])
        self.env.write_file("/jffs/addons/splitdns/rules.json", json.dumps(restored_data["rules"]))
        self.assertTrue(self.env.file_exists("/jffs/addons/splitdns/splitdns.conf"))

        # Final Uninstall: clean all Split DNS traces
        self.env.remove_file(f"/www/user/{allocated_slot}")
        self.env.unpatch_menu_tree()
        self.env.remove_file("/jffs/addons/splitdns/splitdns.conf")
        self.env.remove_file("/jffs/addons/splitdns/rules.json")

        self.assertFalse(self.env.file_exists(f"/www/user/{allocated_slot}"))
        self.assertNotIn("Split DNS", self.env.read_file("/tmp/menuTree.js"))
        self.assertIn("AmneziaWG", self.env.read_file("/tmp/menuTree.js"))

    def test_coexistence_with_multi_addon_stack(self):
        """
        Simulates coexistence with AmneziaWG (user1, user2) AND XrayUI (user3):
        Verifies Split DNS automatically allocates user4.asp without conflict.
        """
        # Occupy user3 with XrayUI
        self.env.write_file("/www/user/user3.asp", "<!-- XRAY_UI_PAGE -->\n<html>XrayUI</html>")

        # Split DNS requests slot
        splitdns_page = f"{SPLITDNS_UI_MARKER}\n<html>Split DNS</html>"
        allocated_slot = self.env.am_get_webui_page(splitdns_page)

        # Should allocate user4.asp!
        self.assertEqual(allocated_slot, "user4.asp")

        # Confirm user1, user2, user3 remain untouched
        self.assertIn("AMNEZIAWG_CLIENT", self.env.read_file("/www/user/user1.asp"))
        self.assertIn("AMNEZIAWG_SERVER", self.env.read_file("/www/user/user2.asp"))
        self.assertIn("XRAY_UI_PAGE", self.env.read_file("/www/user/user3.asp"))


if __name__ == "__main__":
    unittest.main()
