# Ansible Role: banner

[![CI](https://github.com/guidugli/ansible-role-banner/actions/workflows/CI.yml/badge.svg)](https://github.com/guidugli/ansible-role-banner/actions/workflows/CI.yml)
[![Release](https://github.com/guidugli/ansible-role-banner/actions/workflows/release.yml/badge.svg)](https://github.com/guidugli/ansible-role-banner/actions/workflows/release.yml)
[![Galaxy](https://img.shields.io/badge/ansible--galaxy-guidugli.banner-blue.svg)](https://galaxy.ansible.com/ui/standalone/roles/guidugli/banner/)
[![License](https://img.shields.io/github/license/guidugli/ansible-role-banner)](LICENSE)

Manage Linux login and pre-authentication banners by deploying static files to `/etc/motd`, `/etc/issue`, and `/etc/issue.net`.

## Overview

This role provides a small, predictable banner-management surface:

- optional management of `motd`, `issue`, and `issue.net`
- shipped banner files copied with deterministic ownership and mode
- optional removal of existing symbolic links before file deployment
- semantic validation through `meta/argument_specs.yml` plus `tasks/assert.yml`
- Molecule coverage that verifies symlink replacement, idempotence, file mode, and file content
- metadata generated from a single source of truth in `molecule/shared/vars.yml`

## Features

- Uses `ansible.builtin.*` modules consistently.
- Keeps privilege escalation at the play level instead of forcing `become` inside role tasks.
- Avoids duplicate task-level `validate_argument_spec`; role argument validation is handled automatically by Ansible when the role is loaded.
- Uses concrete defaults for booleans and validated strings to avoid auto-validation pitfalls.
- Keeps test assets readable and DRY with shared Molecule playbooks.

## Supported platforms

The generated metadata currently declares support for:

- Ubuntu: `noble`, `jammy`
- Debian: `trixie`, `bookworm`
- Fedora: `43`, `42`

## Role variables

See `defaults/main.yml` for the complete defaults.

```yaml
---
banner_manage_motd: true
banner_manage_issue: true
banner_manage_issue_net: true

banner_motd_file: banner.txt
banner_issue_file: banner.txt
banner_issuenet_file: banner.txt

banner_remove_existing_symlinks: true
banner_owner: root
banner_group: root
banner_mode: '0644'
banner_backup: false
```

### Variable behavior notes

- `banner_*_file` values must refer to files located under the role `files/` directory.
- Empty strings are treated as invalid for enabled banner targets.
- If you disable a target with `banner_manage_*: false`, its file variable is ignored.
- `banner_mode` must be a four-digit octal string such as `0644`.

## Important behavior

### Symlink handling

Some systems or base images may ship `/etc/motd`, `/etc/issue`, or `/etc/issue.net` as symbolic links. When `banner_remove_existing_symlinks` is `true`, the role removes the link first and then manages the target path as a regular file.

### Privilege escalation

This role intentionally does **not** set `become: true` inside role tasks. The caller should decide that at the play level.

Example:

```yaml
---
- name: Apply login banners
  hosts: all
  become: true
  roles:
    - role: guidugli.banner
```

## How it works

1. Ansible performs automatic role argument validation using `meta/argument_specs.yml`.
2. `tasks/assert.yml` performs semantic checks that are easier to express as assertions.
3. If enabled, symlink banner targets are removed.
4. The role copies the requested files from `files/` into `/etc` with the configured owner, group, mode, and backup behavior.

## Usage examples

### Default behavior

```yaml
---
- name: Configure standard banners
  hosts: all
  become: true
  roles:
    - role: guidugli.banner
```

### Manage only `/etc/issue` and `/etc/issue.net`

```yaml
---
- name: Configure console pre-authentication banners only
  hosts: all
  become: true
  roles:
    - role: guidugli.banner
      vars:
        banner_manage_motd: false
        banner_issue_file: console_banner.txt
        banner_issuenet_file: console_banner.txt
```

### Preserve existing symlinks

```yaml
---
- name: Skip symlink replacement
  hosts: all
  become: true
  roles:
    - role: guidugli.banner
      vars:
        banner_remove_existing_symlinks: false
```

## Molecule testing

The role uses a shared Molecule layout:

```text
molecule/
  shared/
    vars.yml
    prepare.yml
    converge.yml
    verify.yml
  default/
    molecule.yml
    prepare.yml
    converge.yml
    verify.yml
```

The default scenario:

- creates symlinks for the managed banner targets during `prepare.yml`
- converges the role with play-level `become: true`
- relies on Molecule idempotence checks
- verifies regular-file replacement, ownership, mode, and deployed content

Typical local commands:

```bash
python -m pip install --upgrade pip
python -m pip install "ansible-core>=2.16,<2.20" "molecule-plugins[docker]" molecule ansible-lint yamllint
molecule test
```

To test a different container image with the shared scenario:

```bash
MOLECULE_IMAGE=docker.io/geerlingguy/docker-debian13-ansible:latest molecule test
```

## Metadata generation

`meta/main.yml` is generated from:

- `templates/meta_main.yml.j2`
- `molecule/shared/vars.yml`
- `scripts/render_meta_main.py`

Refresh generated metadata with:

```bash
./scripts/update_release_metadata.sh
```

The helper script performs a lightweight `py_compile` preflight before writing generated files.

## Release workflow

- CI regenerates metadata and fails if committed generated assets drift from the source template/data.
- The release workflow re-runs validation on version tags and then triggers Ansible Galaxy role import using the repository name and a GitHub Actions secret.

Required repository configuration:

- secret: `GALAXY_API_KEY`
- variable: `WORKING_DIR` (recommended if you check out the repo into a nested path)
- variable: `GALAXY_NAMESPACE` (for the release workflow)

## Repository structure

```text
.
├── defaults/
├── files/
├── handlers/
├── meta/
├── molecule/
│   ├── default/
│   └── shared/
├── scripts/
├── tasks/
├── templates/
├── .github/workflows/
├── README.md
└── LICENSE
```

## Design notes

- This role is **not** a bootstrap/pre-Python role, so it uses normal Ansible modules rather than `raw`.
- The role keeps its public variables in `defaults/main.yml`; `vars/main.yml` should remain empty or be removed unless a future internal-only need appears.
- Metadata generation is template-first so `meta/main.yml` can be reproduced exactly.
- A dedicated systemd Molecule scenario is unnecessary here because the role manages static files and does not exercise systemd-specific behavior.

## License

MIT

## Author

Carlos Eduardo Panazzolo Guidugli
