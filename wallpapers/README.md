# Wallpapers

Custom wallpapers for NixOS configurations.

## Available Wallpapers

### devops-dark.svg
Custom DevOps-themed wallpaper with **Lavender gradient color scheme**.

**Features:**
- 1920x1080 resolution (SVG, scales to any resolution)
- Lavender gradient background (#9b8fd6 → #b4a7e0 → #c4b5ea)
- DevOps pipeline visualization (CODE → BUILD → TEST → DEPLOY → MONITOR)
- Technology badges: Docker, Kubernetes, Nix, Terraform, ArgoCD, Ansible, Prometheus, Grafana, GitLab CI, Jenkins
- Light lavender background for better contrast with dark terminals

**Usage:**
- **GNOME**: Automatically configured via `modules/desktops/gnome.nix` → `/etc/nixos/wallpapers/devops-dark.svg`
- **niri**: Symlinked to `~/.config/niri/wallpaper.svg` via home-manager

## Adding New Wallpapers

### Quick Guide

1. **Save your wallpaper** in this folder (any name, any format):
   ```bash
   wallpapers/my-awesome-wallpaper.jpg
   # or .png, .svg, etc.
   ```

2. **For GNOME**, edit `modules/desktops/gnome.nix`:
   ```nix
   # Update the wallpaper paths (around line 82):
   picture-uri = "file:///etc/nixos/wallpapers/my-awesome-wallpaper.jpg";
   picture-uri-dark = "file:///etc/nixos/wallpapers/my-awesome-wallpaper.jpg";
   
   # Update the source (around line 124):
   environment.etc."nixos/wallpapers/my-awesome-wallpaper.jpg".source = 
     ../../wallpapers/my-awesome-wallpaper.jpg;
   ```

3. **For niri**, edit `modules/desktops/niri/default.nix`:
   ```nix
   # Update the source (around line 46):
   home.file.".config/niri/wallpaper.jpg".source = 
     ../../../wallpapers/my-awesome-wallpaper.jpg;
   ```

4. **Rebuild**:
   ```bash
   sudo nixos-rebuild switch --flake .#macbook
   ```

### Wallpaper Options (GNOME)

Change `picture-options` in GNOME config:
- `"zoom"` - Zoom to fill (default, recommended)
- `"scaled"` - Scale to fit
- `"centered"` - Center image
- `"stretched"` - Stretch to fill
- `"spanned"` - Span across monitors

## Converting SVG to PNG (if needed)

```bash
# Using inkscape
inkscape -w 1920 -h 1080 devops-dark.svg -o devops-dark.png

# Using ImageMagick
convert -density 300 -resize 1920x1080 devops-dark.svg devops-dark.png
```
