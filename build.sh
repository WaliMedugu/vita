#!/bin/bash

# Exit on error
set -e

echo "=== Vercel Flutter Web Build Start ==="

# Check if flutter directory is cached/present
if [ ! -d "flutter" ]; then
  echo "=== Downloading Flutter SDK (stable channel) ==="
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
  echo "=== Flutter SDK cached, updating... ==="
  cd flutter
  git fetch --depth 1
  git checkout stable
  git pull origin stable
  cd ..
fi

# Add Flutter to the path
export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Running Flutter doctor ==="
flutter doctor -v

echo "=== Configuring Web Support ==="
flutter config --enable-web

echo "=== Building Flutter Web Application ==="
cd vita
flutter pub get
flutter build web --release

echo "=== Vercel Flutter Web Build Done! ==="
