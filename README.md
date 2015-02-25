Faust Edition Text Generation
=============================

This project contains processing steps for generating the more reading-text, less diplomatic text representations of the [Faust edition](http://faustedition.de/). 

This is work in progress.


Overview
--------

The scripts can be used to generate an HTML representation for (theoretically) any of the Faust transcripts, although they are mainly tested with the transcripts selected for generating the reading texts for Faust I and II. For each text they run on, they generate two HTML representations, one that contains the whole text and one that is split by `<div>`s  (i.e., acts and scenes). These representations are optimized for easy reading: They have their genetic markup removed, `ſ` has been normalized to `s`, most of the original prints' typography is not reproduced, etc.

For each of the chunks (lines, mostly) that have a canonical numbering, an apparatus generated from all of the witnesses in the edition is available by clicking the line. Available variants are indicated by a shaded background. The lines in the apparatus have been post-processed in the same way as the main texts.


Usage
-----

To generate the HTML representation, you need:

* The XProc processor [XML Calabash](http://xmlcalabash.com/download/). The scripts have only been tested with version 1.0.25-96.
* A local copy of the XML folder of the Faust edition.
* Time :-)

You should then clone this repository and edit the [configuration file, config.xml](config.xml) as you see fit (e.g., enter the path to your copy of the Faust data. You could also leave the config file as it is and pass in the relevant parameters as parameters to the XML processor.

To generate all data, run the pipeline `generate-all`, e.g., using

    calabash generate-all.xpl

This will run all processing steps and generate the HTML data in `target/lesetext_demo` by default.


Source Code Details
-------------------

Basically, we need to perform three steps, in order:

1. Generate a list of witnesses from the metadata in the Faust XML's `documents` folder
2. Generate the HTML fragments that form the apparatus
3. For each text to render, generate the HTML representation (in split and unsplit form).

All steps read `config.xml`, and all XSLT stylesheets have the parameters defined there available. All parameters from `config.xml` can also be passed by the usual means of passing parameters to pipelines (like calabash's `-p` option).

# List Witnesses: `collect-metadata.xpl`

* no input
* output is a list of transcripts

The output is a list of `<textTranscript>` elements, here is an example:

```xml
<textTranscript xmlns="http://www.faustedition.net/ns"
		uri="faust://xml/transcript/gsa/391083/391083.xml"
		href="file:/home/vitt/Faust/transcript/gsa/391083/391083.xml"
		document="document/maximen_reflexionen/gsa_391083.xml"
		type="archivalDocument"
		f:sigil="H P160">
   <idno type="bohnenkamp" uri="faust://document/bohnenkamp/H_P160" rank="2">H P160</idno>
   <idno type="gsa_2" uri="faust://document/gsa_2/GSA_25/W_1783" rank="28">GSA 25/W 1783</idno>
   <idno type="gsa_1"
	 uri="faust://document/gsa_1/GSA_25/XIX,2,9:2"
	 rank="50">GSA 25/XIX,2,9:2</idno>
</textTranscript>
```

`href` is the local path to the actual transcript, `document` is the relative URL to the metadata document. `type` is either `archivalDocument` or `print`. The `<idno>` elements are ordered by an order of preference defined in the pipeline (depending on type) and recorded in the respective `rank` attribute.

# Generate Apparatus: `collate-variants.xpl`

* input is the list of witnesses from the `collect-metadata.xpl` step
* output is a large XML document containing all variants of all lines (only useful for debugging purposes)
* additionally, the variants HTML fragments are written to the `variants` directory configured in `config.xml`

This step performs three substeps that are controlled by additional files:

1. `apply-edits.xpl` (for each transcript) – TEI preprocessing, see separate section
2. `extract-lines.xsl` (for each transcript) – filters only those TEI elements that represent lines used for the apparatus (including descendant nodes), augmenting them with provenance attributes
3. `variant-fragments.xsl` – sorts and groups the lines, and transforms them to HTML.

## Preprocessing the TEI files: `apply-edits.xpl`

* input is one TEI document (transcript)
* output is one TEI document (transcript) that has been normalized.

Basically the document is just passed through the following steps:

1. `textTranscr_pre_transpose.xsl` normalizes references inside `ge:transpose` 
2. `textTranscr_transpose.xsl` applies transpositions
3. `text-emend.xsl` applies genetic markup that is using `spanTo` etc.
4. `textTranscr_fuer_Drucke.xsl` applies genetic markup (`del`, `corr` etc.), performs character normalizations and a set of other normalizations
5. `prose-to-lines.xsl` transforms the `<p>`-based markup in _Trüber Tag. Feld._ to a `<lg>/<l>` based markup as in the verse parts to ease collation.

# Generate the master HTML files: `print2html.xpl`

* input: a transcript. Additionally, the variants must already exist.
* option: `basename` is the name used for the HTML files, relative to the output directory given by the `html` parameter
* side effect: sectioned HTML files and a _basename_`.all.html` file for the all-in-one document are generated inside the folder specified using the `html` parameter
* output: List of generated HTML files

Steps:

1. `apply-edits.xpl`, TEI normalization, see above 
2. `print2html.xsl`, the actual transformation to html

# Additional source files

* `lesetext.css` is a stylesheet that is included in all generated HTML documents.
* `utils.xsl` contains a number of functions used by the other stylesheets, e.g., to calculate the variant groups
* `config.xml` contains the parameters for all steps

## Experimental stuff

* `transcr.xpr` - oxygen project
* `broken-macrogen-links.xpl` lists links in macrogenesis that cannot be automatically resolved to uris from the metadata
* `config-test.xpl`
* `faust_nurtext_textko.xsl`