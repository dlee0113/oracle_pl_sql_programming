             Using the "vim" editor for PL/SQL Programming

INTRODUCTION

As mentioned in Chapter 3, I am a big fan of a free editor known as "vim"
which has broad compatibility with (but many more cool features than) Unix's
"vi."  Vim has both console-based and GUI versions, and it runs on almost
anything.  Its feature list is as long as your arm and if you want it to
do something new, you can program it yourself.

Vim has a dedicated community of developers who contribute files enabling
vim to provide support for their favorite languages.  You guessed it, there
is reasonably good support for PL/SQL.


DOWNLOADING AND INSTALLING THE BASE PACKAGE

You can download and run vim from <http://www.vim.org>

On the download page, you will have a choice as to whether you or not you want
to download the "runtime" files with the core package.  If this is your first
time to install vim, you need both. (FYI, the PL/SQL definition files are part
of the "runtime" package.)

Once you get it downloaded, run the installation per the instructions on the
web page.


GETTING THE LATEST PL/SQL-SPECIFIC FILES

At any given point in time, the official distribution may or may not have
the latest files for PL/SQL.  I have been working with the powers that be
to get some new features in the base distribution, but in the meantime, you
can check here:

   http://plnet.org/files/vim

At the moment, this is the site where I post my versions of the PL/SQL files.

There are actually two files, both named plsql.vim.  One is a file for syntax
highlighting, and the other is for automatic indentation.


INSTALLING A NEW SYNTAX FILE

To install a new syntax file, just rename or delete the old one and copy the
new one into the "syntax" subdirectory of your vim installation (for example,
c:\apps\vim\vim61\syntax\plsql.vim, or /usr/share/vim/vim61/syntax/plsql.vim).


INSTALLING A NEW INDENT FILE AND GETTING VIM TO INDENT/UNINDENT YOUR PL/SQL
AUTOMATICALLY

Installing a new indent file is like installing a syntax file except you're
going to put it in the "indent" subdirectory.  (for example,
c:\apps\vim\vimy61\indent/plsql.vim, or /usr/share/vim/vim61/indent/plsql.vim).

To get automatic PL/SQL indentation to work, though, you also have to run
the "indent" macro.  One way to do this is edit you "vimrc" file and have it
run on vim startup.  On Unix, this file is "$HOME/.vimrc" and on MS Windows it
is in your vim installation as something like "c:\apps\vim\_vimrc".  Here is
what I put in my .vimrc file:

set et
set ts=3
set sw=3
set ai
runtime! indent.vim

This has some other goodies you will want.  "set et" means that vim won't put
tab characters into your file, even if you hit the tab key.  "set ts=3" means
that if you *do* hit the tab key, vim will insert three spaces.  "set sw=3"
means that vim's indentation feature will use 3 spaces when indenting and
unindenting.  "set ai" means that a given line of code should be default align
vertically with the line that precedes it.  And finally "runtime! indent.vim"
means you want to run the "indent.vim" script which will get the automatic
indentation to work.  


GETTING VIM TO RECOGNIZE YOUR SOURCE FILE AS PL/SQL

To get automatic PL/SQL syntax highlighting to work for all files of particular
file extensions, you will probably want to update the file named "filetype.vim"
once you get it installed.  This file is in the root of your vim installation
(c:\apps\vim\vim61\filetype.vim or /usr/share/vim/vim61/filetype.vim).  In my
file I changed the line for PL/SQL from this:
   au BufNewFile,BufRead *.pls,*.plsql             setf plsql
to this:
   au BufNewFile,BufRead *.fun,*.pks,*.pkb,*.sql,*.pls,*.plsql    setf plsql

...and I also commented out the definition line for SQL, because I want all
my SQL files to use the PL/SQL syntax definition.

Another way you can get vim to recognize a particular file as being PL/SQL is
to put a vim-specific comment in the file.  Vim will read the comment and set
the features you request.  For example, you might put the following at the
bottom of a source file:

-- vim: syntax=plsql


TESTING WHETHER IT IS WORKING

To test whether the indentation is working, bring up vim using a command such
as

vim test.plsql

and then (i)nsert into the buffer the following:

BEGIN
NULL;
foo;
END;

As you type, vim should reformat the program as follows:

BEGIN
   NULL;
   foo;
END;

The BEGIN/END should be in one color, NULL should be in another color, and
foo should be in a third color.


Enjoy!

--Bill Pribyl
http://www.datacraft.com


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
