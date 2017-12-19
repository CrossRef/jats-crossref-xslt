## NLM / JATS to CrossRef Deposit XML XSLT

## What is this?

This repository contains an XSLT file that will translate [NISO NLM or JATS](https://jats.nlm.nih.gov/versions.html)
to [CrossRef Deposit XML](https://support.crossref.org/hc/en-us/articles/215577783-Creating-content-registration-XML).

Direct links to content:
* `nlm-jats-crossref.xslt`:
  - [GitHub Raw (HTTPS)](https://raw.githubusercontent.com/semprag/jats-crossref-xslt/master/nlm-jats-crossref.xslt)


## How do I use this?

Either use CrossRef's [Web Deposit Form](https://www.crossref.org/webDeposit/) to deposit NISO NLM or JATS manually
or build the XSLT into a CrossRef deposit process using JAXP or your favorite language's XML and XSLT processing library.

A command line XSLT processor can be used for diagnostic and experimental purposes:

- [Xalan Java](http://xml.apache.org/xalan-j/commandline.html)
- [xsltproc](http://xmlsoft.org/XSLT/xsltproc.html)


## Supported NLM / JATS Versions

Currently the following NLM and JATS [versions](https://jats.nlm.nih.gov/versions.html) are supported:

| Version                                  | Notes   |
|------------------------------------------|---------|
| [NLM 2.3](http://dtd.nlm.nih.gov/2.3/)   |         |
| [NLM 3.0](http://dtd.nlm.nih.gov/3.0/)   |         |
| [JATS 1.0](http://jats.nlm.nih.gov/1.0/) |         |


## Translated Features

###  Bibliographic

###  Funding

###  Identifiers


## Contributing

CrossRef welcomes contributions to enhance this XSLT. Please make a pull request to contribute.
