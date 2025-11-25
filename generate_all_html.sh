#!/bin/bash
# SPDX-FileCopyrightText: 2025 Johnny Jazeix <jazeix@gmail.com>
#
#   SPDX-License-Identifier: GPL-3.0-or-later

# Environment variables needed. They are set by the CI
#export SGML_CATALOG_FILES=/usr/share/sgml/docbook/dtd/xml/4.5/catalog:/usr/share/kf5/kdoctools/customization/catalog.xml:/usr/share/sgml/docbook/dtd/xml/4.5/docbook.dtd
#export DBLATEX_BASE_DIR=$PWD/docs-kde-org

# TODO Handle if there are several modules in the same repo if it is possible?

if [ "$#" -ne 2 ]; then
    echo "Missing project name or branch"
    exit -1
fi

project=$1 # Project is given by CI
branch=$2 # Branch is given by CI

base_dir=${PWD}

# Probably a way to do a jq one-liner...
i18n_branch=`curl https://projects.kde.org/api/v1/identifier/$project | jq -r '.i18n' | jq -r 'to_entries[] | select(.value == "$branch") | .key'`

if [ "x$i18n_branch" = "x" ]; then
    echo "$branch is not a branch to process for docbook generation"
    exit 0
fi
# Replace trunkKF6 with trunk_kf6
transmod=${i18n_branch/KF/_kf}
wget https://invent.kde.org/sysadmin/l10n-scripty/-/raw/master/documentation_paths.${transmod}
# Now we can read from l10n-scripty/documentation_paths.${transmod} to retrieve doc_path
source generate_common.sh
doc_path=`get_doc_dir $1`
rm documentation_paths.${transmod}

gen_folder=$(mktemp -d)
output_folder=${base_dir}/html_generated
rm -rf ${output_folder}
mkdir -p ${output_folder}
# First generate English
locale=en

cp -R ${base_dir}/_install/share/kf6/kdoctools/customization/* ${gen_folder}/
cp -R ${base_dir}/docs-kde-org/*.xsl ${gen_folder}/

cp ${doc_path}/index.docbook ${gen_folder}/

pushd ${gen_folder}
export SGML_CATALOG_FILES=/usr/share/kf6/kdoctools/customization/
xsltproc --stringparam kde.common ../en/kdoctools6-common/ ${gen_folder}/kde-chunk-online.xsl index.docbook

mkdir -p ${output_folder}/${locale}/
cp -R ${doc_path}/images ${output_folder}/${locale}/
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
    cp -R ${base_dir}/po/${locale}/docs/${project}/* ${gen_folder}/

    # Replace en with $locale?
    xsltproc --stringparam kde.common /kf6/en/kdoctools6-common/ ${gen_folder}/kde-chunk-online.xsl index.docbook
    mkdir -p ${output_folder}/${locale}/
    # Copy original images
    cp -R ${doc_path}/images ${output_folder}/${locale}/
    # Copy overriden files per language (docbook and image files)
    cp -R ${base_dir}/po/${locale}/docs/${project}/* ${output_folder}/${locale}/
    mv ${gen_folder}/*.html ${output_folder}/${locale}/
    popd
    rm -rf ${gen_folder}
done
