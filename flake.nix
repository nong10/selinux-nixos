{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { system = "x86_64-linux"; };
  in
  with pkgs.lib;
  {
    nixosModules.default = {config, ... }: {
      options.selinux.refpolicy.configuration = {
        config.genFile = mkEnableOption "generate /etc/selinux/config";
        semanage_config.genFile = mkEnableOption "generate /etc/selinux/semanage.conf";

        config.text = mkOption {
          type = types.str;
          default = ''
            SELINUX=disabled
            SELINUXTYPE=refpolicy
          '';
          description = "text inside /etc/selinux/config";
        };
        semanage_config.text = mkOption {
          type = types.str;
          default = ''
            compiler-directory=${pkgs.policycoreutils}/libexec/selinux/hll
          '';
          description = "text inside /etc/selinux/semanage.conf";
        };
      };

     config = mkMerge
        [ 
          (mkIf config.selinux.refpolicy.configuration.config.genFile {
            environment.etc."selinux/config".text = ''
              ${config.selinux.refpolicy.configuration.config.text}
            '';
          })
          (mkIf config.selinux.refpolicy.configuration.semanage_config.genFile {
            environment.etc."selinux/semanage.conf".text = ''
              ${config.selinux.refpolicy.configuration.semanage_config.text}
            '';
          })
        ];     
      };
    };

}
