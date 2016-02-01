# WindowScanr: sliding window analysis

![](window_example.png)

`windowscanr` is a simple package with one main function: `winScan()`. This function 
allows one to calculate any statistics across a sliding window. It works on data.frame objects, 
and supports both "rolling" windows (simply based on the rows of the table) or "position" windows 
(based on a variable of positions given by the user). 

It can apply any valid functions given by the user and define windows based on grouping variables. 

See package vignette for more details.

# Installing

You can install the package using `devtools`:

```
library(devtools)
install_github('tavareshugo/windowscanr')
```

# Quick intro

See the package vignette:

```
library(windowscanr)
vignettes("windowscanr_intro")
```
