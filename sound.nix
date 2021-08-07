{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.prict.sound;
in {
  options.prict.sound = {
    enable = mkEnableOption "nixos is shit";
  };

  config = mkIf cfg.enable {
    sound.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    environment.systemPackages = [
      #pkgs.helvum FIXME
      #TODO replace pulseaudio-specifc packages
      pkgs.pulsemixer
      pkgs.pulseaudio #provides pactl
    ];
  };
}

