#!/bin/bash

if test "$#" = "0" ; then
    echo please pass the list of pdfs, e.g. '*.pdf'
    echo possible environment variables are: REGEN=y LINKPDF=y
    exit
fi

out=gist
mkdir -p "${out}"

elementIn () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

gogogo() {
    local generated=("${out}/index.html")
    local j=0 ; for i in "$@" ; do
        local jj=$(printf %03d $j)
        local input=$(readlink -f "$i")
        local pdf=${input}
        local bn=$(basename "$i")
        local sha=$(sha1sum "$input" | colrm 10)
        local jpg=$(printf '%s-%s.jpg' "$sha" "${bn//[^a-zA-Z0-9]/-}")
        if echo "$i" | grep -q '^/' ; then
            local pdfurl="file://${pdf}"
        else
            # ../ to undo the ${OUT}
            local pdfurl="../${i}"
        fi
        printf "Input: $input" >&2
        local gen=false
        if [ "$REGEN" != "" -o ! -f "${out}/${jpg}" ] ; then
            gen=true
        fi
        local ext=${input##*.}
        if [ "$ext" = "xopp" ] ; then
            printf " ... xopp->pdf" >&2
            pdf=$(printf '%s-%s.pdf' "$sha" "${bn//[^a-zA-Z0-9]/-}")
            if [ "$LINKPDF" != "" ] ; then
                pdfurl="file://$(readlink -f "$out/$pdf")"
            fi
            if $gen ; then
                xournalpp "$input" -p "$out/$pdf" 2>/dev/null >&2
            fi
            generated+=("$out/$pdf")
        fi
        generated+=("$out/$jpg")
        if $gen ; then
            printf " ... pdf->jpg" >&2
            (cd "${out}" && convert -density 50 -background white "$pdf" -geometry x500 p${jj}.png)
            (cd "${out}" && if test -f p${jj}.png ; then mv p${jj}.png p${jj}-000.png ; fi)
            (cd "${out}" && montage p"$jj"-* -tile x2  -geometry +2+2 ${jpg})
            (cd "${out}" && rm -rf p"$jj"-*)
        fi
        if $gen ; then
            echo " ... done" >&2
        else
            echo " ... skipped as '${out}/${jpg}' exists" >&2
        fi
        j=$(($j + 1))
        cat<<EOF
{ pdf: "${pdfurl}", img: "${jpg}" },
EOF
    done
    local unused=()
    for i in "${out}/"* ; do
        if elementIn "$i" "${generated[@]}" ; then
            true # ok
        else
            unused+=("$i")
        fi
    done
    if [ "${#unused[@]}" -gt 0 ] ; then
        echo "Unused generated files:" >&2
        for i in "${unused[@]}" ; do
            printf " '%s'" "$i" >&2
        done
        echo >&2
    fi
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
           document.onkeydown = function(e) {
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

(header ; gogogo "$@" ; footer) > "${out}/index.html"

echo "Output has been generated in '${out}/index.html'"
echo "# Maybe run:"
#echo "fff gist/index.html .."
echo "firefox gist/index.html"
