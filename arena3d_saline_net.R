#!/usr/bin/Rscript

library(tidyverse)
library(igraph)


saline_net <- read_delim("arena_example_prego_saline_edgelist_names.tsv", delim="\t", col_names=T)
node_metadata <- read_delim("prego_saline_environments/saline_envo_pairs_metadata-arena.tsv", delim="\t", col_names=T)

saline_net_sum <- saline_net %>% group_by(SourceNode, TargetNode) %>% summarise(n=n(), .groups="keep")
g_saline <- graph_from_data_frame(saline_net, directed=F)

V(g_saline)$Rank <- node_metadata$Rank
V(g_saline)$Layer <- node_metadata$Layer
V(g_saline)$Degree <- degree(g_saline)
V(g_saline)$Betweenness <- betweenness(g_saline)

is.connected(g_saline)
clusters(g_saline)

clu <- components(g_saline)

louvain <- cluster_louvain(g_saline)
comms_louvain <- communities(louvain)

groups(clu)

decg <- decompose.graph(g_saline, min.vertices = 10)

c_saline_deg <- decg[[1]]
