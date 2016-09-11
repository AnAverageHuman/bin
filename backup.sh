#!/bin/bash
# Creates an encrypted SquashFS image of the current directory.
# Decrypt using `gpg -d --output OUTPUTFILE "${BKPREFIX}.squashfs"`.
set -euo pipefail

DATE=$(date +%Y%m%d-%H%M)
ARCH=Gentoo
BKDIR=/mnt/Data/backups/$ARCH
BKPREFIX=$BKDIR/$DATE
UNENCRYPTED=${BKPREFIX}.sfs
ENCRYPTED=${BKPREFIX}.squashfs
EXCLUDE_DIRS=(lost+found opt backups dev media mnt proc sys tmp var/tmp)
GPG_PUBLIC=77154550

finish() {
    printf "\nShredding unencrypted backup."
    shred --iterations=1 --random-source=/dev/urandom --remove=wipesync --zero "${UNENCRYPTED}"
    sync
    printf "\nDone!\n"
}
trap finish EXIT

mkdir -p $BKDIR
printf "Creating SquashFS backup of %s in %s. \n" "$(pwd)" "$BKDIR"
mksquashfs / "${UNENCRYPTED}" -e "${EXCLUDE_DIRS[@]}"

read -n1 -p "Press any key to start encrypting with GnuPG."
gpg --output "${ENCRYPTED}" --sign --encrypt --hidden-recipient "$GPG_PUBLIC" "${UNENCRYPTED}"

exit

