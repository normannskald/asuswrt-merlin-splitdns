# Asuswrt-Merlin Split DNS (`asuswrt-merlin-splitdns`)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Asuswrt-Merlin](https://img.shields.io/badge/Platform-Asuswrt--Merlin%20386%2F388%2F3004-red.svg)](https://www.asuswrt-merlin.net/)
[![UI: RU / EN](https://img.shields.io/badge/Web%20UI-RU%20%7C%20EN-success.svg)](#)

**[Русская документация](#-русская-документация) | [English Documentation](#-english-documentation)**

---

## 🇷🇺 Русская документация

**Split DNS для Asuswrt-Merlin** — это безопасный, универсальный аддон с полноценным графическим веб-интерфейсом (в штатном стиле Asuswrt-Merlin / ROG Dark), предназначенный для условной маршрутизации DNS-запросов (`dnsmasq conditional forwarding`).

### Проблема, которую решает аддон

При использовании на роутере шифрованного DNS (**DNS Privacy / DNS-over-TLS / Stubby** с зарубежными серверами Cloudflare `1.1.1.1`, Quad9 `9.9.9.9`, Google `8.8.8.8`) или VPN-туннелей многие российские государственные, региональные, банковские и ведомственные сайты (например, `lkfl2.nalog.ru`, `gosuslugi.ru`, `cbr.ru`, `mos.ru` и региональные порталы) перестают открываться или отвечают ошибкой `SERVFAIL` / `DNS_PROBE_FINISHED_NXDOMAIN`.

Это происходит потому, что авторитетные NS-серверы ряда российских доменов блокируют или отбрасывают запросы, приходящие с зарубежных IP-адресов публичных DoT-резолверов.

**Split DNS** решает эту проблему на уровне роутера без отключения DNS-over-TLS:
- Все мировые сайты продолжают разрешаться через ваш защищённый **DNS-over-TLS (Stubby)** или VPN.
- Запросы к выбранным национальным доменным зонам (`.ru`, `.рф`, `.su` и др.), государственным порталам и вашим пользовательским правилам направляются напрямую на быстрые отечественные DNS-серверы (**Яндекс.DNS**, **НСДИ / MSK-IX** или **DNS вашего интернет-провайдера**).

---

### Ключевые возможности

1. **Полная совместимость с другими аддонами (`AmneziaWG`, `XrayUI` и др.)**
   - **Никакой жёсткой привязки к `user3.asp`**: аддон использует штатный механизм `/usr/sbin/helper.sh` (`am_get_webui_page`) и автоматически занимает первый свободный слот (`user1.asp` … `user20.asp`). Если на роутере уже установлены `AmneziaWG` (клиент и сервер в `user1.asp` и `user2.asp`) или `XrayUI`, Split DNS аккуратно встанет в следующий свободный слот.
   - **Неразрушающий патч меню (`menuTree.js`)**: вкладка `Split DNS` добавляется в раздел **WAN (Интернет)** под защитой мьютекса `flock`, сохраняя вкладки и виджеты всех соседних аддонов.

2. **Изоляция хранилища (защита от лимита 8 КБ в `custom_settings.txt`)**
   - В прошивке Asuswrt-Merlin системный файл `/jffs/addons/custom_settings.txt` имеет жёсткий лимит 8 КБ. Split DNS использует его **только как транзитный транспорт** в момент нажатия кнопки «Применить» и мгновенно очищает свои ключи, сохраняя все настройки и правила в собственной директории `/jffs/addons/splitdns/` (`splitdns.conf` и `rules.json`). Ключи других аддонов (`awg_*` и др.) остаются полностью нетронутыми.

3. **Тройная защита `dnsmasq` и нулевой риск падения сети**
   - Перед каждым перезапуском конфигурация проверяется через `dnsmasq --test`.
   - В `/jffs/scripts/dnsmasq.postconf` устанавливается защитный хук, предотвращающий ошибку старта `dnsmasq`, если файл правил был удалён вручную.
   - Сторожевой таймер (watchdog) проверяет PID `dnsmasq` через 1 секунду после рестарта и автоматически откатывает подключение при любом сбое.
   - Правила генерируются в чистом формате `server=/domain/ip` без привязки к сетевым интерфейсам (`@ifname`), полагаясь на системную таблицу маршрутизации ядра Linux.

4. **Двуязычный интерфейс (RU / EN) с встроенными подсказками `[?]`**
   - Автоматическое определение языка прошивки роутера (`preferred_lang`) + мгновенное переключение `RU` / `EN` в шапке страницы.
   - Каждая секция, переключатель, профиль и режим снабжены интерактивными всплывающими подсказками `[?]` — читать внешнюю документацию для настройки не требуется.

5. **Готовые пресеты и 6 профилей DNS-серверов**
   - **Пресет 1 — Национальные доменные зоны**: `.ru`, `.рф` (`xn--p1ai`), `.su`, `.москва` (`xn--80adxhks`), `.рус` (`xn--p1acf`), `.tatar`, `.дети` (`xn--d1acj3b`).
   - **Пресет 2 — Государственные и социально значимые ресурсы РФ**: встроенный каталог из 54 доменов (Госуслуги, ФНС `lkfl2.nalog.ru`, Банк России, суды, министерства, РЖД, Почта России, НСПК Мир, крупнейшие банки и УЦ).
   - **Удобные кнопки-помощники пресетов**: кнопки пресетов расположены непосредственно над единой таблицей правил — нажатие предзаполняет строку ввода (`+`), позволяя гибко выбрать целевой DNS-профиль и отредактировать список доменов перед добавлением.
   - **6 профилей апстрим-резолверов**:
     - `Яндекс.DNS Базовый` (`77.88.8.8`, `77.88.8.1`)
     - `Яндекс.DNS Безопасный` (`77.88.8.88`, `77.88.8.2` — защита от фишинга и вредоносных сайтов)
     - `Яндекс.DNS Семейный` (`77.88.8.7`, `77.88.8.3` — фильтрация контента 18+)
     - `НСДИ / MSK-IX` (`195.208.4.1`, `195.208.5.1` — Национальная система доменных имён)
     - `DNS интернет-провайдера (WAN)` (автоматическое получение DNS с WAN-интерфейса роутера)
     - `Свой DNS-сервер` (произвольный IPv4 и порт, например `192.168.50.2#5353`)

6. **Единая таблица правил, редактирование, Drag-and-Drop и исключения DoT (`127.0.1.1`)**
   - **Удобное управление и приоритет правил**: редактирование существующих записей прямо в строке добавления по нажатию на кнопку «карандаш» (`.edit_btn`) и свободное перетаскивание строк Drag-and-Drop (`⋮⋮`). При совпадении доменов приоритет отдается правилам выше по таблице, а `dnsmasq` автоматически разрешает более специфичные поддомены приоритетнее родительских зон.
   - Поддержка как одиночных доменов, так и **групп доменов** в одном правиле (через запятую или пробел).
   - Автоматическая конвертация кириллических доменов (`.рф`, `.рус`, `.москва`, `.дети`) в стандарт **RFC 3490 Punycode** (`xn--...`).
   - **3 режима маршрутизации для каждого правила**:
     1. *По умолчанию (из выбранного профиля выше)* — направляет домены на текущий профиль Split DNS.
     2. *Штатный DNS роутера / DoT (`127.0.1.1` — исключение)* — благодаря правилу наиболее длинного суффикса (`longest suffix match`) в `dnsmasq`, позволяет вывести конкретный сайт `.ru` из-под действия пресета `.ru` обратно в шифрованный DoT (Stubby).
     3. *Свой IP (`IPv4#порт`)* — направляет домены на указанный локальный или внешний DNS-сервер (например, корпоративный контроллер домена, AdGuard Home или Pi-hole).

7. **Диагностика в стиле Network Tools, управление в стиле Administration и обновления**
   - **Живая DNS-диагностика в нативном стиле Asuswrt (*Network Tools -> Netstat*)**: проверка разрешения любого домена (по умолчанию `lkfl2.nalog.ru`) прямо из интерфейса с отображением IP-адресов, времени отклика и резолвера в моноширинной консольной области.
   - **Управление настройками в нативном стиле Asuswrt (*Administration -> Restore/Save/Upload Setting*)**: выгрузка настроек и правил в файл JSON (`Save`), загрузка из файла (`Upload`) и безопасный сброс параметров к фабричным (`Restore Default`).
   - **Хирургический сброс (Surgical Reset)**: безопасный сброс настроек аддона **без использования снимков начального состояния (snapshots)**. Очищает исключительно правила и конфигурацию Split DNS, не затрагивая настройки WAN, VPN, DoT или других аддонов.
   - **Проверка обновлений и обновление в 1 клик**: сравнение установленной версии с репозиторием GitHub и обновление прямо из браузера с сохранением всех настроек.

---

### Установка в одну команду (SSH)

Подключитесь к роутеру по SSH (например, через терминал или PuTTY) под учётной записью администратора и выполните:

```sh
curl -fsSL https://raw.githubusercontent.com/normannskald/asuswrt-merlin-splitdns/main/install.sh | sh
```

> **Требования**: Прошивка Asuswrt-Merlin с включённым разделом JFFS (*Администрирование → Система → Enable JFFS custom scripts and configs = Yes*).

После установки скрипт выведет прямую ссылку на веб-интерфейс (например, `http://192.168.50.1/user3.asp`), а в боковом меню роутера в разделе **Интернет (WAN)** появится вкладка **Split DNS**.

---

### Управление через SSH (CLI и интерактивное меню)

Вы можете запустить интерактивное меню установщика в любой момент:

```sh
sh /jffs/addons/splitdns/install.sh
```

Или управлять аддоном напрямую через CLI-команды скрипта `/jffs/addons/splitdns/splitdns.sh` (если установлен Entware, также доступна короткая команда `splitdns`):

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
| `/jffs/addons/splitdns/splitdns.sh uninstall` | Полностью удалить аддон, убрать вкладку из меню и очистить все хуки |

---

## 🇬🇧 English Documentation

**Split DNS for Asuswrt-Merlin** is a safe, non-destructive conditional DNS forwarding addon (`dnsmasq`) with a native Asuswrt-Merlin / ROG Dark Web UI.

### Problem Statement

When **DNS Privacy (DNS-over-TLS / Stubby)** with international resolvers (Cloudflare `1.1.1.1`, Quad9 `9.9.9.9`, Google `8.8.8.8`) or VPN tunnels are active on an Asuswrt-Merlin router, many Russian national, government, banking, and regional domains (such as `lkfl2.nalog.ru`, `gosuslugi.ru`, `cbr.ru`, `mos.ru`) fail to resolve (`SERVFAIL` / timeout) because their authoritative nameservers drop queries originating from foreign resolver IP addresses.

**Split DNS** solves this cleanly using `dnsmasq` conditional forwarding (`server=/domain/ip`):
- Global domains continue resolving through your encrypted **DNS-over-TLS (Stubby)** or VPN configuration.
- National TLD zones, government portals, and custom domain rules are selectively forwarded to fast domestic DNS resolvers (**Yandex.DNS**, **NSDI / MSK-IX**, **ISP WAN DNS**, or a **Custom DNS server**).

---

### Key Features

- **Dynamic WebUI Slot Allocation**: Uses Asuswrt-Merlin's native `/usr/sbin/helper.sh` (`am_get_webui_page`) to dynamically claim the first free `user1.asp`–`user20.asp` page. Coexists seamlessly with **AmneziaWG**, **XrayUI**, **Diversion**, and other addons.
- **Mutex-Protected Menu Patching**: Safely injects the `Split DNS` tab into the **WAN** menu (`menu_WAN`) using `flock` synchronization on `/tmp/.splitdns_menutree.lock` without clobbering tabs from other addons.
- **Dedicated JFFS Storage (Immune to the 8 KB `custom_settings.txt` Limit)**: Persists configuration and rules in `/jffs/addons/splitdns/splitdns.conf` and `/jffs/addons/splitdns/rules.json`. Uses `/jffs/addons/custom_settings.txt` strictly as a transient transport during form submission and immediately cleans up its keys.
- **Triple-Guarded `dnsmasq` Safety**:
  1. Validates generated configurations with `dnsmasq --test` before applying.
  2. Installs a missing-file guard in `/jffs/scripts/dnsmasq.postconf`.
  3. Uses a 1-second self-healing watchdog on `service restart_dnsmasq` that automatically rolls back if `dnsmasq` fails to start.
- **Bilingual Web UI (`RU` / `EN`) with Interactive Tooltips `[?]`**: Automatically detects the router's language (`preferred_lang`) and provides an instant `RU` / `EN` switcher plus built-in contextual help modals for every option.
- **Built-in Presets & 6 Upstream Profiles**:
  - **National Domain Zones Preset**: `.ru`, `.рф` (`xn--p1ai`), `.su`, `.москва` (`xn--80adxhks`), `.рус` (`xn--p1acf`), `.tatar`, `.дети` (`xn--d1acj3b`).
  - **Government & Social Services Preset**: Curated catalog of 54 essential domains (`gosuslugi.ru`, `lkfl2.nalog.ru`, `cbr.ru`, `mos.ru`, `rzd.ru`, `sberbank.ru`, etc.).
  - **Convenient Preset Helper Buttons**: Presets are helper buttons located right above the unified rules table; clicking them pre-fills the input row (`+`), allowing you to select the upstream profile and modify domains before saving.
  - **6 DNS Profiles**: Yandex Basic (`77.88.8.8`), Yandex Safe (`77.88.8.88`), Yandex Family (`77.88.8.7`), NSDI / MSK-IX (`195.208.4.1`), Auto ISP WAN DNS, and Custom IPv4 (`IP#port`).
- **Unified Rules Table, In-Place Editing, Drag-and-Drop & DoT Exceptions (`127.0.1.1`)**:
  - Full rule lifecycle: edit existing rules using the pencil button (`.edit_btn`) and reorder rules via Drag-and-Drop handles (`⋮⋮`). Rules located higher in the table take priority for identical domains, while `dnsmasq` naturally prioritizes more specific subdomains over parent zones.
  - Group multiple domains in a single rule (comma or space separated).
  - Automatic client-side **RFC 3490 Punycode** conversion for Cyrillic domains.
  - Three target modes per rule: **Profile Default**, **Router DoT Exception (`127.0.1.1`)** (leverages `dnsmasq` longest-suffix matching to exclude specific `.ru` domains from the national preset back to Stubby DoT), and **Custom Server (`IP#port`)**.
- **Native Network Tools Diagnostics, Administration Settings Management & In-UI Updater**:
  - **Native Network Tools Style Diagnostics**: Live domain resolution check (default: `lkfl2.nalog.ru`) styled cleanly after Asuswrt's *Network Tools -> Netstat*, displaying DNS answers, query latency, and authoritative resolvers in a monospace output area.
  - **Native Administration Style Settings Management**: Backup, restore, and reset styled cleanly after Asuswrt's *Administration -> Restore/Save/Upload Setting* with dedicated Save (Export), Upload (Import), and Restore Default (Surgical Reset) controls.
  - **Surgical Reset**: Resets only Split DNS settings and rules without using state snapshots, ensuring zero conflict with parallel changes made in the stock Asuswrt-Merlin UI or other addons.
  - **In-UI Updates**: Check for new releases on GitHub and update in one click from the Web UI.

---

### One-Line Installation (SSH)

Connect to your router via SSH and run:

```sh
curl -fsSL https://raw.githubusercontent.com/normannskald/asuswrt-merlin-splitdns/main/install.sh | sh
```

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
