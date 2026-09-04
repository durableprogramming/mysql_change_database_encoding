{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/packages/
  packages = [ pkgs.git pkgs.libmysqlclient pkgs.percona-toolkit ];

  languages.ruby.enable = true;
  languages.ruby.version = "3.3.2";

  enterShell = ''
    ruby --version
    git --version
  '';

  enterTest = ''
    bundle exec rake test
  '';

  # See full reference at https://devenv.sh/reference/options/
}
