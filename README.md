# My NixOS Configuration

## ❄️ Overview

This is my personal NixOS system configuration flake. There are many like it, but this one is mine. I don't do anything particularly special, but you're free to look around and use what you want.

## 📁 Organization

The basic organization is something like this:

```
nixos
├─── README.md
├─── assets
│   ╰─── desktop.jpg
├─── home
│   ├─── default.nix
│   ╰─── <username>
│       ╰─── <user home-manager config>
├─── host
│   ├─── default.nix
│   ╰─── <hostname>
│       ╰─── <host machine config>
╰─── secrets
    ├─── secrets.nix
    ╰─── <program_secret.age>
```

### 🖼️ Assets

Contains assets for the system, such as a desktop background image or profile picture.

### 🏡 Home

User environment definition via [home-manager](https://github.com/nix-community/home-manager). Currently only one user defined, since I am the only one using these machines.

### 🖥️ Host

Contains host machine configuration. Basically what would be in configuration.nix on a non-flake system.

### 🔐 Secrets

Nix friendly secrets storage using [agenix](https://github.com/ryantm/agenix).


ref: https://github.com/AlexNabokikh/nix-config
grok: https://grok.com/c/eb9c2be6-3df9-43c3-9845-02a0f78393f7?rid=09479c4f-008d-4f93-87fe-7fb8d3339e1b