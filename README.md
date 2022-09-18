# PREGO use cases

Here we have a collection of some ways to use PREGO knowledge base.

## Term collection from biological questions

There are cases that microbiologists are focused on specific environmental 
characteristics in their research. An important abiotic characteristic of 
environments is salinity. As climate change accelarates, salinity in various
habitats is also increased and an important challenge is the advancements
of agriculture crops with microbiome symbiotes tolerant in high salinity.

PREGO, being a data and metadata aggregator, can provide microbes and their 
processes that are associated with Environmental Ontology terms of saline 
environments. These are: 

```
ENVO:00000017	saline hydrographic feature
ENVO:00000019	saline lake
ENVO:00000054	saline marsh
ENVO:00000055	saline evaporation pond
ENVO:00000226	saline wedge estuary
ENVO:00000240	saline wetland
ENVO:00000279	saline pan
ENVO:00002010	saline water
ENVO:00002012	hypersaline water
ENVO:00002121	alkaline salt lake
ENVO:00002197	saline water aquarium
ENVO:00002209	saline lake sediment
ENVO:00005775	salt contaminated soil
ENVO:01000022	marine salt marsh biome
ENVO:01000307	saline water environment
ENVO:00002252	solonchak
ENVO:00002255	solonetz
ENVO:00000369	brine pool
ENVO:00003044	brine
```

Searching the PREGO knowledge base for the above terms results in multilayer network
data, environments, microbes and processes as compliled from the Literature, 
Environmental Samples and Annotated Genomes.


PREGO's knowledge space contains 94042 associations of these entities from all
channels combined. This information is obtained by a 
[filtering script](https://github.com/lab42open-team/prego_statistics/blob/master/filter_saline_envo.awk)
executed on bulk data available for download (see the [paper](https://www.mdpi.com/2076-2607/10/2/293))

```
20344 experiments
  94 knowledge
73604 textmining
```

PREGO scoring scheme assists in filtering the most probable associations.

```
gawk -F"\t" '{if ($1 ~ /textmining/){if ($6>4.8){print $0}} else {if ($8>=3){print $0}}}' saline_envo_pairs.tsv > saline_envo_pairs_filters.tsv
```

Narrows down to these associations
```
491 experiments
  94 knowledge
 711 textmining
```

In order to add metadata we create a file that contains the ids, name, layer 
and rank (if it is a taxon). We further filter the microbes to keep only 
species and strains.

```
gawk -F"\t" '(ARGIND==1){terms[$3]=1; terms[$5]=1}(ARGIND==2){rank[$1]=$5}(ARGIND==3 && ($2 in terms)){if ($1==-2) {if (rank[$2]=="species" || rank[$2]=="strain"){print $2 FS $3 FS $1 FS rank[$2]}} ; if ($1 !="-2" && $1 !=-3) {print $2 FS $3 FS $1 FS "na"} }' saline_envo_pairs_filters.tsv nodes.dmp /data/dictionary/database_preferred.tsv > saline_envo_pairs_metadata.tsv

```
Because of the last filtering of species and strains we have to filter the 
edgelist again based on the latest ids.

```
 gawk -F"\t" 'FNR==NR{terms[$1]=1; next}($5 in terms){print}' saline_envo_pairs_metadata.tsv saline_envo_pairs_filters.tsv > saline_envo_pairs_edgelist.tsv
```

The final network has 4 layers, 758 nodes and 904 edges in total.


### References
- Microorganisms in Saline Environments: Strategies and Functions
- Environmental Microbiology: Fundamentals and Applications

## Single term search

PREGO users can query with a single term to find the associated terms. For
example 

In the second example, we queried the PREGO (18) knowledge base for anaerobic 
ammonium oxidation, a biological process (gene ontology term GO:0019331). PREGO 
contains associations with microorganism taxa in the Literature channel for this query. We 
filtered the top 11 organisms at the genus level that where co-mentioned in the scientific 
literature. From these microorganisms we selected the genus, Beggiatoa to find 
the associated environment types. We selected the top 12 environments from the 
Literature channel and the top 8 environments from the Environmental Samples 
channel to a total of 20 environment associations. This compilation forms a 
tripartite network with Biological Processes, Organisms and Environments as layers. 
There are two types edges that show the PREGO channel that each is association is
derived from forming a multi-edged network. 

(C) Process, Organism and Environment association tables as derived from PREGO. On 
the left are the associations of the anaerobic ammonium oxidation process with 
organisms. In the middle are the associations of the genus Beggiatoa with 
Environments and their channel sources. (D) The multilayer and multiedge ARENA3D web 
visualization of these 2 distinct tables with different channels. There are 2 
associations of Beggiatoa with Environments, sediment and coast, that form multi-edges.

For each taxonomic group, the related environment types and biological processes were retrieved. 

As in the first case, association sources (literature, environmental sample records and genome annotations) are represented as different information channels (Figure 2C).

## Bulk Download general information


