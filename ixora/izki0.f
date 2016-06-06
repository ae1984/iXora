/* izki0.f
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

def var v-mess1 as char initial "PozЁcijas kods " format "x(15)".
def var v-mess2 as char initial " Aile " format "x(6)".
def var v-mess3 as char initial "Kop– " format "x(5)".

form
     v-row0 label "PozЁcijas kods"
     v-col0 label "Aile"
     with frame rc00.
/*
form
    header
	g-comp format "x(40)" skip
	"MёneЅa bilances p–rskats " dames skip
	with frame hfnbd .

form
    header
	g-comp format "x(40)" skip
	dames skip
	"MёneЅa bilances p–rskata "
	"Pielikums" skip
	"Latvijas un –rzemju val­t–s " skip
	with frame hfnbdp .



*/

def var m-key1 as log format "J–/Nё" initial false.
def var v-file as char.
message " S–kt darbu ? "update m-key1.
if not m-key1 then return.
