## Reflections for Milestone 3 - Group 10
#### Date: 2021/01/29

#### Status

So far, we have implemented the majority of functionality we designed for our detailed view. This includes full dynamic bootstrap styled layout, and a clean sidebar/content window design. In this milestone we incorporated feedback from Joel Ostbloom to limit the width of our app so that trends are not flattened out so much on each plot. Remaining feedback will be incorporated for our final milestone 4.

#### Next Steps

For milestone 4, we aim to implement our overview functionality and build in tabs to switch back and forth from detailed to overview. Our overview graph will have a stacked bar chart by country, to allow comparisons overall between countries. We also hope to build a world map to allow explorations of happiness in a spatial form, instead of just on a line graph. The color themes and overall aesthetic of the dashboard will also be improved from the default styling. Finally, we will also build some more intuitive callbacks to filter to certain countries from the map on user clicks. Hopefully this improves the user experience significantly and makes the data more intuitive to work with.

#### Reflections

Implementing the same functionality in another language always has it's pain points. We struggled with callback functionality in the R Dash package as it wasn't throwing intuitive errors when we weren't returning a list like we were supposed to. The web server behind Dash in R is also a little less user friendly on debugging as it won’t reload with certain content changes, and it doesn’t warn you that no updates are occurring. The use of `ggplotly` on top of `ggplot2` objects sped up graph creation as the group is quite comfortable with the common design patterns of ggplot objects.
