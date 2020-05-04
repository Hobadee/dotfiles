#!/usr/bin/env bash

example(){
	# Stolen from https://unix.stackexchange.com/questions/127712/merging-folders-with-mv
	
	# usage source1 .. sourceN dest

	# Is likely broken with whitespace.  (See comments on SE thread.)
	
	length=$(($#-1))
	sources=${@:1:$length}
	DEST=$(readlink -f ${!#})
	for SRC in "$sources"; do
		pushd "$SRC";
		find . -type d -exec mkdir -p "${DEST}/{}" \;
		find . -type f -exec mv {} "${DEST}/{}" \;
		find . -type d -empty -delete
		popd
	done
}


example2() {
	echo "Sources:"
	for i in ${!SRC[*]}
	do
		echo "${SRC[$i]}";
	done

	exit 42
}

##############################################


# Exit codes:
# 0  - No errors
# 1  - Invalid Options
# 42 - Debug/Testing


usage(){
cat <<EOF
Usage:
$0 [options] <source1> [.. sourceN] <destination>

--- Conflict Handling ---
-o    Overwrite existing files
-s    Skip existing files
-i    Ask interactively on existing files (Default)
-d    Duplicate file  (Will append timestamp to file being moved over)
-n    Keep newer file
-l    Keep larger file

--- Other Options ---
-h    Print help and exit
-v    Verbose
-p    Pretend - don't actually run anything, just output what we would do.
EOF
}

HELP=false;
SKIP=false;
OVERWRITE=false;
DUPLICATE=false;
INTERACT=true;
NEWER=false;
LARGER=false;
SRC=();
DST=false;
VERBOSE=false;
PRETEND=false;

# Commands
MKDIR_EXEC=mkdir;
MKDIR_OPTS="p";
MV_EXEC=mv;
MV_OPTS="";
RM_EXEC=rm
RM_OPTS="df"
FIND_DELETE="delete"
#TIMESTAMP=$(date +%Y-%m-%d@%H%M);

while getopts :osidnlhvp OPTION
do
    case $OPTION in
		# --- Conflict Handling ---
		o)OVERWRITE=true;
			;;
		s)SKIP=true;
			;;
		i)INTERACT=true;
			;;
		d)DUPLICATE=true;
			;;
		n)NEWER=true;
			;;
		l)LARGER=true;
			;;
			
		# --- Other Options ---
		h)HELP=true
			usage;
			exit 0;
			;;
		v)VERBOSE=true;
			;;
		p)PRETEND=true;
			;;
		
		# --- Error Handling ---
		\?)
			echo "Invalid option: -$OPTARG" >&2;
			usage;
			exit 1;
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2;
			exit 1
			;;
    esac
done

if [[ $OVERWRITE == true ]]; then
	MV_OPTS="f"
fi
if [[ $NEWER == true ]]; then
	echo "Option not currently supported."
	exit 1
fi
if [[ $LARGER == true ]]; then
	echo "Option not currently supported."
	exit 1
fi
if [[ $SKIP == true ]]; then
	MV_OPTS="n"
fi
if [[ $DUPLICATE == true ]]; then
	echo "Option not currently supported."
	exit 1
fi
if [[ $INTERACT == true ]]; then
	MV_OPTS="i"
fi

# --- Other Options ---
if [[ $PRETEND == true ]]; then
	MKDIR_EXEC="echo $MKDIR_EXEC"
	MV_EXEC="echo $MV_EXEC"
	RM_EXEC="echo $RM_EXEC"
	FIND_DELETE="print";
fi

if [[ $VERBOSE == true ]]; then
	MV_OPTS="v$MV_OPTS"
fi

#
# Options done - get SRCs and DST
#
shift $((OPTIND-1));
# Just SRCs and DST now in $@

# Verify we have at least 2 options - SRC and DST.  Exit if not.
if (( $# < 2 )); then
	echo "No source/destination!";
	exit 1;
fi

# Map all SRC and DST arguments
n=0;
for i in "$@"
do
	n=$(($n+1));
	if (( $n >= $# )); then
		DST="$i";
		break;
	else
		SRC+=("$i");
	fi
done

if [[ ! -d $DST ]]; then
    echo "Destination not a directory.  Please specify a directory.";
    exit 1;
fi

#
# Enviornment setup.  Begin moving files.
#


for i in ${!SRC[*]}
do
	pushd $(dirname "${SRC[$i]}") > /dev/null
	find ${SRC[$i]} -type d -exec $MKDIR_EXEC "-$MKDIR_OPTS" "${DST}/{}" \;
	find ${SRC[$i]} ! -type d -exec $MV_EXEC "-$MV_OPTS" "{}" "${DST}/{}" \;
	find ${SRC[$i]} -type d -empty -$FIND_DELETE > /dev/null;
	popd > /dev/null
done

exit 0
