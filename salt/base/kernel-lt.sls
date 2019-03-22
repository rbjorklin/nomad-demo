# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

ensure newer kernel installed:
  pkg.installed:
    - pkgs:
      - kernel-ml
      #- kernel-lt # Prefer this for stability but Ceph Mimic requires a newer kernel

use first listed kernel:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^GRUB_DEFAULT=saved$'
    - repl: '#GRUB_DEFAULT=saved'

regenerate grub.cfg:
  cmd.run:
    - name: grub2-mkconfig -o /boot/grub2/grub.cfg
    - onchanges:
      - file: use first listed kernel
      - pkg: ensure newer kernel installed
