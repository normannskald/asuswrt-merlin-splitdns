#!/bin/sh
# ==============================================================================
# Split DNS Addon for Asuswrt-Merlin
# File: /jffs/addons/splitdns/splitdns.sh
# License: MIT
# Copyright (c) 2026 normannskald
# ==============================================================================

set -u

# --- Global Paths & Constants ---
TAG="splitdns"
ADDON_DIR="/jffs/addons/splitdns"
CONF_FILE="$ADDON_DIR/splitdns.conf"
RULES_FILE="$ADDON_DIR/rules.json"
PROFILES_FILE="$ADDON_DIR/profiles.json"
DNSMASQ_CONF="$ADDON_DIR/dnsmasq_splitdns.conf"
DNSMASQ_ADD="/jffs/configs/dnsmasq.conf.add"
POSTCONF_SCRIPT="/jffs/scripts/dnsmasq.postconf"
SERVICES_START="/jffs/scripts/services-start"
SERVICE_EVENT="/jffs/scripts/service-event"
STATUS_FILE="/www/user/splitdns_status.htm"
PAGE_SOURCE="$ADDON_DIR/splitdns_page.asp"
LOCKFILE="/tmp/.splitdns_menutree.lock"
GLOBAL_LOCK="/tmp/.splitdns_lock"
VERSION="1.2.0"
GITHUB_REPO="normannskald/asuswrt-merlin-splitdns"
RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main"
ROUTER_DOT_IP="127.0.1.1"

# --- Configuration State Variables & Defaults ---
ENABLED="1"
PROFILE="yandex_basic"
DNS_PRIMARY="77.88.8.8"
DNS_SECONDARY="77.88.8.1"
CUSTOM_DNS_PRIMARY=""
CUSTOM_DNS_SECONDARY=""
SLOT="none"
RULES_COUNT="0"

# --- Source helper.sh if available, provide fallbacks for offline testing ---
if [ -f /usr/sbin/helper.sh ]; then
    . /usr/sbin/helper.sh
else
    am_get_webui_page() {
        local i=1
        while [ "$i" -le 20 ]; do
            local p="/www/user/user${i}.asp"
            if [ ! -f "$p" ]; then
                am_webui_page="user${i}.asp"
                return 0
            fi
            if [ -n "${1:-}" ] && [ -f "$1" ]; then
                local m1=$(md5sum "$1" 2>/dev/null | awk '{print $1}')
                local m2=$(md5sum "$p" 2>/dev/null | awk '{print $1}')
                if [ -n "$m1" ] && [ "$m1" = "$m2" ]; then
                    am_webui_page="user${i}.asp"
                    return 0
                fi
            fi
            i=$((i + 1))
        done
        am_webui_page="none"
        return 1
    }
    pc_delete() {
        sed -i "/$1/d" "$2" 2>/dev/null || true
    }
    pc_append() {
        echo "$1" >> "$2"
    }
fi

# --- Logging & Diagnostics ---
log() {
    logger -t "$TAG" "$*" 2>/dev/null || true
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# --- Network & WAN Utilities ---
get_wan_dns() {
    local xdns=""
    if which nvram >/dev/null 2>&1; then
        xdns=$(nvram get wan0_xdns 2>/dev/null)
        [ -z "$xdns" ] && xdns=$(nvram get wan_xdns 2>/dev/null)
        if [ -z "$xdns" ]; then
            xdns=$(nvram get wan0_dns 2>/dev/null)
            [ -z "$xdns" ] && xdns=$(nvram get wan_dns 2>/dev/null)
        fi
    fi
    local d1=$(echo "$xdns" | awk '{print $1}')
    local d2=$(echo "$xdns" | awk '{print $2}')
    [ -z "$d1" ] && d1="77.88.8.8"
    [ -z "$d2" ] && d2="77.88.8.1"
    echo "$d1 $d2"
}

resolve_profile_dns() {
    local prof="${1:-${PROFILE:-yandex_basic}}"
    case "$prof" in
        yandex_basic)  echo "77.88.8.8 77.88.8.1" ;;
        yandex_safe)   echo "77.88.8.88 77.88.8.2" ;;
        yandex_family) echo "77.88.8.7 77.88.8.3" ;;
        nsdi)          echo "195.208.4.1 195.208.5.1" ;;
        isp)           get_wan_dns ;;
        custom)
            local c1="${CUSTOM_DNS_PRIMARY:-}"
            local c2="${CUSTOM_DNS_SECONDARY:-}"
            if [ -z "$c1" ] && [ -z "$c2" ]; then
                echo "77.88.8.8 77.88.8.1"
            else
                echo "${c1:-77.88.8.8} ${c2:-}"
            fi
            ;;
        *)             echo "77.88.8.8 77.88.8.1" ;;
    esac
}

# --- Configuration Management ---
load_config() {
    ENABLED="1"
    PROFILE="yandex_basic"
    DNS_PRIMARY="77.88.8.8"
    DNS_SECONDARY="77.88.8.1"
    CUSTOM_DNS_PRIMARY=""
    CUSTOM_DNS_SECONDARY=""
    SLOT="none"
    RULES_COUNT="0"

    if [ -f "$CONF_FILE" ]; then
        . "$CONF_FILE"
    fi

    if [ ! -f "$PROFILES_FILE" ]; then
        mkdir -p "$ADDON_DIR"
        printf '%s\n' '[{"id": "prof_1", "name": "Яндекс.DNS Базовый", "dns1": "77.88.8.8", "dns2": "77.88.8.1"}]' > "$PROFILES_FILE"
        chmod 644 "$PROFILES_FILE" 2>/dev/null || true
    fi
}

save_config() {
    mkdir -p "$ADDON_DIR"
    local tmp="$CONF_FILE.tmp.$$"
    cat << EOF > "$tmp"
ENABLED="${ENABLED:-1}"
PROFILE="${PROFILE:-yandex_basic}"
DNS_PRIMARY="${DNS_PRIMARY:-77.88.8.8}"
DNS_SECONDARY="${DNS_SECONDARY:-77.88.8.1}"
CUSTOM_DNS_PRIMARY="${CUSTOM_DNS_PRIMARY:-}"
CUSTOM_DNS_SECONDARY="${CUSTOM_DNS_SECONDARY:-}"
SLOT="${SLOT:-none}"
RULES_COUNT="${RULES_COUNT:-0}"
VERSION="$VERSION"
LAST_UPDATE="$(date -u '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date)"
EOF
    mv -f "$tmp" "$CONF_FILE"
    chmod 644 "$CONF_FILE" 2>/dev/null || true
}

# --- Transient Settings Handling ---
TEST_DOMAIN_ARG=""
parse_transient_settings() {
    local trans_file="$1"
    [ ! -f "$trans_file" ] && return 0

    local config_changed=0
    while IFS= read -r line || [ -n "$line" ]; do
        local key=$(echo "$line" | sed 's/[= ].*//')
        local val=""
        if echo "$line" | grep -q '[= ]'; then
            val=$(echo "$line" | sed 's/^[^= ]*[= ]//')
        fi
        case "$key" in
            splitdns_enable|splitdns_enabled)
                local raw_en=$(echo "$val" | tr -cd '01')
                [ "$raw_en" = "1" ] && ENABLED="1" || ENABLED="0"
                config_changed=1
                ;;
            splitdns_profile)
                local raw_prof=$(echo "$val" | tr -cd 'a-z_')
                case "$raw_prof" in
                    yandex_basic|yandex_safe|yandex_family|nsdi|isp|custom)
                        PROFILE="$raw_prof"
                        ;;
                    *)
                        PROFILE="yandex_basic"
                        ;;
                esac
                config_changed=1
                ;;
            splitdns_custom_dns1)
                CUSTOM_DNS_PRIMARY=$(echo "$val" | tr -cd '0-9a-fA-F.:#')
                config_changed=1
                ;;
            splitdns_custom_dns2)
                CUSTOM_DNS_SECONDARY=$(echo "$val" | tr -cd '0-9a-fA-F.:#')
                config_changed=1
                ;;
            splitdns_profiles_b64)
                local b64_p=$(echo "$val" | tr -cd 'A-Za-z0-9+/=')
                if [ -n "$b64_p" ]; then
                    if which base64 >/dev/null 2>&1; then
                        echo "$b64_p" | base64 -d > "$PROFILES_FILE" 2>/dev/null || true
                    elif which openssl >/dev/null 2>&1; then
                        echo "$b64_p" | openssl base64 -d -A > "$PROFILES_FILE" 2>/dev/null || true
                    fi
                fi
                config_changed=1
                ;;
            splitdns_profiles_json)
                if [ -n "$val" ]; then
                    echo "$val" > "$PROFILES_FILE"
                fi
                config_changed=1
                ;;
            splitdns_rules_b64)
                local b64_data=$(echo "$val" | tr -cd 'A-Za-z0-9+/=')
                if [ -n "$b64_data" ]; then
                    if which base64 >/dev/null 2>&1; then
                        echo "$b64_data" | base64 -d > "$RULES_FILE" 2>/dev/null || true
                    elif which openssl >/dev/null 2>&1; then
                        echo "$b64_data" | openssl base64 -d -A > "$RULES_FILE" 2>/dev/null || true
                    fi
                fi
                config_changed=1
                ;;
            splitdns_rules_json)
                if [ -n "$val" ]; then
                    echo "$val" > "$RULES_FILE"
                fi
                config_changed=1
                ;;
            splitdns_test_domain)
                TEST_DOMAIN_ARG=$(echo "$val" | tr -cd 'a-zA-Z0-9._-')
                ;;
        esac
    done < "$trans_file"

    if [ "$config_changed" = "1" ]; then
        save_config
    fi
}

# --- Dnsmasq Rules Generator ---
generate_dnsmasq_rules() {
    mkdir -p "$ADDON_DIR"
    local tmp_conf="$DNSMASQ_CONF.tmp.$$"

    if [ "${ENABLED:-0}" != "1" ]; then
        echo "# Split DNS is disabled" > "$tmp_conf"
        mv -f "$tmp_conf" "$DNSMASQ_CONF"
        return 0
    fi

    local resolved_ips=$(resolve_profile_dns "$PROFILE")
    local p_dns1=$(echo "$resolved_ips" | awk '{print $1}')
    local p_dns2=$(echo "$resolved_ips" | awk '{print $2}')
    DNS_PRIMARY="$p_dns1"
    DNS_SECONDARY="$p_dns2"

    cat << EOF > "$tmp_conf"
# --- Generated by Asuswrt-Merlin Split DNS ---
# Profile: $PROFILE
# Upstreams: $p_dns1 ${p_dns2:-}

EOF

    # Custom User Rules & Exceptions via Awk (top-to-bottom priority)
    if [ -f "$RULES_FILE" ] && [ -s "$RULES_FILE" ]; then
        echo "# Custom User Rules & Exceptions" >> "$tmp_conf"
        awk -v dot_ip="$ROUTER_DOT_IP" -v prof_file="$PROFILES_FILE" '
        BEGIN {
            if (prof_file != "") {
                p_buf = ""
                while ((getline p_line < prof_file) > 0) {
                    p_buf = p_buf " " p_line
                }
                close(prof_file)
                while (match(p_buf, /[{][^}]+[}]/)) {
                    p_obj = substr(p_buf, RSTART + 1, RLENGTH - 2)
                    p_buf = substr(p_buf, RSTART + RLENGTH)
                    p_id = ""; p_dns1 = ""; p_dns2 = ""
                    if (match(p_obj, /"id"[ \t]*:[ \t]*"[^"]*"/)) {
                        val = substr(p_obj, RSTART, RLENGTH); sub(/.*:[ \t]*"/, "", val); sub(/"$/, "", val); p_id = val
                    }
                    if (match(p_obj, /"dns1"[ \t]*:[ \t]*"[^"]*"/)) {
                        val = substr(p_obj, RSTART, RLENGTH); sub(/.*:[ \t]*"/, "", val); sub(/"$/, "", val); p_dns1 = val
                    }
                    if (match(p_obj, /"dns2"[ \t]*:[ \t]*"[^"]*"/)) {
                        val = substr(p_obj, RSTART, RLENGTH); sub(/.*:[ \t]*"/, "", val); sub(/"$/, "", val); p_dns2 = val
                    }
                    if (p_id != "") {
                        prof_dns1[p_id] = p_dns1
                        prof_dns2[p_id] = p_dns2
                        if (first_prof_dns1 == "") {
                            first_prof_dns1 = p_dns1
                            first_prof_dns2 = p_dns2
                        }
                    }
                }
            }
        }
        {
            buffer = buffer " " $0
        }
        END {
            line = buffer
            while (match(line, /[{][^}]+[}]/)) {
                obj = substr(line, RSTART + 1, RLENGTH - 2)
                line = substr(line, RSTART + RLENGTH)
                enabled = 0; domains = ""; target_type = "profile"; target_ip = ""
                if (match(obj, /"enabled"[ \t]*:[ \t]*[0-9]+/)) {
                    val = substr(obj, RSTART, RLENGTH); sub(/.*:[ \t]*/, "", val); enabled = val
                }
                if (enabled != 1) continue
                if (match(obj, /"domains"[ \t]*:[ \t]*"[^"]*"/)) {
                    val = substr(obj, RSTART, RLENGTH); sub(/.*:[ \t]*"/, "", val); sub(/"$/, "", val); domains = val
                }
                if (domains == "") continue
                if (match(obj, /"target_type"[ \t]*:[ \t]*"[^"]*"/)) {
                    val = substr(obj, RSTART, RLENGTH); sub(/.*:[ \t]*"/, "", val); sub(/"$/, "", val); target_type = val
                }
                if (match(obj, /"target_ip"[ \t]*:[ \t]*"[^"]*"/)) {
                    val = substr(obj, RSTART, RLENGTH); sub(/.*:[ \t]*"/, "", val); sub(/"$/, "", val); target_ip = val
                }
                ip1 = ""; ip2 = ""
                if (target_type == "router") {
                    ip1 = dot_ip
                } else if (prof_dns1[target_type] != "") {
                    ip1 = prof_dns1[target_type]
                    ip2 = prof_dns2[target_type]
                } else if (target_type == "custom" && target_ip != "") {
                    ip1 = target_ip
                } else if (first_prof_dns1 != "") {
                    ip1 = first_prof_dns1
                    ip2 = first_prof_dns2
                } else {
                    ip1 = "77.88.8.8"
                    ip2 = "77.88.8.1"
                }
                if (ip1 == "") continue
                gsub(/\\[tnr]/, " ", domains)
                gsub(/[,; \t\r\n]+/, " ", domains)
                n = split(domains, dom_arr, /[ ]/)
                for (i = 1; i <= n; i++) {
                    d = dom_arr[i]
                    sub(/^\*\./, "", d)
                    sub(/^[.]+/, "", d)
                    sub(/[.]+$/, "", d)
                    if (d == "рф" || d == "РФ") d = "xn--p1ai"
                    else if (d == "москва" || d == "МОСКВА") d = "xn--80adxhks"
                    else if (d == "рус" || d == "РУС") d = "xn--p1acf"
                    else if (d == "дети" || d == "ДЕТИ") d = "xn--d1acj3b"
                    else if (d == "бел" || d == "БЕЛ") d = "xn--90ais"
                    d = tolower(d)
                    gsub(/[^a-zA-Z0-9._-]/, "", d)
                    gsub(/[.]+[.]+/, ".", d)
                    sub(/^[.]+/, "", d)
                    sub(/[.]+$/, "", d)
                    if (d == "" || d == "." || d !~ /[a-zA-Z0-9]/) continue
                    if (seen[d]++) continue
                    print "server=/" d "/" ip1
                    if (ip2 != "" && ip2 != ip1) {
                        print "server=/" d "/" ip2
                    }
                }
            }
        }' "$RULES_FILE" >> "$tmp_conf"
        echo "" >> "$tmp_conf"
    fi

    # Validate syntax if dnsmasq binary exists
    if which dnsmasq >/dev/null 2>&1; then
        if ! dnsmasq --test -C "$tmp_conf" >/dev/null 2>&1; then
            log "ERROR: dnsmasq --test failed on generated config"
            rm -f "$tmp_conf"
            return 1
        fi
    fi

    mv -f "$tmp_conf" "$DNSMASQ_CONF"
    return 0
}

# --- Triple-Guarded Dnsmasq Restart ---
safe_restart_dnsmasq() {
    local test_opt=""
    if [ -f "$DNSMASQ_CONF" ]; then
        test_opt="-C $DNSMASQ_CONF"
        if which dnsmasq >/dev/null 2>&1; then
            if ! dnsmasq --test $test_opt >/dev/null 2>&1; then
                log "ERROR: dnsmasq --test failed on $DNSMASQ_CONF. Refusing to restart."
                return 1
            fi
        fi
    fi

    # Compound restart with 1-second watchdog self-healing
    if which service >/dev/null 2>&1; then
        dnsmasq --test $test_opt && service restart_dnsmasq && (sleep 1; pidof dnsmasq >/dev/null 2>&1 || (sed -i '/dnsmasq_splitdns\.conf/d' "$DNSMASQ_ADD" 2>/dev/null && service restart_dnsmasq))
    elif which killall >/dev/null 2>&1; then
        killall -HUP dnsmasq 2>/dev/null || true
    fi

    log "dnsmasq restarted successfully and verified healthy"
    return 0
}

# --- Dynamic Slot Allocation & MenuTree Patching ---
mount_ui() {
    load_config
    mkdir -p /www/user

    # 1. Purge any stale Split DNS slots matching unique marker
    for page in /www/user/user*.asp; do
        [ -f "$page" ] || continue
        if grep -q "AS_SPLITDNS_UI_PAGE" "$page" 2>/dev/null; then
            rm -f "$page"
        fi
    done

    # 2. Discover slot via helper.sh
    local page_src="$PAGE_SOURCE"
    if [ ! -f "$page_src" ] && [ -f "./splitdns_page.asp" ]; then
        page_src="./splitdns_page.asp"
    fi

    am_get_webui_page "$page_src"
    if [ -z "${am_webui_page:-}" ] || [ "$am_webui_page" = "none" ]; then
        log "ERROR: No available Web UI slots (user1-user20 occupied)."
        return 1
    fi

    # 3. Deploy ASP page to allocated slot
    if [ -f "$page_src" ]; then
        cp -f "$page_src" "/www/user/$am_webui_page"
        chmod 644 "/www/user/$am_webui_page"
    else
        # Staging placeholder if splitdns_page.asp not yet deployed
        cat << EOF > "/www/user/$am_webui_page"
<!-- AS_SPLITDNS_UI_PAGE -->
<html><head><title>Split DNS</title></head><body><h1>Split DNS UI Page</h1></body></html>
EOF
        chmod 644 "/www/user/$am_webui_page"
    fi

    SLOT="$am_webui_page"
    save_config

    # Helper endpoint to safely read existing custom_settings in Web UI
    printf '%s' 'SDNSCS<% get_custom_settings(); %>SDNSCS' > /www/user/splitdns_cs.htm 2>/dev/null || true
    chmod 644 /www/user/splitdns_cs.htm 2>/dev/null || true

    # 4. Mutex-protected MenuTree patching
    (
        if which flock >/dev/null 2>&1; then
            flock -x 9
        fi

        # Ensure RAM copy exists
        if [ ! -f /tmp/menuTree.js ] && [ -f /www/require/modules/menuTree.js ]; then
            cp -f /www/require/modules/menuTree.js /tmp/menuTree.js
        fi

        if [ -f /tmp/menuTree.js ]; then
            # Remove old tab
            sed -i '/tabName: "Split DNS"/d' /tmp/menuTree.js

            # Insert tab into menu_WAN before __INHERIT__
            awk -v pg="$am_webui_page" '
                /index:[[:space:]]*"menu_WAN"/ { in_wan=1 }
                in_wan && /"NULL"/ && /__INHERIT__/ {
                    printf "{url: \"%s\", tabName: \"Split DNS\"},\n", pg
                    in_wan=0
                }
                { print }
            ' /tmp/menuTree.js > /tmp/menuTree.js.new && mv -f /tmp/menuTree.js.new /tmp/menuTree.js

            # Remount bind mount
            umount /www/require/modules/menuTree.js 2>/dev/null || true
            mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js 2>/dev/null || true
        fi
    ) 9>"$LOCKFILE"

    update_status
    log "Web UI mounted on $am_webui_page and menuTree.js patched."
    return 0
}

unmount_ui() {
    (
        if which flock >/dev/null 2>&1; then
            flock -x 9
        fi

        if [ -f /tmp/menuTree.js ]; then
            sed -i '/tabName: "Split DNS"/d' /tmp/menuTree.js
            umount /www/require/modules/menuTree.js 2>/dev/null || true
            mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js 2>/dev/null || true
        fi
    ) 9>"$LOCKFILE"

    for page in /www/user/user*.asp; do
        [ -f "$page" ] || continue
        if grep -q "AS_SPLITDNS_UI_PAGE" "$page" 2>/dev/null; then
            rm -f "$page"
        fi
    done

    rm -f "$STATUS_FILE" /www/user/splitdns_cs.htm /www/user/splitdns_diag.htm /www/user/splitdns_update.htm
    log "Web UI unmounted cleanly."
}

# --- Status Generation ---
update_status() {
    mkdir -p /www/user
    local pid=0
    local running="false"
    if which pidof >/dev/null 2>&1; then
        local pids=$(pidof dnsmasq 2>/dev/null || true)
        if [ -n "$pids" ]; then
            pid=$(echo "$pids" | awk '{print $1}')
            running="true"
        fi
    fi

    local active_cnt=0
    if [ -f "$DNSMASQ_CONF" ]; then
        active_cnt=$(grep -c '^server=' "$DNSMASQ_CONF" 2>/dev/null || true)
        [ -n "$active_cnt" ] || active_cnt=0
    fi

    local wan_ips=$(get_wan_dns)
    local w1=$(echo "$wan_ips" | awk '{print $1}')
    local w2=$(echo "$wan_ips" | awk '{print $2}')

    local r_json="[]"
    if [ -f "$RULES_FILE" ] && [ -s "$RULES_FILE" ]; then
        r_json=$(cat "$RULES_FILE" 2>/dev/null || echo "[]")
    fi

    local p_json='[{"id": "prof_1", "name": "Яндекс.DNS Базовый", "dns1": "77.88.8.8", "dns2": "77.88.8.1"}]'
    if [ -f "$PROFILES_FILE" ] && [ -s "$PROFILES_FILE" ]; then
        p_json=$(cat "$PROFILES_FILE" 2>/dev/null || echo "$p_json")
    fi

    local tmp_stat="/tmp/splitdns_status.tmp.$$"
    cat << EOF > "$tmp_stat"
{
  "version": "$VERSION",
  "enabled": ${ENABLED:-0},
  "service_status": "$([ "${ENABLED:-0}" = "1" ] && echo "running" || echo "stopped")",
  "profile": "${PROFILE:-yandex_basic}",
  "dns_primary": "${DNS_PRIMARY:-77.88.8.8}",
  "dns_secondary": "${DNS_SECONDARY:-77.88.8.1}",
  "custom_dns_primary": "${CUSTOM_DNS_PRIMARY:-}",
  "custom_dns_secondary": "${CUSTOM_DNS_SECONDARY:-}",
  "wan_dns1": "$w1",
  "wan_dns2": "$w2",
  "profiles": $p_json,
  "rules": $r_json,
  "dnsmasq_running": $running,
  "dnsmasq_pid": ${pid:-0},
  "active_rules_count": ${active_cnt:-0},
  "slot": "${SLOT:-none}"
}
EOF
    mv -f "$tmp_stat" "$STATUS_FILE"
    chmod 644 "$STATUS_FILE" 2>/dev/null || true
}

# --- Postconf & Service-Event Hook Helpers ---
ensure_postconf_hook() {
    mkdir -p /jffs/scripts
    if [ ! -f "$POSTCONF_SCRIPT" ]; then
        echo "#!/bin/sh" > "$POSTCONF_SCRIPT"
    fi
    chmod 755 "$POSTCONF_SCRIPT" 2>/dev/null || true
    if ! grep -q "splitdns" "$POSTCONF_SCRIPT" 2>/dev/null; then
        cat << 'EOF' >> "$POSTCONF_SCRIPT"
# --- SPLITDNS_START ---
. /usr/sbin/helper.sh
[ -f /jffs/addons/splitdns/dnsmasq_splitdns.conf ] || pc_delete "conf-file=/jffs/addons/splitdns/dnsmasq_splitdns.conf" "$1"
# --- SPLITDNS_END ---
EOF
    fi
}

ensure_service_event_hook() {
    mkdir -p /jffs/scripts
    if [ ! -f "$SERVICE_EVENT" ]; then
        echo "#!/bin/sh" > "$SERVICE_EVENT"
    fi
    chmod 755 "$SERVICE_EVENT" 2>/dev/null || true
    if ! grep -q "splitdns.sh" "$SERVICE_EVENT" 2>/dev/null; then
        echo 'echo "$2" | grep -q "^splitdns" && /jffs/addons/splitdns/splitdns.sh "service_event" "$1" "$2" # splitdns-addon' >> "$SERVICE_EVENT"
    fi
}

# --- CLI Subcommands Implementation ---

cmd_start() {
    log "Starting Split DNS Addon..."
    load_config
    ensure_service_event_hook
    mount_ui

    if [ "${ENABLED:-0}" = "1" ]; then
        generate_dnsmasq_rules

        mkdir -p /jffs/configs
        touch "$DNSMASQ_ADD"
        if ! grep -q "dnsmasq_splitdns.conf" "$DNSMASQ_ADD" 2>/dev/null; then
            echo "conf-file=$DNSMASQ_CONF" >> "$DNSMASQ_ADD"
        fi

        # Fallback guard in dnsmasq.postconf
        ensure_postconf_hook

        safe_restart_dnsmasq
    fi

    update_status
    log "Split DNS start complete."
}

cmd_stop() {
    log "Stopping Split DNS Addon..."
    load_config

    if [ -f "$DNSMASQ_ADD" ]; then
        sed -i '/dnsmasq_splitdns\.conf/d' "$DNSMASQ_ADD" 2>/dev/null || true
    fi

    safe_restart_dnsmasq
    update_status
    log "Split DNS stop complete."
}

cmd_restart() {
    cmd_stop
    cmd_start
}

cmd_apply() {
    log "Applying Split DNS settings..."
    load_config

    # Process transient custom_settings.txt if present
    if [ -f /jffs/addons/custom_settings.txt ] && grep -q '^splitdns_' /jffs/addons/custom_settings.txt 2>/dev/null; then
        local trans="/tmp/splitdns_transient_$$.tmp"
        grep '^splitdns_' /jffs/addons/custom_settings.txt > "$trans" 2>/dev/null || true
        sed -i '/^splitdns_/d' /jffs/addons/custom_settings.txt
        parse_transient_settings "$trans"
        rm -f "$trans"
    fi

    generate_dnsmasq_rules

    if [ "${ENABLED:-0}" = "1" ]; then
        mkdir -p /jffs/configs
        touch "$DNSMASQ_ADD"
        if ! grep -q "dnsmasq_splitdns.conf" "$DNSMASQ_ADD" 2>/dev/null; then
            echo "conf-file=$DNSMASQ_CONF" >> "$DNSMASQ_ADD"
        fi
        ensure_postconf_hook
        safe_restart_dnsmasq
    else
        if [ -f "$DNSMASQ_ADD" ]; then
            sed -i '/dnsmasq_splitdns\.conf/d' "$DNSMASQ_ADD" 2>/dev/null || true
        fi
        safe_restart_dnsmasq
    fi

    update_status
    log "Split DNS settings applied successfully."
}

cmd_reset() {
    log "Performing surgical reset of Split DNS..."
    load_config

    # 1. Clean transient settings from custom_settings.txt
    if [ -f /jffs/addons/custom_settings.txt ]; then
        sed -i '/^splitdns_/d' /jffs/addons/custom_settings.txt 2>/dev/null || true
    fi

    # 2. Remove Split DNS inclusion from dnsmasq.conf.add
    if [ -f "$DNSMASQ_ADD" ]; then
        sed -i '/dnsmasq_splitdns\.conf/d' "$DNSMASQ_ADD" 2>/dev/null || true
    fi

    # 3. Reset persistent config to factory disabled state
    ENABLED="0"
    PROFILE="yandex_basic"
    DNS_PRIMARY="77.88.8.8"
    DNS_SECONDARY="77.88.8.1"
    CUSTOM_DNS_PRIMARY=""
    CUSTOM_DNS_SECONDARY=""
    RULES_COUNT="0"
    SLOT="${SLOT:-none}"
    save_config

    # 4. Reset rules and profiles to defaults
    printf '%s\n' '[{"id": "prof_1", "name": "Яндекс.DNS Базовый", "dns1": "77.88.8.8", "dns2": "77.88.8.1"}]' > "$PROFILES_FILE"
    chmod 644 "$PROFILES_FILE" 2>/dev/null || true
    echo "[]" > "$RULES_FILE"
    chmod 644 "$RULES_FILE" 2>/dev/null || true

    # 5. Generate disabled dnsmasq configuration (writes "# Split DNS is disabled" to $DNSMASQ_CONF)
    generate_dnsmasq_rules

    # 6. Safely restart dnsmasq with watchdog self-healing
    safe_restart_dnsmasq

    # 7. Update status JSON for Web UI
    update_status
    log "Surgical reset completed. Other addons remain untouched."
}

cmd_uninstall() {
    log "Uninstalling Split DNS Addon..."
    unmount_ui

    if [ -f "$DNSMASQ_ADD" ]; then
        sed -i '/dnsmasq_splitdns\.conf/d' "$DNSMASQ_ADD" 2>/dev/null || true
    fi

    if [ -f "$POSTCONF_SCRIPT" ]; then
        sed -i '/# --- SPLITDNS_START ---/,/# --- SPLITDNS_END ---/d' "$POSTCONF_SCRIPT" 2>/dev/null || true
    fi

    if [ -f "$SERVICES_START" ]; then
        sed -i '/splitdns\.sh/d' "$SERVICES_START" 2>/dev/null || true
    fi

    if [ -f "$SERVICE_EVENT" ]; then
        sed -i '/splitdns\.sh/d' "$SERVICE_EVENT" 2>/dev/null || true
    fi

    if [ -f /jffs/addons/custom_settings.txt ]; then
        sed -i '/^splitdns_/d' /jffs/addons/custom_settings.txt 2>/dev/null || true
    fi

    safe_restart_dnsmasq
    rm -rf "$ADDON_DIR"
    rm -f /opt/bin/splitdns
    rm -f "$PROFILES_FILE"
    log "Split DNS completely uninstalled."
}

cmd_test_domain() {
    local domain="${1:-lkfl2.nalog.ru}"
    load_config
    local profile_dns=$(resolve_profile_dns "$PROFILE")
    local def_resolver=$(echo "$profile_dns" | awk '{print $1}')
    local resolver="${2:-$def_resolver}"

    local t_start=0
    local t_end=0
    local t_diff=0

    if [ -f /proc/uptime ]; then
        t_start=$(awk '{printf "%d\n", $1 * 1000}' /proc/uptime 2>/dev/null || echo "0")
    fi

    local query_out=""
    if which nslookup >/dev/null 2>&1; then
        query_out=$(nslookup "$domain" "$resolver" 2>&1 || true)
    fi

    if [ -f /proc/uptime ]; then
        t_end=$(awk '{printf "%d\n", $1 * 1000}' /proc/uptime 2>/dev/null || echo "0")
        t_diff=$((t_end - t_start))
        [ "$t_diff" -lt 0 ] && t_diff=0
    else
        t_diff=15
    fi

    # Extract IP addresses
    local ips=""
    if [ -n "$query_out" ]; then
        ips=$(echo "$query_out" | sed -n '/^Name:/,$ p' | grep '^Address' | sed -e 's/Address [0-9]*: //' -e 's/Address: //' -e 's/ .*//' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | tr '\n' ' ' | sed 's/ $//')
        if [ -z "$ips" ]; then
            ips=$(echo "$query_out" | grep -v 'Server:' | grep -E 'Address.*: [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $NF}' | tr '\n' ' ' | sed 's/ $//')
        fi
    fi

    local ips_json="[]"
    local status="error"
    if [ -n "$ips" ]; then
        status="ok"
        ips_json=$(echo "$ips" | awk '{
            printf "["
            for (i=1; i<=NF; i++) {
                printf "\"%s\"%s", $i, (i==NF ? "" : ", ")
            }
            printf "]"
        }')
    fi

    printf '{"domain": "%s", "status": "%s", "ips": %s, "resolver": "%s", "time_ms": %d}\n' \
        "$domain" "$status" "$ips_json" "$resolver" "$t_diff"
}

cmd_check_update() {
    local rem_ver=""
    if which curl >/dev/null 2>&1; then
        rem_ver=$(curl -fsSL --connect-timeout 5 --max-time 10 "${RAW_URL}/splitdns.sh" 2>/dev/null | grep '^VERSION=' | head -n 1 | cut -d'"' -f2 || true)
    fi

    local update_available="false"
    if [ -n "$rem_ver" ] && [ "$rem_ver" != "$VERSION" ]; then
        update_available="true"
    fi

    printf '{"current_version": "%s", "latest_version": "%s", "update_available": %s}\n' \
        "$VERSION" "${rem_ver:-$VERSION}" "$update_available"
}

cmd_update() {
    log "Updating Split DNS Addon..."
    load_config
    local tmp_up="/tmp/splitdns_update_$$"
    mkdir -p "$tmp_up"
    trap 'rm -rf "$tmp_up"' EXIT INT TERM

    curl -fsSL "${RAW_URL}/splitdns.sh" -o "${tmp_up}/splitdns.sh" || {
        log "ERROR: Failed to download update."
        return 1
    }
    curl -fsSL "${RAW_URL}/splitdns_page.asp" -o "${tmp_up}/splitdns_page.asp" || {
        log "ERROR: Failed to download web page update."
        return 1
    }

    sh -n "${tmp_up}/splitdns.sh" || {
        log "ERROR: Syntax check failed on update script."
        return 1
    }

    # Backup configs
    cp -p "$CONF_FILE" "${tmp_up}/splitdns.conf.bak" 2>/dev/null || true
    cp -p "$RULES_FILE" "${tmp_up}/rules.json.bak" 2>/dev/null || true

    cp -f "${tmp_up}/splitdns.sh" "$ADDON_DIR/splitdns.sh" && chmod 755 "$ADDON_DIR/splitdns.sh"
    cp -f "${tmp_up}/splitdns_page.asp" "$ADDON_DIR/splitdns_page.asp" && chmod 644 "$ADDON_DIR/splitdns_page.asp"

    mount_ui
    cmd_apply
    log "Split DNS updated successfully to latest release."
}

cmd_status() {
    load_config
    update_status
    local s_stat=$([ "${ENABLED:-0}" = "1" ] && echo "Running" || echo "Stopped")
    printf "========================================================\n"
    printf " Asuswrt-Merlin Split DNS v%s\n" "$VERSION"
    printf " Status       : %s\n" "$s_stat"
    printf " Profile      : %s (%s, %s)\n" "$PROFILE" "$DNS_PRIMARY" "$DNS_SECONDARY"
    printf " Dynamic Slot : %s\n" "$SLOT"
    printf " Config File  : %s\n" "$CONF_FILE"
    printf " Status JSON  : %s\n" "$STATUS_FILE"
    printf "========================================================\n"
}

handle_service_event() {
    local evt="${2:-${1:-}}"
    case "$evt" in
        *check_update*)
            mkdir -p /www/user
            cmd_check_update > /www/user/splitdns_update.htm 2>/dev/null || true
            chmod 644 /www/user/splitdns_update.htm 2>/dev/null || true
            ;;
        *update*)
            cmd_update
            ;;
        *test*)
            TEST_DOMAIN_ARG=""
            if [ -f /jffs/addons/custom_settings.txt ] && grep -q '^splitdns_' /jffs/addons/custom_settings.txt 2>/dev/null; then
                local trans="/tmp/splitdns_diag_$$.tmp"
                grep '^splitdns_' /jffs/addons/custom_settings.txt > "$trans" 2>/dev/null || true
                sed -i '/^splitdns_/d' /jffs/addons/custom_settings.txt
                parse_transient_settings "$trans"
                rm -f "$trans"
            fi
            mkdir -p /www/user
            cmd_test_domain "${TEST_DOMAIN_ARG:-lkfl2.nalog.ru}" > /www/user/splitdns_diag.htm 2>/dev/null || true
            chmod 644 /www/user/splitdns_diag.htm 2>/dev/null || true
            ;;
        *apply*) cmd_apply ;;
        *reset*) cmd_reset ;;
        *restart*) cmd_restart ;;
        *start*) cmd_start ;;
        *stop*) cmd_stop ;;
        *) cmd_apply ;;
    esac
}

# --- Main Entry Point ---
COMMAND="${1:-}"

case "$COMMAND" in
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    apply)
        cmd_apply
        ;;
    reset)
        cmd_reset
        ;;
    mount_ui)
        mount_ui
        ;;
    test_domain)
        shift
        cmd_test_domain "$@"
        ;;
    check_update)
        cmd_check_update
        ;;
    update)
        cmd_update
        ;;
    uninstall)
        cmd_uninstall
        ;;
    status)
        cmd_status
        ;;
    service_event)
        shift
        handle_service_event "$@"
        ;;
    -h|--help|help)
        printf "Usage: %s {start|stop|restart|apply|reset|mount_ui|test_domain|check_update|update|uninstall|status}\n" "$0"
        exit 0
        ;;
    *)
        if [ -z "$COMMAND" ]; then
            cmd_status
        else
            echo "Unknown command: $COMMAND" >&2
            printf "Usage: %s {start|stop|restart|apply|reset|mount_ui|test_domain|check_update|update|uninstall|status}\n" "$0" >&2
            exit 1
        fi
        ;;
esac

exit 0
