#!/bin/bash

# TMP
if test -d gist/ ; then
    GENIMG=false
else
    GEIMG=true
fi
#GENIMG=true


out=gist
mkdir -p ${out}

gogogo() {
    J=0 ; for i in "$@" ; do
        jj=$(printf %03d $j)
        pdf=$(readlink -f "$i")
        if echo "$i" | grep -q '^/' ; then
            pdfurl="file://${pdf}"
        else
            # ../ to undo the ${OUT}
            pdfurl="../${i}"
        fi
        if $GENIMG ; then
            (cd ${out} && convert -density 50 -background white "$pdf" -geometry x500 p${jj}.png)
            (cd ${out} && montage p"$jj"-* -tile x2  -geometry +2+2 all-p${jj}.jpg)
            (cd ${out} && rm -rf p"$jj"-*)
        fi
        j=$(($j + 1))
        cat<<EOF
{ pdf: "${pdfurl}", img: "all-p${jj}.jpg" },
EOF
    done
}


header() {
cat <<EOF
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0">

        <!-- PROVIDE METADATA -->
        <!-- ================ -->
        <title>PDFSet GIST by https://github.com/twitwi/ResearchTipsAndTricks/</title>
        <meta name="author" content="https://github.com/twitwi/ResearchTipsAndTricks/">

        <!-- override some style here if needed (or in an external file) -->
        <style type="text/css">

html, body {margin:0; padding:0; width: 100%; height: 100%;}
body {overflow-x: scroll;}
img.fit{height: 95%;}
.overlay {position: fixed; left: 45%; top:0;}

        </style>
        <script>
        function gistNamespace() {
           if (typeof String.prototype.startsWith != 'function') {
             String.prototype.startsWith = function (str){
               return this.indexOf(str) == 0;
             }
           }
           var EMPTY = "__empty__";
           var meta = [
EOF
}
footer() {
cat<<EOF
           EMPTY];
           var cur = 0;
           if (location.hash.startsWith('#p')) {
              cur = parseInt(location.hash.substr(2)) - 1;
           }
           /*
           var next = function() { cur = (cur+1) % (meta.length-1) }
           var prev = function() { cur = (cur+meta.length-2) % (meta.length-1) }
           */
           var next = function(n) { cur = cur+n; if (cur>meta.length-2) cur=meta.length-2; }
           var prev = function(n) { cur = cur-n; if (cur<0) cur=0; }
           var updt = function() {
              document.getElementById("theA").href = meta[cur].pdf;
              document.getElementById("theIMG").src = meta[cur].img;
              var N = cur + 1
              var what = N+" / "+(meta.length-1);
              document.title = "PDFs GIST "+what;
              document.getElementById("theN").innerHTML = what;
              location.hash = "#p"+N;
           }
           updt();
           document.onkeypress = function(e) {
              if (e.keyCode == 37) { prev(1); updt(); return false; }
              if (e.keyCode == 38) { prev(10); updt(); return false; }
              if (e.keyCode == 39) { next(1); updt(); return false; }
              if (e.keyCode == 40) { next(10); updt(); return false; }
           }
        }
        window.onload = gistNamespace;
        </script>
    </head>
    <body>
       <a id="theA" href=""><img id="theIMG" class="fit" src=""></a>
       <div class="overlay" id="theN"></div>
    </body>
</html>
EOF
}

(header ; gogogo "$@" ; footer) > ${out}/index.html

echo "Output has been generated in '${out}/index.html'"
