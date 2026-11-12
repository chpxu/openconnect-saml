{
  description = "OpenConnect wrapper with Azure AD (SAML) SSO support for Cisco SSL-VPNs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
    in
    {
      overlays.default = final: _prev: {
        openconnect-saml = final.callPackage ./package.nix { };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.openconnect-saml;
          openconnect-saml = pkgs.openconnect-saml;
          gui = pkgs.openconnect-saml.override { withGui = true; };
          full = pkgs.openconnect-saml.override {
            withGui = true;
            withFido2 = true;
            withTui = true;
          };
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = nixpkgs.lib.getExe self.packages.${system}.default;
        };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ pkgs.openconnect-saml ];
            packages = [pkgs.openconnect-saml] ++ (with pkgs.python314Packages; [
            pyqt6
              pyqt6-webengine
              pytest
              pytest-asyncio
              pytest-httpserver
              cryptography
              ruff

            ]);
          };
        }
      );
    };
}
