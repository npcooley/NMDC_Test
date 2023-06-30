NMDC_Test
================
npc
2023-06-30

# README

This repo contains answers to pre-interview questions assigned before an
interview for an NMDC position.

``` r
# load in some libraries and set the WD
suppressMessages(library(utils))
suppressMessages(library(yaml))
suppressMessages(library(jsonlite))
suppressMessages(library(httr))
setwd("~/Repos/NMDC_Test")
source(file = "R/Biosample_Metadata.R")
```

## Question 1:

*Write a script to download the metadata from one NMDC’s biosample API
endpoints for biosample id nmdc:bsm-11-q84vp418 and return the values
for id, habitat, and gold_biosample_identifiers.*

A brief barebones function can be constructed in R that semi-flexibly
pulls data from the NMDC API endpoints. This function only relies on two
packages that are not in base R, `httr` and `jsonlite`. The function is
present in the `R` directory, while a script that loads the function and
attempts to print out the requested metadata in relatively acceptable
formating is present in the `Scripts` directory. A brief example of the
function in use is provided in the code chunk below.

``` r
res1 <- Biosample_Metadata(metadata1 = "id",
                           annotations = "habitat",
                           alternative_IDs = "GOLD",
                           ID = "nmdc:bsm-11-q84vp418")
print(res1)
```

    ## $id
    ## [1] "nmdc:bsm-11-q84vp418"
    ## 
    ## $habitat
    ## [1] "freshwater"
    ## 
    ## $alternatate_ID_GOLD
    ## [1] "GOLD:Gb0258705"

## Question 2:

*Review the existing docker containers available on dockerhub for
SPAdes, a common assembler for metagenomic datasets, and describe how
you would determine which, if any, of the existing containers you would
use versus writing one from scratch.*

SPAdes has included it’s `--meta` mode for a while, so any container
that is successfully installing a recent version of SPAdes should be
acceptable for assembly alone. Pre- and post-assembly tasks like binning
and quality control would require other tools though. How that work is
divided up is largely a choice dependent upon available resources, and
tool dependencies. A dockerfile that constructs a custom container with
common tools for read QC, assembly, and binning is present in the
`Container01` directory of this repo.

## Question 3:

*Using a workflow management tool of your choice, write a portable
workflow which 1) runs the SPAdes test dataset (spades.py –test) and 2)
returns the version of SPAdes used.*

A workflow for testing SPAdes using CWL is constructed below. A
dockerfile that constructs the container these were tested in is present
in the `Container01` directory of this repo, and the generated `.cwl`
files are deposited in the `Scripts` folder of this repo. In brief, two
cwl processes are invoked by a single cwl workflow to run and capture
the stdout for `spades.py --test` and `spades.py --version`. This
container can also be pulled locally for testing with
`docker pull npcooley/nmdctest01:1.0`. With all three `.cwl` files in
the home directory and `spades.py` present in the `$PATH` variable,
`cwltool combine.cwl` should run to completion and return two text
files, `res1.txt` containing the stdout from running the spades test
set, and `res2.txt` containing the version info for the spades
installation.

``` r
suppressMessages(library(yaml))

TEST <- as.yaml(list("cwlVersion" = "v1.0",
                     "class" = "CommandLineTool",
                     "baseCommand" = c("spades.py", "--test"),
                     "stdout" = "res1.txt",
                     "inputs" = list(),
                     "outputs" = list("example_out" = list("type" = "stdout"))))
TEST <- gsub(pattern = "'",
             replacement = "",
             x = TEST)
# cat(TEST)

VER <- as.yaml(list("cwlVersion" = "v1.0",
                    "class" = "CommandLineTool",
                    "baseCommand" = c("spades.py", "--version"),
                    "stdout" = "res2.txt",
                    "inputs" = list(),
                    "outputs" = list("example_out" = list("type" = "stdout"))))
VER <- gsub(pattern = "'",
            replacement = "",
            x = VER)
# cat(VER)

COMBINE <- as.yaml(list("cwlVersion" = "v1.0",
                        "class" = "Workflow",
                        "inputs" = list(),
                        "outputs" = list("out" = list("type" = "File",
                                                      "outputSource" = "step1/example_out"),
                                         "res" = list("type" = "File",
                                                      "outputSource" = "step2/example_out")),
                        "steps" = list("step1" = list("run" = "test.cwl",
                                                      "in" = list(),
                                                      "out" = "[example_out]"),
                                       "step2" = list("run" = "version.cwl",
                                                      "in" = list(),
                                                      "out" = "[example_out]"))))
COMBINE <- gsub(pattern = "'",
                replacement = "",
                x = COMBINE)
# cat(COMBINE)

writeLines(TEST, "Scripts/test.cwl")
writeLines(VER, "Scripts/version.cwl")
writeLines(COMBINE, "Scripts/combine.cwl")
```

## Question 4:

*Clone the nmdc-schema repository or use the UI documentation to list
the required slots for Class OmicsProcessing.*

A brief R workflow for scraping the required slots for the
`OmicsProcessing` class is included in the R code chunk below:

``` r
suppressMessages(library(rvest))

# scrape the page
res2 <- read_html("https://microbiomedata.github.io/nmdc-schema/OmicsProcessing/")
# grab the tables
res3 <- html_table(res2)
# slots are the first table, print the first column:
print(res3[[1]]$Name)
```

    ##  [1] "add_date"                            "chimera_check"                      
    ##  [3] "gold_sequencing_project_identifiers" "has_input"                          
    ##  [5] "has_output"                          "insdc_experiment_identifiers"       
    ##  [7] "instrument_name"                     "mod_date"                           
    ##  [9] "ncbi_project_name"                   "nucl_acid_amp"                      
    ## [11] "nucl_acid_ext"                       "omics_type"                         
    ## [13] "part_of"                             "pcr_cond"                           
    ## [15] "pcr_primers"                         "principal_investigator"             
    ## [17] "processing_institution"              "samp_vol_we_dna_ext"                
    ## [19] "seq_meth"                            "seq_quality_check"                  
    ## [21] "target_gene"                         "target_subfragment"                 
    ## [23] "type"                                "id"                                 
    ## [25] "name"                                "description"                        
    ## [27] "alternative_identifiers"

``` r
# find out the required slots:
temp1 <- tempfile()
res3 <- html_text(html_elements(res2, "#induced+ details"))
writeLines(res3, temp1)
res4 <- read_yaml(temp1)

# there are no 'required: FALSE' slots in the YAML, so can just look for 'required' as the list name
res5 <- res4$slot_usage
req_by_slot <- sapply(X = res5,
                      FUN = function(x) {
                        "required" %in% names(x)
                      })
req_by_slot <- names(req_by_slot)[req_by_slot]
# print out slots that have a required slot
print(req_by_slot)
```

    ## [1] "id"        "has_input"

``` r
res6 <- res4$attributes
req_by_attribute <- sapply(X = res6,
                           FUN = function(x) {
                             "required" %in% names(x)
                           })
req_by_attribute <- names(req_by_attribute)[req_by_attribute]
# print out slots that have a required slot
print(req_by_attribute)
```

    ## [1] "has_input" "id"

## session stuff

    ## R version 4.3.0 (2023-04-21)
    ## Platform: x86_64-apple-darwin20 (64-bit)
    ## Running under: macOS Monterey 12.4
    ## 
    ## Matrix products: default
    ## BLAS:   /Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/lib/libRblas.0.dylib 
    ## LAPACK: /Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/lib/libRlapack.dylib;  LAPACK version 3.11.0
    ## 
    ## locale:
    ## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    ## 
    ## time zone: America/New_York
    ## tzcode source: internal
    ## 
    ## attached base packages:
    ## [1] methods utils   base   
    ## 
    ## other attached packages:
    ## [1] rvest_1.0.3    httr_1.4.6     jsonlite_1.8.4 yaml_2.3.7    
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] vctrs_0.6.2     cli_3.6.1       knitr_1.42      rlang_1.1.1    
    ##  [5] xfun_0.39       stringi_1.7.12  glue_1.6.2      selectr_0.4-2  
    ##  [9] htmltools_0.5.5 fansi_1.0.4     rmarkdown_2.21  evaluate_0.21  
    ## [13] tibble_3.2.1    fastmap_1.1.1   lifecycle_1.0.3 stringr_1.5.0  
    ## [17] compiler_4.3.0  pkgconfig_2.0.3 rstudioapi_0.14 stats_4.3.0    
    ## [21] graphics_4.3.0  digest_0.6.31   R6_2.5.1        utf8_1.2.3     
    ## [25] pillar_1.9.0    curl_5.0.0      magrittr_2.0.3  tools_4.3.0    
    ## [29] grDevices_4.3.0 xml2_1.3.4

    ##                _                           
    ## platform       x86_64-apple-darwin20       
    ## arch           x86_64                      
    ## os             darwin20                    
    ## system         x86_64, darwin20            
    ## status                                     
    ## major          4                           
    ## minor          3.0                         
    ## year           2023                        
    ## month          04                          
    ## day            21                          
    ## svn rev        84292                       
    ## language       R                           
    ## version.string R version 4.3.0 (2023-04-21)
    ## nickname       Already Tomorrow
