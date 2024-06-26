#!/usr/bin/Rscript

library(tidyverse)
library(tidygraph)
library(igraph)
library(ggraph)


soil_net <- read_delim("prego_soil_envo_pairs_arena.tsv",
                       delim="\t",
                       col_names=T) |> relocate(TargetNode,SourceNode,TargetLayer,SourceLayer,Weight,Channel)
node_metadata <- read_delim("prego_soil_envo_pairs_metadata.tsv", delim="\t", col_names=F)
colnames(node_metadata) <- c("id", "name", "type","rank")

node_metadata_u <- node_metadata[!duplicated(node_metadata$id), ]

phyla <- read_delim("prego_soil_higher_taxa.tsv", delim="\t", col_names=T)

soil_net_sum <- soil_net %>% group_by(SourceNode, TargetNode) %>% summarise(n=n(), .groups="keep")
g_soil <- graph_from_data_frame(soil_net, directed=F)

node_metadata <- node_metadata_u |>
    filter(id %in% V(g_soil)$name) |>
    distinct()

V(g_soil)$Rank <- node_metadata$rank
V(g_soil)$Layer <- node_metadata$type
V(g_soil)$Degree <- degree(g_soil)
V(g_soil)$Betweenness <- betweenness(g_soil)

is.connected(g_soil)
clusters(g_soil)

clu <- components(g_soil)

louvain <- cluster_louvain(g_soil)
comms_louvain <- communities(louvain)

groups(clu)

decg <- decompose.graph(g_soil, min.vertices = 10)

c_soil_deg <- decg[[1]]


### multipartite

tidy_g <- as_tbl_graph(c_soil_deg) %>%
  activate(nodes) %>%
  mutate(layer = as.factor(Layer))


soil_m_c <- ggraph(tidy_g, layout = 'fr') + 
  geom_edge_link2(aes(edge_color=Channel, edge_width=Weight, edge_alpha = 0.5)) +
  geom_node_point(aes(color = layer), size = 4) +
  scale_color_manual(values = c("red", "blue", "green", "purple")) +
  theme_graph()

ggsave("soil_net_cirle.png",
       plot=soil_m_c, 
       height = 30, 
       width = 30,
       dpi = 300, 
       units="cm",
       device="png")
