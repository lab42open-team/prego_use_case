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

phyla <- read_delim("prego_soil_higher_taxa.tsv", delim="\t", col_names=T) |> na.omit(phylum_name)


############################### taxonomy ######################

domain <- as.character(unique(phyla$superkingdom))

phyla_top <- phyla |> filter(no_entities>10)

p <- ggplot(phyla_top) +
    geom_col(position="dodge",
            aes(x    = no_entities,
                y    = reorder(phylum_name, -no_entities,decreasing=TRUE),
                fill = as.character(channel))) +
        scale_fill_manual(name = "Channel",
                          labels = c("All","Literature", "Samples", "Annotations"),
                          values=c("all"="#8793Af",
                                   "textmining"="#1d2758",
                                   "experiments"="#c81976",
                                   "knowledge"="#e66101"))+
        scale_x_continuous(breaks=seq(0,1800,200),
                           name = "Number of entities")+
        theme_bw() +
        theme(legend.position = c(0.85,0.1),
              axis.text    = element_text(size =  8),
              axis.text.x  = element_text(angle = 45, hjust = 1),
              axis.title.y = element_blank(),
              axis.text.y  = element_text(size = 8))

ggsave("prego_soil_phyla_summary.png",
       plot=p,
       width = 15,
       height = 20,
       units = "cm",
       dpi = 300,
       device="png")


################################ network ######################

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
  geom_edge_link2(aes(edge_color=Channel, edge_width=0.01*Weight, edge_alpha = 0.5)) +
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
