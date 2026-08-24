#!/usr/bin/env bash
set -e

echo "Instalando Flutter..."

git clone \
  --depth 1 \
  --branch stable \
  https://github.com/flutter/flutter.git \
  .flutter

export PATH="$PWD/.flutter/bin:$PATH"

echo "Descargando dependencias..."
flutter pub get

echo "Compilando Flutter Web..."

flutter build web \
  --release \
  --dart-define=API_BASE_URL="$API_BASE_URL"

echo "Build terminado."
