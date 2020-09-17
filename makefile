rPackageName=pgdraw
rLibraryPath=C:/Users/dschmidt/Documents/R/win-library/3.5
newDate=$(shell date +%Y-%m-%d)
rPackageVersion=$(shell grep "Version:" ./$(rPackageName)/DESCRIPTION | cut -c1-9 --complement)

build: roxy
	R CMD build $(rPackageName)
	R CMD INSTALL $(rPackageName) --build --library=$(rLibraryPath)

check: roxy
	R CMD build $(rPackageName)
	R CMD check $(rPackageName)_$(rPackageVersion).tar.gz

install: roxy
	R CMD build $(rPackageName)
	R CMD INSTALL $(rPackageName)_$(rPackageVersion).tar.gz

roxy:
	rm -f ./$(rPackageName)/man/*.Rd
	printf ".libPaths(c('$(rLibraryPath)', .libPaths()))\nlibrary(roxygen2,Rcpp)\npath <- \"./$(rPackageName)/\"\nRcpp::compileAttributes(path)\nroxygenize(package.dir=path)\n" > tmp_roxy.R
	R CMD BATCH tmp_roxy.R
	R CMD BATCH tmp_roxy.R
	cd ./$(rPackageName) && sed -i 's/\(Date: \).*/Date: '"$(newDate)"'/' DESCRIPTION
	cd ./$(rPackageName) && sed -i -e 's/\".registration=TRUE\"/.registration=TRUE/' NAMESPACE

clean:
	rm -rf $(rPackageName)_$(rPackageVersion).tar.gz $(rPackageName).Rcheck
	rm -rf ./$(rPackageName)/man/*.Rd
	rm -rf ./tmp_roxy.R ./tmp_roxy.Rout