# ChameleonUltraGUI
A GUI for the Chameleon Ultra written in Flutter for crossplatform operation

[![Autobuild](https://github.com/GameTec-live/ChameleonUltraGUI/actions/workflows/buildapp.yml/badge.svg)](https://github.com/GameTec-live/ChameleonUltraGUI/actions/workflows/buildapp.yml) 
[![Open collective](https://opencollective.com/chameleon-ultra-gui/tiers/badge.svg)](https://opencollective.com/chameleon-ultra-gui#support)

## Installation
You can download the latest builds from Github Actions [here](https://github.com/GameTec-live/ChameleonUltraGUI/actions/workflows/buildapp.yml?query=branch%3Amain) under the artifacts section.

Note: Under some Linux systems, especially ones running KDE desktop enviroments, you may need to install the zenity package for the filepicker to work correctly.

Key:
- apk: Android APK, download and install either via ADB or your app/filemanager of choice
- appbundle: Android Appbundle, unsigned Appbundle, used for Google Playstore publishing (soonTM)
- linux: zip file containing the linux build, either run the binary manually or install using cmake
- linux-debian: Debain Auto Packaging, Download and install with either apt, apt-get or dpkg.
- windows: zip file containing windows build, run the binary manually
- windows-installer: NSIS based Windows Installer, Installs the Windows build and creates Shortcuts

#### Note for Linux users:
You might need to add your user to the dialout or, on archlinux, to the uucp group for the app to talk to the device. If your user is not in this group, you may get serial or permission errors.
It is also highly recommended to either uninstal or disable modemmanager (`sudo systemctl disable --now modemmanager`) as many distros ship modemmanager and it may interfere with communication.

## Contributing
Contributions are welcome, most stuff that needs to be done can either be found in our [issues](https://github.com/GameTec-live/ChameleonUltraGUI/issues) or on the [Project board](https://github.com/users/GameTec-live/projects/2)

## Screenshots
![Connect Page](/screenshots/connect.png)
![Home Page](/screenshots/home.png)
![Slot Manager Page](/screenshots/smanager.png)
![Saved Cards Page](/screenshots/saved.png)
![Read Card Page](/screenshots/rcard.png)
![Settings Page](/screenshots/settings.png)
![Dev Page](/screenshots/devpage.png)

<details>
  <summary>Mac and IOS</summary>

  ### Mac and IOS
  Why are there no Mac and IOS builds?
  It is planned to provide Mac and IOS builds at some point, but due to none of us owning a Mac and Apple charging a 100$ a year fee development has a very low priority.
  Apples hardware is also more locked down, so it may not even be possible to use serial communication and using bluetooth isnt even possible on the chameleon ultra, yet.

  TLDR; yes, some day, but very low priority.
</details>

## Donate
If you want to support us and donate 1) Thank you, you make it possible for us to keep this app free and make it easier to publish this app on the apple appstore 2) You have the following options:

Open Collective: [ChameleonUltraGUI](https://opencollective.com/chameleon-ultra-gui)

Crypto Currencies if your into that jam (Altough open collective is preffered):
- BTC: bc1qrcd4ctxagaxsetyhpzc08d2upl0mh498gp3lkl
- ETH: 0x0f20e505E9e534236dF4390DcFfD5C4A03C0eec7
