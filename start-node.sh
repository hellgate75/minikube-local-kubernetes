#!/bin/sh

FOLDER="$(realpath "$(dirname "$0")")"

sh $FOLDER/install.sh
RES="$?"
if [ "0" != "$RES" ]; then
	exit $RES
fi

sh $FOLDER/check-profile.sh

PROFILE="$(cat $FOLDER/.profile 2> /dev/null)"
PROFILE_TAG=""
if [ "" != "$PROFILE" ] && [ "minikube" != "$PROFILE" ]; then
	PROFILE_TAG="-p $PROFILE"
fi

if [ "" == "$(echo $PATH|grep $FOLDER/bin)" ]; then
	PATH=$PATH:$FOLDER/bin
fi

if [ "" = "$(which kubectl)" ]; then
	echo "Unable to locate kubectl, please install it ..."
fi

if [ "" = "$(which minikube)" ]; then
	echo "Unable to locate mini-kube, please install it ..."
	exit 1
fi

STATUS="$(minikube status $PROFILE_TAG)"
if [ "" = "$(echo $STATUS|grep -i running)" ]; then
	OPTION=""
	if [ "" != "$(echo $STATUS|grep -i nonexistent)" ]; then
		echo "Creating Minikube environment ..."
		LIST="$(minikube.exe start --help|grep vm-driver|grep virtualbox|awk 'BEGIN {FS=OFS=":"}{print $NF}')"
		echo "Please provide the driver type or leave blank for auto-detect : "
		echo "options: $LIST"
		printf "Choice [default: auto-detect]: "
		read OPTION
		if [ "" != "$OPTION" ]; then
			echo "Using vm driver: $OPTION"
			OPTION="--vm-driver=$OPTION"
		else
			echo "Using vm driver: <auto-detect>"
		fi
	fi
	OPTION="$PROFILE_TAG $OPTION"
	echo "Starting Minikube ..."
	echo "Running: <minikube start $OPTION>"
	sh -c "minikube start $OPTION"
	echo "Minikube started ..."
else
	echo "Minikube already running ..."
fi
