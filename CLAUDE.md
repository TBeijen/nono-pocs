# nono-pocs

POC repo for investigating and configuring nono.sh sandbox profiles for AI coding agents (Claude Code, opencode, etc.).

## Layout

- `profile-claude-code-tb-dump.txt` — Output of `nono profile show claude-code-tb`, showing the resolved profile
- `.resources/nono` — Symlink to the nono.sh source code (`~/projects/personal/always-further/nono`)
- `.resources/profiles` — Symlink to user nono profiles (`~/.config/nono/profiles`)

## Key paths in the nono codebase

- `crates/nono-cli/data/policy.json` — Embedded policy: security group definitions (deny_keychains_macos, claude_code_macos, etc.)
- `crates/nono-cli/src/profile/mod.rs` — Profile parsing, merging (`merge_profiles`), group resolution (`merge_implicit_default_groups`)
- `crates/nono-cli/src/deprecated_schema.rs` — Legacy `policy.*` field drain into canonical `filesystem.*`/`groups.*` fields
- `crates/nono/src/sandbox/macos.rs` — Seatbelt profile generation, including `has_explicit_keychain_db_access()` check
- `crates/nono-cli/src/policy.rs` — Deny override / `bypass_protection` application (`apply_deny_overrides`)

## Base claude-code profile (registry pack)

The `claude-code` profile ships as a registry pack at `~/.config/nono/packages/always-further/claude/profiles/claude.json`. It extends `default` and includes the `claude_code_macos` security group.

## User profile

The user's custom profile is at `~/.config/nono/profiles/claude-code-tb.json`. It extends `claude-code`.

## Profile merging rules

- Merging is **cumulative** via `dedup_append(base, child)` — both allow and deny entries from parent and child are combined
- There is no way for a child profile to **remove** an allow entry from the parent
- `groups.exclude` can remove security groups, but NOT individual filesystem entries added by the parent profile directly
- `bypass_protection` (legacy: `policy.override_deny`) removes deny rules and emits Seatbelt allow rules to punch through
