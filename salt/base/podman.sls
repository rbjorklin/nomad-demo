# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

Ensure podman installed:
  pkg.installed:
    - name: podman
