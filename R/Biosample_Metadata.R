###### -- a function for pulling metadata for an NMDC identifier --------------
# author: nicholas cooley
# maintainer: nicholas cooley
# contact: npc19@pitt.edu / npcooley@gmail.com

Biosample_Metadata <- function(metadata1 = NULL,
                               annotations = NULL,
                               alternative_IDs = NULL,
                               ID = NULL) {
  
  # required packages must be installed and load
  if (!("httr" %in% .packages(all.available = TRUE))) {
    stop("The package 'httr' is not installed. Please install it.")
  }
  
  if (!("httr" %in% (.packages()))) {
    stop("The package 'httr' is not currently loaded. Please load it.")
  }
  
  if (!("jsonlite" %in% .packages(all.available = TRUE))) {
    stop("The package 'jsonlite' is not installed Please install it.")
  }
  
  if (!("jsonlite" %in% (.packages()))) {
    stop("The package 'jsonlite' is not currently loaded. Please load it.")
  }
  
  # some tests
  # return(missing(metadata1))
  
  # paste together the query:
  ADD <- "https://data.dev.microbiomedata.org/api"
  DB <- "biosample"
  # default for testing purposes
  # if (missing(ID)) {
  #   ID <- "gold:Gb0115217"
  # }
  if (missing(ID)) {
    stop("A prospective ID must be supplied.")
  }
  QUERY <- paste(ADD,
                 DB,
                 ID,
                 sep = "/")
  
  # print(QUERY)
  
  RESP <- GET(url = enc2utf8(QUERY))
  CONTENT <- content(x = RESP,
                     as = "text",
                     encoding = "UTF-8")
  PARSE <- fromJSON(txt = CONTENT)
  
  t1 <- missing(metadata1)
  t2 <- missing(annotations)
  t3 <- missing(alternative_IDs)
  
  if (t1 &
      t2 &
      t3) {
    return(PARSE)
  } else {
    RES <- list()
    if (!t1) {
      p1 <- vector(mode = "list",
                   length = length(metadata1))
      for (m1 in seq_along(metadata1)) {
        p1[[m1]] <- PARSE[[metadata1[m1]]]
      }
      names(p1) <- metadata1
      RES <- c(RES, p1)
    }
    
    if (!t2) {
      p2 <- vector(mode = "list",
                   length = length(annotations))
      for (m1 in seq_along(annotations)) {
        p2[[m1]] <- PARSE[["annotations"]][[annotations[m1]]]
      }
      names(p2) <- annotations
      RES <- c(RES, p2)
    }
    
    if (!t3) {
      p3 <- vector(mode = "list",
                   length = length(alternative_IDs))
      aids <- PARSE[["alternate_identifiers"]]
      for (m1 in seq_along(p3)) {
        p3[[m1]] <- aids[grepl(pattern = alternative_IDs[m1],
                               x = aids,
        )]
      }
      # return(list(aids,
      #             p3,
      #             alternative_IDs))
      names(p3) <- paste0("alternatate_ID_",
                          alternative_IDs)
      RES <- c(RES, p3)
    }
    
    return(RES)
  }
}
