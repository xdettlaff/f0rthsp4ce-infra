{ config, pkgs, botka-v0, botka-v1, ... }:

{
  users.users.telegram-bot = {
    isNormalUser = true;
    uid = 1101;
    packages = [ pkgs.sqlite-interactive ];
    group = "telegram-bot";
  };
  users.groups.telegram-bot = { };

  age.secrets.credentials-botka-v0.file =
    ../../../secrets/credentials/botka-v0.age;
  age.secrets.credentials-botka-v0.owner = "telegram-bot";
  age.secrets.credentials-botka-v0.group = "telegram-bot";
  systemd.services.telegram-bot-v0 = {
    description = "Telegram bot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      TZ = "Asia/Tbilisi";
      RUST_BACKTRACE = "1";
    };
    serviceConfig = {
      ExecStart = "${botka-v0.packages.x86_64-linux.f0bot}/bin/f0bot bot ${config.age.secrets.credentials-botka-v0.path}";
      KillSignal = "SIGINT"; # freaking tokio::ctrl_c handler
      WorkingDirectory = "/home/telegram-bot/v0";
      User = "telegram-bot";
      Group = "telegram-bot";
      Restart = "on-failure";
    };
  };

  age.secrets.credentials-botka-v1.file =
    ../../../secrets/credentials/botka-v1.age;
  age.secrets.credentials-botka-v1.owner = "telegram-bot";
  age.secrets.credentials-botka-v1.group = "telegram-bot";
  systemd.services.telegram-bot-v1 = {
    description = "Telegram bot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      TZ = "Asia/Tbilisi";
      RUST_BACKTRACE = "1";
    };
    serviceConfig = {
      ExecStart = "${botka-v1.packages.x86_64-linux.f0bot}/bin/f0bot bot ${config.age.secrets.credentials-botka-v1.path}";
      KillSignal = "SIGINT"; # freaking tokio::ctrl_c handler
      WorkingDirectory = "/home/telegram-bot/v1";
      User = "telegram-bot";
      Group = "telegram-bot";
      Restart = "on-failure";
    };
  };
}
