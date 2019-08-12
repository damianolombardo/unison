#!/usr/bin/env bash

# Create unison user and group
addgroup -g $UNISON_GID $UNISON_GROUP
adduser -u $UNISON_UID -G $UNISON_GROUP -s /bin/bash $UNISON_USER

# Create directory for filesync
if [ ! -d "$UNISON_DIR" ]; then
    echo "Creating $UNISON_DIR directory for sync..."
    mkdir -p $UNISON_DIR >> /dev/null 2>&1
fi


if [ ! -d /unison ]; then
# Create directory for unison meta
    mkdir -p /unison >> /dev/null 2>&1
    chown -R $UNISON_USER:$UNISON_GROUP /unison
# Symlink .unison folder from user home directory to sync directory so that we only need 1 volume    
    ln -s /unison /home/$UNISON_USER/.unison >> /dev/null 2>&1
fi

if [ ! -f /unison/General_UDisk.sh ]; then
# Copy sample automatic script for reference
    cp /General_UDisk.sh /unison/General_UDisk.sh >> /dev/null 2>&1
fi

# Change data owner
chown -R $UNISON_USER:$UNISON_GROUP $UNISON_DIR

# Start process on path which we want to sync
cd $UNISON_DIR

# Run unison server as UNISON_USER and pass signals through
exec su-exec $UNISON_USER unison -socket 5000
