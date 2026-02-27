# Development guide

## How to build

The fastest and recommended way to develop is using a local [Visual Studio Code](https://code.visualstudio.com/) dev environment. This repository contains a dev container setup for VS Code with all required development tools to build OpenCCU.

1. Please follow the instructions to download and install the [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) VS Code extension.
2. Open the root folder inside VS Code, and when prompted re-open the window inside the container (or, from the Command Palette, select 'Rebuild and Reopen in Container').
3. Follow one of the subsections below depending on what component you want to build

### Building OpenCCU images

1. When VS Code has opened your folder in the container (which can take some time for the first run) you will need to start a terminal (Terminal -> New Terminal).
2. Use `make` to build OpenCCU images. If you run `make` without targets, a list of available commands is printed.

### Building and testing the Home Assistant Add-on

1. When VS Code has opened your folder in the container (which can take some time for the first run) you'll need to run the task (Terminal -> Run Task) 'Start Home Assistant', which will bootstrap Supervisor and Home Assistant.
2. You'll then be able to access the normal onboarding process via the Home Assistant instance at `http://localhost:7123/`.
3. The add-on(s) found in your root folder will automatically be found in the Local Add-ons repository.
4. Install the OpenCCU add-on from the Supervisor menu.
5. Once installed, you need to start the add-on.
6. It is useful to enable “Show in sidebar” so you can open the OpenCCU WebUI (Note: you might need to wait a few seconds until it is available).

## Continuous Integration

OpenCCU uses GitHub Workflows for Continuous Integration. The actions tab shows available workflows.

## Requirements

OCI packages require a secret to be uploaded `CR_PAT`. See GitHub [instructions(<https://docs.github.com/en/packages/guides/migrating-to-github-container-registry-for-docker-images#authenticating-with-the-container-registry>)] on how to create a Personal Access Token to upload to the GitHub Container Registry.

## Workflows

- **ci**: on each push, pull request or manual - builds all artefacts (dev versions)
- **release**: manually triggered - builds a draft release and attach official builds. Updates OCI and Helm latest tags.
- **snapshot**: cronjob - only works on official repo (dummy in fork) - uploads all snapshot versions

## How to draft a release

1. As a first step and to prepare a draft release in which a raw ChangeLog will be added, go into the [Release Build](https://github.com/OpenCCU/OpenCCU/actions?query=workflow%3A%22Release+Build%22) action and run it, but make sure "Skip build" is set to true and you are using the upcoming release date in the "Release date override" setting
2. After this draft release build is done you should see a new draft release in the releases section with the raw changelog listing all changes. Make sure to edit them and sort them into the corresponding group and explaining in less technical details what was changed.
3. If you are done with finetuning the ChangeLog and Release draft make sure that the `config.yaml` file in the `home-assistant-addon-dev` vs. `home-assistant-addon` top-level directories have all latest development changes merged. You can use the following diff command to analyze:
   `diff -u home-assistant-addon-dev/config.yaml home-assistant-addon/config.yaml`
5. Go to [_Actions_ -> _Release Build_](https://github.com/OpenCCU/OpenCCU/actions?query=workflow%3A%22Release+Build%22)
6. Click on _Run Workflow_
7. Select the branch (Usually `master`)
8. Set the "Release date override" to the actual date (YYYYMMDD) you would like to append to the OCCU (3.XX.YY) version string.
9. Set the "Skip build" to `false` or otherwise the workflow will just be tested without actually running the time consuming build job or releasing the helm charts, docker, etc.
10. Click on _Run Workflow_ to start the build. The build does the following
   - creates a new release draft with the 3.XX.YY.YYYYMMDD used as name, tag and version. If the release draft already exists then it is **not modified**.
     **NOTE**: if binaries were already uploaded to the draft release you need to delete them before re-triggering the CI or the upload will fail
   - builds all binaries and upload them to the draft release
   - uploads the container with `latest` as tag - NOTE: after this step OCI users using latest will get the update right away!
   - uploads a new release Helm chart using the `OCCU_VERSION` (3.XX.YY) as version. NOTE: after this point the Kubernetes users will get the update right away!
   - bumps all public version references in `release/LATEST-VERSION.js`, `helm/openccu/Chart.yaml`, `release/rpi-imager.json` and `home-assistant-addon/config.yaml`.
   - substitutes all SHA256 checksums in the release draft with the actual binary sha256 checksums.
10. While the draft is being built, the release readme can be updated from the GitHub WebUI
11. Once the build run has completed and all binaries are uploaded to the release draft the typical release archives + images should appear in the release draft assets section.
12. Verify everything and click "Publish" to finally publish the release
13. Update `openccu.de` and make sure to set the new released version in the update server on openccu.de so that every existing user will get a notification.

## Components Update Guide

This short documentation serves as a quick-guide to which and from where components should be update on a regular basis.

- Buildroot:
  <https://buildroot.org/>

- Java-AZUL:
  <https://www.azul.com/downloads/zulu-embedded/>

- CloudMatic Addon:
  <https://github.com/EasySmartHome/CloudMatic-CCUAddon>

- RaspberryPi Linux Kernel:
  <https://github.com/raspberrypi/linux/>

- RaspberryPi rpi-eeprom:
  <https://github.com/raspberrypi/rpi-eeprom/commits/master/firmware/stable>

- Intel e1000e network driver (for OVA):
  <https://sourceforge.net/projects/e1000/files/e1000e%20stable/>

- ASUS Tinkerboard Kernel Patches (Armbian):
  <https://github.com/armbian/build/tree/master/patch/kernel/rockchip-current>
  
- CodeMirror WebUI Script Editor Engine:
  <https://codemirror.net/>

- S.USV Support-Tools:
  <https://s-usv.de/downloads/>

- generic_raw_uart/HB-RF-USB/HB-RF-USB-2/HB-RF-ETH driver:
  <https://github.com/alexreinert/piVCCU/tree/master/kernel>

- detect_radio_module tool:
  <https://github.com/alexreinert/piVCCU/tree/master/detect_radio_module>
