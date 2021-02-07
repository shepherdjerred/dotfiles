$packages = @(
("SublimeHQ.SublimeText"),
("Git.Git"),
("RiotGame.LeagueOfLegends"),
("Google.Chrome"),
("Logitech.Options"),
("Discord.Discord"),
("7zip.7zip"),
("JetBrains.Toolbox"),
("Microsoft.PowerToys"),
("Windows.Terminal"),
("Microsoft.PowerShell"),
("Mojang.MinecraftLauncher"),
("AdoptOpenJDK.OpenJDK"),
("OpenJS.NodeJS"),
("RubyInstallerTeam.Ruby"),
("Python.Python"),
("Rustlang.rust-msvc"),
("Docker.DockerDesktop"),
("Notion.Notion"),
("Spotify.Spotify"),
("ShareX.ShareX"),
("Valve.Steam"),
("ElectronicArts.Origin"),
("Blizzard.BattleNet"),
("Telegram.TelegramDesktop"),
("Armin2208.WindowsAutoNightMode"),
("Nvidia.GeForceExperience")
)

# manual:
# microsoft office
# adobe creative cloud
# blitz
# aerial
# bing wallpaper
# resilio sync
# affinity

foreach ($package in $packages) {
  winget install $package
}
