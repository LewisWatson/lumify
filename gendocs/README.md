# Generated Documentation

## dependency.graphml
Generated via [Maven Dependency Graph Plugin](https://github.com/janssk1/maven-graph-plugin/wiki/Manual) though see also [Stack Overflow Answer](http://stackoverflow.com/questions/4084669/how-to-generate-a-graph-of-the-dependency-between-all-modules-of-a-maven-project/8914344#8914344)

`mvn com.github.janssk1:maven-dependencygraph-plugin:1.0:graph`

Recommended to run 

`saxon input.graphml exclude-third-party-deps.xsl internal="my.package" > input-internal.graphml` 

to strip out dependencies (.xsl included here).

----

## dependency.graphml (alternative)
Could have used 

`mvn dependency:tree -DoutputType=graphml -DoutputFile=depdendency.graphml` 

though this works for a single module only.

See [Visual Maven Dependency Tree View](http://www.summa-tech.com/blog/2011/04/12/a-visual-maven-dependency-tree-view)

This does look handy inside yed.

----

## depgraph-maven-plugin
Used [depgraph-maven-plugin](https://github.com/ferstl/depgraph-maven-plugin) to generate .dot files on a per-module basis and then ran dot but again this was on a per-module basis.

The aggregate view `mvn com.github.ferstl:depgraph-mavn-plugin:1.0.1:depgraph-aggregate-by-groupid` also did it on a per-module basis and was still unreadable.

I've put examples in this folder of the generated .png files.

`mvn com.github.ferstl:depgraph-mavn-plugin:1.0.1:depgraph-aggregate-by-groupid`

`dot -Tpng <dotfile>  > <pngfile>`

----

## maven-overview-plugin
Used [maven-overview-plugin](https://code.google.com/p/maven-overview-plugin/) to generate .png files directly;

`mvn com.googlecode.maven-overview-plugin:maven-overview-plugin:RELEASE:overview`

----

