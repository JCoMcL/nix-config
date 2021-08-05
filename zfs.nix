hostid:
{config, pkgs, ... }:
{
  networking.hostId = hostid;
  boot.supportedFilesystems = [ "zfs" ];
  # boot.kernelParams = ["zfs.zfs_arc_max=12884901888"];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  # services.zfs.forceImportAll = false;
  # services.zfs.forceImportRoot = false;
}
