#/bin/bash

DEBUG="false"

if [ $DEBUG == "true" ]; then
  echo "Starting..."
fi

cd /srv/bins
mkdir -p roadside

SRC='/srv/nextcloud/nc_data/jens@gecius.de/files/SofortUpload/PicSay/'
DST='/srv/nginx_for_nedoc.gecius.de,nedoc1.gecius.de/html/roadside/'

LOGINURL="https://www.mopar-forum.eu/ucp.php?mode=login"
POSTURL="https://www.mopar-forum.eu/posting.php?mode=reply&f=22&t=24613"

if [ $DEBUG == "true" ]; then
  echo "Deleting old list..."
fi

rm roadside/files.neu &>/dev/null

for i in $SRC*
 do
  file="${i##*/}"
  if [ $DEBUG == "true" ]; then
   echo "Found $file"
  fi
  if [ ! -f "$DST$file" ]
  then
   if [[ $i =~ .(JPG|jpg) ]]
    then
     if [ $DEBUG == "true" ]; then
      echo "$file fehlt im Ziel"
     fi
## convertiere fehlende Dateien nach roadside in 800x600
     convert $i -auto-orient -geometry 800x600 "$DST$file"

## Generiere Output für roadside post
      echo "[img]https://nedoc.gecius.de/roadside/${file}[/img]" >> roadside/files.neu
      echo >> roadside/files.neu
   fi
  fi
 done

if [ -f roadside/files.neu ]
 then
  rm roadside/session.* &>/dev/null

# MSG=`cat roadside/files.neu|tr [:cntrl:] -d`
  if [ $DEBUG == "true" ]; then
   echo -e "login and check sid etc...."
  fi
# LINK="${BASE}ucp.php?mode=login"
  curl -k -c roadside/Moparcookie -o roadside/session.0.html $LOGINURL &>/dev/null
  creationtime=$(grep 'creation_time' roadside/session.0.html | cut -d'"' -f6)
  formtoken=$(grep 'form_token' roadside/session.0.html | cut -d'"' -f6)
  sid=$(grep 'value' roadside/session.0.html | grep 'name="sid' | cut -d'"' -f6)

  if [ $DEBUG == "true" ]; then
   echo "got ids"
   echo "ct: $creationtime"
   echo "ft: $formtoken"
   echo "lastclick: $lastclick"
   echo "tcpi: $postid"
   echo "sid: $sid"
   echo "Wait 2 secs"
  fi

  curl -k -c roadside/Moparcookie -o roadside/session.1.html "$LOGINURL&amp;sid=$sid" \
       -d "username=69" -d "password=cupof69tea" -d "login=Anmelden" \
       -d "creation_time=$creationtime" \
       -d "sid=$sid" \
       -d "redirect=index.php" \
       -d "form_token=$formtoken" &>/dev/null
  if [ $DEBUG == "true" ]; then
   echo $?
  fi
  curl -k -b roadside/Moparcookie -o roadside/session.2.html "$POSTURL&amp;sid=$sid" &>/dev/null
  if [ $DEBUG == "true" ]; then
   echo $?
  fi
  postid=$(grep 'topic_cur_post_id' roadside/session.2.html | cut -d'"' -f6)
  lastclick=$(grep 'lastclick' roadside/session.2.html | cut -d'"' -f12)
  creationtime=$(grep 'creation_time' roadside/session.2.html | cut -d'"' -f6)
  formtoken=$(grep 'form_token' roadside/session.2.html | cut -d'"' -f6)
  subject="Re: on roadside"

  if [ $DEBUG == "true" ]; then
   echo "got ids"
   echo "ct: $creationtime"
   echo "ft: $formtoken"
   echo "lastclick: $lastclick"
   echo "tcpi: $postid"
   echo "sid: $sid"
   echo "Wait 2 secs"
  fi

  sleep 2

  curl -k --data-urlencode "message@roadside/files.neu" \
       -d "lastclick=$lastclick" \
       -d "subject=$subject" \
       -d "creation_time=$creationtime" \
       -d "form_token=$formtoken" \
       -d "sid=$sid" \
       -d "attach_sig=checked" \
       -d "notify=checked" \
       -d "post=Abschicken" $POSTURL -b roadside/Moparcookie -o roadside/session.3.html &>/dev/null

#  dat=`date +%Y%m%d-%H:%M:%S`
#  rm posted.*
#  touch posted.${dat}
#  chmod a+r *
  if [ $DEBUG == "true" ]; then
   echo "done"
   echo "closing..."
  else
   rm roadside/Moparcookie &>/dev/null
   rm roadside/session.* &>/dev/null
   rm roadside/files.neu &>/dev/null
  fi
fi
