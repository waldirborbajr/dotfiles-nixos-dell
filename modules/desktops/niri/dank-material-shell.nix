# modules/desktops/niri/dank-material-shell.nix
# DankMaterialShell configuration for Niri with Catppuccin theme
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
in
lib.mkIf isMacbook {
  # Install DankMaterialShell
  home.packages = with pkgs; [
    # DankMaterialShell dependencies
    glib
    gtk3
    gtk4
    libadwaita
    libnotify
    
    # Additional utilities for DMS features
    wireplumber
    bluez
    networkmanager
    upower
    
    # Temperature monitoring
    lm_sensors
    
    # System monitoring
    htop
    btop
  ];

  # DankMaterialShell configuration with Catppuccin theme
  xdg.configFile."DankMaterialShell/config.json".text = builtins.toJSON {
    # Theme Configuration - Catppuccin
    currentThemeName = "catppuccin-mocha";
    currentThemeCategory = "registry";
    customThemeFile = "";
    registryThemeVariants = {};
    matugenScheme = "scheme-tonal-spot";
    runUserMatugenTemplates = true;
    matugenTargetMonitor = "";
    
    # Transparency and Appearance
    popupTransparency = 0.95;
    dockTransparency = 0.95;
    widgetBackgroundColor = "sc";
    widgetColorMode = "default";
    cornerRadius = 12;
    
    # Niri-specific Layout Settings
    niriLayoutGapsOverride = 8;
    niriLayoutRadiusOverride = 12;
    niriLayoutBorderSize = 2;
    hyprlandLayoutGapsOverride = -1;
    hyprlandLayoutRadiusOverride = -1;
    hyprlandLayoutBorderSize = -1;
    mangoLayoutGapsOverride = -1;
    mangoLayoutRadiusOverride = -1;
    mangoLayoutBorderSize = -1;
    
    # Clock Settings
    use24HourClock = true;
    showSeconds = true;
    useFahrenheit = false;
    
    # Visual Settings
    nightModeEnabled = false;
    animationSpeed = 1;
    customAnimationDuration = 300;
    wallpaperFillMode = "Fill";
    blurredWallpaperLayer = false;
    blurWallpaperOnOverview = false;
    
    # Top Bar Widgets - Left
    showLauncherButton = true;
    showWorkspaceSwitcher = true;
    showFocusedWindow = true;
    
    # Top Bar Widgets - Center
    showWeather = true;
    showMusic = true;
    showClock = true;
    
    # Top Bar Widgets - Right
    showClipboard = true;
    showCpuUsage = true;
    showMemUsage = true;
    showCpuTemp = true;
    showGpuTemp = false;
    selectedGpuIndex = 0;
    enabledGpuPciIds = [];
    showSystemTray = true;
    showNotificationButton = true;
    showBattery = true;
    showControlCenterButton = true;
    showCapsLockIndicator = true;
    
    # Control Center Configuration
    controlCenterShowNetworkIcon = true;
    controlCenterShowBluetoothIcon = true;
    controlCenterShowAudioIcon = true;
    controlCenterShowAudioPercent = true;
    controlCenterShowVpnIcon = true;
    controlCenterShowBrightnessIcon = true;
    controlCenterShowBrightnessPercent = true;
    controlCenterShowMicIcon = true;
    controlCenterShowMicPercent = true;
    controlCenterShowBatteryIcon = true;
    controlCenterShowPrinterIcon = false;
    controlCenterShowScreenSharingIcon = true;
    
    # Privacy Indicators
    showPrivacyButton = true;
    privacyShowMicIcon = true;
    privacyShowCameraIcon = true;
    privacyShowScreenShareIcon = true;
    
    # Control Center Widgets
    controlCenterWidgets = [
      { id = "volumeSlider"; enabled = true; width = 50; }
      { id = "brightnessSlider"; enabled = true; width = 50; }
      { id = "wifi"; enabled = true; width = 50; }
      { id = "bluetooth"; enabled = true; width = 50; }
      { id = "audioOutput"; enabled = true; width = 50; }
      { id = "audioInput"; enabled = true; width = 50; }
      { id = "nightMode"; enabled = true; width = 50; }
      { id = "darkMode"; enabled = true; width = 50; }
    ];
    
    # Workspace Configuration
    showWorkspaceIndex = true;
    showWorkspaceName = false;
    showWorkspacePadding = true;
    workspaceScrolling = true;
    showWorkspaceApps = true;
    maxWorkspaceIcons = 5;
    groupWorkspaceApps = true;
    workspaceFollowFocus = true;
    showOccupiedWorkspacesOnly = false;
    reverseScrolling = false;
    dwlShowAllTags = false;
    workspaceColorMode = "primary";
    workspaceUnfocusedColorMode = "default";
    workspaceUrgentColorMode = "default";
    workspaceFocusedBorderEnabled = true;
    workspaceFocusedBorderColor = "primary";
    workspaceFocusedBorderThickness = 2;
    workspaceNameIcons = {};
    
    # Media Player Features
    waveProgressEnabled = true;
    scrollTitleEnabled = true;
    audioVisualizerEnabled = true;
    audioScrollMode = "volume";
    
    # Compact Modes
    clockCompactMode = false;
    focusedWindowCompactMode = false;
    runningAppsCompactMode = false;
    keyboardLayoutNameCompactMode = false;
    runningAppsCurrentWorkspace = false;
    runningAppsGroupByApp = true;
    appIdSubstitutions = [];
    
    # Layout Preferences
    centeringMode = "index";
    clockDateFormat = "%a %d %b";
    lockDateFormat = "%A, %B %d";
    mediaSize = 1;
    
    # App Launcher
    appLauncherViewMode = "grid";
    spotlightModalViewMode = "grid";
    sortAppsAlphabetically = true;
    appLauncherGridColumns = 6;
    spotlightCloseNiriOverview = true;
    niriOverviewOverlayEnabled = true;
    
    # Weather & Location
    useAutoLocation = false;
    weatherEnabled = true;
    networkPreference = "auto";
    vpnLastConnected = "";
    
    # Theme & Icons
    iconTheme = "Papirus-Dark";
    cursorSettings = {
      theme = "Catppuccin-Mocha-Dark-Cursors";
      size = 24;
      niri = {
        hideWhenTyping = false;
        hideAfterInactiveMs = 3000;
      };
      hyprland = {
        hideOnKeyPress = false;
        hideOnTouch = false;
        inactiveTimeout = 0;
      };
      dwl = {
        cursorHideTimeout = 0;
      };
    };
    
    # Launcher Logo
    launcherLogoMode = "apps";
    launcherLogoCustomPath = "";
    launcherLogoColorOverride = "";
    launcherLogoColorInvertOnMode = false;
    launcherLogoBrightness = 0.5;
    launcherLogoContrast = 1;
    launcherLogoSizeOffset = 0;
    
    # Fonts
    fontFamily = "JetBrainsMono Nerd Font";
    monoFontFamily = "JetBrainsMono Nerd Font Mono";
    fontWeight = 600;
    fontScale = 1.15;
    
    # Notepad
    notepadUseMonospace = true;
    notepadFontFamily = "JetBrainsMono Nerd Font Mono";
    notepadFontSize = 13;
    notepadShowLineNumbers = true;
    notepadTransparencyOverride = -1;
    notepadLastCustomTransparency = 0.9;
    
    # Sounds
    soundsEnabled = true;
    useSystemSoundTheme = true;
    soundNewNotification = true;
    soundVolumeChanged = false;
    soundPluggedIn = true;
    
    # Power Management
    acMonitorTimeout = 900;
    acLockTimeout = 1800;
    acSuspendTimeout = 0;
    acSuspendBehavior = 0;
    acProfileName = "performance";
    batteryMonitorTimeout = 300;
    batteryLockTimeout = 600;
    batterySuspendTimeout = 1800;
    batterySuspendBehavior = 1;
    batteryProfileName = "power-saver";
    batteryChargeLimit = 80;
    lockBeforeSuspend = true;
    loginctlLockIntegration = true;
    fadeToLockEnabled = true;
    fadeToLockGracePeriod = 5;
    fadeToDpmsEnabled = true;
    fadeToDpmsGracePeriod = 10;
    
    # Launch Prefix
    launchPrefix = "";
    
    # Device Pins
    brightnessDevicePins = {};
    wifiNetworkPins = {};
    bluetoothDevicePins = {};
    audioInputDevicePins = {};
    audioOutputDevicePins = {};
    
    # GTK/Qt Theming with Catppuccin
    gtkThemingEnabled = true;
    qtThemingEnabled = true;
    syncModeWithPortal = true;
    terminalsAlwaysDark = false;
    
    # Matugen Templates for Catppuccin
    runDmsMatugenTemplates = true;
    matugenTemplateGtk = true;
    matugenTemplateNiri = true;
    matugenTemplateHyprland = false;
    matugenTemplateMangowc = false;
    matugenTemplateQt5ct = true;
    matugenTemplateQt6ct = true;
    matugenTemplateFirefox = true;
    matugenTemplatePywalfox = false;
    matugenTemplateZenBrowser = false;
    matugenTemplateVesktop = false;
    matugenTemplateEquibop = false;
    matugenTemplateGhostty = false;
    matugenTemplateKitty = false;
    matugenTemplateFoot = false;
    matugenTemplateAlacritty = true;
    matugenTemplateNeovim = false;
    matugenTemplateWezterm = false;
    matugenTemplateDgop = false;
    matugenTemplateKcolorscheme = false;
    matugenTemplateVscode = true;
    
    # Dock Configuration (Disabled by default)
    showDock = false;
    dockAutoHide = false;
    dockGroupByApp = false;
    dockOpenOnOverview = false;
    dockPosition = 3;
    dockSpacing = 8;
    dockBottomGap = 8;
    dockMargin = 0;
    dockIconSize = 48;
    dockIndicatorStyle = "dot";
    dockBorderEnabled = false;
    dockBorderColor = "surfaceText";
    dockBorderOpacity = 1;
    dockBorderThickness = 2;
    dockIsolateDisplays = false;
    
    # Notifications
    notificationOverlayEnabled = true;
    modalDarkenBackground = true;
    
    # Lock Screen
    lockScreenShowPowerActions = true;
    lockScreenShowSystemIcons = true;
    lockScreenShowTime = true;
    lockScreenShowDate = true;
    lockScreenShowProfileImage = true;
    lockScreenShowPasswordField = true;
    enableFprint = false;
    maxFprintTries = 15;
    lockScreenActiveMonitor = "all";
    lockScreenInactiveColor = "#1e1e2e";
    lockScreenNotificationMode = 1;
    
    # Brightness Slider
    hideBrightnessSlider = false;
    
    # Notification Settings
    notificationTimeoutLow = 3000;
    notificationTimeoutNormal = 5000;
    notificationTimeoutCritical = 0;
    notificationCompactMode = false;
    notificationPopupPosition = 1;
    notificationHistoryEnabled = true;
    notificationHistoryMaxCount = 100;
    notificationHistoryMaxAgeDays = 7;
    notificationHistorySaveLow = true;
    notificationHistorySaveNormal = true;
    notificationHistorySaveCritical = true;
    
    # OSD (On-Screen Display)
    osdAlwaysShowValue = true;
    osdPosition = 5;
    osdVolumeEnabled = true;
    osdMediaVolumeEnabled = true;
    osdBrightnessEnabled = true;
    osdIdleInhibitorEnabled = true;
    osdMicMuteEnabled = true;
    osdCapsLockEnabled = true;
    osdPowerProfileEnabled = true;
    osdAudioOutputEnabled = true;
    
    # Power Menu
    powerActionConfirm = true;
    powerActionHoldDuration = 0.5;
    powerMenuActions = [
      "lock"
      "logout"
      "suspend"
      "reboot"
      "poweroff"
    ];
    powerMenuDefaultAction = "lock";
    powerMenuGridLayout = true;
    customPowerActionLock = "";
    customPowerActionLogout = "";
    customPowerActionSuspend = "";
    customPowerActionHibernate = "";
    customPowerActionReboot = "";
    customPowerActionPowerOff = "";
    
    # System Updater
    updaterHideWidget = false;
    updaterUseCustomCommand = false;
    updaterCustomCommand = "";
    updaterTerminalAdditionalParams = "";
    
    # Display Configuration
    displayNameMode = "system";
    screenPreferences = {};
    showOnLastDisplay = {};
    niriOutputSettings = {};
    hyprlandOutputSettings = {};
    
    # Bar Configuration
    barConfigs = [
      {
        id = "main-bar";
        name = "Main Bar - Catppuccin";
        enabled = true;
        position = 0;
        screenPreferences = [ "all" ];
        showOnLastDisplay = true;
        
        leftWidgets = [
          { id = "launcherButton"; enabled = true; }
          { id = "separator"; enabled = true; }
          { id = "workspaceSwitcher"; enabled = true; }
          { id = "separator"; enabled = true; }
          { id = "focusedWindow"; enabled = true; }
        ];
        
        centerWidgets = [
          { id = "clock"; enabled = true; }
          { id = "weather"; enabled = true; }
        ];
        
        rightWidgets = [
          { id = "music"; enabled = true; }
          { id = "separator"; enabled = true; }
          { id = "systemTray"; enabled = true; }
          { id = "clipboard"; enabled = true; }
          { id = "diskUsage"; enabled = true; mountPath = "/"; }
          { id = "cpuUsage"; enabled = true; }
          { id = "memUsage"; enabled = true; }
          { id = "notificationButton"; enabled = true; }
          { id = "controlCenterButton"; enabled = true; }
        ];
        
        spacing = 12;
        innerPadding = 8;
        bottomGap = 6;
        transparency = 0.95;
        widgetTransparency = 1;
        squareCorners = false;
        noBackground = false;
        gothCornersEnabled = false;
        gothCornerRadiusOverride = false;
        gothCornerRadiusValue = 12;
        borderEnabled = true;
        borderColor = "primary";
        borderOpacity = 0.3;
        borderThickness = 2;
        widgetOutlineEnabled = false;
        widgetOutlineColor = "primary";
        widgetOutlineOpacity = 1;
        widgetOutlineThickness = 1;
        fontScale = 1.15;
        autoHide = false;
        autoHideDelay = 250;
        showOnWindowsOpen = true;
        openOnOverview = false;
        visible = true;
        popupGapsAuto = true;
        popupGapsManual = 8;
        maximizeDetection = true;
        scrollEnabled = true;
        scrollXBehavior = "column";
        scrollYBehavior = "workspace";
        shadowIntensity = 20;
        shadowOpacity = 60;
        shadowColorMode = "text";
        shadowCustomColor = "#000000";
      }
    ];
    
    # Desktop Clock
    desktopClockEnabled = false;
    desktopClockStyle = "analog";
    desktopClockTransparency = 0.8;
    desktopClockColorMode = "primary";
    desktopClockCustomColor = {
      r = 1;
      g = 1;
      b = 1;
      a = 1;
      hsvHue = -1;
      hsvSaturation = 0;
      hsvValue = 1;
      hslHue = -1;
      hslSaturation = 0;
      hslLightness = 1;
      valid = true;
    };
    desktopClockShowDate = true;
    desktopClockShowAnalogNumbers = false;
    desktopClockShowAnalogSeconds = true;
    desktopClockX = -1;
    desktopClockY = -1;
    desktopClockWidth = 280;
    desktopClockHeight = 180;
    desktopClockDisplayPreferences = [ "all" ];
    
    # System Monitor
    systemMonitorEnabled = false;
    systemMonitorShowHeader = true;
    systemMonitorTransparency = 0.8;
    systemMonitorColorMode = "primary";
    systemMonitorCustomColor = {
      r = 1;
      g = 1;
      b = 1;
      a = 1;
      hsvHue = -1;
      hsvSaturation = 0;
      hsvValue = 1;
      hslHue = -1;
      hslSaturation = 0;
      hslLightness = 1;
      valid = true;
    };
    systemMonitorShowCpu = true;
    systemMonitorShowCpuGraph = true;
    systemMonitorShowCpuTemp = true;
    systemMonitorShowGpuTemp = false;
    systemMonitorGpuPciId = "";
    systemMonitorShowMemory = true;
    systemMonitorShowMemoryGraph = true;
    systemMonitorShowNetwork = true;
    systemMonitorShowNetworkGraph = true;
    systemMonitorShowDisk = true;
    systemMonitorShowTopProcesses = true;
    systemMonitorTopProcessCount = 5;
    systemMonitorTopProcessSortBy = "cpu";
    systemMonitorGraphInterval = 60;
    systemMonitorLayoutMode = "auto";
    systemMonitorX = -1;
    systemMonitorY = -1;
    systemMonitorWidth = 400;
    systemMonitorHeight = 600;
    systemMonitorDisplayPreferences = [ "all" ];
    systemMonitorVariants = [];
    
    # Desktop Widget Positions
    desktopWidgetPositions = {};
    desktopWidgetGridSettings = {};
    desktopWidgetInstances = [];
    desktopWidgetGroups = [];
    
    # Built-in Plugin Settings
    builtInPluginSettings = {
      dms_settings_search = {
        trigger = "?";
      };
    };
    
    # Config Version
    configVersion = 5;
  };
  
  # Session variables for DankMaterialShell
  home.sessionVariables = {
    DMS_COMPOSITOR = "niri";
    DMS_THEME = "catppuccin-mocha";
  };
}
