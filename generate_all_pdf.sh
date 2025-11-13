#!/bin/bash
# SPDX-FileCopyrightText: 2025 Johnny Jazeix <jazeix@gmail.com>
#
#   SPDX-License-Identifier: GPL-3.0-or-later

# Environment variables needed. They are set by the CI
#export SGML_CATALOG_FILES=/usr/share/sgml/docbook/dtd/xml/4.5/catalog:/usr/share/kf5/kdoctools/customization/catalog.xml:/usr/share/sgml/docbook/dtd/xml/4.5/docbook.dtd
#export DBLATEX_BASE_DIR=$PWD/docs-kde-org

base_dir=${PWD}
output_folder=${base_dir}/pdf_generated
rm -rf ${output_folder}
mkdir -p ${output_folder}
# First generate English
locale=en
./docs-kde-org/buildpdf.sh index.docbook
mv gcompris_teachers_doc.pdf ${output_folder}/gcompris_teachers_doc_${locale}.pdf
# Generate all languages in git repository
for folder in po/*; do
    locale=${folder##po/}
    echo "Generating docbook for locale" $locale;
    gen_folder=$(mktemp -d)
    mkdir -p ${gen_folder}
    pushd ${gen_folder}
    # Copy original images
    cp -R ${base_dir}/images ${gen_folder}/
    # Copy overriden files per language (docbook and image files)
    cp -R ${base_dir}/po/${locale}/docs/gcompris-teachers-doc/* ${gen_folder}
    ${base_dir}/docs-kde-org/buildpdf.sh ${gen_folder}/index.docbook
    # The pdf name is the tmp folder name
    mv ${gen_folder}/*.pdf ${output_folder}/gcompris_teachers_doc_${locale}.pdf
    popd
    rm -rf ${gen_folder}
done
