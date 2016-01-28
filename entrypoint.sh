#!/bin/bash
if [ -e requirements.txt ]; then
	pip install -r requirements.txt
fi

debug=0

while getopts 'hdo:' flag; do
        case "${flag}" in
                h)
                        echo "options:"
                        echo "-h        show brief help"
                        echo "-d        debug mode, no nginx or uwsgi, direct start with 'python app.py'"
                        echo "-o gid    installs docker into the container, gid should be the docker group id of your docker server"
                        exit 0
                        ;;
                d)
			debug=1
                        ;;
                o)
			apk add --update --no-cache docker
			apk add shadow --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
			groupmod -g ${OPTARG} docker
			gpasswd -a nginx docker
                        ;;
                *)
                        break
                        ;;
        esac
done


if [ "$debug" = "1" ]; then
	echo "Running app in debug mode!"
	python app.py
else
	echo "Running app in production mode!"
	nginx && uwsgi --ini /app.ini
fi
