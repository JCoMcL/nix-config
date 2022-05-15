{config, pkgs, fetchFromGithub, ... }:

{
  imports = [
      ./hardware-configuration.nix
      (import ./zfs.nix "da587d42")
      ./sound.nix
      ./variables.nix
      ./papermc.nix
      #<agenix/modules/age.nix> TODO proper secret management
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sdc"; # or "nodev" for efi only
  boot.loader.timeout = 0;

  networking.hostName = "kiddo"; # Define your hostname.
  networking.hostId = "da587d42"; # Define your hostname.

  networking.useDHCP = false;
  networking.interfaces.enp5s0.useDHCP = true;

  boot.kernelParams = [
     "boot.shell_on_fail"
     "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];

  time.timeZone = "Europe/Dublin";

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "prohibit-password";

  users.users.root.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8S2LCAfLtVrnxHpNTFiz3G8sYpkWShS1tU80IE0UN3 jcomcl@jozbox"];

  networking.firewall.allowedTCPPorts = [ 80 ];
  networking.firewall.allowedUDPPorts = [ 80 ];

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
    videoDrivers = [ "nvidia" ];
    autoRepeatDelay = 180;
    autoRepeatInterval = 50;
    windowManager.dwm.enable = true;
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  programs.zsh.setOptions = [];
  programs.zsh.promptInit = "";
  users.defaultUserShell = pkgs.zsh;

  # Vidogaem
  programs.steam.enable = true;

# # Laptop
# programs.light.enable = true;
# hardware.bluetooth.enable = true;
# networking.wireless.iwd.enable = true;

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
      src = super.fetchFromGitHub {
        owner = "jcomcl";
        repo = "dwm";
        rev = "a43c92720e1766f2d6c6aca1afd998265d7931ba";
        sha256 = "1sdrvzsdbrh4mxl3a3gqkqnb4iwk820aflarzlvymwdy21lkkrcf";
      };
    });
    st = (super.st.overrideAttrs (old: {
      src = super.fetchFromGitHub {
        owner = "jcomcl";
        repo = "st";
        rev = "e9acc67c4b0c0f411fc0b6de7f276c8a7ccd1e98";
        sha256 = "0d36nqbw7073zdywd696gnmqwn37f5c9pgrfghwmj0xm2bxrb644";
      };
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
    #syncthing
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
    # gcc ccls
    # python3 python-language-server pipenv python38Packages.pip
    # nodejs nodePackages.prettier
    # nodePackages.typescript nodePackages.typescript-language-server
    # nodePackages.vscode-html-languageserver-bin html-tidy
    # nodePackages.vscode-css-languageserver-bin
    # nodePackages.vim-language-server
    # rustc cargo rls cargo-edit rust-bindgen rustfmt
    # go gopls
    # ghc
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
    marktext ghostwriter #TODO pick one
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
    feh
    # status
    sysstat
    inotify-tools
    acpid
    # server
    ddclient
    minecraft-server
  ];

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
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "Hack" ];
    emoji = [ "Twitter Color Emoji" ];
  };

  services.games.minecraft = {
    enable = true;
    agreeToEULA = true;
    openFirewall = true;
    extraUDPPorts = [ 24454 ];
    jvmOpts = "-Xms2G -Xmx5G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";
  };

  services.ddclient = {
    enable = true;
    use = "web, web=http://ipv4.nsupdate.info/myip";
    server = "ipv4.nsupdate.info";
    username = "kiddont.nsupdate.info";
    passwordFile = "/etc/nixos/secret/nsupdate";
    domains = [ "kiddont.nsupdate.info" ];
  };

  system.stateVersion = "21.11";

  time.timeZone = "Europe/Dublin";

}

