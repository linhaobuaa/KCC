require("clue")
require("slam")

#print(getwd())
dataset <- "la12"

data <- read_stm_CLUTO(paste("~/KCC/Matlab/Drivers/data/",dataset,".mat",sep=""))
data_labels <- read.csv(paste("~/KCC/Matlab/Drivers/data/",dataset,"_rclass.dat",sep=""), header=FALSE)
#View(data)
#View(data_labels)
groundtruth_n_classes <- length(unique(data_labels$V1))
print(groundtruth_n_classes)

## Create multiple k-means partition of the data with random parameter selection strategy
set.seed(1234)
n_objs <- nrow(data)
max_k <- ceiling(sqrt(n_objs))
print (max_k)
r <- 100
Ki <- sample(groundtruth_n_classes:max_k, r, replace=TRUE)
print (Ki)
bplist <- list()
for (i in 1:r)
{
  bp <- kmeans(data, Ki[i])
  bplist[[i]] <- bp
}

hens <- cl_ensemble(list = bplist)
consensus_result <- cl_consensus(hens,method="SE",control = list(k = groundtruth_n_classes, verbose = TRUE))
hard_consensus_result <- cl_class_ids(consensus_result)
#View(hard_consensus_result)
#print(typeof(hard_consensus_result))

library(R.matlab)
writeMat(paste("~/KCC/Matlab/Drivers/baseline_clue_jss05/clue_",dataset,"_consensusresult.mat",sep=""), consensus=hard_consensus_result)
