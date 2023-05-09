#!/usr/bin/env bash

set -euo pipefail

echo "Checking if kind is already installed..."
if command -v kind &> /dev/null; then
  echo "kind is already installed"
else
  echo "Installing kind..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    KIND_BINARY_URL="https://kind.sigs.k8s.io/dl/v0.18.0/kind-linux-amd64"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    MACHINE_TYPE=$(uname -m)
    if [[ "$MACHINE_TYPE" == "x86_64" ]]; then
      KIND_BINARY_URL="https://kind.sigs.k8s.io/dl/v0.18.0/kind-darwin-amd64"
    elif [[ "$MACHINE_TYPE" == "arm64" ]]; then
      KIND_BINARY_URL="https://kind.sigs.k8s.io/dl/v0.18.0/kind-darwin-arm64"
    else
      echo "Unsupported machine type: $MACHINE_TYPE"
      exit 1
    fi
  else
    echo "Unsupported OS: $OSTYPE"
    exit 1
  fi
  curl -Lo ./kind $KIND_BINARY_URL
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
  echo "kind installed successfully"
fi

echo "Creating a local Kubernetes cluster..."
SCRIPT_DIR=$(dirname "$(realpath "$0")")
kind create cluster --config "$SCRIPT_DIR/kind-config.yml"
echo "Local Kubernetes cluster created successfully"

echo "Getting kubeconfig..."
kubectl cluster-info --context kind-kind
echo "Kubeconfig retrieved successfully"

echo "Applying Kubernetes manifests..."
kubectl apply -f "$SCRIPT_DIR/manifests/"
echo "Kubernetes manifests applied successfully"
