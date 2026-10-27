#!/bin/sh
# ==============================================================================
# Asuswrt-Merlin Split DNS Installer & Manager
# Repository: https://github.com/normannskald/asuswrt-merlin-splitdns
# License: MIT
# Copyright (c) 2026 normannskald
# ==============================================================================

set -e

VERSION="1.0.0"
GITHUB_REPO="normannskald/asuswrt-merlin-splitdns"
RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main"
ADDON_DIR="/jffs/addons/splitdns"
SCRIPT_PATH="${ADDON_DIR}/splitdns.sh"
PAGE_PATH="${ADDON_DIR}/splitdns_page.asp"
LOCKFILE="/tmp/.splitdns_menutree.lock"

log_info() {
    printf "[INFO] %s\n" "$1"
}

log_err() {
    printf "[ERROR] %s\n" "$1" >&2
}

check_root() {
    local u=$(whoami 2>/dev/null || echo "$USER")
    [ -n "$u" ] || u="admin"
    if [ "$u" != "admin" ] && [ "$u" != "root" ] && [ ! -w /jffs ]; then
        log_err "This installer must be run as root (admin)."
        exit 1
    fi
}

check_jffs() {
    if ! mount | grep -q ' on /jffs '; then
        log_err "/jffs partition is not mounted. Please enable JFFS in Web UI."
        return 1
    fi
    if [ "$(nvram get jffs2_scripts 2>/dev/null)" != "1" ]; then
        log_err "Custom JFFS scripts are disabled in NVRAM (jffs2_scripts != 1)."
        log_err "Enable 'Enable JFFS custom scripts and configs' in Administration -> System."
        return 1
    fi
    mkdir -p /jffs/scripts /jffs/configs "${ADDON_DIR}"
    return 0
}

cmd_install() {
    log_info "Installing Split DNS Addon v${VERSION}..."
    check_jffs || exit 1

    TMP_DIR="/tmp/splitdns_install_$$"
    mkdir -p "$TMP_DIR"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

    # Source files: local or GitHub download
    SCRIPT_SRC=""
    PAGE_SRC=""
    INSTALLER_DIR=$(dirname "$0")

    if [ -f "${INSTALLER_DIR}/splitdns.sh" ] && [ -f "${INSTALLER_DIR}/splitdns_page.asp" ]; then
        log_info "Using local package files from ${INSTALLER_DIR}..."
        cp "${INSTALLER_DIR}/splitdns.sh" "${TMP_DIR}/splitdns.sh"
        cp "${INSTALLER_DIR}/splitdns_page.asp" "${TMP_DIR}/splitdns_page.asp"
    else
        log_info "Downloading splitdns.sh from GitHub repository..."
        curl -fsSL "${RAW_URL}/splitdns.sh" -o "${TMP_DIR}/splitdns.sh" || {
            log_err "Failed to download splitdns.sh from GitHub."
            exit 1
        }

        log_info "Downloading splitdns_page.asp from GitHub repository..."
        curl -fsSL "${RAW_URL}/splitdns_page.asp" -o "${TMP_DIR}/splitdns_page.asp" || {
            log_err "Failed to download splitdns_page.asp from GitHub."
            exit 1
        }
    fi

    # Validation
    if [ ! -s "${TMP_DIR}/splitdns.sh" ] || [ ! -s "${TMP_DIR}/splitdns_page.asp" ]; then
        log_err "Downloaded or source files are empty. Aborting."
        exit 1
    fi

    sh -n "${TMP_DIR}/splitdns.sh" || {
        log_err "Downloaded splitdns.sh failed syntax check. Aborting."
        exit 1
    }

    grep -q "AS_SPLITDNS_UI_PAGE" "${TMP_DIR}/splitdns_page.asp" || {
        log_err "Downloaded splitdns_page.asp missing signature marker. Aborting."
        exit 1
    }

    # Deploy executable and web page
    cp -f "${TMP_DIR}/splitdns.sh" "${SCRIPT_PATH}"
    chmod 755 "${SCRIPT_PATH}"
    cp -f "${TMP_DIR}/splitdns_page.asp" "${PAGE_PATH}"
    chmod 644 "${PAGE_PATH}"

    # Save local copy of install.sh
    if [ -f "$0" ] && grep -q "Split DNS Installer" "$0" 2>/dev/null; then
        cp -f "$0" "${ADDON_DIR}/install.sh" 2>/dev/null || true
    else
        curl -fsSL "${RAW_URL}/install.sh" -o "${ADDON_DIR}/install.sh" 2>/dev/null || true
    fi
    [ -f "${ADDON_DIR}/install.sh" ] && chmod 755 "${ADDON_DIR}/install.sh"

    # Default configs
    if [ ! -f "${ADDON_DIR}/splitdns.conf" ]; then
        cat << 'EOF' > "${ADDON_DIR}/splitdns.conf"
ENABLED="1"
PROFILE="yandex_basic"
DNS_PRIMARY="77.88.8.8"
DNS_SECONDARY="77.88.8.1"
CUSTOM_DNS_PRIMARY=""
CUSTOM_DNS_SECONDARY=""
PRESET_NATIONAL_ZONES="1"
PRESET_GOV_SERVICES="1"
SLOT="none"
VERSION="1.0.0"
LAST_UPDATE=""
EOF
        chmod 644 "${ADDON_DIR}/splitdns.conf"
    fi

    if [ ! -f "${ADDON_DIR}/rules.json" ]; then
        echo "[]" > "${ADDON_DIR}/rules.json"
        chmod 644 "${ADDON_DIR}/rules.json"
    fi

    # Startup hook in services-start
    if [ ! -f /jffs/scripts/services-start ]; then
        echo "#!/bin/sh" > /jffs/scripts/services-start
    fi
    chmod 755 /jffs/scripts/services-start
    if ! grep -q "splitdns.sh" /jffs/scripts/services-start 2>/dev/null; then
        echo "(sleep 2; /jffs/addons/splitdns/splitdns.sh start) & # splitdns-addon" >> /jffs/scripts/services-start
        log_info "Registered startup hook in /jffs/scripts/services-start"
    fi

    # Service-event hook for Web UI actions
    if [ ! -f /jffs/scripts/service-event ]; then
        echo "#!/bin/sh" > /jffs/scripts/service-event
    fi
    chmod 755 /jffs/scripts/service-event
    if ! grep -q "splitdns.sh" /jffs/scripts/service-event 2>/dev/null; then
        echo 'echo "$2" | grep -q "^splitdns" && /jffs/addons/splitdns/splitdns.sh "service_event" "$1" "$2" # splitdns-addon' >> /jffs/scripts/service-event
        log_info "Registered Web UI hook in /jffs/scripts/service-event"
    fi

    # Postconf hook in dnsmasq.postconf
    if [ ! -f /jffs/scripts/dnsmasq.postconf ]; then
        echo "#!/bin/sh" > /jffs/scripts/dnsmasq.postconf
    fi
    chmod 755 /jffs/scripts/dnsmasq.postconf
    if ! grep -q "splitdns" /jffs/scripts/dnsmasq.postconf 2>/dev/null; then
        cat << 'EOF' >> /jffs/scripts/dnsmasq.postconf
# --- SPLITDNS_START ---
. /usr/sbin/helper.sh
[ -f /jffs/addons/splitdns/dnsmasq_splitdns.conf ] || pc_delete "conf-file=/jffs/addons/splitdns/dnsmasq_splitdns.conf" "$1"
# --- SPLITDNS_END ---
EOF
        log_info "Registered fallback guard in /jffs/scripts/dnsmasq.postconf"
    fi

    # CLI Shortcut in /opt/bin if Entware present
    [ -d /opt/bin ] && ln -sf "${SCRIPT_PATH}" /opt/bin/splitdns

    # Initialize Web UI and service
    "${SCRIPT_PATH}" mount_ui
    "${SCRIPT_PATH}" apply

    LAN_IP=$(nvram get lan_ipaddr 2>/dev/null || echo "192.168.50.1")
    SLOT=$(grep -l "AS_SPLITDNS_UI_PAGE" /www/user/user*.asp 2>/dev/null | head -n 1 | sed 's#/www/user/##')
    if [ -z "$SLOT" ] && [ -f "${ADDON_DIR}/splitdns.conf" ]; then
        SLOT=$(grep '^SLOT=' "${ADDON_DIR}/splitdns.conf" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    fi
    [ -z "$SLOT" ] || [ "$SLOT" = "none" ] && SLOT="user3.asp"

    printf "\n"
    printf "========================================================\n"
    printf " Split DNS installed successfully!\n"
    printf " Web UI URL: http://%s/%s\n" "$LAN_IP" "$SLOT"
    printf " CLI Shortcut: %s\n" "$SCRIPT_PATH"
    printf "========================================================\n\n"
}

cmd_update() {
    log_info "Updating Split DNS Addon..."
    [ ! -f "${SCRIPT_PATH}" ] && { log_err "Split DNS is not installed. Run install first."; exit 1; }
    
    TMP_DIR="/tmp/splitdns_update_$$"
    mkdir -p "$TMP_DIR"
    trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

    INSTALLER_DIR=$(dirname "$0")
    if [ -f "${INSTALLER_DIR}/splitdns.sh" ] && [ -f "${INSTALLER_DIR}/splitdns_page.asp" ]; then
        cp "${INSTALLER_DIR}/splitdns.sh" "${TMP_DIR}/splitdns.sh"
        cp "${INSTALLER_DIR}/splitdns_page.asp" "${TMP_DIR}/splitdns_page.asp"
    else
        curl -fsSL "${RAW_URL}/splitdns.sh" -o "${TMP_DIR}/splitdns.sh"
        curl -fsSL "${RAW_URL}/splitdns_page.asp" -o "${TMP_DIR}/splitdns_page.asp"
    fi

    sh -n "${TMP_DIR}/splitdns.sh" || { log_err "Syntax check failed on remote script."; exit 1; }
    grep -q "AS_SPLITDNS_UI_PAGE" "${TMP_DIR}/splitdns_page.asp" || { log_err "Missing UI marker in update page."; exit 1; }

    # Backup configs
    cp -p "${ADDON_DIR}/splitdns.conf" "${TMP_DIR}/splitdns.conf.bak" 2>/dev/null || true
    cp -p "${ADDON_DIR}/rules.json" "${TMP_DIR}/rules.json.bak" 2>/dev/null || true

    cp -f "${TMP_DIR}/splitdns.sh" "${SCRIPT_PATH}" && chmod 755 "${SCRIPT_PATH}"
    cp -f "${TMP_DIR}/splitdns_page.asp" "${PAGE_PATH}" && chmod 644 "${PAGE_PATH}"

    "${SCRIPT_PATH}" mount_ui
    "${SCRIPT_PATH}" apply
    log_info "Split DNS updated successfully."
}

cmd_reset() {
    printf "Are you sure you want to reset Split DNS settings? [y/N]: "
    read -r confirm
    case "$confirm" in
        [yY]|[yY][eE][sS])
            "${SCRIPT_PATH}" reset
            log_info "Split DNS settings reset to factory defaults."
            ;;
        *)
            log_info "Reset aborted."
            ;;
    esac
}

cmd_uninstall() {
    printf "Are you sure you want to uninstall Split DNS? [y/N]: "
    read -r confirm
    case "$confirm" in
        [yY]|[yY][eE][sS])
            if [ -f "${SCRIPT_PATH}" ]; then
                "${SCRIPT_PATH}" uninstall
            else
                sed -i '/splitdns\.sh/d' /jffs/scripts/services-start 2>/dev/null || true
                sed -i '/splitdns\.sh/d' /jffs/scripts/service-event 2>/dev/null || true
                sed -i '/# --- SPLITDNS_START ---/,/# --- SPLITDNS_END ---/d' /jffs/scripts/dnsmasq.postconf 2>/dev/null || true
                sed -i '/dnsmasq_splitdns\.conf/d' /jffs/configs/dnsmasq.conf.add 2>/dev/null || true
                rm -rf "${ADDON_DIR}"
            fi
            rm -f /opt/bin/splitdns
            log_info "Split DNS completely uninstalled."
            ;;
        *)
            log_info "Uninstall aborted."
            ;;
    esac
}

cmd_status() {
    if [ -f "${SCRIPT_PATH}" ]; then
        "${SCRIPT_PATH}" status
    else
        log_info "Split DNS is not installed."
    fi
}

show_menu() {
    while true; do
        printf "\n========================================================\n"
        printf " Asuswrt-Merlin Split DNS Installer & Manager v%s\n" "$VERSION"
        printf "========================================================\n"
        printf " 1) Install Split DNS\n"
        printf " 2) Update Addon\n"
        printf " 3) Status & Diagnostics\n"
        printf " 4) Reset Settings (Surgical)\n"
        printf " 5) Uninstall Addon\n"
        printf " 6) Exit\n"
        printf "========================================================\n"
        printf " Please choose an option [1-6]: "
        read -r choice
        case "$choice" in
            1|i|install|Install) cmd_install; break ;;
            2|u|update|Update)   cmd_update; break ;;
            3|s|status|Status)   cmd_status ;;
            4|r|reset|Reset)     cmd_reset; break ;;
            5|uninstall|Uninstall) cmd_uninstall; break ;;
            6|q|e|exit|quit|Exit|Quit) printf "Exiting.\n"; exit 0 ;;
            *) printf "Invalid option. Enter 1-6.\n" ;;
        esac
    done
}

check_root

ACTION="${1:-}"
if [ -n "$ACTION" ]; then
    case "$ACTION" in
        install) cmd_install ;;
        update) cmd_update ;;
        status) cmd_status ;;
        reset) cmd_reset ;;
        uninstall) cmd_uninstall ;;
        -h|--help|help)
            printf "Usage: %s [install|update|status|reset|uninstall]\n" "$0"
            exit 0
            ;;
        *)
            log_err "Unknown command: $ACTION"
            printf "Usage: %s [install|update|status|reset|uninstall]\n" "$0"
            exit 1
            ;;
    esac
else
    # Terminal reconnection if piped
    if [ ! -t 0 ] && [ -c /dev/tty ]; then
        exec < /dev/tty
        show_menu
    elif [ -t 0 ]; then
        show_menu
    else
        # Headless piped execution without tty -> default to install
        cmd_install
    fi
fi
