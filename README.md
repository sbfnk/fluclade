# fluclade

Flu clade frequency model implemented in [libbi](http://libbi.org/).

To test, run

```[bash]
Rscript fluclade.r -h
```

## Requirements

It needs [libbi](http://libbi.org/), and the [RBi](https://github.com/sbfnk/RBi), [RBi.helpers](https://github.com/sbfnk/RBi.helpers), [docopt](https://cran.r-project.org/web/packages/docopt/index.html), [cowplot](https://cran.r-project.org/web/packages/cowplot/index.html) and [data.table](https://cran.r-project.org/web/packages/data.table/index.html) R packages:

```{r}
install.packages('devtools')
library('devtools')
install_github("sbfnk/RBi")
install_github("sbfnk/RBi.helpers")
install.packages('docopt')
install.packages('cowplot')
install.packages('data.table')
```
