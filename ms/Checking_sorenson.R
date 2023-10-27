##diversity test
library(targets)
library(tidyverse)
library(betapart)
targets::tar_load(ManyEcoEvo_results)
diversity<-ManyEcoEvo_results[[5]][[1]]


#turn variables selected into presence absense data
divdat_bt<-column_to_rownames(diversity, var = "id_col")
divdat_bt<-subset(select(divdat_bt,-c("dataset")))
divdat_bt <- data.frame(ifelse(is.na(divdat_bt),0,1)) #change to binary data
divdat_bt2 <-divdat_bt #duplicate data so can calculate how many variables used without stuffing up the diversity index calculation
divdat_bt2$no.variables<-rowSums(divdat_bt2, na.rm=TRUE)

pair_bt<-beta.pair(divdat_bt, index.family = "sorensen")
sorensendata_bt<-as.data.frame(as.matrix(pair_bt[["beta.sor"]]))
sorensendata_bt$meandiversityindex<-rowMeans(sorensendata_bt, na.rm=TRUE)
sorensendata_bt <- rownames_to_column(sorensendata_bt, var = "id_col")
sorensendata_bt<-sorensendata_bt[c(1,ncol(sorensendata_bt))]
sorensendata_bt$no.variables<-divdat_bt2$no.variables
