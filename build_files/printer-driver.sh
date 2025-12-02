#!/bin/bash

set -ouex pipefail

### Install Canon CQue printer driver.
echo "Installing Canon CQue drivers..."
wget --output-document /tmp/cque-en-4.0-14.x86_64.tar.gz \
        https://files.canon-europe.com/files/soft01-48570/Driver/cque-en-4.0-14.x86_64.tar.gz
mkdir /tmp/cque
tar xzf /tmp/cque-en-4.0-14.x86_64.tar.gz --directory /tmp/cque
/tmp/cque/cque-en-4.0-14/setup
rm /tmp/cque-en-4.0-14.x86_64.tar.gz
rm -r /tmp/cque
