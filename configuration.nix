{config, pkgs, fetchFromGithub, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      (import ./zfs.nix "2f5d4055")
    ];

  networking.hostName = "jozbox";

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  # failed attempts to fix thunderbolt
  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;
  services.udev.extraRules = ''ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"'';

  hardware.uinput.enable = true;

  networking.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.resolvconf.dnsExtensionMechanism = false;

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
  programs.steam.enable = true;

  # Laptop
  programs.light.enable = true;
  hardware.bluetooth.enable = true;
  networking.wireless.iwd.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

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
    # HiDPI
    google-chrome = super.google-chrome.override {
      commandLineArgs = "--high-dpi-support=1 --force-device-scale-factor=1";
    };
  })];

  #more manpages
  documentation.dev.enable = true;

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
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
    pulsemixer
    syncthing
    # utils
    input-utils #provides lsinput
    linuxConsoleTools # provides jstest
    utillinux # provides blkid
    v4l-utils # provides v4l2-ctl
    dmidecode
    qrencode
    zip unzip
    pandoc
    calibre #provides ebook-convert
    imagemagick
    ghostscript
    glxinfo
    youtube-dl
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
    binutils
    pkgconf
    darkhttpd
    # languages
    gcc ccls
    python3 python-language-server pipenv python38Packages.pip
    nodejs nodePackages.prettier
    nodePackages.typescript nodePackages.typescript-language-server
    nodePackages.vscode-html-languageserver-bin html-tidy
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vim-language-server
    rustc cargo rls cargo-edit rust-bindgen rustfmt
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
    google-chrome
    godot
    discord
    sxiv
    sent
    zathura
    mpv
    maim
    audacity
    typora
    gimp krita
    inkscape
    vmpk
    libreoffice
    # Vidogaem
    minecraft
    # X11 utils
    redshift
    hsetroot
    xdotool
    xclip #TODO remove xclip
    xsel
    xorg.xev
    xorg.xkbcomp
    xwallpaper
    feh
    # status
    sysstat
    inotify-tools
    acpid
  ];

  services.acpid.enable = true; #for status

  environment.variables.QT_SCALE_FACTOR = "1.5";

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
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "Hack" ];
    emoji = [ "Twitter Color Emoji" ];
  };

  networking.firewall.enable = false;

  system.stateVersion = "unstable";

  time.timeZone = "Europe/Dublin";

}

