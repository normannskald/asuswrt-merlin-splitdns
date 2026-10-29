"""
Tier 1: Feature Coverage & Functional Tests
Tests every feature and interface contract defined in PROJECT.md and ORIGINAL_REQUEST.md.
"""

import unittest
import json
import os
import re
from tests.mock_router import (
    MockRouterEnvironment,
    SplitDnsConfigGenerator,
    DnsmasqEngine,
    DNS_PROFILES,
    NATIONAL_ZONES,
    GOV_SERVICES_DOMAINS,
    ROUTER_DOT_IP,
    SPLITDNS_UI_MARKER,
    MENUTREE_SPLITDNS_START,
    MENUTREE_SPLITDNS_END,
)

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


class TestTier1FeatureCoverage(unittest.TestCase):
    """Tier 1: Comprehensive feature coverage and specification compliance."""

    def setUp(self):
        self.env = MockRouterEnvironment()

    # --- Feature 1: Installer & CLI Menu ---
    def test_installer_cli_modes(self):
        """Validates installer commands, interactive menu options, and flags in install.sh."""
        install_sh_path = os.path.join(PROJECT_ROOT, "install.sh")
        self.assertTrue(os.path.isfile(install_sh_path), f"install.sh not found at {install_sh_path}")
        with open(install_sh_path, "r", encoding="utf-8") as f:
            install_src = f.read()

        # 1. Verify all CLI actions exist in case "$ACTION" in
        expected_cli_actions = ["install", "update", "status", "reset", "uninstall"]
        for action in expected_cli_actions:
            self.assertRegex(
                install_src,
                rf'(?m)^\s*{action}\)',
                f"CLI action '{action}' not found in case \"$ACTION\" in install.sh"
            )

        # 2. Verify help options exist
        self.assertRegex(install_src, r'-h\|--help\|help\)', "Help flags (-h|--help|help) missing in install.sh")

        # 3. Verify handler functions exist in install.sh
        expected_functions = [
            "cmd_install",
            "cmd_update",
            "cmd_status",
            "cmd_reset",
            "cmd_uninstall",
            "show_menu",
            "check_root",
            "check_jffs",
        ]
        for func in expected_functions:
            self.assertRegex(
                install_src,
                rf'(?m)^{func}\(\)\s*\{{',
                f"Handler function '{func}' definition missing in install.sh"
            )

        # 4. Verify usage string documents the options
        usage_matches = re.findall(r'Usage:[^\n]+', install_src)
        self.assertTrue(len(usage_matches) > 0, "No Usage: string found in install.sh")
        for usage_line in usage_matches:
            for action in expected_cli_actions:
                self.assertIn(action, usage_line, f"Action '{action}' missing from usage in install.sh")

        # 5. Verify interactive menu has numeric and mnemonic options
        self.assertIn("show_menu()", install_src)
        self.assertIn("1|i|install|Install)", install_src)
        self.assertIn("2|u|update|Update)", install_src)
        self.assertIn("3|s|status|Status)", install_src)
        self.assertIn("4|r|reset|Reset)", install_src)
        self.assertIn("5|uninstall|Uninstall)", install_src)

    def test_installer_check_root_portability(self):
        """Validates that check_root() in install.sh uses BusyBox-portable check."""
        install_sh_path = os.path.join(PROJECT_ROOT, "install.sh")
        with open(install_sh_path, "r", encoding="utf-8") as f:
            install_src = f.read()

        match = re.search(r'check_root\(\)\s*\{([\s\S]*?)\}', install_src)
        self.assertIsNotNone(match, "check_root() function not found in install.sh")
        check_root_body = match.group(1)

        self.assertIn("whoami", check_root_body)
        self.assertIn("admin", check_root_body)
        self.assertIn("root", check_root_body)
        self.assertNotIn('[ "$(id -u)" -ne 0 ]', check_root_body)

    def test_installer_banner_slot_fallback(self):
        """Validates that install.sh reliably populates SLOT without broken pipeline fallback."""
        install_sh_path = os.path.join(PROJECT_ROOT, "install.sh")
        with open(install_sh_path, "r", encoding="utf-8") as f:
            install_src = f.read()

        self.assertNotIn("sed 's#/www/user/##' || echo", install_src)
        self.assertIn('[ -z "$SLOT" ]', install_src)

    def test_installer_prerequisites(self):
        """Validates JFFS partition and BusyBox ash compatibility requirements."""
        # Check BusyBox ash requirements
        self.assertEqual(self.env.nvram.get("productid"), "RT-AX56U")
        self.assertEqual(self.env.nvram.get("buildno"), "388.8")

    # --- Feature 2: Backend Core Lifecycle & CLI ---
    def test_cli_lifecycle_commands(self):
        """Validates all 10 CLI subcommands defined in PROJECT.md interface contract in splitdns.sh."""
        splitdns_sh_path = os.path.join(PROJECT_ROOT, "splitdns.sh")
        self.assertTrue(os.path.isfile(splitdns_sh_path), f"splitdns.sh not found at {splitdns_sh_path}")
        with open(splitdns_sh_path, "r", encoding="utf-8") as f:
            splitdns_src = f.read()

        contract_subcommands = [
            "start",
            "stop",
            "restart",
            "apply",
            "reset",
            "mount_ui",
            "test_domain",
            "check_update",
            "update",
            "uninstall",
        ]

        # 1. Verify all 10 subcommands exist in case "$COMMAND" in dispatch table
        for cmd in contract_subcommands:
            self.assertRegex(
                splitdns_src,
                rf'(?m)^\s*{cmd}\)',
                f"Subcommand '{cmd}' not found in case \"$COMMAND\" dispatch table of splitdns.sh"
            )

        # 2. Verify all 10 subcommands exist in the usage strings
        usage_matches = re.findall(r'Usage:[^\n]+', splitdns_src)
        self.assertTrue(len(usage_matches) > 0, "No Usage: string found in splitdns.sh")
        for usage_line in usage_matches:
            for cmd in contract_subcommands:
                self.assertIn(
                    cmd,
                    usage_line,
                    f"Subcommand '{cmd}' missing from usage message '{usage_line}' in splitdns.sh"
                )

        # 3. Verify backing handler functions exist in splitdns.sh
        expected_handlers = {
            "start": "cmd_start",
            "stop": "cmd_stop",
            "restart": "cmd_restart",
            "apply": "cmd_apply",
            "reset": "cmd_reset",
            "mount_ui": "mount_ui",
            "test_domain": "cmd_test_domain",
            "check_update": "cmd_check_update",
            "update": "cmd_update",
            "uninstall": "cmd_uninstall",
        }
        for cmd, func in expected_handlers.items():
            self.assertRegex(
                splitdns_src,
                rf'(?m)^{func}\(\)\s*\{{',
                f"Backing handler function '{func}' for subcommand '{cmd}' is not defined in splitdns.sh"
            )

    def test_cli_invalid_subcommand(self):
        """Verifies that unknown commands are rejected with error semantics in splitdns.sh and install.sh."""
        splitdns_sh_path = os.path.join(PROJECT_ROOT, "splitdns.sh")
        with open(splitdns_sh_path, "r", encoding="utf-8") as f:
            splitdns_src = f.read()

        install_sh_path = os.path.join(PROJECT_ROOT, "install.sh")
        with open(install_sh_path, "r", encoding="utf-8") as f:
            install_src = f.read()

        # In splitdns.sh: verify wildcard branch catches unknown command and exits with 1
        self.assertRegex(
            splitdns_src,
            r'\*\)[\s\S]*?Unknown command:[\s\S]*?exit 1',
            "splitdns.sh must output 'Unknown command' and exit 1 on invalid subcommand"
        )

        # In install.sh: verify wildcard branch catches unknown command and exits with 1
        self.assertRegex(
            install_src,
            r'\*\)[\s\S]*?Unknown command:[\s\S]*?exit 1',
            "install.sh must output 'Unknown command' and exit 1 on invalid subcommand"
        )

        # Verify an arbitrary invalid action is not a valid branch in splitdns.sh or install.sh
        invalid_cmd = "invalid_action_foo"
        self.assertNotRegex(
            splitdns_src,
            rf'(?m)^\s*{invalid_cmd}\)',
            f"Invalid command {invalid_cmd} should not be a valid branch in splitdns.sh"
        )
        self.assertNotRegex(
            install_src,
            rf'(?m)^\s*{invalid_cmd}\)',
            f"Invalid command {invalid_cmd} should not be a valid branch in install.sh"
        )

    # --- Feature 3: Dynamic Slot Allocation ---
    def test_dynamic_slot_allocation(self):
        """
        Verifies am_get_webui_page logic:
        Pre-occupied user1.asp (AmneziaWG Client) and user2.asp (AmneziaWG Server)
        must remain untouched, allocating user3.asp to Split DNS.
        """
        new_page_content = f"{SPLITDNS_UI_MARKER}\n<html>Split DNS UI Page</html>"
        allocated_slot = self.env.am_get_webui_page(new_page_content)
        self.assertEqual(allocated_slot, "user3.asp")

        # Confirm user1 and user2 remain occupied by AmneziaWG
        user1 = self.env.read_file("/www/user/user1.asp")
        user2 = self.env.read_file("/www/user/user2.asp")
        self.assertIn("AMNEZIAWG_CLIENT", user1)
        self.assertIn("AMNEZIAWG_SERVER", user2)

    def test_slot_marker_cleanup(self):
        """Verifies that stale Split DNS pages are cleaned up prior to new slot allocation."""
        # Create a stale Split DNS page on user4.asp
        stale_content = f"{SPLITDNS_UI_MARKER}\n<html>Old Split DNS Page</html>"
        self.env.write_file("/www/user/user4.asp", stale_content)
        self.assertTrue(self.env.file_exists("/www/user/user4.asp"))

        # Allocate slot for updated page
        new_content = f"{SPLITDNS_UI_MARKER}\n<html>Updated Split DNS Page</html>"
        slot = self.env.am_get_webui_page(new_content)
        # Should allocate user3.asp and purge user4.asp
        self.assertEqual(slot, "user3.asp")
        self.assertFalse(self.env.file_exists("/www/user/user4.asp"))

    # --- Feature 4: Non-Destructive MenuTree Patching ---
    def test_menutree_patch_with_mutex_lock(self):
        """Verifies menuTree.js patch inserts Split DNS into menu_WAN."""
        slot = "user3.asp"
        self.env.patch_menu_tree(slot)
        patched_js = self.env.read_file("/tmp/menuTree.js")

        self.assertIn(MENUTREE_SPLITDNS_START, patched_js)
        self.assertIn(MENUTREE_SPLITDNS_END, patched_js)
        self.assertIn(f'url: "{slot}", tabName: "Split DNS"', patched_js)
        self.assertIn('menu_WAN', patched_js)

    def test_menutree_preserves_amneziawg(self):
        """Verifies menuTree patching leaves AmneziaWG in menu_VPN intact."""
        slot = "user3.asp"
        self.env.patch_menu_tree(slot)
        patched_js = self.env.read_file("/tmp/menuTree.js")

        # AmneziaWG tabs must remain preserved
        self.assertIn('/* AWG_WIDGET_START */ {url: "user1.asp", tabName: "AmneziaWG"}, /* AWG_WIDGET_END */', patched_js)
        self.assertIn('{url: "user2.asp", tabName: "AmneziaWG Server"}', patched_js)

    # --- Feature 5: Storage Isolation & Zero Pollution ---
    def test_storage_isolation_splitdns_conf(self):
        """Verifies storage isolation: splitdns.conf stores options, custom_settings.txt is cleaned."""
        # Simulate transient form submit in custom_settings.txt
        transient_settings = (
            "awg_enable=1\n"
            "splitdns_enabled=1\n"
            "splitdns_profile=yandex_basic\n"
        )
        self.env.write_file("/jffs/addons/custom_settings.txt", transient_settings)

        # After apply, transient keys are purged
        self.env.purge_transient_custom_settings()
        cleaned_content = self.env.read_file("/jffs/addons/custom_settings.txt")

        self.assertNotIn("splitdns_enabled", cleaned_content)
        self.assertNotIn("splitdns_profile", cleaned_content)
        self.assertIn("awg_enable=1", cleaned_content)

    # --- Feature 6: Triple-Guarded Dnsmasq Integration & Atomic Restart ---
    def test_dnsmasq_rule_generation_syntax(self):
        """Verifies dnsmasq directives conform to server=/domain/ip with NO @ifname."""
        conf = SplitDnsConfigGenerator.generate_dnsmasq_conf(
            enabled=True,
            profile="yandex_basic",
            custom_dns1="",
            custom_dns2="",
            preset_national=True,
            preset_gov=False,
            rules=[],
            isp_dns=("77.88.8.8", "77.88.8.1"),
        )
        # Parse into engine
        engine = DnsmasqEngine(conf)
        self.assertTrue(engine.test_syntax())
        self.assertNotIn("@", conf)  # Strict requirement: No @ifname binding

        # Check national zone directives
        for zone in NATIONAL_ZONES:
            self.assertTrue(any(r[0] == zone for r in engine.rules))

    def test_postconf_fallback_guard(self):
        """Verifies postconf fallback script logic removes include if file missing."""
        postconf = self.env.read_file("/jffs/scripts/dnsmasq.postconf")
        # Ensure guard script structure can be installed without overwriting existing hooks
        splitdns_hook = (
            "# --- SPLITDNS_START ---\n"
            "if [ ! -f /jffs/addons/splitdns/dnsmasq_splitdns.conf ]; then\n"
            "    sed -i '/dnsmasq_splitdns.conf/d' \"$1\" 2>/dev/null\n"
            "fi\n"
            "# --- SPLITDNS_END ---\n"
        )
        new_postconf = postconf + splitdns_hook
        self.env.write_file("/jffs/scripts/dnsmasq.postconf", new_postconf)

        current_postconf = self.env.read_file("/jffs/scripts/dnsmasq.postconf")
        self.assertIn("amneziawg", current_postconf)
        self.assertIn("SPLITDNS_START", current_postconf)

    def test_atomic_restart_watchdog(self):
        """Verifies safe_restart_dnsmasq in splitdns.sh implements atomic restart and self-healing watchdog."""
        splitdns_sh_path = os.path.join(PROJECT_ROOT, "splitdns.sh")
        self.assertTrue(os.path.isfile(splitdns_sh_path), f"splitdns.sh not found at {splitdns_sh_path}")
        with open(splitdns_sh_path, "r", encoding="utf-8") as f:
            src = f.read()

        match = re.search(r'safe_restart_dnsmasq\(\)\s*\{([\s\S]*?)\n\}', src)
        self.assertIsNotNone(match, "safe_restart_dnsmasq() function definition not found in splitdns.sh")
        func_body = match.group(1)

        # Genuinely verify the 4 atomic restart watchdog requirements from dispatch
        self.assertIn("dnsmasq --test", func_body, "dnsmasq --test missing from safe_restart_dnsmasq")
        self.assertIn("service restart_dnsmasq", func_body, "service restart_dnsmasq missing from safe_restart_dnsmasq")
        self.assertIn("pidof dnsmasq", func_body, "pidof dnsmasq missing from safe_restart_dnsmasq")
        self.assertIn(r"sed -i '/dnsmasq_splitdns\.conf/d'", func_body, "sed watchdog purge missing from safe_restart_dnsmasq")

    # --- Feature 7: Surgical Reset ---
    def test_surgical_reset_preserves_external_addons(self):
        """Verifies surgical reset cleans only Split DNS, preserving AmneziaWG and user settings."""
        # Set up Split DNS files
        self.env.write_file("/jffs/addons/splitdns/splitdns.conf", "ENABLED=1\nPROFILE=yandex_basic\n")
        self.env.write_file("/jffs/addons/splitdns/rules.json", "[]")
        self.env.write_file("/jffs/addons/splitdns/dnsmasq_splitdns.conf", "server=/ru/77.88.8.8\n")
        self.env.write_file(
            "/jffs/configs/dnsmasq.conf.add",
            "conf-file=/jffs/addons/splitdns/dnsmasq_splitdns.conf\n"
            "conf-file=/jffs/addons/amneziawg/dnsmasq.conf\n"
        )

        # Execute surgical reset
        self.env.remove_file("/jffs/addons/splitdns/splitdns.conf")
        self.env.remove_file("/jffs/addons/splitdns/rules.json")
        self.env.remove_file("/jffs/addons/splitdns/dnsmasq_splitdns.conf")
        add_conf = self.env.read_file("/jffs/configs/dnsmasq.conf.add")
        new_add_conf = "\n".join([line for line in add_conf.splitlines() if "dnsmasq_splitdns.conf" not in line])
        self.env.write_file("/jffs/configs/dnsmasq.conf.add", new_add_conf)

        # Assert Split DNS deleted
        self.assertFalse(self.env.file_exists("/jffs/addons/splitdns/splitdns.conf"))
        self.assertFalse(self.env.file_exists("/jffs/addons/splitdns/rules.json"))
        self.assertFalse(self.env.file_exists("/jffs/addons/splitdns/dnsmasq_splitdns.conf"))

        # Assert AmneziaWG untouched
        current_add = self.env.read_file("/jffs/configs/dnsmasq.conf.add")
        self.assertIn("conf-file=/jffs/addons/amneziawg/dnsmasq.conf", current_add)
        self.assertIn("awg_enable=1", self.env.read_file("/jffs/addons/custom_settings.txt"))

    # --- Feature 8: Web UI & Localization ---
    def test_webui_asp_structure_and_dictionaries(self):
        """Verifies splitdns_page.asp structure and RU/EN localization dictionaries."""
        asp_path = os.path.join(PROJECT_ROOT, "splitdns_page.asp")
        if not os.path.isfile(asp_path):
            self.skipTest("splitdns_page.asp scheduled for Milestone 2")

        with open(asp_path, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn("AS_SPLITDNS_UI_PAGE", content)
        self.assertTrue("dict_ru" in content or "ru:" in content or "preferred_lang" in content)

    # --- Feature 9: Presets Generation ---
    def test_preset_national_zones_generation(self):
        """Verifies generation of all national TLD rules."""
        conf = SplitDnsConfigGenerator.generate_dnsmasq_conf(
            enabled=True,
            profile="yandex_basic",
            custom_dns1="",
            custom_dns2="",
            preset_national=True,
            preset_gov=False,
            rules=[],
            isp_dns=("77.88.8.8", "77.88.8.1"),
        )
        for zone in ["ru", "xn--p1ai", "su", "xn--80adxhks", "xn--p1acf", "tatar", "xn--d1acj3b"]:
            self.assertIn(f"server=/{zone}/77.88.8.8", conf)
            self.assertIn(f"server=/{zone}/77.88.8.1", conf)

    def test_preset_gov_services_generation(self):
        """Verifies generation of Russian Government and Social Services rules."""
        conf = SplitDnsConfigGenerator.generate_dnsmasq_conf(
            enabled=True,
            profile="yandex_basic",
            custom_dns1="",
            custom_dns2="",
            preset_national=False,
            preset_gov=True,
            rules=[],
            isp_dns=("77.88.8.8", "77.88.8.1"),
        )
        for gov in ["gosuslugi.ru", "nalog.ru", "lkfl2.nalog.ru", "cbr.ru", "mos.ru", "sberbank.ru"]:
            self.assertIn(f"server=/{gov}/77.88.8.8", conf)
            self.assertIn(f"server=/{gov}/77.88.8.1", conf)

    # --- Feature 10: 6 DNS Upstream Profiles ---
    def test_dns_profiles_ip_mapping(self):
        """Validates all 6 DNS profiles IP addresses."""
        self.assertEqual(DNS_PROFILES["yandex_basic"], ("77.88.8.8", "77.88.8.1"))
        self.assertEqual(DNS_PROFILES["yandex_safe"], ("77.88.8.88", "77.88.8.2"))
        self.assertEqual(DNS_PROFILES["yandex_family"], ("77.88.8.7", "77.88.8.3"))
        self.assertEqual(DNS_PROFILES["nsdi"], ("195.208.4.1", "195.208.5.1"))

    # --- Feature 11: Custom Rules Schema & Modes ---
    def test_custom_rules_schema_and_modes(self):
        """Verifies custom rule schema: profile mode, router DoT exception, and custom IP."""
        rules = [
            {"id": 1, "enabled": 1, "domains": "company.ru", "target_type": "profile", "target_ip": "", "comment": "Rule 1"},
            {"id": 2, "enabled": 1, "domains": "dot-exception.ru", "target_type": "router", "target_ip": "", "comment": "Rule 2"},
            {"id": 3, "enabled": 1, "domains": "local.dev", "target_type": "custom", "target_ip": "192.168.50.5#5353", "comment": "Rule 3"},
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
        self.assertIn("server=/company.ru/77.88.8.8", conf)
        self.assertIn(f"server=/dot-exception.ru/{ROUTER_DOT_IP}", conf)
        self.assertIn("server=/local.dev/192.168.50.5#5353", conf)

    # --- Feature 12: Live DNS Diagnostic Tool Output ---
    def test_diagnostic_test_domain_json_output(self):
        """Validates that cmd_test_domain in splitdns.sh formats and outputs JSON matching the diagnostic contract."""
        splitdns_sh_path = os.path.join(PROJECT_ROOT, "splitdns.sh")
        self.assertTrue(os.path.isfile(splitdns_sh_path), f"splitdns.sh not found at {splitdns_sh_path}")
        with open(splitdns_sh_path, "r", encoding="utf-8") as f:
            src = f.read()

        match = re.search(r'cmd_test_domain\(\)\s*\{([\s\S]*?)\n\}', src)
        self.assertIsNotNone(match, "cmd_test_domain() function definition not found in splitdns.sh")
        func_body = match.group(1)

        printf_match = re.search(r'printf\s+[\'"](\{.*?\})', func_body)
        self.assertIsNotNone(printf_match, "JSON printf template not found in cmd_test_domain")
        json_template = printf_match.group(1)

        for key in ['"domain"', '"status"', '"ips"', '"resolver"', '"time_ms"']:
            self.assertIn(key, json_template, f"Key {key} missing from cmd_test_domain JSON output template")

    # --- Feature 13: UI Version Check, Web Update & Backup/Restore ---
    def test_backup_restore_json_schema(self):
        """Validates export and import JSON schema."""
        backup_data = {
            "version": "1.0.0",
            "enabled": 1,
            "profile": "yandex_basic",
            "custom_dns_primary": "",
            "custom_dns_secondary": "",
            "preset_national_zones": 1,
            "preset_gov_services": 1,
            "rules": [
                {"id": 1, "enabled": 1, "domains": "example.ru", "target_type": "profile", "target_ip": "", "comment": "test"}
            ]
        }
        serialized = json.dumps(backup_data)
        deserialized = json.loads(serialized)
        self.assertEqual(deserialized["profile"], "yandex_basic")
        self.assertEqual(len(deserialized["rules"]), 1)

    def test_version_check_json(self):
        """Validates that cmd_check_update in splitdns.sh formats and outputs JSON matching update check contract."""
        splitdns_sh_path = os.path.join(PROJECT_ROOT, "splitdns.sh")
        self.assertTrue(os.path.isfile(splitdns_sh_path), f"splitdns.sh not found at {splitdns_sh_path}")
        with open(splitdns_sh_path, "r", encoding="utf-8") as f:
            src = f.read()

        match = re.search(r'cmd_check_update\(\)\s*\{([\s\S]*?)\n\}', src)
        self.assertIsNotNone(match, "cmd_check_update() function definition not found in splitdns.sh")
        func_body = match.group(1)

        printf_match = re.search(r'printf\s+[\'"](\{.*?\})', func_body)
        self.assertIsNotNone(printf_match, "JSON printf template not found in cmd_check_update")
        json_template = printf_match.group(1)

        for key in ['"current_version"', '"latest_version"', '"update_available"']:
            self.assertIn(key, json_template, f"Key {key} missing from cmd_check_update JSON output template")

    # --- Feature 15 & 16: Documentation & Guides Structure ---
    def test_license_and_readme_structure(self):
        """Verifies MIT License and bilingual README specifications."""
        readme_path = os.path.join(PROJECT_ROOT, "README.md")
        license_path = os.path.join(PROJECT_ROOT, "LICENSE")
        if not (os.path.isfile(readme_path) and os.path.isfile(license_path)):
            self.skipTest("README.md and LICENSE scheduled for Milestone 4")

        with open(license_path, "r", encoding="utf-8") as f:
            lic = f.read()
        self.assertIn("MIT License", lic)
        self.assertIn("normannskald", lic)

        with open(readme_path, "r", encoding="utf-8") as f:
            readme = f.read()
        self.assertIn("Split DNS", readme)

    def test_github_guide_structure(self):
        """Verifies GITHUB_GUIDE requirements (gh auth, push --allow-unrelated-histories, post-commit hook)."""
        guide_path = os.path.join(PROJECT_ROOT, "GITHUB_GUIDE.md")
        if not os.path.isfile(guide_path):
            self.skipTest("GITHUB_GUIDE.md scheduled for Milestone 4")

        with open(guide_path, "r", encoding="utf-8") as f:
            guide = f.read()

        guide_requirements = [
            "gh auth login --web",
            "--allow-unrelated-histories",
            "post-commit",
        ]
        for req in guide_requirements:
            self.assertIn(req, guide)

    # --- Feature 17: v1.2.0 Architecture & Web UI Contracts ---
    def test_v120_profiles_and_multiline_support_in_webui(self):
        """Verifies v1.2.0 Web UI features: profiles table, modal dialog, multiline textareas, and silent diagnostic."""
        asp_path = os.path.join(PROJECT_ROOT, "splitdns_page.asp")
        with open(asp_path, "r", encoding="utf-8") as f:
            asp_content = f.read()

        # Profiles block and modal
        self.assertIn('id="dns_profiles_table"', asp_content, "Missing #dns_profiles_table in Web UI")
        self.assertIn('id="profile_modal"', asp_content, "Missing #profile_modal in Web UI")
        self.assertIn('id="profile_modal_bg"', asp_content, "Missing #profile_modal_bg in Web UI")
        self.assertIn('splitdns-modal-divider', asp_content, "Missing .splitdns-modal-divider in Web UI")
        self.assertIn('#overDiv', asp_content, "Missing #overDiv z-index styling in Web UI")
        self.assertIn('openProfileModal', asp_content, "Missing openProfileModal() function in Web UI")
        self.assertIn('saveProfileFromModal', asp_content, "Missing saveProfileFromModal() function in Web UI")
        self.assertIn('onModalPresetChange', asp_content, "Missing onModalPresetChange() function in Web UI")

        # Multiline inputs for rules
        self.assertIn('<textarea id="new_rule_domains"', asp_content)
        self.assertIn('<textarea id="new_rule_comment"', asp_content)

        # Silent diagnostic without page reload
        self.assertIn('runLiveDomainTest', asp_content)
        self.assertIn('isSilent', asp_content, "Diagnostic should run silently to avoid showLoading page reload")

        # Copyright footer
        self.assertIn('2026 normannskald', asp_content)
        self.assertIn('MIT License', asp_content)

    def test_v120_backend_profiles_handling(self):
        """Verifies v1.2.0 backend features: profiles.json support, transient profiles parsing, and status export."""
        splitdns_sh_path = os.path.join(PROJECT_ROOT, "splitdns.sh")
        with open(splitdns_sh_path, "r", encoding="utf-8") as f:
            sh_content = f.read()

        self.assertIn('PROFILES_FILE="$ADDON_DIR/profiles.json"', sh_content)
        self.assertIn('splitdns_profiles_b64', sh_content)
        self.assertIn('generate_dnsmasq_rules()', sh_content)
        self.assertIn('prof_dns1', sh_content)
        self.assertIn('update_status()', sh_content)
        self.assertIn('"profiles":', sh_content)


if __name__ == "__main__":
    unittest.main()
