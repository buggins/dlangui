 #!/bin/bash
 # Build D headers binding for XCB
 # command line: dbuild.sh
 cd xslt
 for i in $( ls *.xml ); 
 do
 
  dest=$(echo $i | sed -e "s/xml/d/")
  echo Building $dest from $i
  xsltproc --stringparam mode header d-client.xsl $i > ../$dest
 done
