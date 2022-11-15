#' Plot the results of protein set enrichment analysis (PSEA)
#'
#' @description plotPSEA can be used to plot the results of protein set enrichment analysis (psea) for a set of proteins
#' obtained from an experiment.

#' @param x A data frame returned by \code{\link{runPSEA}} function.
#' @param y Default value is NULL. If provided by a protein set enrichment results, the matching results
#' of x and y are plotted.
#' @param sig.level The significance level applied on adjusted p-value by permutation to filter pathways
#' for plotting. The default value is 0.05
#' @param number.rep Only plot PTM terms that occurred more than a specific number of times in UniProt. This number is set
#' by number.rep parameter. The default value is NULL.
#' @return Plot
#'
#' @export
#'
#' @import tidyverse
#' @importFrom forcats fct_reorder
#'
#' @examples
#' psea_res <- runPSEA(protein = exmplData2, os.name = 'Rattus norvegicus (Rat)', nperm = 10)
#' plotPSEA(psea_res, sig.level = 0.05)
#'
plotPSEA = function(x, y = NULL, sig.level = 0.05, number.rep = NULL){

  if( is.null(y) ){

    z <- x[[1]]

    # Add a new column to x, mymean as the average of NES
    # Arrange x based on mymean

    z <- z %>%
      rowwise() %>%
      mutate( mymean = mean(NES) ) %>%
      arrange(mymean)

    # Order factor leveles of PTM according to mymean
    z$PTM <- fct_reorder(z$PTM, z$mymean)

    z <- z %>% mutate( ppvalue = nMoreExtreme/x$nperm )
    z <- z %>% mutate( logCorrectPvalue = -log(ppvalue) )

    if( !is.null(number.rep) ){
      z <- z %>% filter(size >= number.rep)
    }

    # Generate ggplot
    p <- ggplot(data = z, aes(x = PTM, y = NES))
    p <- p + geom_segment( aes(x = PTM, y = NES, xend = PTM, yend = 0), color = 'grey40', size = 1 )
    p <- p + geom_point( aes(fill = Enrichment, size = `size`), shape = 21 )
    #p <- p + geom_repel_label(data = y %>% filter(nMoreExtreme/x$nperm < sig.level), aes(label=nMoreExtreme/x$nperm),label.padding = unit(0.05, 'lines'))
    p <- p + geom_label(data = z %>% filter( ppvalue < sig.level), aes(label=ppvalue),label.padding = unit(0.05, 'lines'))
    #p <- p + geom_label_repel(data = z %>% filter(nMoreExtreme/x$nperm < sig.level), aes(label=nMoreExtreme/x$nperm),label.padding = unit(0.05, 'lines'))
    p <- p + theme(axis.text.x  = element_text(size = 12, face = 'bold', angle = 90),
                   axis.text.y  = element_text(size = 12, face = 'bold'),
                   legend.title = element_text(color = 'blue', size = 10),
                   legend.text  = element_text(size = 12),
                   axis.title   = element_text(size = 16))
    p <- p + scale_size( range = c(4,8) )
    p <- p + xlab('PTM keywords')
    p <- p + ylab('Normalized Enrichment Score (NES)')
    p <- p + coord_flip()

    # Plot
    plot(p)

  }

  if( !is.null(y) ){

   # merge x and y
     xx <- x[[1]]
     xx <- xx %>%
       rowwise() %>%
       mutate( mymean = mean(NES) ) %>%
       arrange(mymean)

     if( !is.null(number.rep) ){
       xx <- xx %>% filter(size >= number.rep)
     }


     yy <- y[[1]]
     yy <- yy %>%
       rowwise() %>%
       mutate( mymean = mean(NES) ) %>%
       arrange(mymean)

     if( !is.null(number.rep) ){
       yy <- yy %>% filter(size >= number.rep)
     }

     temp <- data.frame( rbind(xx,yy), Group = c( rep('List1',nrow(xx)), rep('List2',nrow(yy)) ), stringsAsFactors = FALSE)

     # Check if there are common PTM
     ptm.names <- names( which( table(temp$PTM) == 2 ) )
     if( length(ptm.names) == 0 ){
       stop('No PTM intersection in x and y.')
     }

     # Filter on common PTMs
     data.for.plot <- temp[temp$PTM %in% ptm.names,]

     # Change the order of PTM levels according to mymean
     data.for.plot     <- data.for.plot %>% arrange(mymean)
     data.for.plot$PTM <- fct_reorder(data.for.plot$PTM, data.for.plot$mymean)
     data.for.plot     <- data.for.plot %>% mutate( ppvalue = nMoreExtreme/x$nperm )
     data.for.plot     <- data.for.plot %>% mutate( logCorrectPvalue = -log(ppvalue) )


     # Generate ggplot
     p <- ggplot(data = data.for.plot, aes(x = PTM, y = NES))
     p <- p + geom_line(aes(group = PTM), color = 'grey40', size = 1)
     p <- p + geom_point(aes(shape = Group, color = logCorrectPvalue), size = 4)
     p <- p + geom_label(data = data.for.plot %>% filter( ppvalue < sig.level), aes(label=ppvalue),label.padding = unit(0.05, 'lines'))
     p <- p + theme(axis.text.x  = element_text(size = 12, face = 'bold', angle = 90),
                    axis.text.y  = element_text(size = 12, face = 'bold'),
                    legend.title = element_text(color = 'blue', size = 10),
                    legend.text  = element_text(size = 12),
                    axis.title   = element_text(size = 16))
     p <- p + xlab('PTM keywords')
     p <- p + ylab('Normalized Enrichment Score (NES)')
     p <- p + coord_flip()

     plot(p)

  }

}
