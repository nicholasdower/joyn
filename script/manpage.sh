#!/usr/bin/env bash

set -e
set -u
set -o pipefail

if [ $# -ne 2 ]; then
  echo "usage: $0 <version> <date>" >&2
  exit 1
fi

version="$1"
date="$2"

rm -rf man
mkdir man
cat << EOF > man/join.1
.TH JOIN 1 $date $version ""
.SH NAME
\fBjoin\fR \- Join lines
.SH SYNOPSIS
\fBjoin\fR [\fB-d\fR \fI<delimiter>\fR] [\fI<file> \.\.\.\fR]
.SH DESCRIPTION
Joins lines, optionally using the specified delimeter.
.SH OPTIONS
.TP
\fB\-d, \-\-delimeter\fR
The line delimeter\.
.TP
\fB\-h, \-\-help\fR
Print help\.
.TP
\fB\-v\, \-\-version\fR
Print the version\.
EOF
