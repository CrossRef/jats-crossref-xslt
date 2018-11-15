## NLM / JATS to CrossRef Deposit XML XSLT

## What is this?

This repository contains an XSLT file that will translate [NISO NLM or JATS](http://jats.nlm.nih.gov/versions.html)
to [CrossRef Deposit XML](http://help.crossref.org/deposit_schema).

## How do I use this?

Either use CrossRef's [Web Deposit Form](http://www.crossref.org/webDeposit/) to deposit NISO NLM or JATS manually
or build the XSLT into a CrossRef deposit process using JAXP or your favourite language's XML and XSLT processing library.

An API has been added which accepts a JATS XML file via HTTP POST and returns the Crossref depositable XML. This service uses JATS2CrossRef_web.xsl. Values not present in the JATS XML may be added via URL parameters.

http://doi.crossref.org/service/jatsconversion?email=&registrant=&DOI=&URL=

A commandline XSLT processor can be used for diagnositc and experimental purposes:

- http://xml.apache.org/xalan-j/commandline.html
- http://xmlsoft.org/XSLT/xsltproc.html

## Supported NLM / JATS Versions

Currently the following NLM and JATS [versions](http://jats.nlm.nih.gov/versions.html) are supported:

| Version  | Notes   |
|----------|---------|
| [NLM 2.3](http://dtd.nlm.nih.gov/2.3/) |         |
| [NLM 3.0](http://dtd.nlm.nih.gov/3.0/) |         |
| [JATS 1.0](http://jats.nlm.nih.gov/1.0/) |         |
| [JATS 1.2](http://ftp.ncbi.nlm.nih.gov/pub/jats/publishing/1.2d2/) |   |


## Translated Features

###  Bibliographic

###  Funding

###  Identifiers

## Contributing

CrossRef welcomes contributions to enhance this XSLT. Please make a pull request to contribute.
