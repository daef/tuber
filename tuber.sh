#!/bin/bash

: "${USER:=user}"
: "${PASS:=pass}"
: "${COURSE:=4636c0b6-71a8-45f1-bc6a-ea850f46175e}"
: "${RESOLUTION:=1920x1080}"
: "${FALLBACKRES:=1440x900}"

CURL="curl -L -c cookies -b cookies"
CURL_STDOUT="$CURL -s -o -"
TUBE="https://tube.tugraz.at"
INITURL="$TUBE/Shibboleth.sso/Login?target=/paella/ui/index.html"
EPIURL="$TUBE/search/episode.json?limit=2000&offset=0&sid=$COURSE"

RESPONSE=$($CURL_STDOUT -L -c cookies -b cookies -s -o - ${INITURL})
if [[ ! $RESPONSE =~ "Welcome to TU Graz TUbe" ]] ; then
	echo logging in
	LOGINURL="https://sso.tugraz.at$(echo "$RESPONSE" | htmlq --attribute action 'form[name=form1]')"
	RESPONSE=$($CURL_STDOUT --data-urlencode lang="de" --data-urlencode _eventId_proceed="" --data-urlencode j_username="${USER}" --data-urlencode j_password="${PASS}" ${LOGINURL})
	if [[ ! $RESPONSE =~ "Welcome to TU Graz TUbe" ]] ; then
		echo sso logon failed
		exit 23
	fi
fi
echo logged in
echo $EPIURL
$CURL -s -o episodes.json "$EPIURL"
cat episodes.json | jq -c "
	.[\"search-results\"]
	.result[]
	.mediapackage
	| {
		title: .title,
		urls: [ .media.track[]
			| select(.video.resolution == \"$RESOLUTION\")
			| .url]
	}" |
		while read episode
do
	TITLE="$(echo "$episode" | jq -r .title)"
	FN="$(echo "$TITLE" | tr -dc 'a-zA-Z0-9' ).mp4"
	URL="$(echo "$episode" | jq -r .urls[0])"
  echo episodeurl $URL
  if [ "$URL" != "null" ] ; then
    if [ ! -f "$FN" ] ; then
      echo "downloading $TITLE to $FN"
      $CURL -C - -o "$FN.part" "$URL"
      mv "$FN"{.part,}
    fi
  fi
done

cat episodes.json | jq -c "
	.[\"search-results\"]
	.result[]
	.mediapackage
	| {
		title: .title,
		urls: [ .media.track[]
			| select(.video.resolution == \"$FALLBACKRES\")
			| .url]
	}" |
		while read episode
do
	TITLE="$(echo "$episode" | jq -r .title)"
	FN="$(echo "$TITLE" | tr -dc 'a-zA-Z0-9' ).mp4"
	URL="$(echo "$episode" | jq -r .urls[0])"
  echo fallback episodeurl $URL
	if [ ! -f "$FN" ] ; then
		echo "downloading $TITLE to $FN"
		$CURL -C - -o "$FN.part" "$URL"
		mv "$FN"{.part,}
	fi
done

