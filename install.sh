#!/bin/bash

set -e
set -o pipefail

echo "🚀 Starting installation of Docker, Kind, and kubectl..."

# ----------------------------
# 1. Install Docker
# ----------------------------
if ! command -v docker &>/dev/null; then
  echo "📦 Installing Docker..."
  sudo apt-get update -y
  sudo apt-get install -y docker.io
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
  echo "✅ Docker installed and user added to docker group."
else
  echo "✅ Docker is already installed."
fi

# ----------------------------
# Detect architecture
# ----------------------------
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    KIND_URL="https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64"
    KUBECTL_ARCH="amd64"
    ;;
  aarch64)
    KIND_URL="https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-arm64"
    KUBECTL_ARCH="arm64"
    ;;
  *)
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# ----------------------------
# 2. Install Kind (force overwrite)
# ----------------------------
echo "📦 Installing Kind..."
sudo rm -f /usr/local/bin/kind
curl -Lo kind "$KIND_URL"
chmod +x kind
sudo mv kind /usr/local/bin/kind
echo "✅ Kind installed successfully."

# ----------------------------
# 3. Install kubectl (latest stable, force overwrite)
# ----------------------------
echo "📦 Installing kubectl (latest stable version)..."
sudo rm -f /usr/local/bin/kubectl
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/${KUBECTL_ARCH}/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
echo "✅ kubectl installed successfully."

# ----------------------------
# 4. Confirm Versions
# ----------------------------
echo
echo "🔍 Installed Versions:"
docker --version
kind --version
kubectl version --client --output=yaml

echo
echo "🎉 Docker, Kind, and kubectl installation complete!"
