# { pkgs, ... }:
{
  programs.nixvim.plugins.lazygit = {
    enable = true;
  };
  # extraPlugins = [ pkgs.vimPlugins.lazygit-nvim ];
  #
  # extraConfigLua = ''
  #   require("telescope").load_extension("lazygit")
  # '';
  #
  # keymaps = [
  #   {
  #     mode = "n";
  #     key = "<leader>gg";
  #     action = "<cmd>LazyGit<CR>";
  #     options = {
  #       desc = "LazyGit (root dir)";
  #     };
  #   }
  # ];
}
