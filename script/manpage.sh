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
cat << EOF > man/joyn.1
.TH JOYN 1 $date $version ""
.SH NAME
\fBjoyn\fR \- Join lines
.SH SYNOPSIS
\fBjoyn\fR [\fB-d\fR \fI<delimiter>\fR] [\fI<file> \.\.\.\fR]
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
.SH INSTALLATION
Install:
.PP
.RS 4
brew install nicholasdower/tap/joyn
.RE
.PP
Uninstall:
.PP
.RS 4
brew uninstall joyn
.RE
EOF
