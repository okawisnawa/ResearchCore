#!/bin/bash
# Lab Manager v4.0 - Enterprise Hardened
# Mengelola isolasi kontainer dengan path data terdedikasi
set -euo pipefail

# Konfigurasi Lab
declare -A LABS=(
    ["autonomous-lab"]="ubuntu:24.04"
    ["datamining-lab"]="ubuntu:24.04"
    ["mobile-dev"]="ubuntu:24.04"
    ["forensic-lab"]="docker.io/kalilinux/kali-rolling:latest"
)

log() { echo -e "\033[32m[$(date +'%Y-%m-%d %H:%M:%S')]\033[0m $1"; }
error() { echo -e "\033[31m[ERROR]\033[0m $1" >&2; }

provision_lab() {
    local name=$1 && local image=$2
    local extra_args=""
    # GPU Passthrough hanya untuk autonomous-lab
    [[ "$name" == "autonomous-lab" ]] && extra_args="--nvidia"

    if distrobox list --name "$name" >/dev/null 2>&1; then
        log "Lab '$name' sudah tersedia di sistem."
    else
        log "Provisioning '$name' dari image $image..."
        distrobox create --name "$name" \
            --image "$image" \
            $extra_args \
            --home "$HOME/ResearchLabs/data/$name" \
            --additional-flags "--userns keep-id:uid=$(id -u),gid=$(id -g) --security-opt label=disable" \
            --yes || { error "Provisioning gagal."; return 1; }
    fi
}
backup_lab() {
    local name=$1
    local backup_dir="$HOME/ResearchLabs/backups"
    mkdir -p "$backup_dir"
    
    if [ -d "$HOME/ResearchLabs/data/$name" ]; then
        log "Melakukan kompresi data lab '$name'..."
        tar -czf "$backup_dir/${name}_$(date +'%Y%m%d').tar.gz" -C "$HOME/ResearchLabs/data/" "$name"
        log "Backup berhasil disimpan di: $backup_dir"
    else
        error "Data lab '$name' tidak ditemukan."
    fi
}
main() {
    echo -e "Opsi: [1] Masuk ke Lab [2] Backup Data Lab"
    read -r -p "Pilihan Anda: " mode
    
    echo -e "Available: ${!LABS[*]}"
    read -r -p "Nama lab: " choice
    
    if [[ "$mode" == "1" ]]; then
        [[ -n "${LABS[$choice]+isset}" ]] && distrobox enter "$choice" || error "Lab tidak ditemukan."
    elif [[ "$mode" == "2" ]]; then
        backup_lab "$choice"
    fi
}

main "$@"
