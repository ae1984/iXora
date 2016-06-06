/* pkpartns.p
 * MODULE
        ПОТРЕБКРЕДИТ
 * DESCRIPTION
        Редактирование справочника предприятий-партнеров
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
        11.03.2003 nadejda
 * CHANGES
        28.01.2004 sasco можно вводить несколько видов кредита
        03.02.2004 sasco ввод %% вознаграждения
*/


{mainhead.i}
{pk.i new}
/*
s-credtype = "1".
*/
define variable s_rowid as rowid.
def var v-title as char init "ПРЕДПРИЯТИЯ-ПАРТНЕРЫ ПО КРЕДИТОВАНИЮ ФИЗЛИЦ".
def new shared var v-codif as char init "pkpartn".
def var v-ct as char.
define variable ni as integer.


{jabrw.i 
&start     = "displ v-title format 'x(50)' at 16 with row 4 no-box no-label frame pkheader."
&head      = "codfr"
&headkey   = "code"
&index     = "codfr"

&formname  = "pkpartns"
&framename = "fed"
&where     = " codfr.codfr = v-codif and codfr.code <> 'msc' "

&addcon    = "true"
&deletecon = "true"
&postcreate = "codfr.codfr = v-codif. codfr.level = 1. codfr.name[5] = '2'. "
&prechoose = "displ 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать' 
  with centered row 22 no-box frame pkfooter.
  on help of codfr.name[5] in frame fed do: v-ct = codfr.name[5]. run uni_book ('credtype', '*', output v-ct). 
  codfr.name[5] = v-ct. frame-value = codfr.name[5]. end. " 

/*  codfr.name[5] = entry(1, v-ct). frame-value = codfr.name[5]. end. " */

&predisplay = " /*
                if codfr.name[5] <> '' then 
                do:
                  v-ctname = ''.
                  do ni = 1 to num-entries (codfr.name[5]):
                    find bookcod where bookcod.bookcod = 'credtype' and bookcod.code = entry (ni,codfr.name[5]) no-lock no-error.
                    v-ctname = v-ctname + ',' + bookcod.name.
                  end.
                  v-ctname = substr(v-ctname, 2).
                end. else v-ctname = ''. 
                */
                
                if codfr.name[3] <> '' then v-ctname = DECIMAL (codfr.name[3]).
                                       else v-ctname = 0.0.

                v-intext = (codfr.name[4] = ''). "

&display   = " codfr.code codfr.name[1] v-intext codfr.name[5] v-ctname "

&highlight = " codfr.code codfr.name[1] v-intext codfr.name[5] v-ctname "
&preupdate = " v-intext = (codfr.name[4] = ''). "
&update   = " codfr.code codfr.name[1] v-intext codfr.name[5] v-ctname "
&postupdate = " if codfr.code entered then do: 
                  codfr.codfr = v-codif. codfr.level = 1. 
                  codfr.tree-node = codfr.codfr + CHR(255) + codfr.code. 
                end.
/*
                if codfr.name[5] <> '' then 
                do:
                  v-ctname = ''.
                  do ni = 1 to num-entries (codfr.name[5]):
                    find bookcod where bookcod.bookcod = 'credtype' and bookcod.code = entry (ni,codfr.name[5]) no-lock no-error.
                    v-ctname = v-ctname + ',' + bookcod.name.
                  end.
                  v-ctname = substr(v-ctname, 2).
                end. else v-ctname = ''.
                displ v-ctname with frame fed. 
*/

                if v-ctname > 0.0 then codfr.name[3] = string (v-ctname).
                                  else codfr.name[3] = ''.

                if v-intext then codfr.name[4] = ''. else run pkpartnext (codfr.code, output codfr.name[4]). "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(codfr).
                         output to pkpartn.img .
                         for each codfr where codfr.codfr = v-codif no-lock:
                             display codfr.code codfr.name[1] codfr.name[5].
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('pkpartn.img').
                         find codfr where rowid(codfr) = s_rowid no-lock.
                      end. "

&end = "hide frame fed no-pause. hide frame pkheader no-pause. hide frame pkfooter no-pause."
}
hide message no-pause.


