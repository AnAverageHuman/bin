#!/usr/bin/env bash
set -euo pipefail

# Creates an encrypted SquashFS image of the current directory.

# If encrypting, you must generate private and public keys first:
#   openssl genrsa -out key.pem 4096
#   openssl rsa -in key.pem -out key-public.pem -outform PEM -pubout
#
# To decrypt, first decrypt the passphrase, then decrypt the file.
#   openssl rsautl -decrypt -inkey "$PRIV_KEY" < "$ENC_BKKEY" > "$BKKEY"
#   openssl enc -aes-256-cbc -d -pass file:"$BKKEY" < "$ENCRYPTED" > "$UNENCRYPTED"


# Set to 0 to disable encrypting backups.
USE_ENCRYPTION=1


DATE=$(date +%Y%m%d-%H%M)
ARCH=Gentoo
BKDIR=/mnt/Data/backups/$ARCH/$DATE
BKPREFIX=$BKDIR/backup
EXCLUDE_DIRS=(backups dev lost+found media mnt opt proc sys tmp usr/portage usr/share/doc usr/share/fonts usr/share/icons var/pkg var/tmp)

BKKEY=$BKDIR/key
ENC_BKKEY=$BKDIR/enc_key
PUB_KEY=$HOME/key-public.pem
UNENCRYPTED=${BKPREFIX}.sfs
ENCRYPTED=${BKPREFIX}.squashfs


if [ $USE_ENCRYPTION = 1 ]; then
    finish() {
        printf "\nShredding unencrypted backup."
        shred --iterations=1 --random-source=/dev/urandom --remove=wipesync --zero "${UNENCRYPTED}" "${BKKEY}"
        sync
        printf "\nDone!\n"
    }
    trap finish EXIT
fi


mkdir -p $BKDIR
printf "Creating SquashFS backup of %s in %s. \n" "$(pwd)" "$BKDIR"
mksquashfs / "${UNENCRYPTED}" -e "${EXCLUDE_DIRS[@]}"


if [ $USE_ENCRYPTION = 1 ]; then
    printf "Generating key. \n"
    openssl rand 501 -out $BKKEY
    printf "Encrypting backup with key. \n"
    openssl enc -aes-256-cbc -pass file:$BKKEY < "$UNENCRYPTED" > "$ENCRYPTED"
    printf "Encrypting key with public key. \n"
    openssl rsautl -encrypt -pubin -inkey "$PUB_KEY" < $BKKEY > $ENC_BKKEY
fi

exit

