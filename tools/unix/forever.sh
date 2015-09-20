cd deploy/
localdir="$PWD"
forever stop tddhx
forever start -a -l $localdir/log.log -e $localdir/err.log -o $localdir/out.log --workingDir $localdir --uid "tddhx" $localdir/app.js
