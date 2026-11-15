{ pkgs, lib, ... }:

let
  driver = pkgs.stdenv.mkDerivation {
    passthru.driverPath = "/lib/libfprint-2/tod-1";
    pname = "libfprint-2-tod1-broadcom-cv2";
    version = "0-unstable";

    src = pkgs.fetchgit {
      url = "https://git.launchpad.net/~oem-solutions-engineers/libfprint-2-tod1-broadcom/+git/libfprint-2-tod1-broadcom";
      rev = "f7d31fcb9f6952d7d76ba50287e000c29760589d";
      hash = "sha256-ulyq7vtM8moyzPmfXP3pyojPe90/BP/4DCI7ic5WPic=";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.python3
    ];

    buildInputs = (pkgs.libfprint-2-tod1-broadcom.buildInputs or [ ]) ++ [
      pkgs.libfprint-tod
      pkgs.glib
      pkgs.libusb1
      pkgs.stdenv.cc.cc.lib
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      stock="usr/lib/x86_64-linux-gnu/libfprint-2/tod-1/libfprint-2-tod-1-broadcom.so"
      dst="$out/lib/libfprint-2/tod-1/libfprint-2-tod-1-broadcom.so"

      echo "54fa3befc02df393077cebf96e018e3bf752cee61509897d945ab18c58c5e172  $stock" | sha256sum -c -
      mkdir -p "$(dirname "$dst")" "$out/lib/udev/rules.d"

      python3 -c '
      import sys
      p = [
        # 1. .rodata id_table: USB PID 0x5842 -> 0x5834
        ("425800005c0a0000", "345800005c0a0000"),
        # 2. device enumerator: PID-filter je -> jmp
        ("66f7c1fdff740c", "66f7c1fdffeb0c"),
        # 3. dev_probe: treat fw-check err 0x1c as success (skip Citadel upgrade check)
        ("83f81c741f", "83f81c743a"),
        # 4. enroll FSM: route CV2 status 0x59 to normal status-0 commit path
        ("4181fda40000000f84fd010000", "4181fd590000000f8416000000"),
        # 5. verify: drop edx!=0 short-circuit (6x nop) so verify_report always runs
        ("85d20f858a00000083f801", "85d290909090909083f801"),
        # 6. commit wrapper: pass CV2 identity blobs (len 8 / 21) via RIP-rel ptrs
        ("bf01000000488d3563a60000e80e02feff4883ec08418b7d004531c9534531c031c931d26a004889ee488d44241c50", "4883ec08418b7d004c8d0d68a600005341b815000000488d0d52a60000ba080000006a004889ee488d44241c509090"),
        # 7. .rodata: reuse commit debug string for BroadcomWBF identity blobs
        ("63616c6c2063765f66696e6765727072696e745f636f6d6d69745f656e", "00000400040000000101ff0000000d000c42726f6164636f6d57424600"),
      ]
      with open(sys.argv[1], "rb") as f:
          d = f.read()
      for a, b in p:
          x, y = bytes.fromhex(a), bytes.fromhex(b)
          assert len(x) == len(y) and d.count(x) == 1
          d = d.replace(x, y, 1)
      with open(sys.argv[2], "wb") as f:
          f.write(d)
      ' "$stock" "$dst"

      echo "308055122a9d4b7b723325a4935f25a23300ac656962c9db7e5285164233c5ab  $dst" | sha256sum -c -
      chmod 755 "$dst"

      printf '%s\n' 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0a5c", ATTRS{idProduct}=="5834", ENV{LIBFPRINT_DRIVER}="Broadcom Sensors"' \
        > "$out/lib/udev/rules.d/61-broadcom-cv2-5834.rules"

      if [ -d var/lib/fprint/fw ]; then
        mkdir -p "$out/lib/fprint/fw"
        cp -r var/lib/fprint/fw/* "$out/lib/fprint/fw/"
      fi

      runHook postInstall
    '';

    meta = {
      description = "Patched Broadcom libfprint-2 TOD driver for Dell ControlVault 2 (0a5c:5834)";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  nixpkgs.config.allowUnfree = true;

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      inherit driver;
    };
  };

  services.udev.packages = [ driver ];

  systemd.tmpfiles.rules = [
    "d /var/lib/fprint 0755 root root -"
    "L+ /var/lib/fprint/fw - - - - ${driver}/lib/fprint/fw"
  ];
}
