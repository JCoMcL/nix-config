{config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      (import ./zfs.nix "2f5d4055")
      ./sound.nix
      ./cachix.nix
    ];

  networking.hostName = "jozbox";

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "coretemp" ];

  # failed attempts to fix thunderbolt
  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;
  services.udev.extraRules = ''ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"'';

  hardware.uinput.enable = true;

  networking.useDHCP = false;
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    dhcp = "dhcpcd";
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
   '';
  };

  xdg = {
    #mime.enable = false;
    #icons.enable = false;
    #menus.enable = false;
    #portal.enable = false;
    sounds.enable = false;
    #autostart.enable = false;
  };

  services.xserver = {
    enable = true;
    autorun = true;
    videoDrivers = [ "modesetting" "nvidia" ];
    autoRepeatDelay = 180;
    autoRepeatInterval = 50;
    wacom.enable = true;
    displayManager.startx.enable = true;
  };

  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  programs.zsh.setOptions = [];
  programs.zsh.promptInit = "";
  users.defaultUserShell = pkgs.zsh;

  # Vidogaem
  #programs.steam.enable = true;
  services.joycond.enable = true;

  # Laptop
  programs.light.enable = true;
  hardware.bluetooth.enable = true;
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  prict.sound.enable = true;

  users.users.jcomcl = {
    isNormalUser = true;
    extraGroups = [ "libvirtd" "input" "wheel" "video" "uinput" ];
  };

# # virtualization
# virtualisation.libvirtd.enable = true;
# boot.kernelModules = [ "vfio-pci" ];
# boot.blacklistedKernelModules = [ "nouveau" ];
# boot.kernelParams = [ "intel_iommu=on" ];

  services.actkbd = {
    enable = false;
    bindings = [
      { keys = [ 115 ]; events = [ "key" ]; command = "${pkgs.pulseaudio}/bin/pactl  set-sink-volume @DEFAULT_SINK@ +1000"; }
      { keys = [ 114 ]; events = [ "key" ]; command = "${pkgs.pulseaudio}/bin/pactl  set-sink-volume @DEFAULT_SINK@ -1000"; }
    ];
  };

  nixpkgs.overlays = [ (self: super: {
    dwm = super.dwm.overrideAttrs (old: {
      src = /home/jcomcl/src/dwm;
    });
    st = (super.st.overrideAttrs (old: {
      src = /home/jcomcl/src/st;
    })).override {
      extraLibs = [pkgs.harfbuzz];
    };
    dunst = super.dunst.overrideAttrs (old: {
      src = /home/jcomcl/src/dunst;
    });
  })];

  #more manpages
  documentation.dev.enable = true;

  nixpkgs.config.allowUnfree = true;
  
  programs.wireshark.enable = true;
  environment.systemPackages = let unstable = import <nixos-unstable> { config.allowUnfree = true; }; in with pkgs; [
    # basic
    zsh
    neovim
    lf
    screen
    htop
    manpages
    dhcpcd
    # extra
    neofetch
    gotop
    syncthing
    # utils
    input-utils #provides lsinput
    linuxConsoleTools # provides jstest
    utillinux # provides blkid
    v4l-utils # provides v4l2-ctl
    dmidecode
    qrencode
    zip unzip
    onboard
    pandoc
    calibre #provides ebook-convert
    imagemagick
    ghostscript
    glxinfo
    yt-dlp
    sshfs
    #edir
    trash-cli
    killall
    libnotify
    ffmpeg
    pandoc
    pciutils # provides lspci
    usbutils # provides lsusb
    usb_modeswitch
    file
    wget
    whois
    # development
    autoconf
    automake
    gnumake
    gdb gdbgui
    git
    git-filter-repo
    binutils
    pkgconf
    darkhttpd
    cachix
    # languages
    gcc ccls cling
    (python3.withPackages(ps: with ps; [
      numpy
    ])) pipenv python39Packages.pip python39Packages.pyflakes mypy
    nodejs nodePackages.prettier
    nodePackages.typescript nodePackages.typescript-language-server
    nodePackages.vscode-html-languageserver-bin html-tidy
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vim-language-server
    rustc cargo rls cargo-edit rust-bindgen rustfmt
    antlr4 jdk
    go gopls
    ghc stack ormolu
    rnix-lsp
    #fun
    cowsay
    fortune
    figlet
    # X11 basic
    dwm
    dmenu
    st
    picom
    dunst
    xbindkeys
    # graphical apps
    prusa-slicer
    arandr
    openscad
    blender
    google-chrome
    parted
    godot
    discord
    sxiv
    sent
    zathura
    mpv
    maim
    audacity
    marktext
    gimp krita
    inkscape
    vmpk
    libreoffice
    onboard
    meme-image-generator
    f3d
    # Vidogaem
    unstable.polymc  #minecraft
    starsector
    # X11 utils
    redshift
    hsetroot
    xdotool
    xclip #TODO remove xclip
    xsel
    xorg.xev
    xorg.xkbcomp
    xwallpaper
    slop
    # statusbar
    sysstat
    inotify-tools
    acpid
     #lm-sensors
    # android
    android-udev-rules
    android-file-transfer
    adbfs-rootless
 
    #(callPackage ./pkg/chitubox {})
  ];
  programs.adb.enable = true;

  services.acpid.enable = true; #for status

  # defaults
  environment.variables = {
    EDITOR = "nvim";
    PAGER = "less";
    BROWSER = "google-chrome-stable";
  };

  fonts.fonts = with pkgs; [
    hack-font
    font-awesome
    twemoji-color-font
    #ancient fonts
    aegyptus
    aegan
    unidings
    textfonts
    maya
    assyrian
    akkadian
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "Hack" ];
    emoji = [ "Twitter Color Emoji" ];
  };

  networking.firewall.enable = false;

  system.stateVersion = "21.11";

  time.timeZone = "Europe/Dublin";

}

