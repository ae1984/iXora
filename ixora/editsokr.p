/* editsokr.p
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

/* sokrat.p */

{comm-txb.i}
{trim.i}

def shared var g-lang as char.

def var v-type as int no-undo.
def var v-cif like cif.cif.
def var seltxb as int no-undo.

run sel ("Выберите:", "1.  Наименования по клиентам|2.  Сокращения для филиала|3.  Список общих сокращений").
if return-value = "1" then v-type = 1. /* наименования клиентов */
else
if return-value = "2" then v-type = 4. /* филиал */
else
if return-value = "3" then v-type = 3. /* общее + транслит */
else undo, return.

if v-type = 1 then do on endkey undo, leave:
   update v-cif label "Код клиента (ENTER-все клиенты; F2-список)" help ""
   with row 3 centered side-labels frame getCif.
   hide frame getCif.
   if not can-find (cif where cif.cif = v-cif) then v-cif = "".
end.

if (v-type = 2) or (v-type = 3) then seltxb = 0. /* общие */
                                else seltxb = comm-cod(). /* клиенты + филиал */

{jabrw.i
&start     = " "
&head      = "sokrat"
&index     = "txb-type-key"
&formname  = "editsokr"
&framename = "sokrat"
&where     = " sokrat.txb = seltxb and sokrat.type = v-type and (v-cif = """" or sokrat.key = v-cif) "
&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = " sokrat.txb  = seltxb. sokrat.type = v-type. "
&update = " sokrat.key sokrat.full "
&prechoose = " message 'F4-Выход, INS-вставка, F10-удаление'. "
&predisplay = " "
&display = " sokrat.key sokrat.full "
&highlight = " sokrat.key sokrat.full "
&predelete = " "
&postupdate   = " sokrat.teng = GPSTrim(GEnglish(sokrat.full)). " 
&end = "hide frame sokrat."
}

hide message. pause 0.

for each sokrat where key = "": 
    delete sokrat. 
    end.

