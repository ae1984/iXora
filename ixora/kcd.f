/* kcd.f
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

def var m-key1 as log format "J–/Nё" initial false.
message " S–kt darbu ? "update m-key1.
if not m-key1 then return.

update
v-row0 label "PozЁcijas kods " format "999"
v-col0 label "Aile " format "9"
with frame rc 1 column title "P–rskats".


def var v-mess1 as char initial "PozЁcijas kods " format "x(15)".
def var v-mess2 as char initial " Aile " format "x(6)".
def var v-mess3 as char initial "Kop– " format "x(5)".

form
    header
	g-comp format "x(40)" skip
	"KredЁta ceturkЅna p–rskats " dames skip
	with frame hfnbd .
