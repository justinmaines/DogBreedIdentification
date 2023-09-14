library(data.table)
library(Rtsne)
library(ggplot2)
library(caret)
library(ClusterR)

set.seed(5)

sub <- fread("./project/volume/data/raw/example_sub.csv")

sample_no <- data$id
data$id <- NULL

pca <- prcomp(data)

saveRDS(pca,"./project/volume/models/pca.model")

screeplot(pca)

biplot(pca)

pca_dt <- data.table(unclass(pca)$x)

tsne<-Rtsne(pca_dt, pca = F, perplexity=30, check_duplicates = F)

saveRDS(tsne,"./project/volume/models/tsne.model")

tsne_dt <- data.table(tsne$Y)

ggplot(tsne_dt,aes(x=V1,y=V2))+geom_point()

opt_k <- 4

gmm_data <- GMM(tsne_dt[,.(V1, V2)],opt_k)

saveRDS(gmm_data,"./project/volume/models/gmm.model")

l_clust <- gmm_data$Log_likelihood^10
l_clust <- data.table(l_clust)

net_lh<-apply(l_clust,1,FUN=function(x){sum(1/x)})

cluster_prob<-1/l_clust/net_lh

# Breed 1 is V1, Breed2 is V2, Breed3 is V4, Breed4 is V3

sub$breed_1 <- cluster_prob$V1
sub$breed_2 <- cluster_prob$V2
sub$breed_3 <- cluster_prob$V4
sub$breed_4 <- cluster_prob$V3

fwrite(sub, "./project/volume/data/processed/sub_final.csv")
