# Asuswrt-Merlin Split DNS (`asuswrt-merlin-splitdns`)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Asuswrt-Merlin](https://img.shields.io/badge/Platform-Asuswrt--Merlin%20386%2F388%2F3004-red.svg)](https://www.asuswrt-merlin.net/)
[![Web UI: Native Asuswrt](https://img.shields.io/badge/Web%20UI-Native%20Asuswrt%20Dark-success.svg)](#)
[![Latest Release](https://img.shields.io/badge/Release-v1.1.0-orange.svg)](https://github.com/normannskald/asuswrt-merlin-splitdns/releases)

**[🇷🇺 Русская документация](#-русская-документация) | [🇬🇧 English Documentation](#-english-documentation)**

<p align="center">
  <img src="assets/splitdns_webui.png" alt="Split DNS Web UI on Asuswrt-Merlin" />
</p>

---

## 🇷🇺 Русская документация

**Split DNS для Asuswrt-Merlin** — это аддон с полноценным веб-интерфейсом в нативном стиле прошивки Asuswrt-Merlin, предназначенный для условной маршрутизации DNS-запросов (`dnsmasq conditional forwarding`).

### Проблема, которую решает аддон

При использовании на роутере шифрованного DNS (**DNS Privacy / DNS-over-TLS / Stubby** с зарубежными серверами Cloudflare `1.1.1.1`, Quad9 `9.9.9.9`, Google `8.8.8.8`) или VPN-туннелей многие российские государственные, банковские и региональные сайты (например, `lkfl2.nalog.ru`, `gosuslugi.ru`, `cbr.ru`, `mos.ru`) перестают открываться или отвечают ошибкой `SERVFAIL` / `DNS_PROBE_FINISHED_NXDOMAIN`.

Это происходит потому, что авторитетные NS-серверы ряда российских доменов блокируют или сбрасывают запросы, поступающие с зарубежных IP-адресов публичных DoT-резолверов.

**Split DNS** решает эту проблему на уровне роутера без отключения глобального DNS-over-TLS:
- Все мировые сайты продолжают разрешаться через зашифрованный **DNS-over-TLS (Stubby)** или VPN.
- Запросы к выбранным национальным доменным зонам (`.ru`, `.рф`, `.su` и др.), государственным сервисам и вашим собственным правилам направляются напрямую на быстрые отечественные DNS-серверы (**Яндекс.DNS**, **НСДИ / MSK-IX** или **DNS интернет-провайдера**).

---

### Установка в одну команду (SSH)

Подключитесь к роутеру по SSH под учётной записью администратора и выполните:

```sh
curl -fsSL https://raw.githubusercontent.com/normannskald/asuswrt-merlin-splitdns/main/install.sh | sh
```

> **Требования**: Прошивка Asuswrt-Merlin с включённым разделом JFFS (*Администрирование → Система → Enable JFFS custom scripts and configs = Yes*).

После установки в боковом меню роутера в разделе **Интернет (WAN)** появится вкладка **Split DNS**, а скрипт выведет прямой адрес страницы (например, `http://192.168.50.1/user3.asp`).

---

### Руководство по использованию

Веб-интерфейс Split DNS полностью интегрирован в прошивку роутера, оформлен по официальным гайдлайнам Asuswrt и включает следующие возможности:

#### 1. Выбор целевого профиля DNS
В блоке **Основные параметры** можно в один клик выбрать нужный апстрим-резолвер для правил:
- **Яндекс.DNS Базовый** (`77.88.8.8`, `77.88.8.1`) — быстрый и стабильный доступ.
- **Яндекс.DNS Безопасный** (`77.88.8.88`, `77.88.8.2`) — встроенная защита от вредоносных сайтов и фишинга.
- **Яндекс.DNS Семейный** (`77.88.8.7`, `77.88.8.3`) — блокировка сайтов с контентом 18+.
- **НСДИ / MSK-IX** (`195.208.4.1`, `195.208.5.1`) — Национальная система доменных имён.
- **DNS интернет-провайдера (WAN DHCP)** — автоматическое получение DNS-серверов от вашего провайдера.
- **Пользовательский DNS** — ручной ввод любого первичного и вторичного IPv4 (с возможностью указания нестандартного порта, например `192.168.50.5#5353`).

#### 2. Добавление правил и быстрые пресеты
Правила формируются в единой таблице **Пользовательские правила и исключения**:
- **Кнопки быстрой подстановки пресетов**:
  - `Национальные доменные зоны`: заполняет строку доменов списком `ru, рф, su, москва, рус, tatar, дети`.
  - `Гос. и соц. ресурсы РФ`: заполняет строку списком из 54 доменов (Госуслуги, ФНС, Банк России, суды, ведомства, банки, транспорт).
- После нажатия кнопки пресета вы можете скорректировать список доменов, выбрать тип резолвера и нажать штатную круглую кнопку `+` для добавления правила в таблицу.
- Поддерживается как одиночный ввод, так и перечисление множества доменов через запятую или пробел, включая кириллические домены IDN (автоматически конвертируются в Punycode).

#### 3. Приоритет правил, редактирование и Drag-and-Drop
- **Изменение приоритета перетаскиванием (Drag-and-Drop)**: зажмите значок `⋮⋮` слева от правила и перетащите строку выше или ниже. При совпадении доменов верхнее правило имеет приоритет над нижним.
- **Автоматический приоритет поддоменов в dnsmasq**: более специфичные поддомены всегда имеют естественный приоритет над родительской зоной (например, правило для `sub.example.ru` главнее правила для всей зоны `ru`).
- **Редактирование записей**: нажатие на круглую иконку с карандашом возвращает параметры правила в строку ввода для быстрой правки.
- **Временное отключение**: чекбокс в колонке «Вкл» позволяет выключить правило без его удаления из списка.

#### 4. Режимы маршрутизации и исключения из DoT
Для каждого правила в выпадающем списке доступно 3 режима:
1. **Профиль Split DNS**: направлять домены на выбранный выше глобальный профиль (например, Яндекс.DNS или НСДИ).
2. **Исключение (DoT роутера `127.0.1.1`)**: выводит конкретный домен из-под действия общего правила обратно в зашифрованный DoT (Stubby) роутера.
3. **Свой DNS-сервер (`IP#порт`)**: направляет запросы к домену на индивидуальный DNS-сервер (корпоративный контроллер домена, AdGuard Home, Pi-hole).

#### 5. Диагностика резолвинга
Раздел оформлен в стиле *Сетевые утилиты → Netstat*:
- Введите домен (по умолчанию подставлен `lkfl2.nalog.ru`) и нажмите **Проверить**.
- Роутер выполнит реальный запрос и выведет статус разрешения, использованный DNS-сервер, список полученных IP-адресов и время отклика в миллисекундах.

#### 6. Резервное копирование, восстановление и сброс
Раздел оформлен в стиле *Администрирование → Восстановление/Сохранение настроек*:
- **Сохранение настроек**: скачивает все текущие параметры и таблицу правил в JSON-файл резервной копии.
- **Восстановление настроек**: загружает и валидирует конфигурацию из ранее сохранённого JSON-файла.
- **Заводские настройки (Хирургический сброс)**: безопасно очищает только настройки и правила Split DNS, не затрагивая конфигурацию роутера или соседних аддонов.

#### 7. Обновление аддона
- Кнопка **Проверить обновление** сравнивает текущую установленную версию с последней версией в репозитории GitHub.
- При наличии свежего релиза появляется кнопка **Обновить**, позволяющая обновить аддон в один клик с сохранением всех существующих настроек и правил.

---

### Безопасное удаление аддона без остатка

Если вы решите удалить Split DNS, аддон удаляется полностью и бесследно в автоматическом режиме:

#### Способ 1. Удаление одной командой (SSH)
```sh
curl -fsSL https://raw.githubusercontent.com/normannskald/asuswrt-merlin-splitdns/main/install.sh | sh -s -- uninstall
```

#### Способ 2. Через интерактивное меню
Запустите установщик на роутере:
```sh
sh /jffs/addons/splitdns/install.sh
```
и выберите пункт `5) Uninstall Addon`.

#### Способ 3. Прямая CLI-команда
```sh
/jffs/addons/splitdns/splitdns.sh uninstall
```

**Что происходит при удалении:**
1. Размонтируется веб-страница и удаляется выделенный слот `userX.asp`.
2. Вкладка `Split DNS` аккуратно удаляется из файла меню прошивки (`menuTree.js`), сохраняя вкладки всех соседних аддонов (например, AmneziaWG).
3. Удаляется файл сгенерированных директив `dnsmasq_splitdns.conf` и его подключение из `/jffs/configs/dnsmasq.conf.add`.
4. Удаляются интеграционные хуки из `/jffs/scripts/dnsmasq.postconf`, `/jffs/scripts/services-start` и `/jffs/scripts/service-event`.
5. Очищаются транзитные параметры из `/jffs/addons/custom_settings.txt`.
6. Служба `dnsmasq` проверяется и безопасно перезапускается.
7. Полностью удаляется каталог `/jffs/addons/splitdns/` и ярлык `/opt/bin/splitdns`.
8. Настройки сети, VPN, DoT и сторонние аддоны остаются нетронутыми.

---

### Управление через SSH (CLI)

| Команда | Описание |
| :--- | :--- |
| `/jffs/addons/splitdns/splitdns.sh status` | Показать текущий статус службы, выбранный профиль, активный слот `userX.asp` и пути к файлам |
| `/jffs/addons/splitdns/splitdns.sh start` | Смонтировать веб-интерфейс, сгенерировать правила и запустить Split DNS |
| `/jffs/addons/splitdns/splitdns.sh stop` | Отключить правила Split DNS от `dnsmasq` и безопасно перезапустить `dnsmasq` |
| `/jffs/addons/splitdns/splitdns.sh restart` | Полный перезапуск службы Split DNS |
| `/jffs/addons/splitdns/splitdns.sh apply` | Применить текущие настройки и перегенерировать правила `dnsmasq` |
| `/jffs/addons/splitdns/splitdns.sh reset` | Выполнить хирургический сброс настроек Split DNS к начальным значениям |
| `/jffs/addons/splitdns/splitdns.sh test_domain lkfl2.nalog.ru` | Выполнить диагностический DNS-запрос и вывести результат в формате JSON |
| `/jffs/addons/splitdns/splitdns.sh check_update` | Проверить наличие новой версии на GitHub (выводит JSON) |
| `/jffs/addons/splitdns/splitdns.sh update` | Скачать и установить последнюю версию с GitHub с сохранением настроек |
| `/jffs/addons/splitdns/splitdns.sh uninstall` | Полностью и без остатка удалить аддон с роутера |

---

### Релизы и история версий

#### [v1.1.0](https://github.com/normannskald/asuswrt-merlin-splitdns/releases/tag/v1.1.0) — 2026-10-28
- **Нативный интерфейс в стиле Asuswrt-Merlin**: таблица правил оформлена по образцу страницы DHCP-сервера (`FormTable_table` + `list_table`), блок диагностики — по образцу Netstat, блок резервного копирования — по образцу страницы системных настроек.
- **Быстрые пресеты в единой таблице**: пресеты национальных зон и госсервисов перенесены в удобные кнопки подстановки в строку ввода правил перед нажатием кнопки `+`.
- **Редактирование правил и Drag-and-Drop**: добавлено редактирование строк по кнопке с карандашом (`.edit_btn`) и перетаскивание строк мышью (`⋮⋮`) с приоритетом правил сверху вниз.
- **Подсказки полей через overlib**: штатный стиль подсказок из `/help.js` с курсором `?` и открытием компактного окна по клику.
- **Интеграция с языком прошивки**: автоматическое следование системному выпадающему списку `preferred_lang` в шапке прошивки.
- **Контроль таймаута авто-разлогинивания**: точный учёт системного времени бездействия (`http_autologout`) с автоматическим перенаправлением на страницу логина.

#### [v1.0.0](https://github.com/normannskald/asuswrt-merlin-splitdns/releases/tag/v1.0.0) — 2026-10-27
- Первый стабильный релиз аддона.
- Условная маршрутизация DNS (`dnsmasq`) для обхода гео-блокировок при включённом DoT/VPN.
- Динамическое выделение слотов страниц (`am_get_webui_page`) и бесконфликтное соседство с AmneziaWG и XrayUI.
- 6 профилей DNS, исключения из DoT (`127.0.1.1`), резервное копирование и хирургический сброс настроек.

---

## 🇬🇧 English Documentation

**Split DNS for Asuswrt-Merlin** is an addon with a full Web UI designed in the native Asuswrt-Merlin style for conditional DNS routing (`dnsmasq conditional forwarding`).

### Problem Statement

When **DNS Privacy (DNS-over-TLS / Stubby)** with international resolvers (Cloudflare `1.1.1.1`, Quad9 `9.9.9.9`, Google `8.8.8.8`) or VPN tunnels are active on an Asuswrt-Merlin router, many Russian national, government, banking, and regional domains (such as `lkfl2.nalog.ru`, `gosuslugi.ru`, `cbr.ru`, `mos.ru`) fail to resolve (`SERVFAIL` / timeout) because their authoritative nameservers drop queries originating from foreign resolver IP addresses.

**Split DNS** solves this cleanly at the router level without disabling global DNS-over-TLS:
- Global traffic continues resolving through your encrypted **DNS-over-TLS (Stubby)** or VPN configuration.
- National TLD zones (`.ru`, `.рф`, `.su`, etc.), government services, and custom domain rules are selectively routed to fast domestic DNS resolvers (**Yandex.DNS**, **NSDI / MSK-IX**, or **ISP WAN DNS**).

---

### One-Line Installation (SSH)

Connect to your router via SSH with administrator privileges and run:

```sh
curl -fsSL https://raw.githubusercontent.com/normannskald/asuswrt-merlin-splitdns/main/install.sh | sh
```

> **Requirements**: Asuswrt-Merlin firmware with JFFS enabled (*Administration → System → Enable JFFS custom scripts and configs = Yes*).

Once installed, the **Split DNS** tab will appear under the **WAN** menu, and the installer will display the direct page URL (e.g., `http://192.168.50.1/user3.asp`).

---

### Usage Guide

The Split DNS Web UI is fully integrated into the firmware, adhering strictly to Asuswrt UI design guidelines:

#### 1. Selecting a Target DNS Profile
Under **Basic Settings**, select the preferred upstream DNS resolver:
- **Yandex.DNS Basic** (`77.88.8.8`, `77.88.8.1`) — fast and reliable resolution.
- **Yandex.DNS Safe** (`77.88.8.88`, `77.88.8.2`) — built-in protection against malware and phishing.
- **Yandex.DNS Family** (`77.88.8.7`, `77.88.8.3`) — filters adult content.
- **NSDI / MSK-IX** (`195.208.4.1`, `195.208.5.1`) — Russian National Domain Name System.
- **ISP DNS (WAN DHCP)** — automatically uses DNS servers provided by your WAN connection.
- **Custom DNS** — enter any custom primary and secondary IPv4 addresses (with optional ports, e.g., `192.168.50.5#5353`).

#### 2. Adding Rules & Quick Presets
Rules are configured within the unified **Custom Rules & Exceptions** table:
- **Preset Quick-Fill Buttons**:
  - `National Domain Zones`: fills the domain input field with `ru, рф, su, москва, рус, tatar, дети`.
  - `Gov & Social Services (RF)`: fills the domain input field with a curated list of 54 essential domains.
- After clicking a preset button, you can adjust the domain list, select the routing mode, and click the native round `+` button to add the rule to the table.
- Supports single domain names or multiple domains separated by commas or spaces, including Cyrillic IDN domains (automatically converted to Punycode).

#### 3. Rule Priority, In-Place Editing & Drag-and-Drop
- **Drag-and-Drop Reordering**: click and drag the `⋮⋮` handle on the left to move a row up or down. Rules located higher in the table take priority for identical domains.
- **Subdomain Priority in dnsmasq**: more specific subdomains always take natural precedence over parent zones (e.g., a rule for `sub.example.ru` overrides the parent `.ru` zone rule).
- **In-Place Editing**: click the round pencil icon (`.edit_btn`) on any rule to load its values back into the input row for quick edits.
- **Quick Enable/Disable**: use the checkbox in the "On" column to temporarily toggle a rule without deleting it.

#### 4. Routing Modes & DoT Exceptions
Each rule supports one of three routing targets:
1. **Split DNS Profile**: forwards queries to the active profile chosen above (e.g., Yandex.DNS or NSDI).
2. **Exception (Router DoT `127.0.1.1`)**: routes specific domains back to the router's encrypted DoT (Stubby) resolver, exempting them from broad zone rules.
3. **Custom DNS Server (`IP#port`)**: forwards queries for the specified domains to an individual DNS server (e.g., corporate domain controller, AdGuard Home, Pi-hole).

#### 5. Resolution Diagnostics
Styled after *Network Tools → Netstat*:
- Enter any domain (default placeholder: `lkfl2.nalog.ru`) and click **Test**.
- The router executes a live `nslookup` query and displays the resolution status, resolver IP, resolved addresses, and latency in milliseconds within a monospace console area.

#### 6. Backup, Restore & Reset
Styled after *Administration → Restore/Save/Upload Setting*:
- **Save setting**: downloads a complete JSON backup of all Split DNS settings and custom rules.
- **Restore setting**: uploads and validates a previously exported JSON backup file.
- **Factory default (Surgical Reset)**: cleanly resets Split DNS configuration and rules without affecting the rest of the router or other addons.

#### 7. Addon Updates
- **Check Update**: checks the remote GitHub repository for newer releases.
- If a new version is available, the **Update** button appears, allowing you to update in one click while preserving your existing configuration.

---

### Clean & Safe Uninstallation

If you ever wish to remove Split DNS, it uninstalls cleanly and leaves zero traces:

#### Option 1. One-Line SSH Command
```sh
curl -fsSL https://raw.githubusercontent.com/normannskald/asuswrt-merlin-splitdns/main/install.sh | sh -s -- uninstall
```

#### Option 2. Interactive Installer Menu
Run the installer script on the router:
```sh
sh /jffs/addons/splitdns/install.sh
```
and select option `5) Uninstall Addon`.

#### Option 3. Direct CLI Command
```sh
/jffs/addons/splitdns/splitdns.sh uninstall
```

**Uninstallation Process:**
1. Unmounts the Web UI page and removes the allocated `userX.asp` slot.
2. Removes the `Split DNS` tab from the firmware navigation menu (`menuTree.js`), leaving adjacent addons (such as AmneziaWG) untouched.
3. Removes `dnsmasq_splitdns.conf` and cleans its include line from `/jffs/configs/dnsmasq.conf.add`.
4. Removes startup and event hooks from `/jffs/scripts/dnsmasq.postconf`, `/jffs/scripts/services-start`, and `/jffs/scripts/service-event`.
5. Cleans up transient parameters from `/jffs/addons/custom_settings.txt`.
6. Safely validates and restarts `dnsmasq`.
7. Removes `/jffs/addons/splitdns/` and the `/opt/bin/splitdns` symlink.
8. Network, WAN, VPN, and router settings remain completely intact.

---

### SSH CLI Management

| Command | Description |
| :--- | :--- |
| `/jffs/addons/splitdns/splitdns.sh status` | Show service status, active profile, dynamic slot `userX.asp`, and file paths |
| `/jffs/addons/splitdns/splitdns.sh start` | Mount Web UI, generate dnsmasq configuration, and start service |
| `/jffs/addons/splitdns/splitdns.sh stop` | Detach rules from `dnsmasq` and safely restart `dnsmasq` |
| `/jffs/addons/splitdns/splitdns.sh restart` | Restart Split DNS service and reload dnsmasq |
| `/jffs/addons/splitdns/splitdns.sh apply` | Apply active configuration and regenerate dnsmasq rules |
| `/jffs/addons/splitdns/splitdns.sh reset` | Perform a surgical reset of Split DNS settings to defaults |
| `/jffs/addons/splitdns/splitdns.sh test_domain lkfl2.nalog.ru` | Perform a diagnostic DNS query and output JSON |
| `/jffs/addons/splitdns/splitdns.sh check_update` | Check for newer releases on GitHub (outputs JSON) |
| `/jffs/addons/splitdns/splitdns.sh update` | Download and install latest release from GitHub preserving settings |
| `/jffs/addons/splitdns/splitdns.sh uninstall` | Completely uninstall Split DNS and remove all traces from router |

---

### Releases & Changelog

#### [v1.1.0](https://github.com/normannskald/asuswrt-merlin-splitdns/releases/tag/v1.1.0) — 2026-10-28
- **Native Asuswrt-Merlin UI Style**: rules table redesigned in the style of DHCP Server (`FormTable_table` + `list_table`), diagnostics redesigned in the style of Netstat, backup/restore in the style of Administration settings.
- **Unified Rules Table with Quick Presets**: National Zones and Russian Gov/Social presets available as quick-fill helper buttons directly above the table before clicking `+`.
- **In-Place Rule Editing & Drag-and-Drop**: edit existing rules via the pencil icon (`.edit_btn`) and reorder rules via drag handles (`⋮⋮`) with top-to-bottom rule precedence.
- **Native Tooltips via overlib**: restored native Asuswrt tooltip styling with `?` hover cursor and compact dialogs via `/help.js`.
- **Firmware Language Sync**: automatically adapts to the stock `preferred_lang` dropdown in the firmware header.
- **Session Timeout Enforcement**: wall-clock idle timer tracking `http_autologout` with automatic redirect to the login screen.

#### [v1.0.0](https://github.com/normannskald/asuswrt-merlin-splitdns/releases/tag/v1.0.0) — 2026-10-27
- Initial release of Split DNS for Asuswrt-Merlin.
- Conditional DNS routing (`dnsmasq`) for bypassing geo-blocks while preserving global DoT/VPN.
- Dynamic slot allocation (`am_get_webui_page`) with zero conflict against AmneziaWG, XrayUI, and others.
- 6 DNS profiles, router DoT exceptions (`127.0.1.1`), backup/restore, and surgical reset.

---

### File Architecture on Router

```text
/jffs/addons/splitdns/
├── splitdns.sh             # Backend controller & CLI manager
├── splitdns_page.asp       # Bilingual ROG/Asuswrt Web UI source
├── install.sh              # Local copy of installer & interactive SSH menu
├── splitdns.conf           # Persistent key-value configuration
├── rules.json              # Persistent custom rules & exceptions (JSON)
└── dnsmasq_splitdns.conf   # Generated dnsmasq server=/domain/ip directives
```

---

### License

Released under the [MIT License](LICENSE). Copyright (c) 2026 [normannskald](https://github.com/normannskald).
