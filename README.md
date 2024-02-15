## Overview
Nix is a powerful package manager for Linux and Unix systems that ensures reproducible, declarative, and reliable software management. 

This repository contains configuration for a general-purpose development environment that runs Nix on MacOS, specifically for mobile app development

## Table of Contents
- [Overview](#overview)
- [Layout](#layout)
- [Features](#features)
- [Disclaimer](#disclaimer)
- [Installing](#installing)
  - [For MacOS](#for-macos)
    - [Install dependencies](#1-install-dependencies)
    - [Install Nix](#2-install-nix)
    - [Clone the repository](#3-clone-the-repository)
    - [Apply your current user info](#4-apply-your-current-user-info)
    - [Decide what packages to install](#5-decide-what-packages-to-install)
    - [Review your shell configuration](#7-review-your-shell-configuration)
    - [Install configuration](#9-install-configuration)
    - [Make changes](#10-make-changes)
- [Deploying Changes to Your System](#deploying-changes-to-your-system)
  - [For all platforms](#for-all-platforms)
  - [Update Dependencies](#update-dependencies)

## Layout
```
.
├── apps         # Nix commands used to bootstrap and build configuration
├── hosts        # Host-specific configuration
├── modules      # MacOS and nix-darwin, NixOS, and shared configuration
├── overlays     # Drop an overlay file in this dir, and it runs. So far, mainly patches.
```

## Features
- **Nix Flakes**: 100% flake driven, no `configuration.nix`, [no Nix channels](#why-nix-flakes)─ just `flake.nix`
- **MacOS Dream Setup**: Fully declarative MacOS, including UI, dock and MacOS App Store apps possible
- **Simple Bootstrap**: Simple Nix commands to start from zero
- **Managed Homebrew**: Zero maintenance homebrew environment with `nix-darwin` and `nix-homebrew`
- **Built In Home Manager**: `home-manager` module for seamless configuration (no extra clunky CLI steps)
- **Nix Overlays**: [Auto-loading of Nix overlays]: drop a file in a dir and it runs _(great for patches!)_
- **Declarative Sync**: No-fuss Syncthing: managed keys, certs, and configuration across all platforms
- **Simplicity and Readability**: Optimized for simplicity and readability in all cases, not small files everywhere

## Disclaimer
Installing Nix on MacOS will create an entirely separate volume. It will exceed many gigabytes in size. 

Some folks don't like this. If this is you, turn back now!

> [!NOTE]
> Don't worry; you can always [uninstall](https://github.com/DeterminateSystems/nix-installer#uninstalling) Nix later.


# Installing
> [!IMPORTANT]
> Note: Nix 2.18 currently [has a bug](https://github.com/NixOS/nix/issues/9052) that impacts this repository.

For now, if you run into errors like this:
```
error: path '/nix/store/52k8rqihijagzc2lkv17f4lw9kmh4ki6-gnugrep-3.11-info' is not valid
```

Run `nix copy` to make the path valid.
```
nix copy --from https://cache.nixos.org /nix/store/52k8rqihijagzc2lkv17f4lw9kmh4ki6-gnugrep-3.11-info
```

## For MacOS
I've tested these instructions on a fresh Macbook Pro as of February 2024.

### 1. Install dependencies & clone the repository

 Just run this install script from your terminal:

 ```
 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ErikMikkelson/mac-runner/HEAD/install.sh)"
 ```

### 2. Make apps executable
```sh
find apps/aarch64-darwin -type f \( -name apply -o -name build -o -name build-switch -o -name create-keys -o -name copy-keys -o -name check-keys \) -exec chmod +x {} \;
```

### 3. Apply your current user info
Run this Nix app to replace stub values with your username, full name, and email.
```sh
nix run .#apply
```
> [!NOTE]
> If you're using a git repository, only files in the working tree will be copied to the [Nix Store](https://zero-to-nix.com/concepts/nix-store).
>
> You must run `git add .` first.

### 4. Decide what packages to install
You can search for packages on the [official NixOS website](https://search.nixos.org/packages).

**Review these files**

* [`modules/darwin/casks.nix`](./modules/darwin/casks.nix)
* [`modules/darwin/packages.nix`](./modules/darwin/packages.nix)
* [ `modules/nixos/packages.nix`](./modules/nixos/packages.nix)
* [`modules/shared/packages/nix`](./modules/shared/packages.nix)

### 5. Review your shell configuration
Add anything from your existing `~/.zshrc`, or just review the new configuration.

**Review these files**

* [`modules/darwin/home-manager`](./modules/darwin/home-manager.nix)
* [`modules/shared/home-manager`](./modules/shared/home-manager.nix)

### 6. Install configuration
First-time installations require you to move the current `/etc/nix/nix.conf` out of the way.
```sh
[ -f /etc/nix/nix.conf ] && sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
```

> [!NOTE]
> If you're using a git repository, only files in the working tree will be copied to the [Nix Store](https://zero-to-nix.com/concepts/nix-store).
>
> You must run `git add .` first.

Then, if you want to ensure the build works before deploying the configuration, run:
```sh
nix run .#build
```

### 7. Make changes
Finally, alter your system with this command:
```sh
nix run .#build-switch
```
> [!WARNING]
> On MacOS, your `.zshrc` file will be replaced with the [`zsh` configuration](./templates/starter/modules/shared/home-manager.nix#L8) from this repository. So make some changes here first if you'd like.


# Deploying changes to your system
With Nix, changes to your system are made by 
- editing your system configuration
- building the [system closure](https://zero-to-nix.com/concepts/closures)
- creating and switching to it _(i.e creating a [new generation](https://nixos.wiki/wiki/Terms_and_Definitions_in_Nix_Project#generation))_

## For all platforms
```sh
nix run .#build-switch
```

## Update dependencies
```sh
nix flake update
```

## Thanks
Based on https://github.com/dustinlyons/nixos-config under MIT License

