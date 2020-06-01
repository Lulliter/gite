# CHANGING MIND!!!!!

[in reality this is now a private repo -- too much risk of confidential breach -- so public website does not apply anymore]

Info on this minimal rmarkdown-site website is 
[here - yihui's)](https://bookdown.org/yihui/rmarkdown/rmarkdown-site.html) or 
[here - Garret's)](https://garrettgman.github.io/rmarkdown/rmarkdown_websites.html) 

## Important

**R Markdown websites** can be hosted using GitHub Pages in 2 ways 

1. With two additions to the standard site configuration:
        + Add a file named `.nojekyll` to your site source code directory (this tells GitHub Pages to not process your site with the Jekyll engine).
        + Change your output directory to “.” within `_site.yml`. For example: `output_dir: "."` ( _using this configuration your source code, data, and everything else in your repository is all publicly available alongside your generated website content._ ).

2. Alternatively, you can configure GitHub Pages ⧉ to publish from a /docs subdirectory of your repository. If you work in this configuration you should change your output directory to “docs” within _site.yml. For example:`output_dir: "docs`"
  
## Less important

changing themes [link](https://www.datadreaming.org/post/r-markdown-theme-gallery/)
