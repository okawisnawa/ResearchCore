#!/bin/bash
# Lab Manager v4.2 - Enterprise Hardened & Resilient
# Lokasi: ~/ResearchLabs/scripts/setup_labs.sh
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

# Menangani interupsi (Ctrl+C) agar tidak merusak data
trap 'echo -e "\nProses dihentikan oleh pengguna."; exit 1' SIGINT SIGTERM

check_lab_status() {
    local name=$1
    if distrobox list | grep -q "$name.*running"; then
        return 0
    elif distrobox list | grep -q "$name.*exited"; then
        log "Lab '$name' dalam kondisi mati. Menghidupkan..."
        distrobox start "$name"
    fi
}

provision_lab() {
    local name=$1 && local image=$2
    
    # Jika sudah ada, cek kesehatan saja
    if distrobox list | grep -q "^$name "; then
        check_lab_status "$name"
        return 0
    fi

    log "Provisioning '$name' (Image: $image)..."
    local extra_args=""
    [[ "$name" == "autonomous-lab" ]] && extra_args="--nvidia"

    # Penambahan  untuk menghindari konflik UID, --init untuk systemd compatibility
    distrobox create --name "$name" \
        --image "$image" \
         \
        --init \
        $extra_args \
        --home "$HOME/ResearchLabs/data/$name" \
        --additional-flags "--userns keep-id:uid=$(id -u),gid=$(id -g) --security-opt label=disable" \
        --yes > /dev/null || { error "Provisioning gagal."; return 1; }
    
    log "Lab '$name' siap digunakan."
}

backup_lab() {
    local name=$1
    local backup_dir="$HOME/ResearchLabs/backups"
    mkdir -p "$backup_dir"
    
    if [ -d "$HOME/ResearchLabs/data/$name" ]; then
        log "Melakukan kompresi data lab '$name'..."
        tar -czf "$backup_dir/${name}_$(date +'%Y%m%d_%H%M%S').tar.gz" -C "$HOME/ResearchLabs/data/" "$name"
        log "Backup tersimpan di: $backup_dir"
    else
        error "Data lab '$name' tidak ditemukan."
    fi
}

main() {
    echo -e "--- Lab Manager v4.2 ---"
    echo -e "Opsi: [1] Masuk [2] Backup [3] Hapus Lab"
    read -r -p "Pilihan: " mode
    
    echo -e "Tersedia: ${!LABS[*]}"
    read -r -p "Nama lab: " choice
    
    if [[ -z "${LABS[$choice]+isset}" ]]; then
        error "Lab '$choice' tidak dikenal."
        exit 1
    fi

    case $mode in
        1) 
            provision_lab "$choice" "${LABS[$choice]}"
            distrobox enter "$choice"
            ;;
        2) 
            backup_lab "$choice" 
            ;;
        3) 
            distrobox rm -f "$choice" && log "Lab '$choice' telah dihapus."
            ;;
        *) 
            error "Pilihan tidak valid."
            exit 1 
            ;;
    esac
}

main "$@"
