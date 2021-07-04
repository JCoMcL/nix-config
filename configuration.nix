{config, pkgs, fetchFromGithub, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./zfs.nix
    ];

  networking.hostName = "jozbox";
  networking.hostId = "2f5d4055";

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

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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
      src = super.fetchFromGitHub {
        owner = "jcomcl";
        repo = "dwm";
        rev = "34b47d9508e32916f3867923337b4ccaa1d34542";
        sha256 = "0yr1rh7gmpm57dhd74k5lxsyfd6xdwfyzlsipppj6a7k967l3x5y";
      };
    });
    st = (super.st.overrideAttrs (old: {
      src = super.fetchFromGitHub {
        owner = "jcomcl";
        repo = "st";
        rev = "f545b735df9e096eb245e728435de01ceae51cf0";
        sha256 = "1c75k84j11i25rhspyg8s3hw2vzww4x9cifxga74xda1sghc1hja";
      };
    })).override {
      extraLibs = [pkgs.harfbuzz];
    };
#   dunst = super.dunst.overrideAttrs (old: {
#     src = /home/jcomcl/src/dunst;
#   });
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
    # utils
    input-utils #provides lsinput
    linuxConsoleTools # provides jstest
    utillinux # provides blkid
    v4l-utils # provides v4l2-ctl
    dmidecode
    qrencode
    zip unzip
    pandoc
    calibre
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
    firefox
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
  ];
  fonts.fontconfig = {
    defaultFonts.monospace = [ "Hack" ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable";

}

