#=========================================== (Render site Locally) ================================================#
#=====  Go To Root ./ folder
cd ./

# ====== CLEAN 1/2 (list which files will be removed)
# USING         Rscript -e "Rcode"
Rscript -e "rmarkdown::clean_site(preview = TRUE)"
# ====== CLEAN 2/2  (actually remove the files)
Rscript -e "rmarkdown::clean_site()"

# ====== RENDER the entire site
Rscript -e "rmarkdown::render_site()"
# render a single file only
#Rscript -e "rmarkdown::render_site("G20Journ.Rmd")"

#=========================================== (Push to Github repo) ================================================#
# check status
git status

# Add changes to git Index.
git add docs/* # specific
git add -A # ALL
git add -u # tracked
git add Dafare.Rmd
git add Fatte.Rmd

# Create Std commit "message"....
msg="rebuilt on `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
# ... Commit Those changes.
git commit -m "$msg"
		# git commit -m "gt in Fatte con pic link"
		# git commit -m " output in ./docs/"

# Push source and build repos.
git push origin master



