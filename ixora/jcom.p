/* jcom.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        15.07.2005 saltanat - Включила поля пункта тарифа и полного наименования.
        08.11.2006 Natalya D. - поменяла jabre  на jabrw, что бы была сортировка по индексу
*/

/** jcom.p **/


{mainhead.i}

define variable f_title as character.
{jcom.f}

define shared variable set_rec as recid.                           

on help of joucom.comcode in frame fr_com do:
    run help-tarif.
end.

{jabrw.i
&start = "find jouset where recid (jouset) eq set_rec exclusive-lock.
          f_title = jouset.des."
&head = "joucom"
&where = "joucom.comtype eq jouset.proc and joucom.comnat eq jouset.natcur
            and joucom.fname eq jouset.fname "
&index = "comcode_idx" 
&formname = "jcom"
&framename = "fr_com"
&addcon = "true"
&deletecon = "true"
&display = "joucom.comcode joucom.punkt joucom.comdes joucom.comnat joucom.comprim"
&highlight = "joucom.comcode joucom.punkt joucom.comdes joucom.comnat joucom.comprim"
&postadd = "joucom.comnat = yes.
            update joucom.comcode with frame fr_com.
            find tarif2 where tarif2.num + tarif2.kod eq joucom.comcode and tarif2.stat = 'r'.
            joucom.comdes  = tarif2.pakalp.
            joucom.comnat  = jouset.natcur.
            joucom.comtype = jouset.proc.
            joucom.fname   = jouset.fname.
            display joucom.comdes joucom.comnat with frame fr_com.
            update joucom.comprim with frame fr_com."
&prechoose = "message 
'F4 - выход; INSERT,CURSOR-DOWN - добавить; F10 - удалить;  ENTER - коррект.'."
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
                update joucom.comcode with frame fr_com.
                find tarif2 where tarif2.num + tarif2.kod eq joucom.comcode and tarif2.stat = 'r'.
                joucom.comdes  = tarif2.pakalp.
                display joucom.comdes with frame fr_com.
                update joucom.comprim with frame fr_com.
                next upper.
            end. 
            "
&end = "hide frame fr_com.
return.
"  
}


