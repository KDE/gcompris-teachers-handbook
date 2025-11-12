# [GCompris Teachers Administration Tool](https://gcompris.net)

This is the official documentation repository for the GCompris-teachers tool.

## Generate documentation
To create a PDF, clone https://invent.kde.org/websites/docs-kde-org/ locally.
You will need a few environment variable to make it work.
Export the variable `SGML_CATALOG_FILES` where your catalogs are:
```sh
export SGML_CATALOG_FILES=/usr/share/sgml/docbook/dtd/xml/4.5/catalog:/usr/share/kf5/kdoctools/customization/catalog.xml:/usr/share/sgml/docbook/dtd/xml/4.5/docbook.dtd
```
Then run the buildpdf.sh script from the docs-kde-org folder:
```sh
DBLATEX_BASE_DIR=$PWD/docs-kde-org ./docs-kde-org/buildpdf.sh index.docbook 
```

To generate html files:
```sh
meinproc5 --check index.docbook
```
