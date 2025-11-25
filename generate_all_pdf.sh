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
# TODO maybe compute it once before running both html/pdf scripts and get the doc_path as argument?
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

output_folder=${base_dir}/pdf_generated
rm -rf ${output_folder}
mkdir -p ${output_folder}
# First generate English
locale=en
./docs-kde-org/buildpdf.sh ${doc_path}/index.docbook
mv ${project}.pdf ${output_folder}/${project}_${locale}.pdf

# Generate all languages in git repository
for folder in po/*; do
    locale=${folder##po/}
    echo "Generating docbook for locale" $locale;
    gen_folder=$(mktemp -d)
    mkdir -p ${gen_folder}
    pushd ${gen_folder}
    # Copy original images
    cp -R ${doc_path}/images ${gen_folder}/
    # Copy overriden files per language (docbook and image files)
    cp -R ${base_dir}/po/${locale}/docs/${project}/* ${gen_folder}
    ${base_dir}/docs-kde-org/buildpdf.sh ${gen_folder}/index.docbook
    # The pdf name is the tmp folder name
    mv ${gen_folder}/*.pdf ${output_folder}/${project}_${locale}.pdf
    popd
    rm -rf ${gen_folder}
done
