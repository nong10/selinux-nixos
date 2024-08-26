{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };
  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {};
  in
  with pkgs.lib;
  {
    nixosModules.default = {config, ... }: {
      options.refpolicy.configuration = {
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
          default = "";
          description = "text inside /etc/selinux/semanage.conf";
        };
      };

     config = mkMerge
        [ 
          (mkIf config.refpolicy.configuration.config.genFile {
            environment.etc."selinux/config".text = ''
              ${config.refpolicy.configuration.config.text}
            '';
          })
          (mkIf config.refpolicy.configuration.semanage_config.genFile {
            environment.etc."selinux/semanage.conf".text = ''
              ${config.refpolicy.configuration.semanage_config.text}
            '';
          })
        ];     
      };
    };

}
