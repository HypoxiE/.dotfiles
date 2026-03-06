{
	disko.devices.disk.main = {
		device = "/dev/nvme0n1";
		type = "disk";

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
					};
				};

				nixos = {
					size = "100%";

					content = {
						type = "btrfs";

						subvolumes = {
							"@root" = {
								mountpoint = "/";
								mountOptions = [ "compress=zstd" "noatime" ];
							};
							"@home" = {
								mountpoint = "/home";
								mountOptions = [ "compress=zstd" "noatime" ];
							};
							"@nix"  = {
								mountpoint = "/nix";
								mountOptions = [ "compress=zstd" "noatime" ];
							};
							"@log"  = {
								mountpoint = "/var/log";
								mountOptions = [ "compress=zstd" "noatime" ];
							};
							"@snapshots" = { mountpoint = "/.snapshots"; };
						};
					};
				};
			};
		};
	};
}