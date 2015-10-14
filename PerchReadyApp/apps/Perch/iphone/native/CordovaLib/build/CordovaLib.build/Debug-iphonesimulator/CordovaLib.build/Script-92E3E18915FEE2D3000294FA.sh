#!/bin/sh
pwd
env
if [ -d "${TARGET_BUILD_DIR}/../include" ]
then
    echo "removing ${TARGET_BUILD_DIR}/../include"
    rm -rf "${TARGET_BUILD_DIR}/../include/"*
    rmdir "${TARGET_BUILD_DIR}/../include"

fi

cp -r "${TARGET_BUILD_DIR}/include" "${TARGET_BUILD_DIR}/../include"



