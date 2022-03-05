```R
library(gander)
options(repr.plot.width = 15, repr.plot.height = 9)
```

## gander
### quick and dirty visualization of your data.frame

the main idea here, is to have an easy to use function that will plot all your variables to get you started on exploratory analysis.

at a glance, you can see:
* how many variables you have
* how many observations you have
* distribution of values in each variable
* if a variable is discrete or continuous
* if there is any NA values
* interactions with a target variable


```R
# plot distribution of all variables 
gander(airquality)
```


    
![png](README_files/README_2_0.png)
    



```R
# plot one variable x all others
gander(iris, Petal.Length)
```


    
![png](README_files/README_3_0.png)
    



```R
suppressMessages(library(tidyverse))
# works nicely with tidyverse stuff
# modify your data.frame and pipe to gander
mutate_at(mtcars, c("cyl","vs","am","gear"), factor) %>% gander(mpg)
```


    
![png](README_files/README_4_0.png)
    



```R
# plot timeseries data
gander(Seatbelts, time)
```


    
![png](README_files/README_5_0.png)
    



```R
# plot table data
gander(HairEyeColor, Eye)
```


    
![png](README_files/README_6_0.png)
    



```R
gander(Titanic, Survived)
```


    
![png](README_files/README_7_0.png)
    



```R
gander(quakes)
```


    
![png](README_files/README_8_0.png)
    



```R
gander(diamonds, carat)
```


    
![png](README_files/README_9_0.png)
    



```R
select(starwars, -name, -starships) %>% gander(height)
```


    
![png](README_files/README_10_0.png)
    



```R
select(storms, -name) %>% gander(status)
```


    
![png](README_files/README_11_0.png)
    



```R

```


```R

```
