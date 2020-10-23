#!/usr/bin/perl
# MIT License
#
#Copyright (c) 2020 vinceh121
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

use strict;
use warnings;

use Path::Tiny;
use Term::ANSIColor;
use Getopt::Std;

our($opt_l);

$opt_l = "libreoffice";

exit 0 if !getopts("l:");

print colored("Generating web pages...", "magenta"), "\n";

my $start = path(".");
my $out = path("./html/");
$out->mkpath();

my $files = $start->iterator( {recurse => 1} );


while (my $f = $files->()) { # Go over every file in folder
	next if ($f =~ m/^\.git/ || $f =~ m/html/);
	next if !($f =~ m/.fodt/ || $f =~ m/.fodg/ || $f =~ m/.fods/);
	my $outfmt = "html";

	if ($f =~ m/.fodg/) {
		$outfmt = "svg";
	}

	my $outsub = path($out, $f->parent);
	my $nf = path($outsub, $f . "." . $outfmt);
	print "\t", colored("$f -> $nf", "cyan"), "\n";
	system($opt_l . " --headless --convert-to " . $outfmt . " --outdir \"" . $outsub . "\" \"" . $f . "\"");
}


print colored("Generating index...", "magenta"), "\n";

my $index = "<html><head><link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'></head><body class='w3-padding'><h1>Index of files</h1><ul style='list-style: none'>\n";

#my $subs = $out->iterator( {recurse => 1} );

#while (my $f = $subs->()) {
#	next if !(($f =~ /html$/) || ($f =~ /svg$/));
#	print "\t", colored("Adding $f", "green"), "\n";
#	my $url = substr($f, 5, length($f) - 5);
#	$index = $index . "\t\t<li class='w3-button'><a href=\"" . $url . "\">" . $f->basename . "</a></li>\n";
#}

sub AddFolder {
	my $file = @_[0];
	if ( $file->is_dir ) {
		print "\t", colored("Adding $file", "green"), "\n";
		$index = $index . "\t<li>" .$file->basename . "</li>";
		$index = $index . "\t<ul>";
		my $iter = $file->iterator;
		while ( my $sub = $iter->() ) {
			AddFolder($sub);
		}
		$index = $index . "\t</ul>";
	} else {
		return if !($file =~ m/\.html/);
		print "\t", colored("Adding $file", "blue"), "\n";
		my $url = substr($file, 5, length($file) - 5);
		$index = $index . "\t\t<li class='w3-button'><a href=\"$url\">" . $file->basename . "</a></li>\n";
	}
}

# AddFolder($out);
my @subgen = $out->children;

foreach ( @subgen ) {
	if ($_->is_file) {
		AddFolder($_)
	}
}

$index = $index . "<hr>";

foreach ( @subgen ) {
	if ($_->is_dir) {
		AddFolder($_)
	}
}

$index = $index . "\t</ul></div>\n";


$index = $index . "</ul></body></html>";

print "\t", colored("Writting...", "yellow"), "\n";;

my $indexout = path($out . "/index.html");
$indexout->spew($index);

print colored("Done!", "magenta"), "\n";
