#!/bin/bash
set -e
########################### config #####################
REPO=${REPO:-}
SSHFS_HOST=${SSHFS_HOST:-}
REPO_ADD_ARGS=${REPO_ADD_ARGS:-}
if [ "$#" -eq 0 ]; then
        FILES="$(find . -name *.pkg.tar.xz)"
else
        FILES="$1"
fi

##################### check input ############################
for i in SSHFS_HOST FILES REPO; do
        if eval [ -z "\$$i" ]; then
                eval echo "Variable \\\"\$i\\\" is empty or not set!!"
                exit 5;
        fi
done
##################### main #############################
echo;
echo "Pakages to add:    \"$FILES\""
echo "SSHFS_HOST is      \"$SSHFS_HOST\""
echo "Repository name is \"$REPO\""
echo "Is that ok? [y/n]"
echo -n "> "; read p
[ "$p" != 'y' ] && exit

set -x
mntdir="$(mktemp -d)"
cleanup() {
	if [ -d $mntdir ]; then
	      	if findmnt $mntdir; then
			echo "cleanup - unmounting mntdir"
		       fusermount -u $mntdir
		fi
		echo "cleanup - removing mntdir"
		rmdir $mntdir
	fi
}
trap cleanup EXIT
[ ! -e $mntdir ] && mkdir -p $mntdir

echo "Mounting sshfs $SSHFS_HOST"
sshfs $SSHFS_HOST $mntdir
echo "Copying files to repo dir"
cp $FILES $mntdir/

echo "Executing repo-add command"
repo-add $REPO_ADD_ARGS $mntdir/$REPO.db.tar.gz $FILES

exit ## execute cleanup function
