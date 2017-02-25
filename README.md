To start working with a git checkout:

1. Load the project in RStudio
1. Run roxygen2 over the package by selecting Build -> Document
1. Load the package with devtools::load_all()
1. Run data-raw/preprocess.R
1. Build -> Build and Reload

Summarized data files will be located in inst/extdata.

| Column name | Description |
| --- | --- |
| FSC.A | Forward scatter AUC |
| FSC.H | Forward scatter peak height |
| FSC.W | Forward scatter peak width |
| SSC.* | Side scatter; as above |
| CD86 | Scale value for CD86 staining intensity |
| CD206 | Scale value for CD206 staining intensity |
| Time | Time to event from acquisition start (s) |
| Event.. | Event serial number |
| Filename | Filename of original FCS file |
| Experiment | Replicate ID |
| antibody | "exp" (CD206/CD86) or "iso" (isotype controls) |
| m1_concentration | \[LPS+IFN-&gamma;] (ng/ml) |
| m2_concentration | \[IL-4+IL-13] (ng/ml) |
| timepoint (if applicable) | Duration of incubation with cytokines (h) |

See the vignettes for examples of normalizing data. Grouping on the `antibody` column is critical when plotting or summarizing data!
