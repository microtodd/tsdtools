tsdtools.pl
Technical Software Development tools
Version 1.3
by T.S. Davenport (todd.davenport@yahoo.com)

1. PURPOSE

If you've ever seen the bash message "argument list too long", then this tool might be for you.

(see http://www.linuxjournal.com/article/6060)

2. REQUIREMENTS / PRE-REQUISITES

-Only ever tested on Ubuntu

3. USAGE

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
