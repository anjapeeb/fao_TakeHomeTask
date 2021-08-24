# fao_TakeHomeTask
a) Some basic metadata for the original data; 

Data on country agriculture production value : http://www.fao.org/faostat/en/#data/QV 
Data on population count: https://databank.worldbank.org/source/world-development-indicators# 
Mapping tables: http://www.fao.org/faostat/en/#definitions and table sent across by FAO


b) Concise comments of the tasks carried out, difficulties overcome, possible alternative solutions; 

Initial analysis and data cleaning

1.	Data was loaded in locally either as csv or as xlsx and then converted to csv
2.	The two mapping tables were joined so that full mapping information would be present in one table
3.	Data from FAO on agriculture production was merged with mapping data to extract country groups for each country based on World bank 2021 groupings outlined
4.	Agriculture production value per capita was constructed for each country
5.	Agriculture production value per capita was constructed for each country group and globally and then combined. Any missing and duplicated values removed to create data for creating plots
6.	Line graph constructed: y axis = per capita agri production value, x axis = year with each line representing a global region

Comments: 
•	With more time, it would have been possible to back fill population data for certain country groups thus removing the need to remove them altogether from the analysis. 
•	I employed data.table as this is something that I prefer when working quickly. Whilst there are some limitations to this package, particularly when reading in very large data sets, this was not an issue here and so its use should not hinder the replicability nor reliability of the analysis and its outputs

Rshiny – a very basic r shiny app was created (not utilising modules nor abstractions)

1.	Constructed UI to take on split view with an interactive region selection on the left and a rendered plot on the right
2.	Plot data was imported in and a reactive data table was constructed to take into account user selections
3.	Reactive data fed into plot (constructed in the initial analysis phase with some tweaks to render properly, for example ensuring that the legend printed text as is, that some caption appeared, etc)
4.	Plot rendered to output 
5.	App published to rstudio.io https://fao-informal-test.shinyapps.io/fao-informal-test/ 

Comments: 
•	Due to time constraints, more time and care could have been given over to screen interactivity (i.e. allowing users to view the analysis on different sized screens)

c) A brief narrative to comment and interpret the findings; 
 
•	In 2018, China (which was not listed as part of the mapping data) had the highest per capita agriculture production value of USD 891 (USD in constant 2014-2016), with High income economies and Latin America and Caribbean in second and third place (USD 866 and USD757, respectively).
•	Generally speaking, country groups that may be deemed to be of lower income status, comparatively had lower levels of agriculture production value per capita. 
•	Only two country groups saw a drop in per capita agricultural production value between 2014 and 2018 and they were Middle East & North Africa (excluding high income) and High income economies, with the former dropping by almost 10%
•	Whilst Sub-Saharan Africa (excluding high income) saw some positive growth over this time period, it was considerably below the global average of 2.3%
•	China,  East Asia & Pacific (excluding high income & China), Europe & Central Asia (excluding high income), Latin America & Caribbean (excluding high income) and South Asia saw per capita agriculture production value increase well above the global average, with East Asia & Pacific (excluding high income & China) and South Asia seeing growths of 10 and 9 per cent respectively

	wb_group2021	2014	2015	2016	2017	2018	Change 2014 to 2018 (%)
							
1	China	860	877	875	883	891	3.6046512
2	East Asia & Pacific (excluding high income & China)	478	483	480	523	526	10.0418410
3	Europe & Central Asia (excluding high income)	644	659	664	678	681	5.7453416
4	High income	869	860	878	877	866	-0.3452244
5	Latin America & Caribbean (excluding high income)	724	734	715	754	757	4.5580110
6	Middle East & North Africa (excluding high income)	432	420	411	411	390	-9.7222222
7	South Asia	262	257	264	279	286	9.1603053
8	Sub-Saharan Africa (excluding high income)	268	265	263	267	270	0.7462687
9	World	570	570	571	583	583	2.2807018


d) Any other consideration you deem to be useful.

With regards to visualising the information, it may have also been useful to provide context on population size – for example, bubble plot with each bubble size being representative of population size. 
Depending on use case, it may have also been “fun” to have the plot as an animated gif.

