# Graph Report - MQTT-Mobile-WEB  (2026-08-19)

## Corpus Check
- 215 files · ~75,344 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2460 nodes · 3679 edges · 153 communities (121 shown, 32 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 115 edges (avg confidence: 0.72)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `163df446`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Win32Window
- app_localizations.dart
- AppDelegate
- Docker Compose DB Service (postgres:15-alpine)
- app_localizations_en.dart
- [id]/page.tsx
- device_models.dart
- Linux Desktop CMake Project
- index.ts
- auth.tsx
- websocket_client.dart
- home_screen.dart
- login_screen.dart
- device_service.py
- auth_provider.dart
- my_application.cc
- app_localizations_fa.dart
- access_control.py
- ap_setup_screen.dart
- devDependencies
- provisioning_provider.dart
- device_detail_provider.dart
- Base
- devices.py
- از اینجا شروع کنید — راهنمای جامع SmartPlug
- device_shares_screen.dart
- device_detail_screen.dart
- compilerOptions
- routers/admin.py
- routers/auth.py
- SmartPlug Production Deployment Guide
- households.py
- Start Here — SmartPlug Setup Guide
- next.config.ts
- event_provider.dart
- iOS AppIcon Asset Catalog (AppIcon.appiconset)
- app_router.dart
- MQTT محلی در مقابل VPS
- API Contract
- macOS App Icon Platform Assets
- ws_provider.dart
- provisioning_models.dart
- device_control_provider.dart
- auth_models.dart
- share_models.dart
- راهنمای پیکربندی MQTT (Mosquitto)
- SmartPlug — IoT Smart Plug Platform
- event_history_screen.dart
- Spinner.tsx
- [locale]/layout.tsx
- file.svg Static Asset
- package:flutter_riverpod/flutter_riverpod.dart
- app_theme.dart
- api_client.dart
- secure_storage.dart
- shares.py
- DeviceResponse
- help_screen.dart
- AGENTS.md — MQTT-Mobile-WEB
- wWinMain
- device_states table
- share_repository.dart
- household_models.dart
- app_constants.dart
- manifest.json
- Tables
- package:flutter/material.dart
- راه‌اندازی سریع با Docker
- main.py
- share_provider.dart
- event_repository.dart
- device_repository.dart
- households table
- date_formatter.dart
- phone_validator.dart
- 4. Features (v1)
- link_device_screen.dart
- config.py
- AGENTS.md
- راهنمای استقرار (خلاصه فارسی)
- استقرار روی VPS
- ../../core/theme/app_theme.dart
- Device Provisioning Sequence
- Cloud/Local Hybrid Behavior
- dashboard/page.tsx
- Android Launcher Icon Asset Set (ic_launcher.png, mipmap density variants)
- Black Placeholder Launch Splash
- راهنمای پنل مدیریت پلتفرم
- [id]/shares/page.tsx
- Device Registration Flow
- household_repository.dart
- Launch Screen Customization
- list_device_events
- vps-up.sh
- FlutterActivity
- Dart Analyzer Configuration
- event.py
- tele/{serial}/online
- schemas/user.py
- docker-up.sh
- mqtt-test.sh script
- eslint.config.mjs
- postcss.config.mjs
- PostgreSQL 15
- POST /auth/refresh
- RFC 7807 Error Responses
- pydantic
- pydantic-settings
- Soft Delete Pattern
- alembic
- asyncpg
- fastapi
- sqlalchemy[asyncio]
- Device
- DeviceState?
- Exception
- String?
- flutter_dotenv
- go_router
- http
- smartplug Mobile App
- web_socket_channel
- MQTT Server Setup (Mosquitto)
- frontend/README.md
- Server Architecture
- smartplug
- Device Provisioning Flow (First Boot)
- api_error.dart
- Quick Start with Docker
- provisioning_repository.dart
- auth_repository.dart
- gmqtt
- Product Specification — Smart Plug Platform
- AppLocalizations
- docker-entrypoint.sh
- SmartPlug Documentation
- flutter_riverpod
- python-jose[cryptography]

## God Nodes (most connected - your core abstractions)
1. `Base` - 26 edges
2. `Win32Window` - 22 edges
3. `TimestampMixin` - 21 edges
4. `UUIDMixin` - 21 edges
5. `api` - 19 edges
6. `create_local_test_device()` - 17 edges
7. `MQTTService` - 17 edges
8. `compilerOptions` - 16 edges
9. `iOS AppIcon Asset Catalog (AppIcon.appiconset)` - 16 edges
10. `SoftDeleteMixin` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Share via Phone Number` --semantically_similar_to--> `Sharing`  [INFERRED] [semantically similar]
  AGENTS.md → product_spec.md
- `Cloud MQTT Broker` --semantically_similar_to--> `MQTT Broker (EMQX/Mosquitto)`  [INFERRED] [semantically similar]
  architecture.md → AGENTS.md
- `Phone-number OTP Authentication` --semantically_similar_to--> `JWT Authentication`  [INFERRED] [semantically similar]
  AGENTS.md → architecture.md
- `Cloud/Local Dual MQTT` --semantically_similar_to--> `Cloud/Local Hybrid Behavior`  [INFERRED] [semantically similar]
  AGENTS.md → architecture.md
- `Event Sourcing` --rationale_for--> `Materialized State vs Event History`  [INFERRED]
  AGENTS.md → db_schema.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Real-time State Pipeline** — product_spec_md_device, api_contract_md_mqtt_tele_state, agents_md_fastapi_backend, api_contract_md_ws_device_state [INFERRED 0.95]
- **End-to-End Device Provisioning** — product_spec_md_device_provisioning, architecture_md_provisioning_flow, db_schema_md_pairing_tokens, api_contract_md_patch_devices_link [INFERRED 0.85]
- **Phone OTP to JWT Auth Stack** — agents_md_phone_otp_auth, api_contract_md_post_auth_send_otp, api_contract_md_post_auth_verify_otp, architecture_md_jwt_auth [INFERRED 0.95]
- **Backend Python Dependency Stack** — backend_requirements_fastapi, backend_requirements_uvicorn, backend_requirements_sqlalchemy, backend_requirements_asyncpg, backend_requirements_alembic, backend_requirements_gmqtt, backend_requirements_python_jose [INFERRED 0.85]
- **Backend Docker Compose Stack** — backend_docker_compose_app_service, backend_docker_compose_db_service, backend_docker_compose_pgdata_volume, backend_docker_compose_port_5433 [EXTRACTED 1.00]
- **smartplug Multi-Platform Application Targets** — mobile_linux_cmakelists_smartplug_binary, mobile_windows_cmakelists_smartplug_binary, mobile_web_index_html_smartplug [INFERRED 0.95]
- **Flutter Desktop CMake Build Pipeline** — mobile_linux_cmakelists, mobile_linux_flutter_cmakelists_linux_flutter_library, mobile_linux_runner_cmakelists_linux_executable, mobile_windows_cmakelists, mobile_windows_flutter_cmakelists_windows_flutter_library, mobile_windows_runner_cmakelists_windows_executable [INFERRED 0.85]
- **Next.js Starter Template UI Icons** — frontend_public_file, frontend_public_globe, frontend_public_window [INFERRED 0.85]
- **Next.js and Vercel Branding Logos** — frontend_public_next, frontend_public_vercel, frontend_public_next_wordmark, frontend_public_vercel_triangle [INFERRED 0.85]
- **ic_launcher.png across Android mipmap density buckets** — mobile_android_app_src_main_res_mipmap_hdpi_ic_launcher_launcher_icon_asset_set, concept_mipmap_density_variants [EXTRACTED 1.00]
- **iOS AppIcon size variants (iPhone, iPad, App Store)** — mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_1x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_2x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_3x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_1x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_2x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_3x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_1x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_2x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_3x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_2x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_3x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_1x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_2x, mobile_ios_runner_assets_xcassets_appicon_appiconset_icon_app_83_5x83_5_2x [EXTRACTED 1.00]
- **iOS LaunchImage.imageset Splash Screens** — mobile_ios_runner_assets_xcassets_launchimage_imageset_launchimage, mobile_ios_runner_assets_xcassets_launchimage_imageset_launchimage_2x, mobile_ios_runner_assets_xcassets_launchimage_imageset_launchimage_3x [EXTRACTED 1.00]
- **macOS AppIcon.appiconset Multi-Resolution Icons** — mobile_macos_runner_assets_xcassets_appicon_appiconset_app_icon_16, mobile_macos_runner_assets_xcassets_appicon_appiconset_app_icon_32, mobile_macos_runner_assets_xcassets_appicon_appiconset_app_icon_64, mobile_macos_runner_assets_xcassets_appicon_appiconset_app_icon_128, mobile_macos_runner_assets_xcassets_appicon_appiconset_app_icon_256, mobile_macos_runner_assets_xcassets_appicon_appiconset_app_icon_512, mobile_macos_runner_assets_xcassets_appicon_appiconset_app_icon_1024 [EXTRACTED 1.00]
- **Flutter Web PWA and Favicon Icons** — mobile_web_favicon, mobile_web_icons_icon_192, mobile_web_icons_icon_512, mobile_web_icons_icon_maskable_192, mobile_web_icons_icon_maskable_512 [EXTRACTED 1.00]

## Communities (153 total, 32 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.06
Nodes (52): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+44 more)

### Community 1 - "app_localizations.dart"
Cohesion: 0.01
Nodes (155): app_localizations_en.dart, app_localizations_fa.dart, class, accept, accessLabel, addDevice, addDeviceHint, addShare (+147 more)

### Community 2 - "AppDelegate"
Cohesion: 0.06
Nodes (27): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterPluginRegistry (+19 more)

### Community 3 - "Docker Compose DB Service (postgres:15-alpine)"
Cohesion: 0.40
Nodes (5): Docker Compose App Service (FastAPI uvicorn), Docker Compose DB Service (postgres:15-alpine), pgdata Docker Volume, PostgreSQL Port Mapping 5433:5432, uvicorn[standard]

### Community 4 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (140): accept, accessLabel, addDevice, addDeviceHint, addShare, allDevices, apConnectBody, apConnected (+132 more)

### Community 5 - "[id]/page.tsx"
Cohesion: 0.11
Nodes (23): AddDevicePage(), Step, STEPS, EVENT_COLORS, SECTION_IDS, PowerToggle(), PowerToggleProps, Button() (+15 more)

### Community 6 - "device_models.dart"
Cohesion: 0.06
Nodes (29): int get, apiBaseUrl, deviceApConfigureUrl, mqttBrokerHost, mqttBrokerPort, wsBaseUrl, command, connectivity (+21 more)

### Community 7 - "Linux Desktop CMake Project"
Cohesion: 0.09
Nodes (30): Linux Desktop CMake Project, GTK Application ID com.example.smartplug, APPLY_STANDARD_SETTINGS Build Function, GTK+ 3.0 Dependency, Linux Relocatable Install Bundle, smartplug Linux Executable, flutter_assemble Custom Target, GTK GLIB GIO PkgConfig Dependencies (+22 more)

### Community 8 - "index.ts"
Cohesion: 0.09
Nodes (35): request(), tryRefresh(), AdminDeviceCreateRequest, AdminDeviceListResponse, AdminDeviceUpdateRequest, AdminEventListResponse, AdminHouseholdListResponse, AdminPairingTokenRequest (+27 more)

### Community 9 - "auth.tsx"
Cohesion: 0.12
Nodes (21): AdminLayout(), DashboardPage(), DeviceDetailPage(), AuthLayout(), HelpPanel(), HelpPanelProps, SECTION_KEYS, LanguageSwitcher() (+13 more)

### Community 10 - "websocket_client.dart"
Cohesion: 0.07
Nodes (26): _channel, connect, _controller, data, deviceId, disconnect, dispose, _disposed (+18 more)

### Community 11 - "home_screen.dart"
Cohesion: 0.15
Nodes (15): ConsumerState, ConsumerStatefulWidget, createState, HomeScreen, _HomeScreenState, _selectedHouseholdId, ApSetupScreen, _ApSetupScreenState (+7 more)

### Community 12 - "login_screen.dart"
Cohesion: 0.09
Nodes (26): authProvider, build, _buildOtpStep, _buildPhoneStep, _countdown, createState, dispose, _error (+18 more)

### Community 13 - "device_service.py"
Cohesion: 0.11
Nodes (23): apply_local_telemetry(), create_device_event(), get_device_by_serial(), handle_availability_message(), handle_event_message(), handle_state_message(), AsyncSession, Device (+15 more)

### Community 14 - "auth_provider.dart"
Cohesion: 0.09
Nodes (23): ../../data/repositories/auth_repository.dart, int?, AuthNotifier, AuthState, AuthStatus, build, _checkAuth, copyWith (+15 more)

### Community 15 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 16 - "app_localizations_fa.dart"
Cohesion: 0.01
Nodes (141): app_localizations.dart, accept, accessLabel, addDevice, addDeviceHint, addShare, allDevices, apConnectBody (+133 more)

### Community 17 - "access_control.py"
Cohesion: 0.17
Nodes (22): get_db(), get_current_user(), AsyncSession, User, require_device_permission(), require_platform_admin(), get_device_shares(), get_effective_permission() (+14 more)

### Community 18 - "ap_setup_screen.dart"
Cohesion: 0.07
Nodes (31): ../../../data/models/provisioning_models.dart, provisioningProvider, build, _buildConnectToAp, _buildFailed, _buildInstructions, _buildSendingCreds, _buildStepContent (+23 more)

### Community 19 - "devDependencies"
Cohesion: 0.05
Nodes (37): eslint, eslint-config-next, dependencies, next, next-intl, react, react-dom, devDependencies (+29 more)

### Community 20 - "provisioning_provider.dart"
Cohesion: 0.09
Nodes (21): dart:async, ../../data/repositories/provisioning_repository.dart, build, claimDevice, claimedDeviceId, clearError, error, fetchPairingToken (+13 more)

### Community 21 - "device_detail_provider.dart"
Cohesion: 0.11
Nodes (16): ../../../data/repositories/device_repository.dart, applyLiveUpdate, build, DeviceDetailNotifier, _deviceId, fetch, refresh, _repo (+8 more)

### Community 22 - "Base"
Cohesion: 0.31
Nodes (18): AutomationRule, Base, SoftDeleteMixin, TimestampMixin, UUIDMixin, Device, DeviceEvent, DeviceNetworkConfig (+10 more)

### Community 23 - "devices.py"
Cohesion: 0.10
Nodes (51): _broadcast_state(), control_device(), create_device_pairing_token(), create_local_test_device(), create_provisioning_pairing_token(), delete_device(), _device_to_response(), get_device() (+43 more)

### Community 24 - "از اینجا شروع کنید — راهنمای جامع SmartPlug"
Cohesion: 0.09
Nodes (23): از اینجا شروع کنید — راهنمای جامع SmartPlug, اسکریپت‌های آماده, الف) MQTT محلی (Mosquitto داخل Docker), انتشار روی VPS, انتشار وضعیت آزمایشی (local), ب) MQTT روی VPS (بروکر از راه دور), حالت MQTT: محلی یا VPS, روش الف — از پنل کاربر (سریال واقعی) (+15 more)

### Community 25 - "device_shares_screen.dart"
Cohesion: 0.11
Nodes (19): ../../../core/utils/phone_validator.dart, deviceShareListProvider, build, _buildCreateForm, _confirmRevoke, createState, _creating, deviceId (+11 more)

### Community 26 - "device_detail_screen.dart"
Cohesion: 0.12
Nodes (18): wsProvider, createState, device, DeviceDetailScreen, _DeviceDetailScreenState, deviceId, dispose, _infoRow (+10 more)

### Community 27 - "compilerOptions"
Cohesion: 0.07
Nodes (28): compilerOptions, allowJs, esModuleInterop, incremental, isolatedModules, jsx, lib, module (+20 more)

### Community 28 - "routers/admin.py"
Cohesion: 0.17
Nodes (28): AdminDeviceCreateRequest, AdminDeviceUpdateRequest, AdminPairingTokenRequest, admin_create_device(), admin_create_pairing_token(), admin_list_devices(), admin_list_events(), admin_list_households() (+20 more)

### Community 29 - "routers/auth.py"
Cohesion: 0.12
Nodes (32): AsyncSession, post, refresh_token_endpoint(), send_otp(), verify_otp_endpoint(), DevOtpResponse, get_dev_otp(), AsyncSession (+24 more)

### Community 30 - "SmartPlug Production Deployment Guide"
Cohesion: 0.06
Nodes (35): Application, Backend (`/opt/smartplug/backend/.env`), Database backup, Deploy new API version, Deployment procedure, Docker deployment strategy, Document map, Environment variables (+27 more)

### Community 31 - "households.py"
Cohesion: 0.20
Nodes (19): create_household(), delete_household(), get_household(), list_households(), AsyncSession, delete, get, patch (+11 more)

### Community 32 - "Start Here — SmartPlug Setup Guide"
Cohesion: 0.10
Nodes (20): 1. Environment setup, 2. Choose MQTT mode, 3. Health check, 4. Login and platform admin, 5. Register a device, 6. MQTT test, 7. Stop, Listen for commands (+12 more)

### Community 34 - "event_provider.dart"
Cohesion: 0.12
Nodes (17): ../../data/models/event_models.dart, ../../data/repositories/event_repository.dart, FamilyNotifier, build, copyWith, currentDeviceId, error, EventListNotifier (+9 more)

### Community 35 - "iOS AppIcon Asset Catalog (AppIcon.appiconset)"
Cohesion: 0.12
Nodes (17): Flutter Default App Icon (blue geometric F logo on white), iOS AppIcon Asset Catalog (AppIcon.appiconset), Icon-App-1024x1024@1x (iOS marketing / App Store), Icon-App-20x20@1x (iPad notification), Icon-App-20x20@2x (iPhone/iPad notification), Icon-App-20x20@3x (iPhone notification), Icon-App-29x29@1x (iPad settings), Icon-App-29x29@2x (iPhone/iPad settings) (+9 more)

### Community 36 - "app_router.dart"
Cohesion: 0.10
Nodes (21): GoRouter, build, SmartPlugApp, localeProvider, appRouterProvider, isLoggedIn, _rootNavigatorKey, NavigatorState (+13 more)

### Community 37 - "MQTT محلی در مقابل VPS"
Cohesion: 0.12
Nodes (16): MQTT محلی در مقابل VPS, اجرا, اجرا, تست, تست, تنظیم `.env`, تنظیم `.env`, حالت Local (Mosquitto در Docker) (+8 more)

### Community 38 - "API Contract"
Cohesion: 0.06
Nodes (35): 1. Authentication, 2. Households, 3. Devices, 4. Real-time State, 5. Events, 6. Sharing, 7. MQTT Topics, 8. Error Responses (+27 more)

### Community 39 - "macOS App Icon Platform Assets"
Cohesion: 0.14
Nodes (15): macOS App Icon Platform Assets, Flutter Default Framework Branding, Flutter Web PWA Icon Platform Assets, Flutter Logo macOS App Icon (1024px), Flutter Logo macOS App Icon (128px), Flutter Logo macOS App Icon (16px), Flutter Logo macOS App Icon (256px), Flutter Logo macOS App Icon (32px) (+7 more)

### Community 40 - "ws_provider.dart"
Cohesion: 0.13
Nodes (14): ../../core/network/websocket_client.dart, WebSocketClient, build, _client, connect, disconnect, isConnected, reconnectAfterLogin (+6 more)

### Community 41 - "provisioning_models.dart"
Cohesion: 0.13
Nodes (14): ApSetupStep, DeviceLinkRequest, DeviceRegisterRequest, expiresAt, fromJson, householdId, id, name (+6 more)

### Community 42 - "device_control_provider.dart"
Cohesion: 0.09
Nodes (29): ConsumerWidget, device_detail_provider.dart, device_list_provider.dart, _applyOptimisticUpdate, build, clearError, DeviceControlNotifier, deviceControlProvider (+21 more)

### Community 43 - "auth_models.dart"
Cohesion: 0.14
Nodes (13): accessToken, code, expiresIn, expiresInSeconds, fromJson, phone, refreshToken, retryAfterSeconds (+5 more)

### Community 44 - "share_models.dart"
Cohesion: 0.14
Nodes (13): createdAt, fromJson, granteePhone, id, permission, scope, scopeId, Share (+5 more)

### Community 45 - "راهنمای پیکربندی MQTT (Mosquitto)"
Cohesion: 0.15
Nodes (13): ACL, تست از راه دور, تست سریع با Docker (توسعه), خطای رایج: `Duplicate persistence_location`, خطای رایج: `include_dir` کامنت شده, خطای رایج: TLS بدون گواهی, راهنمای پیکربندی MQTT (Mosquitto), فایروال (+5 more)

### Community 46 - "SmartPlug — IoT Smart Plug Platform"
Cohesion: 0.05
Nodes (44): 1. Clone & enter, 2. Backend setup, 3. Frontend setup, 4. Mobile setup (optional), API Reference, Architecture Overview, Backend, Backend (`backend/.env`) (+36 more)

### Community 47 - "event_history_screen.dart"
Cohesion: 0.18
Nodes (12): eventListProvider, build, createState, deviceId, dispose, EventHistoryScreen, _EventHistoryScreenState, _eventTile (+4 more)

### Community 48 - "Spinner.tsx"
Cohesion: 0.21
Nodes (4): Spinner(), AdminHouseholdResponse, AdminStatsResponse, AdminUserResponse

### Community 49 - "[locale]/layout.tsx"
Cohesion: 0.22
Nodes (6): metadata, vazirmatn, Providers(), Locale, routing, config

### Community 50 - "file.svg Static Asset"
Cohesion: 0.29
Nodes (13): file.svg Static Asset, Document Icon with Folded Corner and Text Lines, globe.svg Static Asset, Globe World Icon with Meridians and Parallels, next.svg Static Asset, Next.js Wordmark Logo, vercel.svg Static Asset, Vercel Triangle Logo Mark (+5 more)

### Community 51 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.20
Nodes (8): app.dart, load, main, main, package:flutter_dotenv/flutter_dotenv.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart, package:smartplug/app.dart

### Community 52 - "app_theme.dart"
Cohesion: 0.15
Nodes (12): AppTheme, error, light, off, offline, on, online, primary (+4 more)

### Community 53 - "api_client.dart"
Cohesion: 0.11
Nodes (18): ../constants/api_constants.dart, ../../core/constants/api_constants.dart, ../../core/storage/secure_storage.dart, dart:convert, ../../data/models/api_error.dart, _client, _headers, instance (+10 more)

### Community 54 - "secure_storage.dart"
Cohesion: 0.12
Nodes (15): _accessTokenKey, async, clear, _phoneKey, _refreshTokenKey, saveTokens, SecureStorage, updateTokens (+7 more)

### Community 55 - "shares.py"
Cohesion: 0.17
Nodes (23): create_share(), incoming_shares(), list_shares(), AsyncSession, delete, get, patch, post (+15 more)

### Community 56 - "DeviceResponse"
Cohesion: 0.24
Nodes (10): DashboardDeviceCard(), DashboardDeviceCardProps, relativeTime(), DeviceCard(), DeviceCardProps, PowerBadge(), PowerBadgeProps, StateBadge() (+2 more)

### Community 57 - "help_screen.dart"
Cohesion: 0.15
Nodes (12): build, _HelpSection, _sections, steps, title, build, build, package:go_router/go_router.dart (+4 more)

### Community 58 - "AGENTS.md — MQTT-Mobile-WEB"
Cohesion: 0.13
Nodes (15): AGENTS.md — MQTT-Mobile-WEB, Backend commands (from `backend/`), Backend gotchas, Frontend commands (from `frontend/`), Frontend gotchas, Full stack Docker (repo root — recommended for MQTT testing), Key constraints, Mobile commands (from `mobile/`) (+7 more)

### Community 59 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16() (+1 more)

### Community 60 - "device_states table"
Cohesion: 0.20
Nodes (11): MQTT Topic Structure, handle_state_message, cmnd/{serial}/power, tele/{serial}/state, PATCH /devices/{id}/control, WebSocket /ws/devices/{id}/state, WebSocket Real-time Updates, device_states table (+3 more)

### Community 61 - "share_repository.dart"
Cohesion: 0.18
Nodes (10): accept, _api, create, decline, listDeviceShares, listIncoming, listMyShares, revoke (+2 more)

### Community 62 - "household_models.dart"
Cohesion: 0.18
Nodes (10): createdAt, deviceCount, fromJson, Household, HouseholdCreateRequest, id, name, role (+2 more)

### Community 63 - "app_constants.dart"
Cohesion: 0.20
Nodes (9): AppConstants, defaultPageSize, httpTimeout, otpExpireSeconds, otpLength, otpRetryAfterSeconds, wsReconnectDelay, static const Duration (+1 more)

### Community 64 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 65 - "Tables"
Cohesion: 0.12
Nodes (16): `automation_rules` (future), Database Schema, `device_events`, `device_network_config`, `device_states`, `devices`, Entity Relationships, `household_members` (+8 more)

### Community 66 - "package:flutter/material.dart"
Cohesion: 0.08
Nodes (25): Color, IconData, _InfoTab, _ReadingsTab, HelpScreen, icon, onTap, _OptionCard (+17 more)

### Community 67 - "راه‌اندازی سریع با Docker"
Cohesion: 0.20
Nodes (10): راه‌اندازی سریع با Docker, عیب‌یابی, مستندات مرتبط, پیش‌نیازها, ۱. تنظیم محیط, ۲. اجرای سرویس‌ها, ۳. بررسی سلامت سرویس‌ها, ۴. تست MQTT (+2 more)

### Community 68 - "main.py"
Cohesion: 0.08
Nodes (23): AppException, Exception, FastAPI, register_exception_handlers(), configure_logging(), lifespan(), FastAPI, health_check() (+15 more)

### Community 69 - "share_provider.dart"
Cohesion: 0.06
Nodes (35): AsyncNotifier, ../../data/models/share_models.dart, ../../data/repositories/share_repository.dart, List, Map, DeviceEvent, deviceId, events (+27 more)

### Community 70 - "event_repository.dart"
Cohesion: 0.29
Nodes (6): ../../core/constants/app_constants.dart, ../../core/network/api_client.dart, _api, EventRepository, getDeviceEvents, ../models/event_models.dart

### Community 71 - "device_repository.dart"
Cohesion: 0.20
Nodes (9): _api, control, createLocalTest, delete, DeviceRepository, list, simulate, updateName (+1 more)

### Community 72 - "households table"
Cohesion: 0.25
Nodes (8): Households REST API, household_members table, households table, users table, Customer, Household, Sharee, User

### Community 73 - "date_formatter.dart"
Cohesion: 0.29
Nodes (6): date, diff, formatDateTime, formatRelativeTime, now, package:intl/intl.dart

### Community 74 - "phone_validator.dart"
Cohesion: 0.29
Nodes (6): _e164Pattern, formatPhoneError, isValidE164, null, trimmed, return

### Community 75 - "4. Features (v1)"
Cohesion: 0.18
Nodes (11): Share via Phone Number, Sharing REST API, share_permissions table, 4. Features (v1), Device control, Device provisioning, Event history, Permission Levels (view/control/admin) (+3 more)

### Community 76 - "link_device_screen.dart"
Cohesion: 0.09
Nodes (24): ../../../data/models/household_models.dart, ../../data/repositories/household_repository.dart, build, create, delete, _fetch, householdListProvider, refresh (+16 more)

### Community 77 - "config.py"
Cohesion: 0.32
Nodes (5): do_run_migrations(), run_async_migrations(), run_migrations_online(), Settings, BaseSettings

### Community 78 - "AGENTS.md"
Cohesion: 0.18
Nodes (11): Event Sourcing, FastAPI Backend, Flutter Mobile App, Next.js 16 Web Frontend, 1. System Context, 2. Cloud/Local Hybrid Behavior, 3. Device Provisioning Flow, 4. MQTT Topic Structure (+3 more)

### Community 79 - "راهنمای استقرار (خلاصه فارسی)"
Cohesion: 0.25
Nodes (8): استقرار تولید (خلاصه), توسعه محلی — Docker (توصیه شده), راهنمای استقرار (خلاصه فارسی), متغیرهای مهم `.env`, مستندات کامل انگلیسی, معماری, پنل مدیریت, چک‌لیست امنیت

### Community 80 - "استقرار روی VPS"
Cohesion: 0.25
Nodes (8): استقرار روی VPS, عیب‌یابی, چه چیزی روی سرور بالا می‌آید؟, ۱. روی VPS, ۲. ورود و تست بدون سخت‌افزار, ۳. دستگاه واقعی (ESP) به MQTT سرور, ۴. اگر Mosquitto از قبل روی VPS نصب است, ۵. فایروال و Mosquitto میزبان

### Community 81 - "../../core/theme/app_theme.dart"
Cohesion: 0.12
Nodes (16): ../../core/theme/app_theme.dart, ../../core/utils/date_formatter.dart, ../../data/models/device_models.dart, incomingShareListProvider, build, IncomingSharesScreen, _incomingTile, build (+8 more)

### Community 82 - "Device Provisioning Sequence"
Cohesion: 0.14
Nodes (17): Device Provisioning Flow, Phone-number OTP Authentication, Devices REST API, GET /devices/{id}/events, tele/{serial}/event, PATCH /devices/{id}/link, POST /auth/send-otp, POST /auth/verify-otp (+9 more)

### Community 83 - "Cloud/Local Hybrid Behavior"
Cohesion: 0.40
Nodes (5): Cloud/Local Dual MQTT, MQTT Broker (EMQX/Mosquitto), Cloud/Local Hybrid Behavior, Cloud MQTT Broker, Local MQTT Broker (LAN)

### Community 84 - "dashboard/page.tsx"
Cohesion: 0.36
Nodes (6): EnrichedEvent, EVENT_COLORS, HouseholdSelector(), HouseholdSelectorProps, DeviceEventResponse, HouseholdResponse

### Community 85 - "Android Launcher Icon Asset Set (ic_launcher.png, mipmap density variants)"
Cohesion: 0.40
Nodes (5): Android App Launcher Icon, Flutter UI Framework, Mipmap Density Variants (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi), Flutter Logo (default boilerplate launcher graphic), Android Launcher Icon Asset Set (ic_launcher.png, mipmap density variants)

### Community 86 - "Black Placeholder Launch Splash"
Cohesion: 0.60
Nodes (5): Black Placeholder Launch Splash, Solid Black Splash Screen (1x), Solid Black Splash Screen (2x), Solid Black Splash Screen (3x), iOS Launch Image Platform Assets

### Community 87 - "راهنمای پنل مدیریت پلتفرم"
Cohesion: 0.29
Nodes (7): API (برای اتوماسیون), ایجاد توکن جفت‌سازی, بخش‌ها, ثبت سریال کارخانه, دسترسی, راهنمای پنل مدیریت پلتفرم, نکات

### Community 88 - "[id]/shares/page.tsx"
Cohesion: 0.57
Nodes (5): DeviceSharesPage(), LoginPageContent(), formatPhoneError(), isValidE164(), SharedUserResponse

### Community 90 - "Device Registration Flow"
Cohesion: 0.06
Nodes (33): Access control details, API reference (registration-related), Authentication, Commercial ownership model, Customer journey, Database flow, Device Registration Flow, Devices (+25 more)

### Community 91 - "household_repository.dart"
Cohesion: 0.29
Nodes (6): _api, create, delete, HouseholdRepository, list, ../models/household_models.dart

### Community 92 - "Launch Screen Customization"
Cohesion: 0.40
Nodes (4): Runner Assets.xcassets, Launch Screen Customization, Launch Screen Assets, Runner Xcode Workspace

### Community 93 - "list_device_events"
Cohesion: 0.40
Nodes (4): list_device_events(), get, Device event history router. Extend here: query events with pagination and…, List events for a device. TODO: implement.

### Community 94 - "vps-up.sh"
Cohesion: 0.40
Nodes (4): CORS_ORIGINS, NEXT_PUBLIC_API_URL, NEXT_PUBLIC_DEFAULT_LOCALE, vps-up.sh script

### Community 96 - "Dart Analyzer Configuration"
Cohesion: 0.67
Nodes (3): Dart Analyzer Configuration, Dart Static Analyzer, flutter_lints Recommended Lint Set

### Community 97 - "event.py"
Cohesion: 0.67
Nodes (3): DeviceEventListResponse, DeviceEventResponse, BaseModel

### Community 136 - "MQTT Server Setup (Mosquitto)"
Cohesion: 0.06
Nodes (32): Access control (ACL), Additional measures, Backend service account, Backend wildcard subscriptions, Backend wiring, Cloud → Device (backend publishes, ESP subscribes), Connect parameters, Device → Cloud (ESP publishes, backend subscribes) (+24 more)

### Community 138 - "frontend/README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 139 - "Server Architecture"
Cohesion: 0.06
Nodes (32): Cloud / local hybrid control paths, Core services (backend), Data model (multi-device), Device command flow (full trace), Discovery and listing, Failure modes and HTTP codes, Future horizontal scaling, Monitoring hooks (+24 more)

### Community 141 - "Device Provisioning Flow (First Boot)"
Cohesion: 0.07
Nodes (28): Cloud / local hybrid during provisioning, `cmnd/{serial}/power`, Device Provisioning Flow (First Boot), Diagnostic commands, Factory reset / re-provisioning, Firmware ↔ backend payload contract, High-level flow, Multi-device provisioning in one home (+20 more)

### Community 142 - "api_error.dart"
Cohesion: 0.20
Nodes (9): bool get, ApiError, detail, isNotFound, isRateLimited, isUnauthorized, isValidationError, statusCode (+1 more)

### Community 143 - "Quick Start with Docker"
Cohesion: 0.18
Nodes (11): 1. Configure environment, 2. Start the stack, 3. Verify services, 4. Test MQTT, 5. Register a device, 6. Stop, Persian guide, Prerequisites (+3 more)

### Community 144 - "provisioning_repository.dart"
Cohesion: 0.20
Nodes (9): ../../core/network/device_ap_client.dart, _api, configureDeviceAp, createPairingToken, getUnlinked, link, ProvisioningRepository, register (+1 more)

### Community 147 - "auth_repository.dart"
Cohesion: 0.25
Nodes (7): ApiClient, _api, AuthRepository, refresh, sendOtp, verifyOtp, ../models/auth_models.dart

### Community 150 - "Product Specification — Smart Plug Platform"
Cohesion: 0.25
Nodes (7): 1. Overview, 2. Target users, 3. Entities, 5. Non-goals (explicitly excluded in v1), 6. Future (explicitly deferred), Smart Plug Platform, Product Specification — Smart Plug Platform

### Community 153 - "AppLocalizations"
Cohesion: 0.40
Nodes (6): LocalizationsDelegate, AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, AppLocalizationsFa, of

### Community 160 - "SmartPlug Documentation"
Cohesion: 0.33
Nodes (6): Docker Compose profiles (summary), English guides (`docs/en/`), Persian guides (`docs/fa/`), Root-level references (English), SmartPlug Documentation, Start here

## Ambiguous Edges - Review These
- `Device Provisioning Sequence` → `devices table`  [AMBIGUOUS]
  architecture.md · relation: conceptually_related_to
- `Globe World Icon with Meridians and Parallels` → `Browser Window Icon with Title-Bar Control Dots`  [AMBIGUOUS]
  frontend/public/globe.svg · relation: conceptually_related_to

## Knowledge Gaps
- **1370 isolated node(s):** `docker-entrypoint.sh script`, `docker-up.sh script`, `mqtt-test.sh script`, `vps-up.sh script`, `NEXT_PUBLIC_API_URL` (+1365 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **32 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Device Provisioning Sequence` and `devices table`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Globe World Icon with Meridians and Parallels` and `Browser Window Icon with Title-Bar Control Dots`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **Why does `AppLocalizations` connect `AppLocalizations` to `app_localizations.dart`, `device_detail_screen.dart`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **Why does `LocaleNotifier` connect `device_control_provider.dart` to `[locale]/layout.tsx`, `secure_storage.dart`?**
  _High betweenness centrality (0.063) - this node is a cross-community bridge._
- **Why does `Locale` connect `[locale]/layout.tsx` to `auth.tsx`, `device_control_provider.dart`?**
  _High betweenness centrality (0.063) - this node is a cross-community bridge._
- **Are the 12 inferred relationships involving `Base` (e.g. with `AutomationRule` and `Device`) actually correct?**
  _`Base` has 12 INFERRED edges - model-reasoned connections that need verification._
- **Are the 11 inferred relationships involving `TimestampMixin` (e.g. with `AutomationRule` and `Device`) actually correct?**
  _`TimestampMixin` has 11 INFERRED edges - model-reasoned connections that need verification._