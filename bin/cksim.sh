#!/bin/sh -f

# ¥Þ¥·¥ó¤¬Æ°ºî¤·¤Æ¤¤¤ë¤«¥Á¥§¥Ã¥¯¤¹¤ë¥¹¥¯¥ê¥×¥È
id=1;
host_name[id]="fusion";
let id=id+1;
host_name[id]="victoria";
let id=id+1;
host_name[id]="juno";
let id=id+1;
host_name[id]="pallas";
let id=id+1;
host_name[id]="irene";
let id=id+1;
host_name[id]="mars";
let id=id+1;
host_name[id]="astraea";
let id=id+1;
host_name[id]="saturn";
let id=id+1;
host_name[id]="iris";
let id=id+1;
host_name[id]="earth";
let id=id+1;
host_name[id]="themis";
let id=id+1;
host_name[id]="thetis";
let id=id+1;
host_name[id]="uranus";
let id=id+1;
host_name[id]="ceres";
let id=id+1;
host_name[id]="pluto";
let id=id+1;
host_name[id]="art0";
let id=id+1;
host_name[id]="art1";
let id=id+1;
host_name[id]="art2";
let id=id+1;
host_name[id]="art3";
let id=id+1;
host_name[id]="art5";
let id=id+1;
host_name[id]="art7";
let id=id+1;
host_name[id]="art13";
let id=id+1;
host_name[id]="art14";
let id=id+1;
host_name[id]="cow";
let id=id+1;
host_name[id]="hebe";
#let id=id+1;
#host_name[id]="aloe";
#let id=id+1;
#host_name[id]="aloesub";
#let id=id+1;
#host_name[id]="mercury";

echo "[35m----------------------------------------------------------------------[m"
echo "[35mcheck host status:";
echo "[35m----------------------------------------------------------------------[m"

for f in `seq ${id}` ;
do
	eval host=${host_name[$f]};
	echo -n "[32mchecking ${host}:[m";
	ckhost=`/usr/bin/rsh ${host} /bin/hostname`;
	if [ ${ckhost} = "No route to host" ]; then
		echo "[32mnot avail[m";
	else
		echo "[32mOK[m";
	fi
	echo "[33mcadtools: `/usr/bin/rsh ${host} /bin/ls -l / | grep -e cadtools`[m";
#	echo "[33mcadlibs: `/usr/bin/rsh ${host} /bin/ls -l / | grep -e cadlibs`[m";
#	echo "";
echo "[35m----------------------------------------------------------------------[m"
done

# END
