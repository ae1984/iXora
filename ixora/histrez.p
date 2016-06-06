/* histrez.p
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
        16/03/04 nataly изменена структура и данные в таблице aad (за одно число может быть нес-ко записей- доп взносов)
*/


def input parameter vaaa like aaa.aaa.
def shared var g-lang as char.

def temp-table baab 
     field aaa like aab.aaa
     field fdt like aab.fdt
     field bal like aab.bal
     field rate like aab.rate
       index aaa aaa.

find aaa where aaa.aaa = vaaa no-lock.
 create baab. 
 find first aab where aab.aaa = aaa.aaa no-lock no-error.
 if avail aab  then do:
  baab.aaa = aab.aaa. 
  baab.fdt = aab.fdt. baab.bal = aab.bal.
  baab.rate = aab.rate.
 end.
 else do:
  baab.aaa = aaa.aaa. 
  baab.fdt = aaa.regdt. baab.bal = aaa.opnamt.
  baab.rate = aaa.rate.
 end.

for each aad where aad.aaa = vaaa.
 if aad.cam = aad.dam then next.
create baab. 
 baab.aaa = aad.aaa. baab.bal = aad.cam - aad.dam.
 baab.fdt = aad.regdt.  baab.rate = aad.rate. 
end.

{jabro.i
&start = " "
&head = "baab"
&headkey = "aaa"
&where = "baab.aaa = vaaa"
&index = "aaa"
&formname = "histrez"
&framename = "aab"
&addcon = "false"
&deletecon = "false"
&viewframe = " "
&predisplay = " "
&display = "baab.fdt baab.bal baab.rate"
&highlight = "baab.fdt"
&predelete = " "
&precreate = " "
&postadd = " "
&prechoose = " "
&postdelete = " "
&postkey = " "
&end = "hide frame aab. hide message."
}
