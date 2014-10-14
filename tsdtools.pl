#!/usr/bin/perl
#
# Author: T.S. Davenport (todd.davenport@yahoo.com)
#
use Cwd;
use File::Path qw(make_path);
use strict;
$|++;

# Get starting timestamp
our $StartTimestamp = time;

# Globals
our $DoCount            = 0;
our $DoCountExt         = "";
our $DoUnzipAll         = 0;
our $DoUnzipAllDest     = 0;
our $DoDos2unix         = 0;
our $DoCopy             = 0;
our $DoCopyDest         = 0;
our $DoCopyExt          = 0;
our $DoDelete           = 0;
our $DoDeleteExt        = 0;
our $DoRecursiveUnzip   = 0;
our $DoRecursiveUnzipD  = 0;

our $Quiet              = 0;

# check for command line args
for (my $i = 0; $i <= $#ARGV; $i++) {
    if ($ARGV[$i] eq '-h') { &printUsage(); exit; }
    if ($ARGV[$i] eq '-v') { &printVersion(); exit; }
    if ($ARGV[$i] eq '-q') { $Quiet = 1; }
    
    if ($ARGV[$i] eq '--numfiles')         { $DoCount = $ARGV[$i + 1]; $DoCountExt = $ARGV[$i + 2]; }
    if ($ARGV[$i] eq '--unzipall')         { $DoUnzipAll = $ARGV[$i + 1]; $DoUnzipAllDest = $ARGV[$i + 2]; }
    if ($ARGV[$i] eq '--cpall')            { $DoCopy = $ARGV[$i + 1]; $DoCopyDest = $ARGV[$i + 2]; $DoCopyExt = $ARGV[$i + 3]; }
    if ($ARGV[$i] eq '--deleteall')        { $DoDelete = $ARGV[$i + 1]; $DoDeleteExt = $ARGV[$i + 2]; }
    if ($ARGV[$i] eq '--dos2unixall')      { $DoDos2unix = $ARGV[$i + 1]; }
    if ($ARGV[$i] eq '--resursiveunzip')   { $DoRecursiveUnzip = $ARGV[$i + 1]; $DoRecursiveUnzipD = $ARGV[$i + 2]; }
}

if ($DoCount ne '0') {
    &getFileCount($DoCount, $DoCountExt);

} elsif ($DoUnzipAll ne '0') {
    &unzipAll($DoUnzipAll,$DoUnzipAllDest)

} elsif ($DoDos2unix ne '0') {
    &dos2unixAll($DoDos2unix);

} elsif ($DoDelete) {
    &deleteAll($DoDelete, $DoDeleteExt);

} elsif ($DoCopy && $DoCopyDest) {
    &copyAll($DoCopy, $DoCopyDest, $DoCopyExt);
    
} elsif ($DoRecursiveUnzip && $DoRecursiveUnzipD) {
    &recursiveUnzip($DoRecursiveUnzip, $DoRecursiveUnzipD);
    
# If nothing specified to do just print uage
} else {
    &printUsage();
}

our $FinishTimestamp = time;
our $TimeElapsedInSec = $FinishTimestamp - $StartTimestamp;
print "Ran in ";
print int($TimeElapsedInSec/(24*60*60)),   " days ";
print int(($TimeElapsedInSec/(60*60))%24), " hours ";
print int(($TimeElapsedInSec/60)%60),      " mins ";
print int($TimeElapsedInSec%60),           " secs\n\n";
exit;

sub unzipAll { # ($dir,$dest)
    my($dir,$dest) = @_;
    print "Unzipping all files in $dir";
    unless ($dest) {
        $dest = $dir;
    }
    if ($dest =~ /^\-/) {
        $dest = $dir;
    }
    print " and putting in $dest";
    print "\n";
    
    print "Continue? (y/N) ";
    my $input = <STDIN>;
    if ($input !~ /^y/i) {
        print "Exiting\n\n";
        return;
    }
    
    my $count = 0;
    
    opendir(my $dirh1, $dir) or die "Can't read $dir:$!\n";
    while ( 
        defined( my $file = readdir $dirh1 )
     ) {

        next if ($file =~ /^\./);
        next unless ($file =~ /zip/i);
        $count++;
        
        if ($dest) {
            print "unzip -j -u $dir/$file -d $dest\n" unless ($Quiet);
            print `unzip -j -u $dir/$file -d $dest`;
        } else {
            print "unzip -j -u $dir/$file\n" unless ($Quiet);
            print `unzip -j -u $dir/$file`;
        }
    }
    closedir $dirh1;
    print "\nDid $count files\n\n";
    return;
}

sub dos2unixAll { # ($dir)
    my($dir) = @_;
    print "dos2unix all files in $dir\n";
    my $count = 0;
    
    print "Continue? (y/N) ";
    my $input = <STDIN>;
    if ($input !~ /^y/i) {
        print "Exiting\n\n";
        return;
    }
    
    opendir(my $dirh1, $dir) or die "Can't read $dir:$!\n";
    while ( 
        defined( my $file = readdir $dirh1 )
     ) {

        next if ($file =~ /^\./);
        $count++;
        print "dos2unix -f $dir/$file\n" unless ($Quiet);
        print `dos2unix -f $dir/$file`;
    }
    closedir $dirh1;
    
    print "\nDid $count files\n\n";
    return;
}

sub copyAll { # ($dir,$dest,$ext)
    my($dir,$dest,$ext) = @_;
    print "copy all files in $dir to $dest";
    
    unless (-d $dest) {
        print "\n$dest doesn't exist as a directory.  Exiting.\n";
        return;
    }
    
    if ($ext =~ /^\-/) {
        $ext = "";
    }
    
    if ($ext) {
        print " if they have extension $ext";
    }
    print "\n";
    my $count = 0;
    
    print "Continue? (y/N) ";
    my $input = <STDIN>;
    if ($input !~ /^y/i) {
        print "Exiting\n\n";
        return;
    }
    
    opendir(my $dirh1, $dir) or die "Can't read $dir:$!\n";
    while ( 
        defined( my $file = readdir $dirh1 )
     ) {

        next if ($file =~ /^\./);
        if ($ext) {
            next unless ($file =~ /$ext$/i);
        }
        $count++;
        print "cp '$dir/$file' $dest\n" unless ($Quiet);
        print `cp '$dir/$file' $dest`;
    }
    closedir $dirh1;
    
    print "\nDid $count files\n\n";
    return;
}

sub deleteAll { # ($dir, $ext)
    my($dir,$ext) = @_;
    print "Delete all files in $dir";
    
    if ($ext =~ /^\-/) {
        $ext = "";
    }
    
    if ($ext) {
        print " if they have extension $ext";
    }
    print "\n";
    my $count = 0;
    
    print "Continue? (y/N) ";
    my $input = <STDIN>;
    if ($input !~ /^y/i) {
        print "Exiting\n\n";
        return;
    }
    
    opendir(my $dirh1, $dir) or die "Can't read $dir:$!\n";
    while ( 
        defined( my $file = readdir $dirh1 )
     ) {

        next if ($file =~ /^\./);
        if ($ext) {
            next unless ($file =~ /$ext$/i);
        }
        $count++;
        print "rm '$dir/$file'\n" unless ($Quiet);
        print `rm '$dir/$file'`;
    }
    closedir $dirh1;
    
    print "\nDid $count files\n\n";
    return;
}

sub getFileCount { # ($dir, $ext)
    my($dir,$ext) = @_;
    print "Counting all files in dir \"$dir\"";
    
    if ($ext =~ /^\-/) {
        $ext = "";
    }
    
    if ($ext) {
        print " with extension \"$ext\"";
    }
    print "\n";
    my $count = 0;
    
    opendir(my $dirh, $dir) or die "Can't read $dir:$!\n";
    while ( 
        defined( my $file = readdir $dirh )
     ) {

        next if ($file =~ /^\./);
        if ($ext) {
            next unless ($file =~ /$ext$/i);
        }
        $count++;
    }
    closedir $dirh;
    print "Found $count files\n\n";
    return;
}

sub recursiveUnzip { # ($dir,$dest)
    my($dir,$dest) = @_;
    
    if (-d $dir) {
        print "Recursive uzipping files in $dir";
    } else {
        print "\n$dest doesn't exist as a directory.  Exiting.\n";
        return;
    }
    
    print " and putting in $dest";
    print "\n";
    
    print "Continue? (y/N) ";
    my $input = <STDIN>;
    if ($input !~ /^y/i) {
        print "Exiting\n\n";
        return;
    }
    
    my $ref;
    &unzipBall($dir, $ref, $dest, 1);

    print "\nDone\n\n";
    return;
}

sub unzipBall { # ($baseDir, $dataRef, $finalDir, $parent)
    my ( $baseDir, $dataRef, $finalDir, $parent ) = @_;
    unless ($parent) {
        $parent = 0;
    }
    opendir( DIR, $baseDir ) or die "Can't open $baseDir:$!\n";
    my @files = readdir(DIR);
    closedir DIR;
    my $filecount = @files;
    foreach my $file (@files) {
        chomp $file;
        next if $file =~ /^\.|^\.\./;
        if ( $file =~ m/__MACOSX/i ) {
            if ( !system("rm -r \"$baseDir/$file\"") ) {

            } else{

            }
        } elsif (-d $baseDir . "/" . $file) {
            my $newBaseDir = $baseDir . "/" . $file;
            &unzipBall( $newBaseDir, $dataRef, $finalDir );
        } elsif ($file =~ m/.zip$/i) {
            my $newDirName = $file;
            $newDirName =~ s/\.zip//i;
            my $newBaseDir = $baseDir . "/" . $newDirName;
            if ( -d $newBaseDir ) { $newBaseDir = "$newBaseDir$filecount" }
            if ( !system("unzip -qq \"$baseDir/$file\" -d \"$newBaseDir\"") ) {
                &unzipBall( $newBaseDir, $dataRef, $finalDir );
                unless ($parent) {
                    if ( !system("rm \"$baseDir/$file\"") ) {
                    } else {
                }
            }
            }else{

            }
        } else {
            my $dir = $baseDir;
            $dataRef->{"$baseDir/$file"}{'id'}       = "$baseDir/$file";
            $dataRef->{"$baseDir/$file"}{'dir'}      = "$dir";
            $dataRef->{"$baseDir/$file"}{'filename'} = "$file";
            unless ( -d $finalDir ) {
                make_path($finalDir);
            }
            system("mv \"$dir/$file\"  \"$finalDir/$file\"");
        }
    }
    if ($parent) {
        finddepth( sub { rmdir }, $baseDir );
    }
    return 0;
}

sub printUsage() {
    my $cwd = getcwd;
    print <<EOF;
tsdtools.pl ($cwd $0)
Technical Software Development tools

-h          Print this help screen.
-v          Print version info.
-q          Quiet, don't print detailed info. If you don't use this option
            all these commands dump a lot to the screen.  > is your friend.

--numfiles <dir> <ext>                    = total num of files in <dir>.  <ext> is optional (i.e. "txt")
--unzipall <dir> <dest>                   = Unzips all .zip files in <dir>. <dest> is optional, unzips to there
                                            Unzip always uses "junk" option which means leading paths are stripped
                                            Unzip always uses -u to handle duplicate file names (newer timestamp wins)
--dos2unixall <dir>                       = dos2unix all files in <dir>. Always uses -f (force)
--cpall <source> <dest> <ext>             = copy all files in <source> to <dest>. <ext> is optional (i.e. "txt"), only
                                            matching files are copied
--deleteall <source> <ext>                = delete all files in <source>. <ext> is optional (i.e. "txt"), only
                                            matching files are deleted
--resursiveunzip <dir> <dest>             = Unzips all .zip files in <dir>. <dest> is required, unzips to there
                                            Recursively walks the tree for <dir> and unzips everything it finds.
                                            If a ZIP file contained a ZIP file, continues to unzip.

EOF

}

sub printVersion() {
    my $cwd = getcwd;
    print <<EOF;
tsdtools.pl ($cwd $0)
Technical Software Development tools
Version 1.3.1
by T.S. Davenport (todd.davenport\@yahoo.com)
EOF

}
