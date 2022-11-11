#' Controlled vocabulary for post-translational modifications (PTM) terms
#'
#'  This dataframe lists the posttranslational modifications used in the UniProt knowledgebase (Swiss-Prot and TrEMBL).
#'  The columns in this dataframe are as follows:
#'
#' \itemize{
#'   \item ID Identifier (FT description)
#'   \item AC Accession (PTM-xxxx)
#'   \item KW Keyword
#'   \item FT Feature key
#'   \item DR Cross-reference to external databases
#' }
#'
#' @docType data
#' @keywords datasets
#' @name ptmlist
#' @usage data(ptmlist)
#' @format A data frame with 686 rows and 5 variables
#' @source \url{https://ftp.uniprot.org/pub/databases/uniprot/knowledgebase/complete/docs/ptmlist.txt}
'ptmlist'


#' Database of protein modifications
#'
#' Ontology database for post-translational modification terms. For more details, see the reference.
#'
#' \itemize{
#'   \item id
#'   \item name
#'   \item def
#' }
#'
#' @source \url{https://raw.githubusercontent.com/HUPO-PSI/psi-mod-CV/master/PSI-MOD.obo}
#' @docType data
#' @keywords datasets
#' @name mod_ont
#' @usage data(mod_ont)
#' @format A data frame with 2102 rows and 3 variables
'mod_ont'



#' Example dataset1
#'
#' A dataset with randomly selected proteins from UniProt.
#'
#' @format A list with 2 elements:
#' \describe{
#'   \item{pl1}{97 randomly selected Homo sapiens (Human) proteins randomly selected from UniProt.}
#'   \item{pl2}{45 randomly selected Homo sapiens (Human) proteins randomly selected from UniProt.}
#'   ...
#' }
#' @source \url{https://www.uniprot.org/}
'exmplData1'



#' Example dataset 2
#'
#' Proteins of rat hippocampus proteome.
#'
#' @format A dataframe with 209 rows and 2 columns.
#' \describe{
#'   \item{UniProtAC}{UniProt accession code of proteins}
#'   \item{Score}{Check with MJ}
#'   ...
#' }
#' @source \doi{molpharm.120.000210}
'exmplData2'
