{
	disko.devices = {
		disk.main = {
			type = "disk";
		device = "/dev/sdb";
			content = {
				type = "gpt";
				partitions = {
					ESP = {
						size = "512M";
						type = "EF00";
						content = {
							type = "filesystem";
							format = "vfat";
							mountpoint = "/boot";
							mountOptions = [ "fmask=0077" "dmask=0077" ];
						};
					};
					nix = {
						size = "10G";	# под пакеты
						content = {
							type = "filesystem";
							format = "ext4";
							mountpoint = "/nix";
						};
					};
					persist = {
						size = "100%";
						content = {
							type = "luks";
							name = "cryptpersist";
							settings.allowDiscards = true;
							content = {
								type = "btrfs";
								extraArgs = [ "-f" ];
								subvolumes = {
									"@persist" = {
										mountpoint = "/persist";
										mountOptions = [ "compress=zstd" "noatime" ];
									};
								};
							};
						};
					};
				};
			};
		};
		nodev = {
			"/" = {
				fsType = "tmpfs";
				mountOptions = [ "defaults" "size=2G" "mode=755" ];
			};
			"/home/hypoxie" = {
				fsType = "tmpfs";
				mountOptions = [ "defaults" "size=4G" "mode=777" ];
				neededForBoot = true;
			};
			"/tmp" = {
				fsType = "tmpfs";
				mountOptions = [ "defaults" "size=1G" "mode=1777" ];
			};
		};
	};
}