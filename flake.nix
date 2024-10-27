{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    sops-nix.url = "github:Mic92/sops-nix"; # secrets management
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR"; # nix user repository

    impermanence.url = "github:nix-community/impermanence"; # nuke / on every boot

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    hyprlock.url = "github:hyprwm/hyprlock";
    hyprlock.inputs.nixpkgs.follows = "hyprland";

    swww.url = "github:LGFae/swww";

    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";

    # nixvim.url = "github:nix-community/nixvim"; # for unstable channel
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs-stable";

    # nixvim.url = "github:pete3n/nixvim-flake"; # https://github.com/pete3n/nixvim-flake 27* panget
    nixvim.url = "github:dc-tec/nixvim"; # https://github.com/dc-tec/nixvim 30* cleanest so far pero walang q so dealbreaker
    # nixvim.url = "github:niksingh710/nvix"; # https://github.com/niksingh710/nvix 69* clickable folds, topbar depth map, wrong formatter, awful color
    # nixvim.url = "github:redyf/Neve"; # https://github.com/redyf/Neve 153* i want the clickable folds from niksingh710, reduce on-screen mess, proper indentation highlighting from dc-tec to here
    # nixvim.url = "github:elythh/nixvim"; # https://github.com/elythh/nixvim 155* panget
  };

  outputs =
    {
      self,
      nixpkgs,
      impermanence,
      disko,
      sops-nix,
      hyprland,
      anyrun,
      home-manager,
      nix-index-database,
      # nixvim, # not using my own nixvim config just yet
      alejandra,
      stylix,
      ...
    }@inputs:
    let
      # https://nixos.wiki/wiki/Nix_Language_Quirks
      # Since this is inside outputs the self argument allows
      # ALL `outputs` inheritable
      inherit (self) outputs; # this makes outputs inheritable below

      # allSystemNames = [ "x86_64-linux" "aarch64-darwin" ];
      # forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      user = {
        username = "kba";
        fullname = "Kenneth B. Aguirre";
        email = "aguirrekenneth@gmail.com";
      };

      hyprlandFlake = hyprland.packages.${pkgs.stdenv.hostPlatform.system};
      anyrunFlake = anyrun.packages.${pkgs.system};

      inheritArgs = {
        inherit
          inputs
          outputs
          user
          hyprlandFlake
          anyrunFlake
          ;
      };
      sharedModules = [
        # stylix.homeManagerModules.stylix # TODO: hm.nix gnome dconf issue
        # stylix.nixosModules.stylix # TODO: still suffering from infinite recursion
        { environment.systemPackages = [ alejandra.defaultPackage.${system} ]; }
        home-manager.nixosModules.home-manager
        nix-index-database.nixosModules.nix-index
        # nixvim.nixosModules.nixvim
        sops-nix.nixosModules.sops

        ./modules # this points to default.nix that imports storage, core, development, graphical
      ];
    in
    {
      nixosConfigurations = {
        # 5700X3D 4080 Super Desktop
        Super = nixpkgs.lib.nixosSystem {
          modules = sharedModules ++ [ ./machines/Super/default.nix ];
          specialArgs = inheritArgs;
        };

        # Beelink Mini PC
        Link = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inheritArgs;
          modules = sharedModules ++ [
            disko.nixosModules.disko
            ./machines/Link/zfs-mirror.nix
            impermanence.nixosModules.impermanence
            ./machines/Link/default.nix
          ];
          # modules = [
          #   disko.nixosModules.disko
          #   ./machines/Link/zfs-mirror.nix
          #   impermanence.nixosModules.impermanence
          #   ./machines/Link/configuration.nix
          #   home-manager.nixosModules.home-manager
          # ];
        };
      };

      # TODO: test alejandra formatter on a rebuild next boot
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    };
}
