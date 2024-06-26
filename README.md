# PREGO use cases

Here we have a collection of some ways to use PREGO knowledge base and how to
visualise the resulted networks using tools like [Arena3D web](https://bib.fleming.gr:8084/app/arena3d).

## Term compilation regarding specific knowledge spaces

There are cases that microbiologists are focused on specific environmental 
characteristics in their research. An important abiotic characteristic of 
environments is salinity. As climate change accelarates, salinity in various
habitats is also increased and an important challenge is the advancements
of agriculture crops with microbiome symbiotes tolerant in high salinity.

### Soil

```
gawk -F"\t" 'BEGIN{soil["ENVO:00001998"]=1}(ARGIND==1 && $4=="ENVO:00001998"){soil[$2]=1}(ARGIND==2 && $2 in soil){print $2 FS $3}' database_groups.tsv database_preferred.tsv > ~/prego_statistics/soil_groups.tsv 
```

There are 115 ENVO terms related to soil. 

```
./filter_soil_envo.awk /data/dictionary/prego_unicellular_ncbi.tsv soil_groups.tsv /data/textmining/database_pairs.tsv /data/experiments/database_pairs.tsv /data/knowledge/database_pairs.tsv > prego_soil_envo.tsv
```
This script leads to 207939 PREGO associations.

Filtering with score values :

```
gawk -F"\t" '{if ($1 ~ /textmining/){if ($6>4.8){print $0}} else {if ($8>=3){print $0}}}' prego_soil_envo.tsv > prego_soil_envo_pairs_filters.tsv
```

results in 14988 associations. Distributed in channels: 
textmining      1137
experiments     7056
knowledge       6795

Metadata of the entities and keep only species and strains

```
gawk -F"\t" '(ARGIND==1){terms[$3]=1; terms[$5]=1}(ARGIND==2){rank[$1]=$5}(ARGIND==3 && ($2 in terms)){if ($1==-2) {if (rank[$2]=="species" || rank[$2]=="strain"){print $2 FS $3 FS $1 FS rank[$2]}} ; if ($1 !="-2" && $1 !=-3) {print $2 FS $3 FS $1 FS "na"} }' prego_soil_envo_pairs_filters.tsv nodes.dmp /data/dictionary/database_preferred.tsv > prego_soil_envo_pairs_metadata.tsv
```

Filter further to keep only species and strains
```
gawk -F"\t" 'FNR==NR{terms[$1]=1; next}($5 in terms){print}' prego_soil_envo_pairs_metadata.tsv prego_soil_envo_pairs_filters.tsv  > prego_soil_envo_pairs_edgelist.tsv
```

textmining      599
experiments     7003
knowledge       6777

Mostly text mining channel was filtered.

Format for Arena3D

```
gawk -F"\t" 'BEGIN{print "SourceNode" FS "TargetNode" FS "Weight" FS "SourceLayer" FS "TargetLayer" FS "Channel"}{if ($1=="textmining"){print $3 FS $5 FS $7 FS $2 FS $4 FS $1}else {print $3 FS $5 FS $8 FS $2 FS $4 FS $1}}' prego_soil_envo_pairs_edgelist.tsv > prego_soil_envo_pairs_arena.tsv
```


### Saline

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

PREGO scoring scheme assists in filtering the most probable associations. In
this case we filtered the Literature channel associations with score higher
that 4.8 and the rest of the channels with score higher or equal to 3.

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
species and strains taxonomic levels.

```
gawk -F"\t" '(ARGIND==1){terms[$3]=1; terms[$5]=1}(ARGIND==2){rank[$1]=$5}(ARGIND==3 && ($2 in terms)){if ($1==-2) {if (rank[$2]=="species" || rank[$2]=="strain"){print $2 FS $3 FS $1 FS rank[$2]}} ; if ($1 !="-2" && $1 !=-3) {print $2 FS $3 FS $1 FS "na"} }' saline_envo_pairs_filters.tsv nodes.dmp /data/dictionary/database_preferred.tsv > saline_envo_pairs_metadata.tsv

```
Because of the last filtering of species and strains we have to filter the 
edgelist again based on the latest ids.

```
 gawk -F"\t" 'FNR==NR{terms[$1]=1; next}($5 in terms){print}' saline_envo_pairs_metadata.tsv saline_envo_pairs_filters.tsv > saline_envo_pairs_edgelist.tsv
```

To display all the attributes names instead of ids run the following line

```
gawk -F"\t" 'BEGIN{channel["-2"]="Organism";channel["-27"]="Environment";channel["-21"]="Biological Process";channel["-23"]="Molecular Function"}(ARGIND==1){node[$1]=$2}(ARGIND==2){ if (FNR==1) {print $0} else {print node[$1] FS node[$2] FS $3 FS channel[$4] FS channel[$5] FS $6}}'  prego_saline_environments/saline_envo_pairs_metadata.tsv prego_saline_environments/saline_envo_pairs_edgelist-arena.tsv > arena_example_prego_saline_edgelist_names.tsv

```

The final network has 4 layers, 758 nodes and 904 edges in total.

### References
- Microorganisms in Saline Environments: Strategies and Functions
- Environmental Microbiology: Fundamentals and Applications

## Single term search

PREGO users can query with a single term to find the associated terms. For
example, anaerobic ammonium oxidation. This redirects the user to organisms 
that this process is found in the Literature channel. Then the user can select
organisms that are of interest, for example Beggiatoa. This genus is known since
the 19th century for oxidizing hydrogen sulfide. These microorganisms are found 
in both marine and fresh water in various habitats such as sendiment, mangooves,
etc. 

Some information regarding the relation of anaerobic ammonium oxidation and 
Beggiatoa that Literature channel unearthed:

Previous studies have observed that both denitrification and anammox in anoxic 
sediments can be supported by intracellular nitrate transport performed by 
sulfide-oxidizing bacteria like Thioploca and Beggiatoa (Mußmann et al., 2007; 
Jørgensen, 2010; Prokopenko et al., 2013) down to deeper sediment layers and 
possibly supplying anammox bacteria with nitrite and/or ammonia produced by DNRA
(source - PMID: 27812355)

So Beggiatoa assist neighbor microbes with annamox in anoxic sediments. 

Furthermore, users can select microorganisms to further expand the indirect 
associations of annamox with the environments. For example using Beggiatoa to 
find the associated environment types we selected the top 12 environments from the 
Literature channel and the top 8 environments from the Environmental Samples 
channel to a total of 20 environment associations. This compilation forms a 
tripartite network with Biological Processes, Organisms and Environments as layers. 
There are two types edges that show the PREGO channel that each is association is
derived from forming a multi-edged network. This network can be visualized with
[Arena3D web](https://bib.fleming.gr:8084/app/arena3d). There are 2 associations
of Beggiatoa with Environments, sediment and coast, that form multi-edges.



