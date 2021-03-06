
examples.deploy.ps = function() {
  deploy.ps()
}

# Copies data sets and other required files to solve problem set
# into the directory specified with dir
deploy.ps = function(ps.name=pkg$ps[1], dir=getwd(), material.dir=NULL, pkg = ps.pkg.info(), ask.user=TRUE, overwrite=FALSE) {
  restore.point("deploy.ps")
    
  if (is.null(material.dir)) {
    pkg.dir = path.package(info$package)
    material.dir = paste0(pkg.dir,"/material/",ps.name)
  }
  
  if (!overwrite) {
    if (is.ps.deployed(dir=dir, material.dir=material.dir)) {
      return(TRUE)
    }
  }

  if (!file.exists(dir)){
    warning(paste0("The directory '",dir,"' does not yet exist. Please create the directory before you proceed."))
    return(FALSE)
  }

  
  if (ask.user) {
    cat(paste0("\nDo you want to deploy the problem set to '", dir,"'?"))
    answer <- readline("Type y if this is ok: ")
    if (!identical(tolower(answer),"y")) {
      cat("\nCancelled deployment of problem set. If you want to deploy and run the problem set in a different directory, set the argument 'dir' in run.ps or deploy.ps.")
      return(FALSE)
    }
  }
  
  cat("\nCopy files to '", dir,"'...",sep="")

  # Copy files into working directory
  files= list.files(material.dir,pattern=".*",full.names = TRUE)  
  file.copy(from=files, to=dir, overwrite = overwrite, recursive = TRUE,copy.mode = !TRUE)
  
  cat(" done!")
  return(TRUE)
}

is.ps.deployed = function(dir,material.dir) {
  need.files= list.files(material.dir,full.names = FALSE)
  has.files = list.files(dir,full.names = FALSE)
  
  length(setdiff(need.files, has.files)) == 0
}

examples.run.ps = function() {
  setwd("D:/libraries/RTutor/work")
  library(RTutorTopIncomeTaxation)
  run.ps(user.name="Seb")
  detach("package:RTutorShroudedFees", unload=TRUE)  
  
}


get.package.info = function(package=NULL) {
  restore.point("get.package.info")
  if (is.null(package))
    return(ps.pkg.info())
  
  call = paste0(package,"::ps.pkg.info()")
  eval(base::parse(text=call))
}

#' Run a problem set from a package in the browser
#' 
#' Only works if a package with problem sets is loaded.
#' For problem sets stored in a local .rps file, use show.ps() instead
#' 
#' 
#' @param user.name Your user name
#' @param ps.name Name of the problem set. By default the first problem set name of your manually loaded RTutor problem set package.
#' @param dir your working directory for the problem set
#' @param load.sav Default=TRUE Shall a previously saved solution be loaded?
#' @param sav.file Optional an alternative name for the saved solution
#' @param sample.solution shall the sample solution be shown?
#' @param run.solved if sample.solution or load.sav shall the correct chunks be automatically run when the problem set is loaded? (By default FALSE, since starting the problem set then may take quite a while)
#' @param import.rmd shall the solution be imported from the rmd file specificed in the argument rmd.file
#' @param rmd.file name of the .rmd file that shall be imported if import.rmd=TRUE
#' @param offline (FALSE or TRUE) Do you have no internet connection. By default it is checked whether RTutor can connect to the MathJax server. If you have no internet connection, you cannot render mathematic formulas. If RTutor wrongly thinks you have an internet connection, while you don't, your chunks may not show at all. If you encounter this problem, set manually offline=TRUE. 
#' @param pkg.dir Folder to look in for problem set
run.ps = function(user.name, ps.name=info$ps[1],dir=getwd(),load.sav = TRUE, sav.file=paste0(user.name, "_", ps.name,".sav",
  pkg.dir = path.package(info$package)),  sample.solution=FALSE, run.solved=FALSE, import.rmd=FALSE, rmd.file = paste0(ps.name,"_",user.name,"_export.rmd"), offline=!can.connect.to.MathJax(), left.margin=2, right.margin=2, info=get.package.info(package), package=NULL, deploy.local=!make.web.app, make.web.app=FALSE, save.nothing=make.web.app, ...) {
  restore.point("run.ps")
  

  rps.dir = paste0(pkg.dir,"/ps")
  material.dir = paste0(pkg.dir,"/material/",ps.name)
  
  if (deploy.local) {
    setwd(dir)
    ret = deploy.ps(ps.name=ps.name, dir=dir, material.dir=material.dir)
    if (!ret) {
      return()
    }
  }
  show.ps(user.name=user.name, ps.name=ps.name, dir=dir, rps.dir=rps.dir,
    sav.file=sav.file,load.sav = load.sav, sample.solution=sample.solution, run.solved=run.solved, import.rmd=import.rmd, rmd.file = rmd.file, offline=offline, left.margin=2, right.margin=2,make.web.app=make.web.app, save.nothing=save.nothing,...)
}

examples.rtutor.package.skel = function() {
    #setwd("C:/Users/Joachim/Documents/BC/Atombombe")
  setwd("D:/libraries/RTutor/examples")
  
  set.restore.point.options(display.restore.point = TRUE)
  
  library(RTutor)
  ps.name = "understanding bank runs" 
  sol.file = paste0(ps.name,"_sol.Rmd") 
  libs = NULL
  libs = c("foreign","reshape2","plyr","dplyr","mfx", "ggplot2","knitr","regtools","ggthemes","dplyrExtras","grid","gridExtra","prettyR") # character vector of all packages you load in the problem set
  
  name.rmd.chunks(sol.file,only.empty.chunks=FALSE)
  
  # Create problemset
  create.ps(sol.file=sol.file, ps.name=ps.name, user.name=NULL,libs=libs, extra.code.file = "extracode.r", var.txt.file = "variables.txt")

  rtutor.package.skel(sol.file=sol.file, ps.name=ps.name, pkg.name="RTutorBankRuns", pkg.parent.dir = "D:/libraries/RTutorBankRuns", libs=libs, author="Joachim Plath", github.user="skranz", extra.code.file = "extracode.r", var.txt.file = "variables.txt", overwrite=TRUE)
  
  
  ##### Example 
  setwd("D:/libraries/RTutor/examples")
  ps.name = "Example"; sol.file = paste0(ps.name,"_sol.Rmd")
  libs = c() # character vector of all packages you load in the problem set
  #name.rmd.chunks(sol.file) # set auto chunk names in this file

  create.ps(sol.file=sol.file, ps.name=ps.name, user.name=NULL,libs=libs, stop.when.finished=FALSE)

   rtutor.package.skel(sol.file=sol.file, ps.name=ps.name, pkg.name="RTutorExample", pkg.parent.dir = "D:/libraries/RTutorExample", libs=libs, author="Sebastian Kranz", github.user="skranz", overwrite=TRUE)

}

#' Generate a package skeleton for a shiny based RTutor problem set that shall be deployed as a package
#'  
rtutor.package.skel = function(sol.file,ps.name,  pkg.name, pkg.parent.dir,author="AUTHOR_NAME", github.user = "GITHUB_USERNAME", date=format(Sys.time(),"%Y-%d-%m"),  source.dir = getwd(),rps.file = paste0(ps.name,".rps"), libs=NULL, extra.code.file=NULL, var.txt.file=NULL, ps.file = paste0(ps.name,".Rmd"), overwrite=FALSE, overwrite.ps=TRUE,...) {
  #create.ps(sol.file=sol.file, ps.name=ps.name, user.name=NULL,libs=libs, extra.code.file = "extracode.r", var.txt.file = "variables.txt")
  restore.point("rtutor.package.skel")

  
  dest.dir = paste0(pkg.parent.dir,"/", pkg.name)
  skel.dir = paste0(path.package("RTutor", quiet = FALSE),"/ps_pkg_skel")
  
  if (!file.exists(dest.dir))
    dir.create(dest.dir)
  
  # Copy package skeletion
  long.skel.files = list.files(skel.dir,full.names = TRUE)
  file.copy(from = long.skel.files,to = dest.dir, overwrite=overwrite, recursive = TRUE)
  
  mat.dir = paste0(dest.dir,"/inst/material/",ps.name)
  if (!file.exists(mat.dir))
    dir.create(mat.dir)

  
  # Replace placeholder strings
  
  
  dest.files = c("R/package_info.r","DESCRIPTION","NAMESPACE","README.md")
  dest.files = paste0(dest.dir,"/",dest.files)
  file = dest.files[1]
  if (length(libs)>0) {
    lib.txt = paste0("RTutor, ", paste0(libs, collapse=", "))
  } else {
    lib.txt = "RTutor"
  }
  descr.txt = paste0("RTutor problem set ", ps.name)
  for (file in dest.files) {
    txt = readLines(file)
    txt = gsub("PACKAGE_NAME",pkg.name,txt, fixed=TRUE)
    txt = gsub("PROBLEM_SET_NAME",ps.name,txt, fixed=TRUE)
    txt = gsub("AUTHOR_NAME",author,txt, fixed=TRUE)
    txt = gsub("CURRENT_DATE",date,txt, fixed=TRUE)
    txt = gsub("DEPENDS_LIBRARIES",lib.txt,txt, fixed=TRUE)
    txt = gsub("DESCRIPTION_TITLE",descr.txt,txt, fixed=TRUE)
    txt = gsub("GITHUB_USERNAME",github.user,txt, fixed=TRUE)
    
    writeLines(txt,file)
  }
  
  
  # Copy files into ps
  ps.dir = paste0(dest.dir,"/inst/ps")
  file.copy(from = c(sol.file, rps.file, extra.code.file, var.txt.file, ps.file),
            to=ps.dir, overwrite=overwrite.ps)
  
  cat(paste0("Package skeleton created in ", paste0(dest.dir,"/",pkg.name), ". ",
             "\nRead 'TO DO.txt' for the remaining steps."))
  
}
  

