{
  description = "Firefly Luciferin - Ambient lighting software";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );
    in
    {
      devShells = forAllSystems (pkgs: {
        default =
          let
            linuxRuntimeLibs = with pkgs; [
              gst_all_1.gstreamer
              gst_all_1.gst-plugins-base
              gst_all_1.gst-plugins-good
              gst_all_1.gst-plugins-bad
              gst_all_1.gst-plugins-ugly
              gst_all_1.gst-libav
              dbus
              alsa-lib
              libpulseaudio
              libayatana-appindicator
              libnotify
              gtk3
              glib
              libGL
            ];
          in
          pkgs.mkShell {
            packages = [
              pkgs.jdk25
              pkgs.maven
            ];

            buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux linuxRuntimeLibs;

            # JNA, JavaFX graphics, and the gstreamer bindings dlopen these at runtime.
            LD_LIBRARY_PATH = pkgs.lib.optionalString pkgs.stdenv.isLinux (
              pkgs.lib.makeLibraryPath linuxRuntimeLibs
            );
            JAVA_HOME = pkgs.jdk25;
          };
      });
    };
}
