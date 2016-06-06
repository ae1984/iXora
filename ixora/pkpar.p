/* pkpar.p
 * MODULE
        ПотребКредиты
   Редактирование критериев анкеты
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
        31/12/99 Марина Андрусенко
 * CHANGES
        26.05.2003 Надежда Лысковская - добавлено значение по умолчанию pkkrit.res[2]
        24.05.2004 nadejda - вывод в файл в той же форме, что и на экран
        06.05.2005 marinav - добавлены поля rating_yc rating_nc
        23/09/2005 madiar - перекомпиляция
        31/10/2005 madiar - добавил поле "Источник анкеты"
        19/04/2006 NatalyaD. - перекомпиляция
*/


{mainhead.i}
{pk.i new}

pause 0.
define variable s_rowid as rowid.
/*def var v-title as char init "КРИТЕРИИ ОЦЕНКИ РЕЙТИНГА КЛИЕНТА".
&start     = "displ v-title format 'x(50)' at 14 with row 4 no-box no-label frame pkheader."
*/

{jabrw.i 
&head      = "pkkrit"
&headkey   = "kritcod"
&index     = "kritcod"

&formname  = "pkpar"
&framename = "pkkri"
&where     = "true"

&addcon    = "true"
&deletecon = "true"
&postcreate = " pkkrit.proc = 'pkrat'. "
       
&prechoose = " hide message. message 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать'."
&postdisplay = " "

&display   = " pkkrit.ln pkkrit.kritcod pkkrit.kritname pkkrit.krittype pkkrit.priz
     pkkrit.credtype pkkrit.rating_y pkkrit.rating_n "
&update    = " pkkrit.ln pkkrit.kritcod pkkrit.kritname pkkrit.krittype pkkrit.priz
     pkkrit.credtype pkkrit.rating_y pkkrit.rating_n "
&postupdate = " if pkkrit.kritaki = '' then do: v-akiin = ''. v-akiout = ''. end.
                else do: v-akiin = entry(1, pkkrit.kritaki, '|').
                  if num-entries(pkkrit.kritaki, '|') >= 2 then
                    v-akiout = entry(2, pkkrit.kritaki, '|'). else v-akiout = ''. end.

                if new pkkrit and pkkrit.procval = '' and pkkrit.krittype <> 'c' then pkkrit.procval = 'val-krtype'.

                update pkkrit.rating_yc[1] pkkrit.rating_nc[1] pkkrit.rating_yc[2] pkkrit.rating_nc[2] pkkrit.res[2] pkkrit.res[1] pkkrit.procval pkkrit.kritspr pkkrit.proc pkkrit.res[3]
                with scrollable frame pkkri1 .
                hide frame pkkri1 no-pause.
                if v-akiin = '' and v-akiout = '' then pkkrit.kritaki = ''.
                else pkkrit.kritaki = trim(v-akiin) + '|' + trim(v-akiout). "
            
&highlight = " pkkrit.ln pkkrit.kritcod "

&postkey   = " else if keyfunction(lastkey) = 'P' then
                      do:
                         s_rowid = rowid(pkkrit).
                         output to pkdata.img .
                         for each pkkrit no-lock:
                             display pkkrit.ln pkkrit.kritcod pkkrit.kritname pkkrit.krittype pkkrit.priz
     pkkrit.credtype pkkrit.rating_y pkkrit.rating_n with frame pkkri.
                             down 1 with frame pkkri.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('pkdata.img').
                         find pkkrit where rowid(pkkrit) = s_rowid no-lock.
                      end. "

&end = "hide all no-pause."
}
hide message.
