Ansible Role: banner
=========

An Ansible Role that configures banners (motd, issue and issue.net) on Linux systems.

Requirements
------------

This role works on Linux systems.

Role Variables
--------------

Available variables are listed below, along with default values (see `defaults/main.yml`). The files specified in the variables should be defined on `files` directory.

    banner_motd_file: banner.txt

Specify the file name to be used as motd file.

    banner_issue_file: banner.txt

Specify the file name to be used as issue file.

    banner_issuenet_file: banner.txt

Specify the file name to be used as motd file.

Dependencies
------------

No dependencies.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: guidugli.banner }

License
-------

MIT / BSD

Author Information
------------------

This role was created in 2020 by Carlos Guidugli.
