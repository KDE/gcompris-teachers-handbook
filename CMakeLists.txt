#=============================================================================
# SPDX-FileCopyrightText: 2025 Johnny Jazeix <jazeix@gmail.com>
#
# SPDX-License-Identifier: BSD-3-Clause
#=============================================================================
cmake_minimum_required(VERSION 3.16)

project(gcompris-server-doc)

include(FeatureSummary)
include(GNUInstallDirs)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(KF6DocTools REQUIRED)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

include(KDEInstallDirs)

kdoctools_create_handbook(index.docbook INSTALL_DESTINATION ${KDE_INSTALL_DOCBUNDLEDIR}/en SUBDIR gcompris-server-doc)
