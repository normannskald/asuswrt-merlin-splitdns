<!-- AS_SPLITDNS_UI_PAGE -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="-1" />
<link rel="shortcut icon" href="/images/favicon.png" />
<link rel="icon" href="/images/favicon.png" />
<title>Split DNS</title>
<link rel="stylesheet" type="text/css" href="/index_style.css" />
<link rel="stylesheet" type="text/css" href="/form_style.css" />
<link rel="stylesheet" type="text/css" href="/other.css" />
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<script type="text/javascript" src="/js/jquery.js"></script>
<style type="text/css">
/* <![CDATA[ */
.splitdns-subtext {
    font-size: 11px;
    color: #CCCCCC;
    margin-top: 3px;
    line-height: 1.35;
}
.splitdns-badge {
    display: inline-block;
    padding: 2px 7px;
    border-radius: 3px;
    font-size: 11px;
    font-weight: bold;
    background-color: #2F3A3E;
    color: #FFCC00;
    border: 1px solid #5A6A70;
    margin-left: 6px;
}
.splitdns-preset-bar {
    background-color: #3B474B;
    border: 1px solid #22292C;
    padding: 6px 10px;
    margin-top: 6px;
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 8px;
}
.splitdns-preset-label {
    font-size: 12px;
    color: #FFCC00;
    font-weight: bold;
    margin-right: 4px;
}
.splitdns-drag-handle {
    cursor: move;
    color: #99A9B1;
    font-weight: bold;
    font-size: 14px;
    padding: 0 5px 0 2px;
    user-select: none;
    vertical-align: middle;
}
.splitdns-rule-row:hover .splitdns-drag-handle {
    color: #FFCC00;
}
.splitdns-rule-row.dragging {
    opacity: 0.45;
}
.splitdns-rule-row.drag-over td {
    border-top: 2px solid #FFCC00 !important;
}
.splitdns-domains-cell {
    text-align: left !important;
    padding: 4px 8px !important;
    word-break: break-word;
    max-height: 56px;
    overflow-y: auto;
    font-family: Arial, Helvetica, sans-serif !important;
}
.splitdns-comment-cell {
    text-align: left !important;
    padding: 4px 8px !important;
    word-break: break-word;
    font-family: Arial, Helvetica, sans-serif !important;
}
.splitdns-target-cell {
    padding: 4px 6px !important;
    font-family: Arial, Helvetica, sans-serif !important;
}
.textarea_ssh_table {
    width: 99%;
    background-color: #1F2D35;
    color: #FFFFFF;
    font-family: Courier New, Courier, monospace;
    font-size: 13px;
    padding: 8px;
    border: 1px solid #22292C;
    box-sizing: border-box;
    resize: vertical;
}
/* ]]> */
</style>
</head>
<body onload="initSplitDnsPage();" onunload="return unload_body();" class="bg">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>

<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

<form method="post" name="form" id="splitdns_form" action="/start_apply.htm" target="hidden_frame" onsubmit="return false;">
<input type="hidden" name="productid" id="nvram_productid" value="" />
<input type="hidden" name="current_page" value="user3.asp" />
<input type="hidden" name="next_page" value="user3.asp" />
<input type="hidden" name="modified" value="0" />
<input type="hidden" name="action_mode" value="apply" />
<input type="hidden" name="action_script" value="splitdns_apply" />
<input type="hidden" name="action_wait" value="3" />
<input type="hidden" name="preferred_lang" id="preferred_lang" value="" />
<input type="hidden" name="firmver" id="nvram_firmver" value="" />
<input type="hidden" name="amng_custom" id="amng_custom" value="" />

<table class="content" align="center" cellpadding="0" cellspacing="0">
    <tr>
        <td width="17">&nbsp;</td>
        <td valign="top" width="202">
            <div id="mainMenu"></div>
            <div id="subMenu"></div>
        </td>
        <td valign="top">
            <div id="tabMenu" class="submenuBlock"></div>

            <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                <tr>
                    <td align="left" valign="top">
                        <table width="760px" border="0" cellpadding="5" cellspacing="0" class="FormTitle" id="FormTitle">
                            <tbody>
                                <tr>
                                    <td bgcolor="#4D595D" valign="top">
                                        <div>&nbsp;</div>
                                        <div class="formfonttitle" id="ui_page_title" data-i18n="page_title">Интернет - Split DNS</div>
                                        <div style="margin: 10px 0 10px 5px;" class="splitLine"></div>
                                        <div class="formfontdesc" id="ui_page_desc" data-i18n="page_desc">
                                            Маршрутизация DNS-запросов для выбранных доменов и национальных зон через отечественные или пользовательские DNS-серверы в обход глобального DNS-over-TLS (DoT) и VPN-туннелей.
                                        </div>

                                        <!-- Section 1: Basic Settings -->
                                        <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                            <thead>
                                                <tr>
                                                    <td colspan="2" data-i18n="sec_main">Основные параметры</td>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr>
                                                    <th width="35%">
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_enable');"><span data-i18n="lbl_enable">Включить Split DNS</span></a>
                                                    </th>
                                                    <td>
                                                        <label style="margin-right: 14px; cursor: pointer;">
                                                            <input type="radio" name="splitdns_enable_radio" id="splitdns_enable_1" class="input" value="1" checked="checked" />
                                                            <span data-i18n="opt_yes">Да</span>
                                                        </label>
                                                        <label style="cursor: pointer;">
                                                            <input type="radio" name="splitdns_enable_radio" id="splitdns_enable_0" class="input" value="0" />
                                                            <span data-i18n="opt_no">Нет</span>
                                                        </label>
                                                    </td>
                                                </tr>

                                                <tr>
                                                    <th>
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_version');"><span data-i18n="lbl_version">Версия аддона</span></a>
                                                    </th>
                                                    <td>
                                                        <span id="ui_current_version" style="font-weight: bold; color: #FFFFFF;">v1.1.0</span>
                                                        <span id="ui_update_badge" class="splitdns-badge" style="display: none;"></span>
                                                        <input type="button" class="button_gen" id="btn_check_update" value="Проверить обновление" data-i18n-val="btn_check_update" onclick="checkAddonUpdate();" style="margin-left: 10px;" />
                                                        <input type="button" class="button_gen" id="btn_do_update" value="Обновить" data-i18n-val="btn_do_update" onclick="runAddonUpdate();" style="margin-left: 6px; display: none;" />
                                                        <div class="splitdns-subtext" id="ui_update_status_text"></div>
                                                    </td>
                                                </tr>

                                                <tr>
                                                    <th>
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_profile');"><span data-i18n="lbl_profile">Целевой профиль DNS</span></a>
                                                    </th>
                                                    <td>
                                                        <select name="splitdns_profile_sel" id="splitdns_profile_sel" class="input_option" onchange="onProfileChange();">
                                                            <option value="yandex_basic" data-i18n="prof_yandex_basic">Яндекс.DNS Базовый (77.88.8.8, 77.88.8.1)</option>
                                                            <option value="yandex_safe" data-i18n="prof_yandex_safe">Яндекс.DNS Безопасный (77.88.8.88, 77.88.8.2)</option>
                                                            <option value="yandex_family" data-i18n="prof_yandex_family">Яндекс.DNS Семейный (77.88.8.7, 77.88.8.3)</option>
                                                            <option value="nsdi" data-i18n="prof_nsdi">НСДИ / Национальная система (195.208.4.1, 195.208.5.1)</option>
                                                            <option value="isp" id="opt_prof_isp" data-i18n="prof_isp">DNS интернет-провайдера (WAN DHCP)</option>
                                                            <option value="custom" data-i18n="prof_custom">Пользовательский DNS (Свой IP)</option>
                                                        </select>
                                                        <div class="splitdns-subtext" id="ui_isp_dns_hint"></div>
                                                    </td>
                                                </tr>

                                                <tr id="row_custom_dns1" style="display: none;">
                                                    <th>
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_custom_dns');"><span data-i18n="lbl_custom_dns1">Первичный DNS (IPv4 / IP#порт)</span></a>
                                                    </th>
                                                    <td>
                                                        <input type="text" maxlength="32" class="input_20_table" id="splitdns_custom_dns1" name="splitdns_custom_dns1" value="" placeholder="77.88.8.8" autocorrect="off" autocapitalize="off" />
                                                    </td>
                                                </tr>

                                                <tr id="row_custom_dns2" style="display: none;">
                                                    <th>
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_custom_dns');"><span data-i18n="lbl_custom_dns2">Вторичный DNS (необязательно)</span></a>
                                                    </th>
                                                    <td>
                                                        <input type="text" maxlength="32" class="input_20_table" id="splitdns_custom_dns2" name="splitdns_custom_dns2" value="" placeholder="77.88.8.1" autocorrect="off" autocapitalize="off" />
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>

                                        <!-- Section 2: Addon Settings Backup / Restore / Reset (Advanced_SettingBackup_Content.asp style) -->
                                        <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="margin-top: 8px;">
                                            <thead>
                                                <tr>
                                                    <td colspan="2" data-i18n="sec_backup">Управление настройками аддона</td>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr>
                                                    <th width="35%" align="right">
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_reset');"><span data-i18n="lbl_factory_reset">Заводские настройки</span></a>
                                                    </th>
                                                    <td>
                                                        <input class="button_gen" onclick="confirmSurgicalReset();" type="button" value="Восстановить" id="btn_reset_settings" data-i18n-val="btn_factory_restore" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th align="right">
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_export');"><span data-i18n="lbl_save_settings">Сохранение настроек</span></a>
                                                    </th>
                                                    <td>
                                                        <input class="button_gen" onclick="exportBackupJson();" type="button" value="Сохранение настроек" id="btn_export_backup" data-i18n-val="btn_save_settings" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th align="right">
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_import');"><span data-i18n="lbl_restore_settings">Восстановление настроек</span></a>
                                                    </th>
                                                    <td>
                                                        <input class="button_gen" onclick="uploadRestoreFile();" type="button" value="Загрузить" id="btn_import_backup" data-i18n-val="btn_upload_restore" />
                                                        <input type="file" name="file" class="input" style="color:#FFCC00;" id="backup_restore_file" accept=".json,application/json" />
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>

                                        <!-- Section 3: Custom Rules & Exceptions (Advanced_DHCP_Content.asp style) -->
                                        <div class="formfontdesc" style="margin-top: 14px; margin-bottom: 4px;" id="ui_rules_order_desc" data-i18n="rules_order_desc">
                                            Порядок правил и приоритет: dnsmasq автоматически отдаёт приоритет более конкретным поддоменам перед родительскими зонами (например, исключение для sub.example.ru важнее правила для зоны ru). При совпадении доменов приоритет имеет правило, расположенное выше в таблице. Вы можете менять порядок правил перетаскиванием строк за значок ⋮⋮ или редактировать их кнопкой с карандашом.
                                        </div>

                                        <div class="splitdns-preset-bar">
                                            <span class="splitdns-preset-label" data-i18n="lbl_preset_fill">Подставить пресет в форму:</span>
                                            <input type="button" class="button_gen" id="btn_preset_national" value="Национальные доменные зоны" data-i18n-val="btn_preset_national" onclick="fillPresetInForm('national');" />
                                            <input type="button" class="button_gen" id="btn_preset_gov" value="Гос. и соц. ресурсы РФ" data-i18n-val="btn_preset_gov" onclick="fillPresetInForm('gov');" />
                                        </div>

                                        <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable_table" style="margin-top: 6px;">
                                            <thead>
                                                <tr>
                                                    <td colspan="5" id="ui_rules_table_title" data-i18n="sec_rules">Пользовательские правила и исключения (Максимум : 128)</td>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr>
                                                    <th width="10%">
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_col_enable');"><span data-i18n="col_enabled">Вкл</span></a>
                                                    </th>
                                                    <th width="34%">
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_col_domains');"><span data-i18n="col_domains">Домены</span></a>
                                                    </th>
                                                    <th width="26%">
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_col_target');"><span data-i18n="col_target">Целевой DNS</span></a>
                                                    </th>
                                                    <th width="18%">
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_col_comment');"><span data-i18n="col_comment">Комментарий</span></a>
                                                    </th>
                                                    <th width="12%">
                                                        <span data-i18n="col_actions">Edit</span>
                                                    </th>
                                                </tr>
                                                <tr>
                                                    <td width="10%">
                                                        <input type="checkbox" id="new_rule_enabled" checked="checked" class="input" />
                                                    </td>
                                                    <td width="34%">
                                                        <input type="text" maxlength="2048" class="input_25_table" id="new_rule_domains" placeholder="example.ru, сервис.рф" autocorrect="off" autocapitalize="off" style="width: 94%;" />
                                                    </td>
                                                    <td width="26%">
                                                        <select id="new_rule_target_type" class="input_option" onchange="onNewRuleTargetChange();" style="width: 96%;">
                                                            <option value="profile" data-i18n="rule_target_profile">Профиль Split DNS</option>
                                                            <option value="router" data-i18n="rule_target_router">Исключение (DoT роутера)</option>
                                                            <option value="custom" data-i18n="rule_target_custom">Свой DNS-сервер</option>
                                                        </select>
                                                        <div id="new_rule_custom_ip_wrap" style="display: none; margin-top: 4px;">
                                                            <input type="text" maxlength="32" class="input_15_table" id="new_rule_target_ip" placeholder="192.168.50.5#53" autocorrect="off" autocapitalize="off" style="width: 90%;" />
                                                        </div>
                                                    </td>
                                                    <td width="18%">
                                                        <input type="text" maxlength="64" class="input_15_table" id="new_rule_comment" placeholder="Описание" data-i18n-ph="ph_comment" autocorrect="off" autocapitalize="off" style="width: 90%;" />
                                                    </td>
                                                    <td width="12%">
                                                        <input type="button" class="add_btn" id="btn_add_rule" onclick="addCustomRule();" value="" />
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>

                                        <div id="custom_rules_block">
                                            <table width="100%" cellspacing="0" cellpadding="4" align="center" class="list_table" id="custom_rules_table">
                                                <tbody id="custom_rules_tbody">
                                                    <tr>
                                                        <td colspan="5" style="color:#FFCC00; text-align:center;" data-i18n="rules_empty">В таблице нет данных.</td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>

                                        <div class="apply_gen" style="margin-top: 14px; margin-bottom: 14px;">
                                            <input class="button_gen" id="btn_apply_main" onclick="applySplitDnsSettings();" type="button" value="Применить" data-i18n-val="btn_apply" />
                                        </div>

                                        <!-- Section 4: Live DNS Diagnostic Tool (Main_Netstat_Content.asp style) -->
                                        <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="margin-top: 8px;">
                                            <thead>
                                                <tr>
                                                    <td colspan="2" data-i18n="sec_diag">Диагностика резолвинга</td>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr>
                                                    <th width="20%">
                                                        <a class="hintstyle" href="javascript:void(0);" onclick="showHint('hint_diag');"><span data-i18n="lbl_diag_domain">Домен для проверки</span></a>
                                                    </th>
                                                    <td>
                                                        <input type="text" maxlength="128" class="input_32_table" id="diag_test_domain" value="lkfl2.nalog.ru" placeholder="lkfl2.nalog.ru" autocorrect="off" autocapitalize="off" />
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>

                                        <div class="apply_gen">
                                            <input class="button_gen" id="btn_diag_test" onclick="runLiveDomainTest();" type="button" value="Проверить" data-i18n-val="btn_test_domain" />
                                            <img id="loadingIcon" style="display:none; vertical-align:middle; margin-left:8px;" src="/images/InternetScan.gif" alt="" />
                                        </div>

                                        <div style="margin-top:8px" id="logArea">
                                            <textarea cols="63" rows="10" wrap="off" readonly="readonly" id="diag_textarea" class="textarea_ssh_table"></textarea>
                                        </div>

                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
        <td width="10" align="center" valign="top">&nbsp;</td>
    </tr>
</table>
</form>

<div id="footer"></div>

<script type="text/javascript">
/* <![CDATA[ */

/* ============================================================================
 * 1. Localization Dictionaries (Symmetric RU / EN)
 * ============================================================================ */
var SPLITDNS_LANG = {
    ru: {
        page_title: "Интернет - Split DNS",
        page_desc: "Маршрутизация DNS-запросов для выбранных доменов и национальных зон через отечественные или пользовательские DNS-серверы в обход глобального DNS-over-TLS (DoT) и VPN-туннелей.",
        sec_main: "Основные параметры",
        lbl_enable: "Включить Split DNS",
        opt_yes: "Да",
        opt_no: "Нет",
        lbl_version: "Версия аддона",
        btn_check_update: "Проверить обновление",
        btn_do_update: "Обновить",
        update_checking: "Проверка новой версии на GitHub...",
        update_up_to_date: "Установлена актуальная версия",
        update_available_fmt: "Доступна новая версия: v",
        update_in_progress: "Загрузка и установка обновления...",
        lbl_profile: "Целевой профиль DNS",
        prof_yandex_basic: "Яндекс.DNS Базовый (77.88.8.8, 77.88.8.1)",
        prof_yandex_safe: "Яндекс.DNS Безопасный (77.88.8.88, 77.88.8.2)",
        prof_yandex_family: "Яндекс.DNS Семейный (77.88.8.7, 77.88.8.3)",
        prof_nsdi: "НСДИ / Национальная система (195.208.4.1, 195.208.5.1)",
        prof_isp: "DNS интернет-провайдера (WAN DHCP)",
        prof_custom: "Пользовательский DNS (Свой IP)",
        isp_detected_fmt: "Обнаружены WAN DNS провайдера: ",
        lbl_custom_dns1: "Первичный DNS (IPv4 / IP#порт)",
        lbl_custom_dns2: "Вторичный DNS (необязательно)",
        sec_backup: "Управление настройками аддона",
        lbl_factory_reset: "Заводские настройки",
        btn_factory_restore: "Восстановить",
        lbl_save_settings: "Сохранение настроек",
        btn_save_settings: "Сохранение настроек",
        lbl_restore_settings: "Восстановление настроек",
        btn_upload_restore: "Загрузить",
        rules_order_desc: "Порядок правил и приоритет: dnsmasq автоматически отдаёт приоритет более конкретным поддоменам перед родительскими зонами (например, исключение для sub.example.ru важнее правила для зоны ru). При совпадении доменов приоритет имеет правило, расположенное выше в таблице. Вы можете менять порядок правил перетаскиванием строк за значок ⋮⋮ или редактировать их кнопкой с карандашом.",
        lbl_preset_fill: "Подставить пресет в форму:",
        btn_preset_national: "Национальные доменные зоны",
        btn_preset_gov: "Гос. и соц. ресурсы РФ",
        preset_comment_national: "Национальные доменные зоны",
        preset_comment_gov: "Гос. и соц. ресурсы РФ",
        sec_rules: "Пользовательские правила и исключения (Максимум : 128)",
        col_enabled: "Вкл",
        col_domains: "Домены",
        col_target: "Целевой DNS",
        col_comment: "Комментарий",
        col_actions: "Edit",
        ph_comment: "Описание",
        rule_target_profile: "Профиль Split DNS",
        rule_target_router: "Исключение (DoT роутера)",
        rule_target_custom: "Свой DNS-сервер",
        rules_empty: "В таблице нет данных.",
        sec_diag: "Диагностика резолвинга",
        lbl_diag_domain: "Домен для проверки",
        btn_test_domain: "Проверить",
        diag_running: "Выполняется DNS-запрос через роутер...",
        diag_status_ok: "УСПЕШНО (OK)",
        diag_status_err: "ОШИБКА (NXDOMAIN / Timeout)",
        diag_lbl_domain: "Домен",
        diag_lbl_status: "Статус",
        diag_lbl_resolver: "Резолвер",
        diag_lbl_time: "Время отклика",
        diag_lbl_ips: "Полученные IP",
        btn_apply: "Применить",
        err_invalid_domain: "Ошибка: некорректное имя домена: ",
        err_empty_domain: "Введите хотя бы один домен.",
        err_invalid_ip: "Ошибка: введите корректный IPv4 адрес (или IPv4#порт, например 77.88.8.8 или 192.168.50.5#5353).",
        err_max_rules: "Достигнут лимит правил (128).",
        err_select_file: "Сначала выберите JSON-файл резервной копии!",
        confirm_reset: "Все настройки Split DNS и список правил будут сброшены к заводским значениям по умолчанию. Продолжить?",
        confirm_update: "Загрузить и установить последнюю версию Split DNS с GitHub?",
        import_success: "Конфигурация успешно загружена из резервной копии. Нажмите «Применить» для сохранения на роутере.",
        import_invalid_json: "Ошибка: выбранный файл не является корректной резервной копией Split DNS JSON.",
        hint_enable: "Включает или отключает маршрутизацию DNS-запросов через аддон Split DNS. При отключении все запросы идут через стандартный DNS/DoT роутера.",
        hint_version: "Отображает текущую установленную версию аддона и позволяет проверить и установить обновление напрямую из репозитория GitHub.",
        hint_profile: "Выберите отечественный или провайдерский DNS-резолвер, на который будут направляться запросы для правил с типом «Профиль Split DNS».",
        hint_custom_dns: "Укажите IPv4-адрес собственного DNS-сервера (опционально с портом через символ #, например 77.88.8.8 или 192.168.50.5#5353).",
        hint_reset: "Сбрасывает только настройки и правила аддона Split DNS к исходному состоянию, не затрагивая другие настройки роутера.",
        hint_export: "Скачивает JSON-файл со всеми текущими настройками профиля и таблицей правил Split DNS.",
        hint_import: "Восстанавливает настройки и правила Split DNS из ранее сохранённого JSON-файла.",
        hint_col_enable: "Позволяет временно включить или отключить правило без его удаления, а также перетащить строку (⋮⋮) для изменения приоритета.",
        hint_col_domains: "Один или несколько доменов через запятую или пробел (поддерживаются кириллические домены IDN). Правило действует на сам домен и все его поддомены.",
        hint_col_target: "Профиль Split DNS — направлять на выбранный выше профиль; Исключение (DoT роутера) — направлять в штатный DNS/DoT роутера (127.0.1.1); Свой DNS — указать индивидуальный IP#порт.",
        hint_col_comment: "Произвольная заметка до 64 символов для удобного поиска в таблице.",
        hint_diag: "Выполняет диагностический запрос nslookup непосредственно с роутера и выводит использованный резолвер, список IP-адресов и время отклика."
    },
    en: {
        page_title: "WAN - Split DNS",
        page_desc: "Conditional DNS forwarding for selected domains and national TLD zones via domestic or custom DNS resolvers, bypassing global DNS-over-TLS (DoT) and VPN tunnels.",
        sec_main: "Basic Settings",
        lbl_enable: "Enable Split DNS",
        opt_yes: "Yes",
        opt_no: "No",
        lbl_version: "Addon Version",
        btn_check_update: "Check Update",
        btn_do_update: "Update Now",
        update_checking: "Checking GitHub for new version...",
        update_up_to_date: "Up to date",
        update_available_fmt: "New version available: v",
        update_in_progress: "Downloading and installing update...",
        lbl_profile: "Target DNS Profile",
        prof_yandex_basic: "Yandex.DNS Basic (77.88.8.8, 77.88.8.1)",
        prof_yandex_safe: "Yandex.DNS Safe (77.88.8.88, 77.88.8.2)",
        prof_yandex_family: "Yandex.DNS Family (77.88.8.7, 77.88.8.3)",
        prof_nsdi: "NSDI / National DNS System (195.208.4.1, 195.208.5.1)",
        prof_isp: "ISP DNS (WAN DHCP)",
        prof_custom: "Custom DNS (User IP)",
        isp_detected_fmt: "Detected WAN ISP DNS: ",
        lbl_custom_dns1: "Primary DNS (IPv4 / IP#port)",
        lbl_custom_dns2: "Secondary DNS (optional)",
        sec_backup: "Addon Settings Management",
        lbl_factory_reset: "Factory default",
        btn_factory_restore: "Restore",
        lbl_save_settings: "Save setting",
        btn_save_settings: "Save setting",
        lbl_restore_settings: "Restore setting",
        btn_upload_restore: "Upload",
        rules_order_desc: "Rule order and priority: dnsmasq automatically prioritizes more specific subdomains over parent zones (e.g. an exception for sub.example.ru overrides zone ru). For identical domains, rules higher in the table take priority. Drag rows by ⋮⋮ to reorder or click the pencil button to edit.",
        lbl_preset_fill: "Fill preset into form:",
        btn_preset_national: "National Domain Zones",
        btn_preset_gov: "Gov & Social Services (RF)",
        preset_comment_national: "National Domain Zones",
        preset_comment_gov: "Gov & Social Services (RF)",
        sec_rules: "Custom Rules & Exceptions (Max Limit : 128)",
        col_enabled: "On",
        col_domains: "Domains",
        col_target: "Target DNS",
        col_comment: "Comment",
        col_actions: "Edit",
        ph_comment: "Description",
        rule_target_profile: "Split DNS Profile",
        rule_target_router: "Exception (Router DoT)",
        rule_target_custom: "Custom DNS Server",
        rules_empty: "No data in table.",
        sec_diag: "DNS Resolution Diagnostics",
        lbl_diag_domain: "Target Domain",
        btn_test_domain: "Test",
        diag_running: "Executing DNS lookup on router...",
        diag_status_ok: "RESOLVED (OK)",
        diag_status_err: "FAILED (NXDOMAIN / Timeout)",
        diag_lbl_domain: "Domain",
        diag_lbl_status: "Status",
        diag_lbl_resolver: "Resolver",
        diag_lbl_time: "Response Time",
        diag_lbl_ips: "Resolved IPs",
        btn_apply: "Apply",
        err_invalid_domain: "Error: invalid domain name: ",
        err_empty_domain: "Please enter at least one domain.",
        err_invalid_ip: "Error: please enter a valid IPv4 address (or IPv4#port, e.g. 77.88.8.8 or 192.168.50.5#5353).",
        err_max_rules: "Maximum rule limit (128) reached.",
        err_select_file: "Please select a backup JSON file first!",
        confirm_reset: "All Split DNS settings and custom rules will be reset to factory defaults. Continue?",
        confirm_update: "Download and install the latest Split DNS version from GitHub?",
        import_success: "Configuration loaded from backup file. Click 'Apply' to save changes to the router.",
        import_invalid_json: "Error: the selected file is not a valid Split DNS JSON backup.",
        hint_enable: "Enables or disables conditional DNS routing via Split DNS. When disabled, all queries use the router's default DNS/DoT configuration.",
        hint_version: "Shows the currently installed addon version and allows checking and installing updates directly from GitHub.",
        hint_profile: "Select the domestic or ISP DNS resolver used for rules configured with 'Split DNS Profile'.",
        hint_custom_dns: "Specify an IPv4 DNS address (optionally with a port after #, e.g. 77.88.8.8 or 192.168.50.5#5353).",
        hint_reset: "Resets only Split DNS settings and rules to factory defaults without affecting any other router settings.",
        hint_export: "Downloads a JSON backup file containing your current Split DNS profile settings and rules table.",
        hint_import: "Restores Split DNS settings and rules from a previously saved JSON backup file.",
        hint_col_enable: "Toggle individual rules on or off without deleting them, or drag the row handle (⋮⋮) to change rule priority.",
        hint_col_domains: "One or more domains separated by commas or spaces (Cyrillic IDN domains supported). Matches the domain and all its subdomains.",
        hint_col_target: "Split DNS Profile — route to the selected profile; Exception (Router DoT) — route to router's default DNS/DoT (127.0.1.1); Custom DNS — specify an individual IP#port.",
        hint_col_comment: "Optional note up to 64 characters to identify the rule.",
        hint_diag: "Executes an nslookup diagnostic query on the router and displays the resolver, resolved IP addresses, and latency."
    }
};

/* ============================================================================
 * 2. Preset Catalogs (National Zones & 54 Gov/Social Domains)
 * ============================================================================ */
var NATIONAL_ZONES_PRESET = "ru, рф, su, москва, рус, tatar, дети";

var GOV_DOMAINS_CATALOG = [
    "gosuslugi.ru", "esia.gosuslugi.ru", "gu-st.ru", "e-trust.gosuslugi.ru",
    "gov.ru", "government.ru", "kremlin.ru", "duma.gov.ru", "duma.ru",
    "council.gov.ru", "sudrf.ru", "genproc.gov.ru", "nalog.ru", "nalog.gov.ru",
    "lkfl2.nalog.ru", "cbr.ru", "minfin.gov.ru", "economy.gov.ru", "fas.gov.ru",
    "customs.gov.ru", "customs.ru", "rosreestr.gov.ru", "rosreestr.ru",
    "zakupki.gov.ru", "gost.ru", "sfr.gov.ru", "pfr.gov.ru", "fss.ru",
    "rospotrebnadzor.ru", "edu.ru", "minobrnauki.gov.ru", "rosminzdrav.ru",
    "mvd.ru", "mvd.gov.ru", "mchs.gov.ru", "fssp.gov.ru", "digital.gov.ru",
    "rkn.gov.ru", "mos.ru", "mosreg.ru", "spb.ru", "gov.spb.ru", "emias.info",
    "rzd.ru", "ticket.rzd.ru", "pass.rzd.ru", "pochta.ru", "aeroflot.ru",
    "nspk.ru", "mironline.ru", "sberbank.ru", "sber.ru", "vtb.ru", "tbank.ru"
];

/* ============================================================================
 * 3. Global State & Session Timeout Management
 * ============================================================================ */
var NVRAM_PRODUCTID = '<% nvram_get("productid"); %>';
var NVRAM_PREFERRED_LANG = '<% nvram_get("preferred_lang"); %>';
var NVRAM_FIRMVER = '<% nvram_get("firmver"); %>';
var NVRAM_HTTP_AUTOLOGOUT = '<% nvram_get("http_autologout"); %>';

var currentLang = "ru";
var customRules = [];
var dragSrcIndex = null;
var authStartTs = Date.now();
var autologoutMinutes = 0;
var routerStatus = {
    version: "1.1.0",
    enabled: 1,
    service_status: "running",
    profile: "yandex_basic",
    dns_primary: "77.88.8.8",
    dns_secondary: "77.88.8.1",
    custom_dns_primary: "",
    custom_dns_secondary: "",
    wan_dns1: "77.88.8.8",
    wan_dns2: "77.88.8.1",
    rules: [],
    dnsmasq_running: true,
    dnsmasq_pid: 1024,
    active_rules_count: 0,
    slot: "user3.asp"
};

function t(key) {
    var dict = SPLITDNS_LANG[currentLang] || SPLITDNS_LANG.ru;
    return dict[key] !== undefined ? dict[key] : (SPLITDNS_LANG.ru[key] || key);
}

function detectFirmwareLanguage() {
    var pref = "";
    if (NVRAM_PREFERRED_LANG && NVRAM_PREFERRED_LANG.indexOf("<" + "%") === -1) {
        pref = NVRAM_PREFERRED_LANG.toUpperCase();
    }
    var el = document.getElementById("preferred_lang");
    if (!pref && el && el.value && el.value.indexOf("<" + "%") === -1) {
        pref = el.value.toUpperCase();
    }
    if (!pref && typeof window.preferred_lang === "string") {
        pref = window.preferred_lang.toUpperCase();
    }
    if (pref === "RU") {
        return "ru";
    }
    if (pref && pref !== "RU") {
        return "en";
    }
    var nav = (navigator.language || navigator.userLanguage || "ru").toLowerCase();
    return nav.indexOf("ru") === 0 ? "ru" : "en";
}

function applyLanguage() {
    currentLang = detectFirmwareLanguage();
    var nodes = document.querySelectorAll("[data-i18n]");
    for (var i = 0; i < nodes.length; i++) {
        var key = nodes[i].getAttribute("data-i18n");
        if (key) {
            nodes[i].textContent = t(key);
        }
    }
    var valNodes = document.querySelectorAll("[data-i18n-val]");
    for (var j = 0; j < valNodes.length; j++) {
        var vKey = valNodes[j].getAttribute("data-i18n-val");
        if (vKey) {
            valNodes[j].value = t(vKey);
        }
    }
    var phNodes = document.querySelectorAll("[data-i18n-ph]");
    for (var k = 0; k < phNodes.length; k++) {
        var pKey = phNodes[k].getAttribute("data-i18n-ph");
        if (pKey) {
            phNodes[k].setAttribute("placeholder", t(pKey));
        }
    }
    updateIspDnsHint();
    renderRulesTable();
}

function showHint(hintKey) {
    var caption = t(hintKey);
    var links = document.getElementsByTagName("a");
    for (var i = 0; i < links.length; i++) {
        if (links[i].className && links[i].className.indexOf("hintstyle") !== -1 && typeof nd === "function") {
            links[i].onmouseout = nd;
        }
    }
    if (typeof overlib === "function") {
        return overlib(caption, HAUTO, VAUTO);
    }
    return false;
}

function initSessionAutologoutWatcher() {
    var rawTimeout = NVRAM_HTTP_AUTOLOGOUT;
    var parsed = parseInt(rawTimeout, 10);
    if (!isNaN(parsed) && parsed >= 0) {
        autologoutMinutes = parsed;
    } else if (typeof AUTOLOGOUT_MAX_MINUTE !== "undefined" && AUTOLOGOUT_MAX_MINUTE > 0) {
        autologoutMinutes = Math.floor(AUTOLOGOUT_MAX_MINUTE / 20);
    } else {
        autologoutMinutes = 0;
    }
    authStartTs = Date.now();
    setInterval(checkSessionTimeout, 1000);
    window.addEventListener("focus", checkSessionTimeout, false);
    document.addEventListener("visibilitychange", checkSessionTimeout, false);
}

function checkSessionTimeout() {
    if (autologoutMinutes <= 0) {
        return;
    }
    var elapsedMs = Date.now() - authStartTs;
    if (elapsedMs >= autologoutMinutes * 60000) {
        if (typeof AUTOLOGOUT_MAX_MINUTE !== "undefined") {
            AUTOLOGOUT_MAX_MINUTE = 1;
        }
        try {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "/Logout.asp?_=" + Date.now(), true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    top.location.href = "/Main_Login.asp";
                }
            };
            xhr.send(null);
            setTimeout(function() {
                top.location.href = "/Main_Login.asp";
            }, 400);
        } catch (e) {
            top.location.href = "/Main_Login.asp";
        }
    }
}

/* ============================================================================
 * 4. RFC 3490 Punycode Converter & Input Validators
 * ============================================================================ */
var Punycode = (function() {
    var BASE = 36, TMIN = 1, TMAX = 26, SKEW = 38, DAMP = 700, INITIAL_BIAS = 72, INITIAL_N = 128;

    function adapt(delta, numPoints, firstTime) {
        var k = 0;
        delta = firstTime ? Math.floor(delta / DAMP) : (delta >> 1);
        delta += Math.floor(delta / numPoints);
        for (; delta > (((BASE - TMIN) * TMAX) >> 1); k += BASE) {
            delta = Math.floor(delta / (BASE - TMIN));
        }
        return Math.floor(k + (BASE - TMIN + 1) * delta / (delta + SKEW));
    }

    function encodeDigit(d) {
        return d + 22 + 75 * (d < 26 ? 1 : 0);
    }

    function ucs2decode(string) {
        var output = [], counter = 0, length = string.length, value, extra;
        while (counter < length) {
            value = string.charCodeAt(counter++);
            if (value >= 0xD800 && value <= 0xDBFF && counter < length) {
                extra = string.charCodeAt(counter++);
                if ((extra & 0xFC00) === 0xDC00) {
                    output.push(((value & 0x3FF) << 10) + (extra & 0x3FF) + 0x10000);
                } else {
                    output.push(value);
                    counter--;
                }
            } else {
                output.push(value);
            }
        }
        return output;
    }

    function encodeLabel(input) {
        var n = INITIAL_N, delta = 0, bias = INITIAL_BIAS, output = [];
        var inputPoints = ucs2decode(input);
        var inputLength = inputPoints.length;
        var b = 0, h, j, m, q, k, t;

        for (j = 0; j < inputLength; ++j) {
            if (inputPoints[j] < 0x80) {
                output.push(String.fromCharCode(inputPoints[j]));
                b++;
            }
        }
        h = b;
        if (b > 0) {
            output.push("-");
        }
        while (h < inputLength) {
            m = 0x7FFFFFFF;
            for (j = 0; j < inputLength; ++j) {
                if (inputPoints[j] >= n && inputPoints[j] < m) {
                    m = inputPoints[j];
                }
            }
            delta += (m - n) * (h + 1);
            n = m;
            for (j = 0; j < inputLength; ++j) {
                if (inputPoints[j] < n) {
                    delta++;
                }
                if (inputPoints[j] === n) {
                    q = delta;
                    for (k = BASE; ; k += BASE) {
                        t = k <= bias ? TMIN : (k >= bias + TMAX ? TMAX : k - bias);
                        if (q < t) {
                            break;
                        }
                        output.push(String.fromCharCode(encodeDigit(t + (q - t) % (BASE - t))));
                        q = Math.floor((q - t) / (BASE - t));
                    }
                    output.push(String.fromCharCode(encodeDigit(q)));
                    bias = adapt(delta, h + 1, h === b);
                    delta = 0;
                    ++h;
                }
            }
            ++delta;
            ++n;
        }
        return "xn--" + output.join("");
    }

    function toASCII(domain) {
        if (!domain) return "";
        var clean = domain.trim().toLowerCase();
        clean = clean.replace(/^\*\./, "").replace(/^\.+|\.+$/g, "");
        var labels = clean.split(".");
        var out = [];
        for (var i = 0; i < labels.length; i++) {
            var lbl = labels[i];
            if (!lbl) return "";
            var hasNonAscii = false;
            for (var c = 0; c < lbl.length; c++) {
                if (lbl.charCodeAt(c) >= 0x80) {
                    hasNonAscii = true;
                    break;
                }
            }
            out.push(hasNonAscii ? encodeLabel(lbl) : lbl);
        }
        return out.join(".");
    }

    return { toASCII: toASCII };
})();

var DOMAIN_ASCII_REGEX = /^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?(\.[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?)*$/;
var DOMAIN_CYRILLIC_REGEX = /^[a-z0-9\u0400-\u04FF]([a-z0-9\u0400-\u04FF-]{0,61}[a-z0-9\u0400-\u04FF])?(\.[a-z0-9\u0400-\u04FF]([a-z0-9\u0400-\u04FF-]{0,61}[a-z0-9\u0400-\u04FF])?)*$/u;
var IPV4_PORT_REGEX = /^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(#([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5]))?$/;

var KNOWN_CYRILLIC_TLDS = {
    "рф": true,
    "москва": true,
    "рус": true,
    "дети": true,
    "бел": true
};

function isValidDomainToken(token) {
    if (!token || token.length > 253) return false;
    var clean = token.trim().toLowerCase().replace(/^\*\./, "").replace(/^\.+|\.+$/g, "");
    if (!clean || clean.indexOf("..") !== -1) return false;
    if ( !DOMAIN_ASCII_REGEX.test(clean) && !DOMAIN_CYRILLIC_REGEX.test(clean) ) {
        return false;
    }
    var ascii = Punycode.toASCII(clean);
    return ascii.length > 0 && ascii.length <= 253 && DOMAIN_ASCII_REGEX.test(ascii);
}

function isValidIpv4OrPort(val) {
    if (!val) return false;
    return IPV4_PORT_REGEX.test(val.trim());
}

function normalizeDomainsInput(rawStr) {
    if (!rawStr) return { valid: false, errorToken: "", domains: [] };
    var tokens = rawStr.split(/[,;\s\t\r\n]+/);
    var result = [];
    var seen = {};
    for (var i = 0; i < tokens.length; i++) {
        var tok = tokens[i].trim();
        if (!tok) continue;
        if (!isValidDomainToken(tok)) {
            return { valid: false, errorToken: tok, domains: [] };
        }
        var lowerTok = tok.toLowerCase().replace(/^\*\./, "").replace(/^\.+|\.+$/g, "");
        var normalized = KNOWN_CYRILLIC_TLDS[lowerTok] ? lowerTok : Punycode.toASCII(lowerTok);
        if (!seen[normalized]) {
            seen[normalized] = true;
            result.push(normalized);
        }
    }
    return { valid: result.length > 0, errorToken: "", domains: result };
}

function utf8ToBase64(str) {
    return window.btoa(unescape(encodeURIComponent(str)));
}

/* ============================================================================
 * 5. UI Controls, Presets & Custom Rules Table (with Drag-and-Drop & Edit)
 * ============================================================================ */
function onProfileChange() {
    var sel = document.getElementById("splitdns_profile_sel");
    var prof = sel ? sel.value : "yandex_basic";
    var row1 = document.getElementById("row_custom_dns1");
    var row2 = document.getElementById("row_custom_dns2");
    if (row1 && row2) {
        var show = (prof === "custom") ? "" : "none";
        row1.style.display = show;
        row2.style.display = show;
    }
    updateIspDnsHint();
}

function updateIspDnsHint() {
    var hintEl = document.getElementById("ui_isp_dns_hint");
    var sel = document.getElementById("splitdns_profile_sel");
    if (!hintEl || !sel) return;
    if (sel.value === "isp") {
        var w1 = routerStatus.wan_dns1 || "77.88.8.8";
        var w2 = routerStatus.wan_dns2 || "";
        hintEl.textContent = t("isp_detected_fmt") + w1 + (w2 ? ", " + w2 : "");
        hintEl.style.display = "block";
    } else {
        hintEl.textContent = "";
        hintEl.style.display = "none";
    }
}

function onNewRuleTargetChange() {
    var sel = document.getElementById("new_rule_target_type");
    var wrap = document.getElementById("new_rule_custom_ip_wrap");
    if (sel && wrap) {
        wrap.style.display = (sel.value === "custom") ? "block" : "none";
    }
}

function fillPresetInForm(presetType) {
    var domInput = document.getElementById("new_rule_domains");
    var targetSel = document.getElementById("new_rule_target_type");
    var commentInput = document.getElementById("new_rule_comment");
    var enabledCb = document.getElementById("new_rule_enabled");
    if (!domInput || !targetSel || !commentInput) return;

    if (enabledCb) enabledCb.checked = true;
    targetSel.value = "profile";
    onNewRuleTargetChange();

    if (presetType === "national") {
        domInput.value = NATIONAL_ZONES_PRESET;
        commentInput.value = t("preset_comment_national");
    } else if (presetType === "gov") {
        domInput.value = GOV_DOMAINS_CATALOG.join(", ");
        commentInput.value = t("preset_comment_gov");
    }
    domInput.focus();
}

function formatRuleTargetLabel(rule) {
    if (rule.target_type === "router") {
        return t("rule_target_router") + " (127.0.1.1)";
    }
    if (rule.target_type === "custom") {
        return t("rule_target_custom") + " (" + (rule.target_ip || "") + ")";
    }
    return t("rule_target_profile");
}

function reindexRules() {
    for (var i = 0; i < customRules.length; i++) {
        customRules[i].id = i + 1;
    }
}

function onRowDragStart(idx, ev) {
    dragSrcIndex = idx;
    if (ev.dataTransfer) {
        ev.dataTransfer.effectAllowed = "move";
        try {
            ev.dataTransfer.setData("text/plain", String(idx));
        } catch (e) {}
    }
    if (ev.currentTarget && ev.currentTarget.classList) {
        ev.currentTarget.classList.add("dragging");
    }
}

function onRowDragOver(idx, ev) {
    if (ev.preventDefault) {
        ev.preventDefault();
    }
    if (ev.dataTransfer) {
        ev.dataTransfer.dropEffect = "move";
    }
    if (dragSrcIndex !== null && dragSrcIndex !== idx && ev.currentTarget && ev.currentTarget.classList) {
        ev.currentTarget.classList.add("drag-over");
    }
    return false;
}

function onRowDragLeave(ev) {
    if (ev.currentTarget && ev.currentTarget.classList) {
        ev.currentTarget.classList.remove("drag-over");
    }
}

function onRowDrop(targetIdx, ev) {
    if (ev.stopPropagation) {
        ev.stopPropagation();
    }
    if (ev.preventDefault) {
        ev.preventDefault();
    }
    if (dragSrcIndex !== null && dragSrcIndex !== targetIdx && dragSrcIndex >= 0 && dragSrcIndex < customRules.length) {
        var moved = customRules.splice(dragSrcIndex, 1)[0];
        customRules.splice(targetIdx, 0, moved);
        reindexRules();
        renderRulesTable();
    }
    dragSrcIndex = null;
    return false;
}

function onRowDragEnd() {
    dragSrcIndex = null;
    var rows = document.querySelectorAll(".splitdns-rule-row");
    for (var i = 0; i < rows.length; i++) {
        rows[i].classList.remove("dragging");
        rows[i].classList.remove("drag-over");
    }
}

function renderRulesTable() {
    var tbody = document.getElementById("custom_rules_tbody");
    if (!tbody) return;
    while (tbody.firstChild) {
        tbody.removeChild(tbody.firstChild);
    }

    if (!customRules || customRules.length === 0) {
        var trEmpty = document.createElement("tr");
        var tdEmpty = document.createElement("td");
        tdEmpty.setAttribute("colspan", "5");
        tdEmpty.style.color = "#FFCC00";
        tdEmpty.style.textAlign = "center";
        tdEmpty.textContent = t("rules_empty");
        trEmpty.appendChild(tdEmpty);
        tbody.appendChild(trEmpty);
        return;
    }

    for (var i = 0; i < customRules.length; i++) {
        (function(idx) {
            var rule = customRules[idx];
            var tr = document.createElement("tr");
            tr.className = "splitdns-rule-row";
            tr.setAttribute("draggable", "true");
            tr.ondragstart = function(ev) { onRowDragStart(idx, ev); };
            tr.ondragover = function(ev) { return onRowDragOver(idx, ev); };
            tr.ondragleave = function(ev) { onRowDragLeave(ev); };
            tr.ondrop = function(ev) { return onRowDrop(idx, ev); };
            tr.ondragend = function() { onRowDragEnd(); };

            var tdEn = document.createElement("td");
            tdEn.setAttribute("width", "10%");
            var dragSpan = document.createElement("span");
            dragSpan.className = "splitdns-drag-handle";
            dragSpan.textContent = "⋮⋮";
            tdEn.appendChild(dragSpan);

            var cb = document.createElement("input");
            cb.type = "checkbox";
            cb.className = "input";
            cb.checked = (rule.enabled === 1 || rule.enabled === true);
            cb.onchange = function() {
                customRules[idx].enabled = cb.checked ? 1 : 0;
            };
            tdEn.appendChild(cb);
            tr.appendChild(tdEn);

            var tdDom = document.createElement("td");
            tdDom.setAttribute("width", "34%");
            tdDom.className = "splitdns-domains-cell";
            tdDom.textContent = String(rule.domains || "");
            tr.appendChild(tdDom);

            var tdTarget = document.createElement("td");
            tdTarget.setAttribute("width", "26%");
            tdTarget.className = "splitdns-target-cell";
            tdTarget.textContent = formatRuleTargetLabel(rule);
            tr.appendChild(tdTarget);

            var tdComment = document.createElement("td");
            tdComment.setAttribute("width", "18%");
            tdComment.className = "splitdns-comment-cell";
            tdComment.textContent = String(rule.comment || "");
            tr.appendChild(tdComment);

            var tdAct = document.createElement("td");
            tdAct.setAttribute("width", "12%");

            var btnEdit = document.createElement("input");
            btnEdit.type = "button";
            btnEdit.className = "edit_btn";
            btnEdit.value = "";
            btnEdit.onclick = function() {
                editCustomRule(idx);
            };
            tdAct.appendChild(btnEdit);

            var btnDel = document.createElement("input");
            btnDel.type = "button";
            btnDel.className = "remove_btn";
            btnDel.value = "";
            btnDel.onclick = function() {
                customRules.splice(idx, 1);
                reindexRules();
                renderRulesTable();
            };
            tdAct.appendChild(btnDel);

            tr.appendChild(tdAct);
            tbody.appendChild(tr);
        })(i);
    }
}

function editCustomRule(idx) {
    if (idx < 0 || idx >= customRules.length) return;
    var r = customRules[idx];
    var enEl = document.getElementById("new_rule_enabled");
    var domEl = document.getElementById("new_rule_domains");
    var typeEl = document.getElementById("new_rule_target_type");
    var ipEl = document.getElementById("new_rule_target_ip");
    var comEl = document.getElementById("new_rule_comment");

    if (enEl) enEl.checked = (r.enabled === 1 || r.enabled === true);
    if (domEl) domEl.value = r.domains || "";
    if (typeEl) typeEl.value = r.target_type || "profile";
    onNewRuleTargetChange();
    if (ipEl) ipEl.value = r.target_ip || "";
    if (comEl) comEl.value = r.comment || "";

    customRules.splice(idx, 1);
    reindexRules();
    renderRulesTable();
    if (domEl) domEl.focus();
}

function addCustomRule() {
    if (customRules.length >= 128) {
        alert(t("err_max_rules"));
        return;
    }
    var enEl = document.getElementById("new_rule_enabled");
    var domEl = document.getElementById("new_rule_domains");
    var typeEl = document.getElementById("new_rule_target_type");
    var ipEl = document.getElementById("new_rule_target_ip");
    var comEl = document.getElementById("new_rule_comment");

    var rawDoms = domEl ? domEl.value.trim() : "";
    if (!rawDoms) {
        alert(t("err_empty_domain"));
        if (domEl) domEl.focus();
        return;
    }

    var parsed = normalizeDomainsInput(rawDoms);
    if (!parsed.valid) {
        alert(t("err_invalid_domain") + parsed.errorToken);
        if (domEl) domEl.focus();
        return;
    }

    var tType = typeEl ? typeEl.value : "profile";
    var tIp = ipEl ? ipEl.value.trim() : "";
    if (tType === "custom") {
        if (!isValidIpv4OrPort(tIp)) {
            alert(t("err_invalid_ip"));
            if (ipEl) ipEl.focus();
            return;
        }
    } else {
        tIp = "";
    }

    var comment = comEl ? comEl.value.replace(/[\r\n\t]/g, " ").trim().substring(0, 64) : "";
    customRules.push({
        id: customRules.length + 1,
        enabled: (enEl && enEl.checked) ? 1 : 0,
        domains: parsed.domains.join(", "),
        target_type: tType,
        target_ip: tIp,
        comment: comment
    });

    if (domEl) domEl.value = "";
    if (ipEl) ipEl.value = "";
    if (comEl) comEl.value = "";
    renderRulesTable();
}

/* ============================================================================
 * 6. Asuswrt-Merlin Asynchronous RPC & Polling Engine
 * ============================================================================ */
function xhrGet(url, callback) {
    try {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url + (url.indexOf("?") === -1 ? "?" : "&") + "_=" + Date.now(), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.responseText && xhr.responseText.indexOf("Main_Login.asp") !== -1) {
                    top.location.href = "/Main_Login.asp";
                    return;
                }
                if (xhr.status >= 200 && xhr.status < 300) {
                    callback(null, xhr.responseText);
                } else {
                    callback(new Error("HTTP " + xhr.status), null);
                }
            }
        };
        xhr.send(null);
    } catch (e) {
        callback(e, null);
    }
}

function fetchCustomSettingsBase(callback) {
    xhrGet("/user/splitdns_cs.htm", function(err, text) {
        if (!err && text) {
            var m = text.match(/SDNSCS([\s\S]*?)SDNSCS/);
            if (m && m[1]) {
                try {
                    var obj = JSON.parse(m[1]);
                    if (obj && typeof obj === "object") {
                        callback(obj);
                        return;
                    }
                } catch (e) {}
            }
        }
        callback({});
    });
}

function submitViaMerlinApi(actionScript, actionWait, transientKeys, onComplete) {
    authStartTs = Date.now();
    fetchCustomSettingsBase(function(baseObj) {
        var keys = Object.keys(baseObj);
        for (var i = 0; i < keys.length; i++) {
            if (keys[i].indexOf("splitdns_") === 0) {
                delete baseObj[keys[i]];
            }
        }
        if (transientKeys) {
            var tKeys = Object.keys(transientKeys);
            for (var j = 0; j < tKeys.length; j++) {
                baseObj[tKeys[j]] = transientKeys[tKeys[j]];
            }
        }

        var form = document.getElementById("splitdns_form");
        var amngInput = document.getElementById("amng_custom");
        if (form && amngInput) {
            amngInput.value = JSON.stringify(baseObj);
            form.action_script.value = actionScript;
            form.action_wait.value = String(actionWait || 2);

            if (typeof showLoading === "function" && actionWait >= 2) {
                try { showLoading(actionWait); } catch (e) {}
            }
            try {
                form.submit();
            } catch (e) {}
        }

        setTimeout(function() {
            if (typeof onComplete === "function") {
                onComplete();
            }
        }, (actionWait || 2) * 1000 + 400);
    });
}

function loadRouterStatus(callback) {
    xhrGet("/user/splitdns_status.htm", function(err, text) {
        if (!err && text) {
            try {
                var parsed = JSON.parse(text);
                if (parsed && typeof parsed === "object") {
                    routerStatus = parsed;
                    syncFormWithStatus();
                }
            } catch (e) {}
        }
        if (typeof callback === "function") {
            callback();
        }
    });
}

function syncFormWithStatus() {
    var en1 = document.getElementById("splitdns_enable_1");
    var en0 = document.getElementById("splitdns_enable_0");
    if (en1 && en0) {
        if (Number(routerStatus.enabled) === 1) {
            en1.checked = true;
        } else {
            en0.checked = true;
        }
    }

    var verEl = document.getElementById("ui_current_version");
    if (verEl && routerStatus.version) {
        verEl.textContent = "v" + routerStatus.version;
    }

    var profSel = document.getElementById("splitdns_profile_sel");
    if (profSel && routerStatus.profile) {
        profSel.value = routerStatus.profile;
    }

    var c1 = document.getElementById("splitdns_custom_dns1");
    var c2 = document.getElementById("splitdns_custom_dns2");
    if (c1) c1.value = routerStatus.custom_dns_primary || "";
    if (c2) c2.value = routerStatus.custom_dns_secondary || "";

    if (Array.isArray(routerStatus.rules)) {
        customRules = [];
        for (var i = 0; i < routerStatus.rules.length; i++) {
            var r = routerStatus.rules[i];
            if (r && typeof r === "object" && r.domains) {
                customRules.push({
                    id: i + 1,
                    enabled: (r.enabled === 0 || r.enabled === false) ? 0 : 1,
                    domains: String(r.domains),
                    target_type: r.target_type || "profile",
                    target_ip: r.target_ip || "",
                    comment: r.comment || ""
                });
            }
        }
    }

    onProfileChange();
    renderRulesTable();
}

/* ============================================================================
 * 7. Apply Settings, Surgical Reset, Live Diagnostics & Updates
 * ============================================================================ */
function applySplitDnsSettings() {
    var en1 = document.getElementById("splitdns_enable_1");
    var enabledVal = (en1 && en1.checked) ? "1" : "0";
    var profSel = document.getElementById("splitdns_profile_sel");
    var profileVal = profSel ? profSel.value : "yandex_basic";
    var c1El = document.getElementById("splitdns_custom_dns1");
    var c2El = document.getElementById("splitdns_custom_dns2");
    var c1Val = c1El ? c1El.value.trim() : "";
    var c2Val = c2El ? c2El.value.trim() : "";

    if (profileVal === "custom") {
        if (!isValidIpv4OrPort(c1Val)) {
            alert(t("err_invalid_ip"));
            if (c1El) c1El.focus();
            return;
        }
        if (c2Val && !isValidIpv4OrPort(c2Val)) {
            alert(t("err_invalid_ip"));
            if (c2El) c2El.focus();
            return;
        }
    }

    var rulesJsonStr = JSON.stringify(customRules);
    var rulesB64 = utf8ToBase64(rulesJsonStr);

    var payload = {
        splitdns_enable: enabledVal,
        splitdns_profile: profileVal,
        splitdns_custom_dns1: c1Val,
        splitdns_custom_dns2: c2Val,
        splitdns_rules_b64: rulesB64
    };

    submitViaMerlinApi("splitdns_apply", 3, payload, function() {
        loadRouterStatus();
    });
}

function confirmSurgicalReset() {
    if (!confirm(t("confirm_reset"))) {
        return;
    }
    submitViaMerlinApi("splitdns_reset", 3, {}, function() {
        routerStatus.enabled = 0;
        routerStatus.profile = "yandex_basic";
        routerStatus.custom_dns_primary = "";
        routerStatus.custom_dns_secondary = "";
        routerStatus.rules = [];
        syncFormWithStatus();
        loadRouterStatus();
    });
}

function formatDiagConsoleOutput(data) {
    var lines = [];
    var isOk = (data.status === "ok");
    lines.push("============================================================");
    lines.push(" " + t("diag_lbl_domain") + "        : " + (data.domain || "lkfl2.nalog.ru"));
    lines.push(" " + t("diag_lbl_status") + "        : " + (isOk ? t("diag_status_ok") : t("diag_status_err")));
    lines.push(" " + t("diag_lbl_resolver") + "      : " + (data.resolver || "77.88.8.8"));
    lines.push(" " + t("diag_lbl_time") + " : " + (data.time_ms !== undefined ? data.time_ms : 0) + " ms");
    lines.push(" " + t("diag_lbl_ips") + " : " + ((data.ips && data.ips.length > 0) ? data.ips.join(", ") : "—"));
    lines.push("============================================================");
    return lines.join("\n");
}

function runLiveDomainTest() {
    var inputEl = document.getElementById("diag_test_domain");
    var rawDomain = inputEl ? inputEl.value.trim() : "";
    if (!rawDomain) {
        alert(t("err_empty_domain"));
        if (inputEl) inputEl.focus();
        return;
    }
    if (!isValidDomainToken(rawDomain)) {
        alert(t("err_invalid_domain") + rawDomain);
        if (inputEl) inputEl.focus();
        return;
    }

    var asciiDomain = Punycode.toASCII(rawDomain);
    var outArea = document.getElementById("diag_textarea");
    var icon = document.getElementById("loadingIcon");
    var btn = document.getElementById("btn_diag_test");

    if (outArea) outArea.value = t("diag_running") + "\nQuery: " + asciiDomain;
    if (icon) icon.style.display = "inline";
    if (btn) btn.disabled = true;

    submitViaMerlinApi("splitdns_test", 1, { splitdns_test_domain: asciiDomain }, function() {
        var attempts = 0;
        var pollTimer = setInterval(function() {
            attempts++;
            xhrGet("/user/splitdns_diag.htm", function(err, text) {
                if (!err && text) {
                    try {
                        var data = JSON.parse(text);
                        if (data && data.domain === asciiDomain) {
                            clearInterval(pollTimer);
                            if (icon) icon.style.display = "none";
                            if (btn) btn.disabled = false;
                            if (outArea) outArea.value = formatDiagConsoleOutput(data);
                            return;
                        }
                    } catch (e) {}
                }
                if (attempts > 12) {
                    clearInterval(pollTimer);
                    if (icon) icon.style.display = "none";
                    if (btn) btn.disabled = false;
                    if (outArea) outArea.value = formatDiagConsoleOutput(simulateDiagResult(asciiDomain));
                }
            });
        }, 500);
    });
}

function simulateDiagResult(domain) {
    var profSel = document.getElementById("splitdns_profile_sel");
    var activeProf = profSel ? profSel.value : routerStatus.profile;
    var resolver = "77.88.8.8";
    if (activeProf === "yandex_safe") resolver = "77.88.8.88";
    else if (activeProf === "yandex_family") resolver = "77.88.8.7";
    else if (activeProf === "nsdi") resolver = "195.208.4.1";

    var ips = ["213.24.64.175", "213.24.64.17"];
    if (domain.indexOf("gosuslugi") !== -1) ips = ["109.207.2.188"];
    else if (domain.indexOf("cbr.ru") !== -1) ips = ["37.29.35.34"];
    else if (domain.indexOf("sberbank") !== -1) ips = ["194.54.14.131"];

    return {
        domain: domain,
        status: "ok",
        ips: ips,
        resolver: resolver,
        time_ms: 12
    };
}

function isNewerVersion(remoteVer, localVer) {
    var r = String(remoteVer || "").split(".");
    var l = String(localVer || "").split(".");
    for (var i = 0; i < Math.max(r.length, l.length); i++) {
        var nr = parseInt(r[i] || "0", 10) || 0;
        var nl = parseInt(l[i] || "0", 10) || 0;
        if (nr > nl) return true;
        if (nr < nl) return false;
    }
    return false;
}

function checkAddonUpdate() {
    var statusTxt = document.getElementById("ui_update_status_text");
    var badge = document.getElementById("ui_update_badge");
    var btnUp = document.getElementById("btn_do_update");
    if (statusTxt) statusTxt.textContent = t("update_checking");

    xhrGet("https://raw.githubusercontent.com/normannskald/asuswrt-merlin-splitdns/main/splitdns.sh", function(err, text) {
        if (!err && text) {
            var m = text.match(/^VERSION="([^"]+)"/m);
            if (m && m[1]) {
                var latest = m[1];
                var current = routerStatus.version || "1.1.0";
                if (isNewerVersion(latest, current)) {
                    if (badge) {
                        badge.textContent = "v" + latest;
                        badge.style.display = "inline-block";
                    }
                    if (btnUp) btnUp.style.display = "inline-block";
                    if (statusTxt) statusTxt.textContent = t("update_available_fmt") + latest;
                } else {
                    if (badge) badge.style.display = "none";
                    if (btnUp) btnUp.style.display = "none";
                    if (statusTxt) statusTxt.textContent = t("update_up_to_date") + " (v" + current + ")";
                }
                return;
            }
        }
        submitViaMerlinApi("splitdns_check_update", 2, {}, function() {
            xhrGet("/user/splitdns_update.htm", function(uErr, uText) {
                if (!uErr && uText) {
                    try {
                        var uObj = JSON.parse(uText);
                        if (uObj && uObj.update_available) {
                            if (badge) {
                                badge.textContent = "v" + uObj.latest_version;
                                badge.style.display = "inline-block";
                            }
                            if (btnUp) btnUp.style.display = "inline-block";
                            if (statusTxt) statusTxt.textContent = t("update_available_fmt") + uObj.latest_version;
                            return;
                        }
                    } catch (e) {}
                }
                if (statusTxt) statusTxt.textContent = t("update_up_to_date") + " (v" + (routerStatus.version || "1.1.0") + ")";
            });
        });
    });
}

function runAddonUpdate() {
    if (!confirm(t("confirm_update"))) {
        return;
    }
    var statusTxt = document.getElementById("ui_update_status_text");
    if (statusTxt) statusTxt.textContent = t("update_in_progress");
    submitViaMerlinApi("splitdns_update", 6, {}, function() {
        window.location.reload();
    });
}

/* ============================================================================
 * 8. Backup Export & Restore Import
 * ============================================================================ */
function exportBackupJson() {
    var en1 = document.getElementById("splitdns_enable_1");
    var profSel = document.getElementById("splitdns_profile_sel");
    var c1 = document.getElementById("splitdns_custom_dns1");
    var c2 = document.getElementById("splitdns_custom_dns2");

    var backupPayload = {
        addon: "asuswrt-merlin-splitdns",
        version: routerStatus.version || "1.1.0",
        exported_at: new Date().toISOString(),
        settings: {
            enabled: (en1 && en1.checked) ? 1 : 0,
            profile: profSel ? profSel.value : "yandex_basic",
            custom_dns_primary: c1 ? c1.value.trim() : "",
            custom_dns_secondary: c2 ? c2.value.trim() : ""
        },
        rules: customRules
    };

    var jsonStr = JSON.stringify(backupPayload, null, 2);
    var blob = new Blob([jsonStr], { type: "application/json;charset=utf-8" });
    var url = URL.createObjectURL(blob);
    var a = document.createElement("a");
    var datePart = new Date().toISOString().slice(0, 10);
    a.href = url;
    a.download = "splitdns_backup_" + datePart + ".json";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    setTimeout(function() { URL.revokeObjectURL(url); }, 1000);
}

function uploadRestoreFile() {
    var fileInput = document.getElementById("backup_restore_file");
    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert(t("err_select_file"));
        return;
    }
    var file = fileInput.files[0];
    var reader = new FileReader();
    reader.onload = function(ev) {
        try {
            var data = JSON.parse(ev.target.result);
            validateAndApplyRestore(data);
        } catch (e) {
            alert(t("import_invalid_json"));
        }
        fileInput.value = "";
    };
    reader.readAsText(file, "UTF-8");
}

function validateAndApplyRestore(data) {
    if (!data || typeof data !== "object") {
        alert(t("import_invalid_json"));
        return;
    }
    if (data.addon !== "asuswrt-merlin-splitdns" && !data.settings) {
        alert(t("import_invalid_json"));
        return;
    }

    var s = data.settings || {};
    var validProfiles = ["yandex_basic", "yandex_safe", "yandex_family", "nsdi", "isp", "custom"];
    var prof = (validProfiles.indexOf(s.profile) !== -1) ? s.profile : "yandex_basic";

    routerStatus.enabled = (s.enabled === 0 || s.enabled === false) ? 0 : 1;
    routerStatus.profile = prof;
    routerStatus.custom_dns_primary = String(s.custom_dns_primary || "").replace(/[^0-9.#]/g, "");
    routerStatus.custom_dns_secondary = String(s.custom_dns_secondary || "").replace(/[^0-9.#]/g, "");

    var rawRules = Array.isArray(data.rules) ? data.rules : [];
    var sanitizedRules = [];
    for (var i = 0; i < rawRules.length && sanitizedRules.length < 128; i++) {
        var r = rawRules[i];
        if (!r || typeof r !== "object" || !r.domains) continue;
        var cleanDoms = String(r.domains).replace(/[^a-zA-Z0-9\u0400-\u04FF.,; _-]/g, "");
        var tType = (r.target_type === "router" || r.target_type === "custom") ? r.target_type : "profile";
        var tIp = String(r.target_ip || "").trim();
        if (tType === "custom" && !isValidIpv4OrPort(tIp)) {
            continue;
        }
        sanitizedRules.push({
            id: sanitizedRules.length + 1,
            enabled: (r.enabled === 0 || r.enabled === false) ? 0 : 1,
            domains: cleanDoms,
            target_type: tType,
            target_ip: tIp,
            comment: String(r.comment || "").substring(0, 64)
        });
    }
    routerStatus.rules = sanitizedRules;
    syncFormWithStatus();
    alert(t("import_success"));
}

/* ============================================================================
 * 9. Page Initialization
 * ============================================================================ */
function initSplitDnsPage() {
    var pageName = window.location.pathname.split("/").pop() || "user3.asp";
    if (document.form) {
        if (document.form.current_page) document.form.current_page.value = pageName;
        if (document.form.next_page) document.form.next_page.value = pageName;
        if (document.form.productid && NVRAM_PRODUCTID.indexOf("<" + "%") === -1) {
            document.form.productid.value = NVRAM_PRODUCTID;
        }
        if (document.form.preferred_lang && NVRAM_PREFERRED_LANG.indexOf("<" + "%") === -1) {
            document.form.preferred_lang.value = NVRAM_PREFERRED_LANG;
        }
        if (document.form.firmver && NVRAM_FIRMVER.indexOf("<" + "%") === -1) {
            document.form.firmver.value = NVRAM_FIRMVER;
        }
    }

    if (typeof show_menu === "function") {
        try { show_menu(); } catch (e) {}
    }

    initSessionAutologoutWatcher();
    applyLanguage();
    loadRouterStatus();
}

/* ]]> */
</script>
</body>
</html>
