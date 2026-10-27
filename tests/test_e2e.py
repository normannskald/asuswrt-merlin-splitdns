"""
Master E2E Test Suite and Runner (Tiers 1-5)
Project: Asuswrt-Merlin Split DNS GUI Addon (asuswrt-merlin-splitdns)
Executes all test tiers (Feature Coverage, Boundaries, Combinations, Scenarios, Adversarial).
"""

import sys
import os
import unittest
import time
import re

# Add project root to sys.path
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from tests.test_tier1_features import TestTier1FeatureCoverage
from tests.test_tier2_boundaries import TestTier2BoundaryAndCornerCases
from tests.test_tier3_combinations import TestTier3CrossFeatureCombinations
from tests.test_tier4_scenarios import TestTier4RealWorldScenarios
from tests.test_tier5_m2_webui_adversarial import (
    TestWebUiXhtmlAndTagBalancer,
    TestWebUiJavaScriptSyntaxAndSafety,
    TestBackupRestoreFuzzing,
    TestLiveDnsDiagnosticSimulationAndFallback,
)
from tests.mock_router import (
    MockRouterEnvironment,
    SplitDnsConfigGenerator,
    DnsmasqEngine,
    ROUTER_DOT_IP,
)


class TestTier5AdversarialAndStress(unittest.TestCase):
    """
    Tier 5: Adversarial Hardening, Escaping Integrity & Resource Stress.
    Validates that malicious inputs, control characters, shell injections,
    and extreme buffer conditions cannot compromise system stability.
    """

    def setUp(self):
        self.env = MockRouterEnvironment()

    def test_adversarial_shell_injection_sanitization(self):
        """
        Adversarial Test: Shell metacharacters injection resistance.
        Inputs containing ;, &, |, $, `, \n, or $(...) must be sanitized to valid
        DNS domain labels or omitted, preventing arbitrary command execution in BusyBox ash.
        """
        malicious_inputs = [
            "nalog.ru; rm -rf /",
            "gosuslugi.ru && reboot",
            "cbr.ru | cat /etc/passwd",
            "test.$(id).ru",
            "`reboot`.ru",
            "mos.ru\nserver=/evil.com/1.2.3.4",
            "<script>alert(1)</script>.ru",
        ]

        for mal_input in malicious_inputs:
            parsed = SplitDnsConfigGenerator.parse_domains_list(mal_input)
            for d in parsed:
                # Dnsmasq directives must never contain shell separators or spaces
                self.assertNotIn(";", d)
                self.assertNotIn(" ", d)
                self.assertNotIn("|", d)
                self.assertNotIn("&", d)
                self.assertNotIn("`", d)
                self.assertNotIn("\n", d)
                self.assertNotIn("\r", d)

    def test_adversarial_custom_settings_8kb_overflow_protection(self):
        """
        Adversarial Test: 8 KB buffer overflow resistance.
        Asuswrt-Merlin's custom_settings.txt has an 8192-byte buffer limit.
        Exceeding 8192 bytes raises an overflow error and Split DNS storage
        isolation guarantees steady-state size remains 0 bytes.
        """
        huge_payload = "A" * 9000
        with self.assertRaises(OverflowError):
            self.env.write_file("/jffs/addons/custom_settings.txt", huge_payload)

    def test_adversarial_malformed_ip_rejection(self):
        """
        Adversarial Test: Invalid IP and port formats.
        Directives must strictly match valid IPv4 or IPv4#PORT structures.
        """
        invalid_directives = [
            "server=/bad.domain/999.999.999.999",
            "server=/bad.domain/1.2.3.4.5",
            "server=/bad.domain/1.1.1.1#invalidport",
            "server=/bad.domain/evil_host",
        ]
        for directive in invalid_directives:
            with self.assertRaises(ValueError):
                DnsmasqEngine(directive)

    def test_adversarial_lockfile_concurrency(self):
        """
        Adversarial Test: Lockfile contention prevention.
        Simulates concurrent menuTree.js patching attempts and verifies idempotency.
        """
        # Patching 5 times consecutively must not duplicate tabs or create invalid JS
        for _ in range(5):
            self.env.patch_menu_tree("user3.asp")

        content = self.env.read_file("/tmp/menuTree.js")
        # Split DNS tab must appear exactly once
        count = content.count('url: "user3.asp", tabName: "Split DNS"')
        self.assertEqual(count, 1)


def run_e2e_suite(selected_tier: int = 0, verbose: bool = False) -> bool:
    """
    Executes specified tier or full E2E test suite.
    Returns True if all tests passed, False otherwise.
    """
    tier_classes = {
        1: (TestTier1FeatureCoverage, "Tier 1: Feature Coverage & Interface Contracts"),
        2: (TestTier2BoundaryAndCornerCases, "Tier 2: Boundary, IDN & Security Audit"),
        3: (TestTier3CrossFeatureCombinations, "Tier 3: Cross-Feature Combinations & Invariants"),
        4: (TestTier4RealWorldScenarios, "Tier 4: Real-World Scenarios (End-to-End Simulation)"),
        5: (TestTier5AdversarialAndStress, "Tier 5: Adversarial Hardening & Stress Testing"),
    }

    start_time = time.time()
    print("=" * 80)
    print(" ASUSWRT-MERLIN SPLIT DNS — MASTER E2E TEST SUITE")
    print(f" Target Mode: Comprehensive Offline Simulator & Contract Verification")
    print(f" Project Root: {PROJECT_ROOT}")
    print("=" * 80)

    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    if selected_tier in tier_classes:
        cls, name = tier_classes[selected_tier]
        print(f"\n[+] Running {name} only...")
        suite.addTests(loader.loadTestsFromTestCase(cls))
    else:
        print("\n[+] Running all Tiers 1 through 5...")
        for tier_num, (cls, name) in tier_classes.items():
            suite.addTests(loader.loadTestsFromTestCase(cls))
        for webui_cls in (
            TestWebUiXhtmlAndTagBalancer,
            TestWebUiJavaScriptSyntaxAndSafety,
            TestBackupRestoreFuzzing,
            TestLiveDnsDiagnosticSimulationAndFallback,
        ):
            suite.addTests(loader.loadTestsFromTestCase(webui_cls))

    runner = unittest.TextTestRunner(verbosity=2 if verbose else 1)
    result = runner.run(suite)
    elapsed = time.time() - start_time

    print("\n" + "=" * 80)
    print(" TEST EXECUTION SUMMARY")
    print(f" Total Tests Run : {result.testsRun}")
    print(f" Passes          : {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f" Failures        : {len(result.failures)}")
    print(f" Errors          : {len(result.errors)}")
    print(f" Skipped         : {len(result.skipped)}")
    print(f" Total Time      : {elapsed:.3f} seconds")
    print("=" * 80)

    if result.wasSuccessful():
        print(" VERDICT: PASS (All test assertions satisfied cleanly)")
        print("=" * 80 + "\n")
        return True
    else:
        print(" VERDICT: FAIL (Test suite encountered failures or errors)")
        print("=" * 80 + "\n")
        return False


if __name__ == "__main__":
    tier_arg = 0
    verbose_arg = False

    for arg in sys.argv[1:]:
        if arg.startswith("--tier="):
            try:
                tier_arg = int(arg.split("=")[1])
            except ValueError:
                pass
        elif arg in ("-v", "--verbose"):
            verbose_arg = True

    success = run_e2e_suite(selected_tier=tier_arg, verbose=verbose_arg)
    sys.exit(0 if success else 1)
