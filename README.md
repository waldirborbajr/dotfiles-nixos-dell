
These are my dotfiles. Feel free to use or copy what you need from this repo.

## Setup Instructions

I manage these dotfiles with `stow`, which is a symlink manager. Clone this
repository to the root of your home directory, `~/.dotfiles` for example.

> [!Note]
> There may be submodules contained inside this repo (see
> [.gitmodules](.gitmodules) for a list of them). Use the `--recures-submodules`
> option while cloning to check out the submodules.

[Contribution guidelines for this project](docs/CONTRIBUTING.md)
Each sub-directory can be individually linked to its correct location using
`stow directory_name` inside the root of this repository. To set up the
dotfiles for `git` just run `stow git`, for example.

To remove the links that were created by `stow`, run `stow -D directory_name`.

You can of course create the symlinks yourself with `ln` or just copy files to
the correct location, if you don't want to use `stow`.


# Configuration for Chirp

```sh
sudo apt remove brltty
```

```sh
sudo usermod -a -G dialout $USER
```

## MacBook WiFi - Linux (#1)

```sh
sudo apt install broadcom-sta-dkms
sudo sed -i 's/wifi.powersave = 3/wifi.powersave = 2/' /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
```

## Write ISO to device

```
sudo dd bs=4M if=/path/to/file.iso of=/dev/sdX status=progress oflag=sync
```

## Installing Nerd Fonts on Ubuntu: A Comprehensive Guide

```
https://linuxvox.com/blog/install-nerd-fonts-ubuntu/
```


