#!/bin/sh

  rm -f all.pkgs
  rm -rf ./debs/tmp

if [[ -e changelog.log ]]; then
   rm changelog.log
fi

  echo "[" > all.pkgs
if [[ -e compatity.txt ]]; then
    compatity=$(cat compatity.txt)
fi

for i in ./debs/*.deb
do
   debInfo=`dpkg -f $i`
   dep=`echo "$debInfo" | grep "Depiction: " | cut -c 12- | tr -d "\n\r"`
   home=`echo "$debInfo" | grep "Homepage: " | cut -c 11- | tr -d "\n\r"`
   pkg=`echo "$debInfo" | grep "Package: " | cut -c 10- | tr -d "\n\r"`
   maintainer=`echo "$debInfo" | grep "Maintainer: " | cut -c 13- | tr -d "\n\r"`
   sponsor=`echo "$debInfo" | grep "Sponsor: " | cut -c 10- | tr -d "\n\r"`
   #Maintainer: nguyenthanh
   #Author: nguyenthanh
   #Sponsor: nguyenthanh
   if [[ -z $dep || -z $home || -z $maintainer || -z $sponsor ]];then
       dpkg-deb -R $i ./debs/tmp
   fi
       buildDEBIAN=0
   if [[ -z $dep ]]; then
       echo "Depiction: https://nguyenthanh1995.github.io/description.html?goto=${pkg}" >> ./debs/tmp/DEBIAN/control
       buildDEBIAN=1
   fi
   if [[ -z $home ]]; then
        echo "Homepage: https://nguyenthanh1995.github.io/" >> ./debs/tmp/DEBIAN/control
       buildDEBIAN=1
   fi
   if [[ -z $maintainer ]]; then
        echo "Maintainer: nguyenthanh1995 <thanhnguyennguyen1995@gmail.com>" >> ./debs/tmp/DEBIAN/control
       buildDEBIAN=1
   fi
   if [[ -z $sponsor ]]; then
        echo "Sponsor: nguyenthanh1995 <https://nguyenthanh1995.github.io>" >> ./debs/tmp/DEBIAN/control
       buildDEBIAN=1
   fi
   #binary 0 or 1
   if [[ $buildDEBIAN == 1 ]]; then
       bsname=$(basename "$i")
       dpkg -bR ./debs/tmp "./debs/$bsname"
       debInfo=`dpkg -f $i`
       echo "$i" >> changelog.log
   fi
#no sign =====================
#add Depiction done ==========


   section=`echo "$debInfo" | grep "Section: " | cut -c 10- | tr -d "\n\r"`
   section="${section//'"'/\\\"}"

   name=`echo "$debInfo" | grep "Name: " | cut -c 7- | tr -d "\n\r"`
   name="${name//'"'/\\\"}"

   vers=`echo "$debInfo" | grep "Version: " | cut -c 10- | tr -d "\n\r"`
   vers="${vers//'"'/\\\"}"

   author=`echo "$debInfo" | grep "Author: " | cut -c 9- | tr -d "\n\r"`
   author="${author//'"'/\\\"}"

   depends=`echo "$debInfo" | grep "Depends: " | cut -c 10- | tr -d "\n\r"`
   depends="${depends//'"'/\\\"}"

   description=`echo "$debInfo" | grep "Description: " | cut -c 14- | tr -d "\n\r"`
   description="${description//'"'/\\\"}"

   arch=`echo "$debInfo" | grep "Architecture: " | cut -c 15- | tr -d "\n\r"`
   arch="${arch//'"'/\\\"}"

   size=$(du -b $i | cut -f1)
   time=$(date +%s -r $i)
    
   echo '{"Name": "'$name'", "Version": "'$vers'", "Section": "'$section'", "Package": "'$pkg'", "Author": "'$author'", "Depends": "'$depends'", "Descript": "'$description'", "Arch": "'$arch'", "Size": "'$size'", "Time": "'$time'000"},' >> all.pkgs
#Building to json done==============
  leng=${#pkg}
  leng=`expr $leng + 1`
  exists=`echo "$compatity" | grep "$pkg" | cut -c "$leng"- | tr -d "\n\r"`
  if [[ -z $exists ]]; then
     echo "$pkg support for iOS..."
     read tmp
     echo "$pkg $tmp" >> compatity.txt;
  fi
  rm -rf ./debs/tmp
done

echo "{}]" >> all.pkgs

echo "------------------"
echo "Building Packages...."
apt-ftparchive packages ./debs > ./Packages;
#sed -i -e '/^SHA/d' ./Packages;
bzip2 -c9k ./Packages > ./Packages.bz2;
echo "------------------"
echo "Building Release...."
printf "Origin: Nguyen Thanh (shin-dev)\nLabel: shin-chan (N.Thanh)\nSuite: stable\nVersion: 1.0\nCodename: ios\nArchitecture: iphoneos-arm\nComponents: main\nDescription: Source Cydia Repo by Shin-chan (Nguyen Thanh)\nMD5Sum:\n "$(cat ./Packages | md5sum | cut -d ' ' -f 1)" "$(stat ./Packages --printf="%s")" Packages\n "$(cat ./Packages.bz2 | md5sum | cut -d ' ' -f 1)" "$(stat ./Packages.bz2 --printf="%s")" Packages.bz2\n" >Release;

echo "------------------"
echo "Done!"
exit 0;