<p align="center">
  <img src="https://github.com/K3V1991/ADB-and-FastbootPlusPlus/blob/main/ADB-and-FastbootPlusPlus.png" width="200" alt="ADB & Fastboot++">
</p>

<h1 align="center"><b>ADB &amp; Fastboot++</b></h1>

<h4 align="center">
A small Windows application that gives you <b>ADB</b> and <b>Fastboot</b>
without installing the full Android SDK. It ships a batch toolkit with menus
for debloating, installing APKs / kernels / recoveries, taking screenshots,
recording the screen, and inspecting versions, IMEI, IPs, and more.
</h4>

<p align="center">
<a href="https://forum.xda-developers.com/t/tool-windows-adb-fastboot-february-2023.3944288/" alt="XDA-Developers"><img src="https://img.shields.io/badge/XDA--Developers-%23AC6E2F.svg?style=for-the-badge&logo=XDA-Developers&logoColor=white" /></a>
  <a href="https://github.com/matiasdieztj/ADB-and-FastbootPlusPlus/releases">
    <img src="https://img.shields.io/github/v/release/matiasdieztj/ADB-and-FastbootPlusPlus?color=blueviolet&style=for-the-badge" alt="Release">
  </a>
  <a href="https://github.com/matiasdieztj/ADB-and-FastbootPlusPlus/releases">
    <img src="https://img.shields.io/github/downloads/matiasdieztj/ADB-and-FastbootPlusPlus/total?color=success&style=for-the-badge" alt="Downloads">
  </a>
</p>

<hr />

## What changed in this fork

- **The repository no longer ships `platform-tools`.** The latest official
  Google build is downloaded automatically on first use, or bundled at release
  time via **GitHub Actions**.
- The `Release` workflow triggers when you publish a GitHub Release, downloads
  `platform-tools-latest-windows.zip`, reads the real version (`Pkg.Revision`)
  from `source.properties`, updates this README, and builds the portable ZIP
  with `platform-tools/` at its root.
- `Toolkit - Portable.bat` looks for `adb.exe` and `fastboot.exe` inside
  `.\platform-tools\` (Google's official layout).

<!-- PT_VERSION -->
**Bundled platform-tools:** _(auto-filled when a release is published)_
<!-- /PT_VERSION -->

## Portable ZIP layout

```

ADB-and-FastbootPlusPlus-Portable-<tag>.zip
├── OpenCMD.bat
├── Toolkit - Portable.bat
├── _bootstrap.bat
├── Commands.txt
├── DevAndUSB.txt
├── README.md
└── platform-tools/
├── adb.exe
├── AdbWinApi.dll
├── AdbWinUsbApi.dll
├── fastboot.exe
└── source.properties

```

## Usage — official release (recommended)

1. Open the [**Releases**](https://github.com/matiasdieztj/ADB-and-FastbootPlusPlus/releases)
   tab and download the latest `ADB-and-FastbootPlusPlus-Portable-*.zip`.
2. Extract the ZIP anywhere (e.g. `C:\ADB`).
3. Double-click **`OpenCMD.bat`**.
4. Done: a console opens with `adb` and `fastboot` already on the `PATH`.

The ZIP already contains `platform-tools/`, so `_bootstrap.bat` does nothing.

## Usage — cloning the repo (development)

1. Clone the repo:
   ```powershell
   git clone https://github.com/matiasdieztj/ADB-and-FastbootPlusPlus.git
   cd ADB-and-FastbootPlusPlus
```

2. Double-click **`OpenCMD.bat`**.
3. Because `platform-tools/` is not tracked, `_bootstrap.bat` will ask you to
download the official ZIP from:

```
https://dl.google.com/android/repository/platform-tools-latest-windows.zip
```

Save it into the repo folder and press any key.
4. `_bootstrap.bat` extracts **only** `adb.exe`, `fastboot.exe`,
`AdbWinApi.dll`, `AdbWinUsbApi.dll` and `source.properties` into
`platform-tools\`, deletes everything else, and removes the original ZIP.
5. In the same run, it patches `Toolkit - Portable.bat` so it uses
`%~dp0platform-tools` instead of the legacy `ADB and Fastboot++ v1.1.1 Portable`.

`platform-tools/` is in `.gitignore`, so it won't be committed by accident.

## Toolkit — main features

- Debloat without root (uninstalls for the current user only).
- Reinstall uninstalled apps.
- Install kernels / recoveries (auto-reboots to bootloader + popup chooser).
- Install APKs and split APK bundles.
- Push files to the device.
- Check firmware, Android, kernel, and security patch versions.
- Check IMEI, IPs, installed packages, and live processes.
- Screenshots (PNG) and screen recording (30 / 60 / 120 / 180 s).
- Reboot / Reboot to bootloader / Reboot to recovery / Boot kernel.
- Bugreport and Logcat saved to the Desktop.

## Requirements

- Windows 10/11.
- OEM USB driver or the **Universal ADB Driver**.
- PowerShell (bundled with Windows).

## Enable Developer Options & USB Debugging

1. Install the USB driver for your phone or the **Universal ADB Driver**.
2. On the phone: **Settings → About phone**, tap *Build number* 7 times to
enable *Developer Options*.
3. **System → Developer Options → USB debugging** → enable.
4. Plug the phone into the PC and switch the USB mode from *Charging only* to
*File transfer*.
5. Open **`OpenCMD.bat`** and run:

```
adb devices
```
6. A dialog will appear on the phone asking to authorize the PC. Accept it.
7. Done.

## Unable to connect to ADB

- [AMD/Ryzen bug (XDA)](https://forum.xda-developers.com/t/fix-fastboot-issues-on-ryzen-based-pcs.4186321/)
- Switch the device from *Charging* to *File transfer* mode.
- Install the latest device driver or the Universal USB Driver.
- Try a different USB cable.
- Try a different port (USB 3.0 → USB 2.0).
- Run a `fastboot ...` command without the phone connected, and plug it in
only once it says `waiting for device`.
- Windows: **Power Options → Advanced settings → USB → USB selective suspend**
→ set to **Disabled** for both *On battery* and *Plugged in*.
- Try another PC.

## CI/CD

Workflow: [`.github/workflows/release.yml`](https://.github/workflows/release.yml)

Triggers:

- `release: types: [published]` → when you publish a GitHub Release.
- `workflow_dispatch` → manual run for testing without publishing.

Steps:

1. Downloads `platform-tools-latest-windows.zip` from Google.
2. Extracts it and reads `Pkg.Revision` from `source.properties`.
3. Patches `Toolkit - Portable.bat` if it still points to the legacy folder.
4. Updates the `<!-- PT_VERSION -->` block in this README.
5. Composes the ZIP with `OpenCMD.bat`, `Toolkit - Portable.bat`,
`_bootstrap.bat`, `Commands.txt`, `DevAndUSB.txt`, `README.md`, and
`platform-tools/`.
6. Uploads it as a release asset
(`ADB-and-FastbootPlusPlus-Portable-<tag>.zip`) or as a workflow artifact
when the run was manual.

## Versioning

The fork keeps the `v2.x.y` scheme. The `platform-tools` version is dictated
by Google: whichever is latest at release time. The `<!-- PT_VERSION -->`
block in this README is updated automatically to reflect what was bundled.

## Credits

- Original project: [K3V1991/ADB-and-FastbootPlusPlus](https://github.com/K3V1991/ADB-and-FastbootPlusPlus)
- platform-tools: [Google — Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools)
- Fork maintained by [matiasdieztj](https://github.com/matiasdieztj)

