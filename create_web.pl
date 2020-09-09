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

print colored("Generating web pages...", "magenta"), "\n";

my $start = path(".");
my $out = path("./html/");

my $subs = $start->iterator;

while (my $sub = $subs->()) { # Go over every folder
	next if $sub->is_file();
	next if $sub->basename eq ".git";
	print colored("Subject $sub", "yellow"), "\n";

	my $files = $sub->iterator;

	while (my $f = $files->()) { # Go over every file in folder
		next if !($f =~ m/.fodt/ || $f =~ m/.fodg/ || $f =~ m/.fods/);
		my $outfmt = "html";

		if ($f =~ m/.fodg/) {
			$outfmt = "svg";
		}

		my $outsub = path($out, $sub->basename);
		my $nf = path($outsub, $f->basename(".fodt") . "." . $outfmt);
		print "\t", colored("$f -> $nf", "green"), "\n";
		system("libreoffice --convert-to " . $outfmt . " --outdir \"" . $outsub . "\" \"" . $f . "\"");
	}
}

print colored("Generating index...", "magenta"), "\n";

my $index = "<html><head><link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'></head><body class='w3-indigo w3-padding'><h1>Index of files</h1><ul style='list-style: none'>\n";

$subs = $out->iterator;

while (my $sub = $subs->()) {
	next if $sub->is_file();
	my $files = $sub->iterator;

	$index = $index . "\t<div class='w3-card w3-blue w3-margin w3-padding'><li>" . $sub->basename . "</li><ul>\n";

	while (my $f = $files->()) {
		next if !(($f =~ /html$/) || ($f =~ /svg$/));
		print "\t", colored("Adding $f", "green"), "\n";
		my $url = substr($f, 5, length($f) - 5);
		$index = $index . "\t\t<li class='w3-button'><a href=\"" . $url . "\">" . $f->basename . "</a></li>\n";
	}

	$index = $index . "\t</ul></div>\n";
}

$index = $index . "</ul></body></html>";

print "\t", colored("Writting...", "yellow"), "\n";;

my $indexout = path($out . "/index.html");
$indexout->spew($index);

print colored("Done!", "magenta"), "\n";
