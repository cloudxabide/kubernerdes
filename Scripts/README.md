# README - Scripts directory

The intent of this directory ~/Scripts is files that can be run non-interactively, broken down by "area of concern".
Non-interactive files will go in ~/Foo

Note:  Anything in my "scripts" that is encapsulated in a bash routine - ie. my_route(){ code; } generally means it is some optional code that I won't generally
 use. (like installing the Desktop UI)

Eventually, I would like to be able to simply run the following to build my environment
```
for SCRIPT in $(ls [0-9]*.sh | sort); do sh ./$SCRIPT; done
```

<pre>
I *think* I want my folder structue on my Admin Host to be...
  ~/ 
   /eksa/
        /management-cluster/*artifacts*
        /workload-cluster/*artifacts*
        /.archive/`date +%F`//management-cluster/
        /.archive/`date +%F`/workload-cluster/
</pre>
