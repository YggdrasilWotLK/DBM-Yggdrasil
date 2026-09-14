# DBM-Yggdrasilcore

A fork of Deadly Boss Mods for WotLK 3.3.5a, maintained specifically for Yggdrasilcore.

## Background

This addon is based on [DBM-Warmane](https://github.com/Zidras/DBM-Warmane) by Zidras, version v.9.2.21 alpha (fall 2023). Since forking from that base, it has been rewritten and extended, including:

- Bug fixes: resolved various Lua errors, including issues originating from DBM-Outland and problems triggered by combat state interactions
- Ruby Sanctum: added missing Blade Tempest timers
- Server alignment: audited and corrected timers, spell IDs, and encounter logic across modules to match Yggdrasilcore's server-side boss scripts

## Installation

1. [Download the repository from this link](https://github.com/YggdrasilWotLK/DBM-Yggdrasil/archive/refs/heads/main.zip).
2. In the .zip file, open folder `DBM-Yggdrasil-main` and copy all addon folders into your WoW 3.3.5a client's Interface/AddOns directory.
3. Restart or reload your UI.

## Compatibility

Tested on Yggdrasilcore. Expected to work well on other AzerothCore-based projects. Timers and mechanics are validated against Yggdrasilcore's server-side boss scripts.

## Contributing

Bug reports and pull requests are welcome, especially ones that identify timer or mechanic mismatches against Yggdrasilcore's boss scripts. Please include the relevant server-side script or a description of the discrepancy when reporting issues.

## Credits

- [Original DBM-Warmane by Zidras](https://github.com/Zidras/DBM-Warmane) and co-authors of this project up until release v.9.2.21 alpha.
- Upstream Deadly Boss Mods project and contributors

## License

This project inherits any applicable licensing terms of DBM-Warmane and upstream Deadly Boss Mods (used for the basis of Zidras' DBM-Warmane, not by YggdrasilWotLK directly). See their respective repositories for full license details.
