# modules/apps/commitizen.nix
# Commitizen - Tool for creating standardized git commits
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.commitizen.enable {
    # ========================================
    # Commitizen (Home Manager)
    # ========================================
    home.packages = with pkgs; [
      commitizen
    ];

    # Commitizen configuration
    home.file.".cz.toml".text = ''
      [tool.commitizen]
      name = "cz_customize"
      tag_format = "$version"
      version_scheme = "semver"
      version_provider = "npm"
      update_changelog_on_bump = true
      major_version_zero = true

      [tool.commitizen.customize]
      message_template = "{{change_type}}"

      [[tool.commitizen.customize.questions]]
      type = "list"
      name = "change_type"
      choices = [
        {value = ":bug:", name = "🐈 A bug fix. Correlates with PATCH in SemVer"},
        {value = ":feat:", name = "⭐ A new feature. Correlates with MINOR in SemVer"},
        {value = ":memo:", name = "📜 Documentation only changes"},
        {value = ":style:", name = "💅 Style Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)"},
        {value = ":recycle:", name = "♻️  Refactor. A code change that neither fixes a bug nor adds a feature"},
        {value = ":zap:", name = "⚡ A code change that improves performance"},
        {value = ":test_tube:", name = "🧪 Adding missing or correcting existing tests"},
        {value = ":arrow_up:", name = "⬆️  Upgrade dependencies"},
        {value = ":construction_worker:", name = "👷 Updates to CI build pipeline"},
        {value = ":alien:", name = "👽 Changes to CI configuration files and scripts (example scopes: GitLabCI)"}
      ]
      message = "Select the type of change you are committing"
    '';

    # Git aliases for commitizen
    programs.git = {
      enable = true;
      settings.alias = {
        cz = "!cz commit";
        czc = "!cz commit";
      };
    };

    # Shell aliases
    programs.zsh.shellAliases = lib.mkIf config.apps.zsh.enable {
      gcz = "cz commit";
      gczc = "cz commit";
    };
  };
}
