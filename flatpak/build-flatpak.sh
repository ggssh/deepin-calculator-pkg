#!/bin/bash

set -e

export HTTP_PROXY="http://127.0.0.1:8889"
export HTTPS_PROXY="http://127.0.0.1:8889"

flatpak-builder --user --install  --force-clean flatpak-test/ deepin-calculator.yaml
flatpak run org.deepin.deepin-calculator