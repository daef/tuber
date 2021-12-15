# tuber - tube.tugraz.at downloader

## requirements

the download script is written using bash syntax
and expects [jq](https://stedolan.github.io/jq/), [htmlq](https://github.com/mgdm/htmlq) and [curl](https://curl.se/) on the PATH.

## docker

if you want to use tuber without polluting your PATH you might want to use the docker container.

## using it to download

tuber expects some environment variables:

* USER and PASS contain the credentials to logon to tube.tugraz.at
* COURSE contains the course-uuid to download
* RESOLUTION contains the quality to download (defaults to 1920x1080 if left unset)

### example using docker

first you have to build the image (once)

    docker build -t tuber .

then you can use the image to download analysis 1 to /tmp

     docker run --rm -v /tmp:/data -e USER=your_user -e PASS=your_pass -e COURSE=4636c0b6-71a8-45f1-bc6a-ea850f46175e tuber

### example without docker

to download analysis 1 to the current directory

USER=your_user PASS=your_pass COURSE=4636c0b6-71a8-45f1-bc6a-ea850f46175e /path/to/tuber.sh


