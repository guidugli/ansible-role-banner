[![CI](https://github.com/guidugli/ansible-role-banner/actions/workflows/CI.yml/badge.svg)](https://github.com/guidugli/ansible-role-banner/actions/workflows/CI.yml)
[![Release](https://img.shields.io/github/v/tag/guidugli/ansible-role-banner?label=release)](https://github.com/guidugli/ansible-role-banner/tags)
[![Galaxy](https://img.shields.io/badge/galaxy-guidugli.banner-5bbdbf)](https://galaxy.ansible.com/ui/standalone/roles/guidugli/banner/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

# Ansible Role: banner

Manage Linux login and pre-authentication banners by deploying role-provided files to `/etc/motd`, `/etc/issue`, and `/etc/issue.net`. Each target can be enabled independently, and existing symbolic links can be replaced safely before deterministic file deployment.

## Requirements

- Ansible Core 2.14 or newer, as declared by the generated role metadata.
- A Linux target that uses `/etc/motd`, `/etc/issue`, or `/etc/issue.net`.
- Elevated access to write under `/etc`. Supply privilege escalation outside this role.
- The `containers.podman` collection at version 1.10.0 or newer for the included Molecule scenarios.

## Features

- Independently manages MOTD, local-console, and remote pre-authentication banners.
- Replaces managed symlinks only when `banner_remove_existing_symlinks` is enabled.
- Uses idempotent `ansible.builtin.stat`, `ansible.builtin.file`, and `ansible.builtin.copy` operations.
- Validates all public inputs through `meta/argument_specs.yml` and semantic assertions.
- Applies consistent `banner` plus functional task tags.
- Keeps privilege escalation under caller control.
- Uses shared Molecule converge and verification plays.

## Supported platforms

The platform matrix and generated metadata cover:

- Ubuntu 26.04 and 24.04
- Debian 13 and 12
- Fedora 44 and 43

The role itself manages static files and does not require systemd.

## Variables

All public variables are defined in `defaults/main.yml` and mirrored in `meta/argument_specs.yml`.

| Variable | Type | Default | Description |
|---|---|---:|---|
| `banner_manage_motd` | boolean | `true` | Manage `/etc/motd`. When false, `banner_motd_file` is ignored. |
| `banner_manage_issue` | boolean | `true` | Manage `/etc/issue`. When false, `banner_issue_file` is ignored. |
| `banner_manage_issue_net` | boolean | `true` | Manage `/etc/issue.net`. When false, `banner_issuenet_file` is ignored. |
| `banner_motd_file` | string | `banner.txt` | Source file under the role `files/` directory for `/etc/motd`. Must be non-empty when MOTD management is enabled. |
| `banner_issue_file` | string | `banner.txt` | Source file under the role `files/` directory for `/etc/issue`. Must be non-empty when issue management is enabled. |
| `banner_issuenet_file` | string | `banner.txt` | Source file under the role `files/` directory for `/etc/issue.net`. Must be non-empty when issue.net management is enabled. |
| `banner_remove_existing_symlinks` | boolean | `true` | Remove an enabled destination first when it is a symbolic link, allowing the role to create a regular file. |
| `banner_owner` | string | `root` | Owner of every managed banner file. Must be non-empty. |
| `banner_group` | string | `root` | Group of every managed banner file. Must be non-empty. |
| `banner_mode` | string | `'0644'` | File mode for every managed banner file. It must be a four-digit octal string. |
| `banner_backup` | boolean | `false` | Ask the copy module to retain a backup when managed content changes. |

At least one target must remain enabled. Source names refer to files in the role's `files/` directory, not files on the managed host.

## Example playbook

```yaml
---
- name: Configure login banners
  hosts: linux
  become: true
  roles:
    - role: guidugli.banner
      vars:
        banner_manage_motd: true
        banner_manage_issue: true
        banner_manage_issue_net: true
        banner_motd_file: banner.txt
        banner_issue_file: banner.txt
        banner_issuenet_file: banner.txt
        banner_remove_existing_symlinks: true
        banner_mode: '0644'
```

To manage only pre-authentication banners, set `banner_manage_motd: false` and leave the two issue targets enabled.

## Molecule testing instructions

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements-dev.txt
ansible-galaxy collection install -r requirements.yml
yamllint .
ansible-lint .
molecule test -s default
molecule test -s systemd
```

The shared prepare play creates symlink fixtures. The verify play checks regular-file replacement, ownership, group, mode, and exact deployed content. The default scenario includes Molecule's idempotence phase.

## Execution notes

- **Privilege model:** role tasks never declare `become`, `become_user`, or `become_method`. Real-host callers should use `become: true` at the play, inventory, or automation-controller level because the role writes under `/etc` and normally assigns root ownership.
- **Container behavior:** the Molecule containers execute as root while shared plays explicitly use `become: false`. No role task assumes that privilege escalation is available inside a container.
- **Systemd behavior:** the role has no service, systemd, unit-file, mount, sysctl, or init operations. The systemd scenario therefore exercises the same static-file behavior in a systemd-capable environment without systemd-specific role logic.
- **Tags:** use `--tags banner` for the whole role, `--tags validate` for validation, or `--tags config` for banner-file management.

## Release workflow

Repository metadata is generated from `templates/meta_main.yml.j2` and `molecule/shared/vars.yml`. Do not edit generated `meta/main.yml` directly.

```bash
./scripts/update_release_metadata.sh
./scripts/release.sh --version v1.2.0 --message "Release v1.2.0"
```

A version tag triggers the repository release workflow and Galaxy import when the required repository configuration is present.

## License

MIT

## Author

Carlos Eduardo Panazzolo Guidugli
