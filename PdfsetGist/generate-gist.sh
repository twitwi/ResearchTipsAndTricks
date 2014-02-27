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
        if $GENIMG ; then
            (cd ${out} && convert -density 50 -background white "$pdf" -geometry x500 p${jj}.png)
            (cd ${out} && montage p"$jj"-* -tile x2  -geometry +2+2 all-p${jj}.jpg)
            (cd ${out} && rm -rf p"$jj"-*)
        fi
        j=$(($j + 1))
        cat<<EOF
{ pdf: "${pdf}", img: "all-p${jj}.jpg" },
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
        <title>Latent Structure Alignment for Unsupervised and Semi-Supervised Transfer Learning</title>
        <meta name="author" content="Rémi Emonet, Damien Muselet, Marc Sebban">

        <!-- override some style here if needed (or in an external file) -->
        <style type="text/css">
html, body{width: 99%; height: 99%; overflow: hidden} img.fit{width: 100%; height: 100%;}
        </style>
        <script>
        function gistNamespace() {
           var EMPTY = "__empty__";
           var meta = [
EOF
}
footer() {
cat<<EOF
           EMPTY];
           var cur = 0;
           /*
           var next = function() { cur = (cur+1) % (meta.length-1) }
           var prev = function() { cur = (cur+meta.length-2) % (meta.length-1) }
           */
           var next = function() { cur = cur+1 }
           var prev = function() { cur = cur-1 }
           var updt = function() {
              document.getElementById("theA").href = "file://"+meta[cur].pdf;
              document.getElementById("theIMG").src = meta[cur].img;
           }
           updt();
           document.onkeypress = function(e) {
              if (e.keyCode == 39) { next(); updt(); }
              if (e.keyCode == 37) { prev(); updt(); }
           }
        }
        window.onload = gistNamespace;
        </script>
    </head>
    <body>
       <a id="theA" href=""><img id="theIMG" class="fit" src=""></a>
    </body>
</html>
EOF
}

(header ; gogogo "$@" ; footer) > ${out}/index.html

