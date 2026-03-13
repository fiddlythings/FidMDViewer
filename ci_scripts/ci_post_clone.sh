#!/bin/bash
set -euo pipefail

brew install xcodegen
xcodegen generate
