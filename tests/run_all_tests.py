#!/usr/bin/env python3
"""
Master Test Suite Runner for Asuswrt-Merlin Split DNS GUI Addon.
Executes all test tiers (Tiers 1-5) using pure Python 3.

Usage:
    python tests/run_all_tests.py
    python tests/run_all_tests.py --tier=1
    python tests/run_all_tests.py --verbose
"""

import sys
import os
import argparse

# Add tests directory to sys.path
TESTS_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(TESTS_DIR, ".."))
if TESTS_DIR not in sys.path:
    sys.path.insert(0, TESTS_DIR)
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from test_e2e import run_e2e_suite


def main():
    parser = argparse.ArgumentParser(
        description="Master Test Runner for Asuswrt-Merlin Split DNS GUI Addon."
    )
    parser.add_argument(
        "--tier",
        type=int,
        choices=[0, 1, 2, 3, 4, 5],
        default=0,
        help="Optional test tier number to execute (1-5). Default is 0 (all tiers).",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Enables verbose per-test execution output.",
    )

    args = parser.parse_args()

    print("=" * 66)
    print(" Asuswrt-Merlin Split DNS — Automated Test Suite Runner (Python)")
    print(f" Python Executable : {sys.executable}")
    print(f" Python Version    : {sys.version.split()[0]}")
    print(f" Project Directory : {PROJECT_ROOT}")
    print("=" * 66)

    success = run_e2e_suite(selected_tier=args.tier, verbose=args.verbose)
    if success:
        print("\n[SUCCESS] All test suites completed successfully with exit code 0.")
        sys.exit(0)
    else:
        print("\n[FAILURE] Test suite failed with errors!")
        sys.exit(1)


if __name__ == "__main__":
    main()
