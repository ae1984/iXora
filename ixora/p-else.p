/* p-else.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/


def shared var s-fproc as int .
def var  fdoc as cha .
def buffer  b-fproc for fproc .
def var ll  as cha .
def var n1  as int .
def var n2  as int .
def var i as int .

ll =
"============================================================================".
find first fproc where recid(fproc) = s-fproc .
find first sysc where sysc.sysc = "PSDOC" no-lock no-error .


	    if keylabel(lastkey) = "1" and avail sysc then
	     do:
	      fdoc = sysc.chval + "/" + caps(fproc.sname) + ".fin"  .
	      unix value("joe " + fdoc ) .
	     end.
	     else
	     if keylabel(lastkey) = "2" and avail sysc then
	     do:
	      fdoc = sysc.chval + "/" + caps(fproc.sname) + ".wrk"  .
	      unix value("joe " + fdoc ) .
	     end.
	     else
	     if keylabel(lastkey) = "3" and avail sysc then
	     do:
	      fdoc = sysc.chval + "/" + caps(fproc.sname) + ".rcs"  .
	      unix value("joe " + fdoc ) .
	     end.
	     else
	     if keylabel(lastkey) = "4" and avail sysc then
	     do:
	      fdoc = sysc.chval + "/" + "concept.txt"  .
	      unix value("joe " + fdoc ) .
	     end.
	     else
	     if keylabel(lastkey) = "5" and avail sysc then
	     do:
	       display " W A I T ... " with centered frame www . pause 0 .
	       unix silent value("echo ''  > tmp.doc ").
	      for each b-fproc :
	       fdoc = sysc.chval + "/" + caps(b-fproc.sname) + ".wrk"  .
	       if search(fdoc) ne ? then do:
		unix silent value("echo  " + fdoc + " >> tmp.doc " ) .
		unix silent value("cat " + fdoc + " >> tmp.doc " ) .
		unix silent value("echo " + ll + " >> tmp.doc " ) .
		end .
	      end .
	      hide frame www .
	      unix value("ps_less tmp.doc " ) .
	     end.
	     else
	     if keylabel(lastkey) = "6" and avail sysc then
	     do:
	       display " W A I T ... " with centered frame www1 . pause 0 .
	       unix silent value("echo ''  > tmp.doc ").
	      for each b-fproc :
	       fdoc = sysc.chval + "/" + caps(b-fproc.sname) + ".rcs"  .
	       if search(fdoc) ne ? then do:
		unix silent value("cat " + fdoc + " >> tmp.doc " ) .
		end .
	      end .
	      hide frame www1 .
	      unix value("ps_less tmp.doc " ) .
	     end.
	     else
	     if keylabel(lastkey) = "7" and avail sysc then
	     do:
	      run docprt .
	     end .
	     else
	     if keylabel(lastkey) = "8" and avail sysc then
	    do:
	     do on endkey undo,leave :
	     update
	      " Print from : " n1  " Print to   : " n2
	      with centered  row 2 no-box no-label frame ss .
	    end .

  /*  display keyfunction(lastkey).   */
	   hide frame ss .
	   if keyfunction(lastkey)  = "End-Error"  then
	    do: undo . pause 0 .
	    return  .  end .

	   display " Printing  ... " with centered frame p1  .  pause 0 .

	   unix  silent value(
	   "awk -v p0=""System DOC Page " + string(n1) +
	   " -"" -v p1=""System DOC Page " + string(n2 + 1) +
	   " -"" '\{ if (index($0,p0) != 0 ) \{t = 1 \} ;" +
	   "if (index($0,p1) != 0 ) \{t = 0\}; if ( t == 1 ) " +
	   "\{print ps \} ; if ( t == 0 && index($0,""\f"") != 0 ) " +
	   "\{ ps = substr($0,2,80 )  \} else \{ ps = $0 \} \} " +
	   "END \{print ""\\f""\} ' " +
	   sysc.chval + "/ALL_PS.doc > tmp.prt  " ) .
	   hide frame p1.
	   unix  silent value ( " print  tmp.prt" )  .
	   end .
	     else
	     if keylabel(lastkey) = "9" and avail sysc then
	     do:
	      fdoc = sysc.chval + "/" + "contents.txt"  .
	      unix value("joe " + fdoc ) .
	     end.
