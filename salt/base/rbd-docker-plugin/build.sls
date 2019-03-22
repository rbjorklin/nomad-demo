{% set gopath = "/tmp/go" %}

ensure golang installed:
  pkg.installed:
    - name: golang

clone rbd-docker-plugin:
  git.cloned:
    - name: https://github.com/yp-engineering/rbd-docker-plugin.git
    - target: {{ gopath }}/src/rbd-docker-plugin

build rbd-docker-plugin:
  cmd.run:
    - name: make
    - cwd: {{ gopath }}/src/rbd-docker-plugin
    - prepend_path: {{ gopath }}/bin
    - env:
      - GOPATH: {{ gopath }}

copy rbd-docker-plugin to salt files:
  cmd.run:
    - name: cp dist/rbd-docker-plugin /srv/files/base/rbd-docker-plugin
    - cwd: {{ gopath }}/src/rbd-docker-plugin
