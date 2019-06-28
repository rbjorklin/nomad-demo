# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

highstate_run:
  local.state.apply:
    - tgt: {{ data['id'] }}
