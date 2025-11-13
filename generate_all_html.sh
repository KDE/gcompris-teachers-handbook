#!/bin/bash
# SPDX-FileCopyrightText: 2025 Johnny Jazeix <jazeix@gmail.com>
#
#   SPDX-License-Identifier: GPL-3.0-or-later

# Environment variables needed. They are set by the CI
#export SGML_CATALOG_FILES=/usr/share/sgml/docbook/dtd/xml/4.5/catalog:/usr/share/kf5/kdoctools/customization/catalog.xml:/usr/share/sgml/docbook/dtd/xml/4.5/docbook.dtd
#export DBLATEX_BASE_DIR=$PWD/docs-kde-org

base_dir=${PWD}
gen_folder=$(mktemp -d)
output_folder=${base_dir}/html_generated
rm -rf ${output_folder}
mkdir -p ${output_folder}
# First generate English
locale=en

cp -R ${base_dir}/_install/share/kf6/kdoctools/customization/* ${gen_folder}/
cp -R ${base_dir}/docs-kde-org/*.xsl ${gen_folder}/

cp ${base_dir}/index.docbook ${gen_folder}/

pushd ${gen_folder}
export SGML_CATALOG_FILES=/usr/share/kf6/kdoctools/customization/
xsltproc --stringparam kde.common ../en/kdoctools6-common/ ${gen_folder}/kde-chunk-online.xsl index.docbook

mkdir -p ${output_folder}/${locale}/
cp -R ${base_dir}/images ${output_folder}/${locale}/
mv ${gen_folder}/*.html ${output_folder}/${locale}/
rm -rf ${gen_folder}

# copy style to en folder
mkdir -p ${output_folder}/${locale}/kdoctools6-common/
cp -R ${base_dir}/_install/share/doc/HTML/en/kdoctools6-common/* ${output_folder}/${locale}/kdoctools6-common/
popd

# Generate all languages in git repository
for folder in po/*; do
    locale=${folder##po/}
    echo "Generating docbook for locale" $locale;
    gen_folder=$(mktemp -d)
    mkdir -p ${gen_folder}
    pushd ${gen_folder}

    cp -R ${base_dir}/_install/share/kf6/kdoctools/customization/* ${gen_folder}/
    cp -R ${base_dir}/docs-kde-org/*.xsl ${gen_folder}/
    cp -R ${base_dir}/po/${locale}/docs/gcompris-teachers-doc/* ${gen_folder}/

    # Replace en with $locale?
    xsltproc --stringparam kde.common /kf6/en/kdoctools6-common/ ${gen_folder}/kde-chunk-online.xsl index.docbook
    mkdir -p ${output_folder}/${locale}/
    # Copy original images
    cp -R ${base_dir}/images ${output_folder}/${locale}/
    # Copy overriden files per language (docbook and image files)
    cp -R ${base_dir}/po/${locale}/docs/gcompris-teachers-doc/* ${output_folder}/${locale}/
    mv ${gen_folder}/*.html ${output_folder}/${locale}/
    popd
    rm -rf ${gen_folder}
done
