#!/bin/sh

declare -a FILES
declare -a MODULES
declare -a MOD_NAMES
declare -a MISC_FILES
declare -a MISC_PATH

FILES=(Image armada-7020-comexpress.dtb)
#MODULES=(mvDmaDrv.ko)
#MOD_NAMES=(mvDmaDrv)
#MISC_FILES=(eeprom)
#MISC_PATH=(/etc/sonic/)
MISC_DIR=(lib)

ARCH=arm64
VERSION=4.9.168
PKG_NAME=linux-image
TMP=${PKG_NAME}-${VERSION}-${ARCH}
DATE=`date -u`

build_deb()
{
    rm -fr ${TMP}
    mkdir -p ${TMP}/DEBIAN
    mkdir -p ${TMP}/boot/
    mkdir -p ${TMP}/lib/modules/${VERSION}/
    for f in ${FILES[*]}
    do
        if [ -f $f ]
        then
            echo "Packing $f"
            [ 
            cp -v $f ${TMP}/boot/
        else
            echo "ERROR: $f NOT found"
        fi
    done
    for f in ${MODULES[*]}
    do
        if [ -f $f ]
        then
            echo "Packing $f"
            cp -v $f ${TMP}/lib/modules/${VERSION}/
        else
            echo "ERROR: $f NOT found"
        fi
    done
    for f in ${MOD_NAMES[*]}
    do
        echo "Adding kernel $f"
        mkdir -p ${TMP}/etc/modules-load.d/
        echo "$f" >> ${TMP}/etc/modules-load.d/marvell.conf
    done
    i=0
    for f in ${MISC_FILES[*]}
    do
        echo "Adding Misc $f to ${MISC_PATH[$i]}"
        mkdir -p ${TMP}/${MISC_PATH[$i]}
        cp -v $f ${TMP}/${MISC_PATH[$i]}
        i=$((i+1))
    done
    i=0
    for f in ${MISC_DIR[*]}
    do
        echo "Adding Misc $f to ${MISC_DIR[$i]}"
        cp -drv $f ${TMP}/
        i=$((i+1))
    done

    echo "Package: ${PKG_NAME}-${VERSION}-${ARCH} " > ${TMP}/DEBIAN/control
    echo "Version: $VERSION" >> ${TMP}/DEBIAN/control
    echo "Section: base" >> ${TMP}/DEBIAN/control
    echo "Priority: optional" >> ${TMP}/DEBIAN/control
    echo "Architecture: $ARCH" >> ${TMP}/DEBIAN/control
    echo "Depends:" >> ${TMP}/DEBIAN/control
    echo "Maintainer: $USER <$USER@marvell.com>" >> ${TMP}/DEBIAN/control
    echo "Date: $DATE" >> ${TMP}/DEBIAN/control
    echo "Description: Linux Marvell Kernel" >> ${TMP}/DEBIAN/control
    #cat ${TMP}/DEBIAN/control
    echo "Building deb package"
    dpkg-deb --build ${TMP}

    dpkg -I ${TMP}.deb

}


build_deb
