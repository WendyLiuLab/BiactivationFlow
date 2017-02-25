#!/usr/bin/env Rscript

library(rmarkdown)
# produce PDFs for LaTeX
render(
    input="../client-code/result-illustrations.Rmd",
    output_format=html_document(
        dev="cairo_pdf",
        self_contained=FALSE,
        fig_height=2.6,
        fig_width=3.5,
        ),
    output_dir=".",
)

return()

# produce a valid HTML document
render(
    input="../client-code/result-illustrations.Rmd",
    output_format=html_document(
        dev="svg",
        self_contained=FALSE,
        fig_height=2.6,
        fig_width=3.5,
        ),
    output_dir=".",
)
