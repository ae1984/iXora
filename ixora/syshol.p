/* syshol.p
 * MODULE
	Администрирование АБПК
 * DESCRIPTION
	Настройка праздничных дней 
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
	12-1-2-1
 * AUTHOR
        31/12/99 pragma
 * BASES
	BANK
	COMM
 * CHANGES
	03/05/06 u00121	-	Добавил в обработку поле hol.stn, сделал синхронизацию изменений справочника по филиалам, вносить изменения в справочник теперь можно только с центрального офиса (Алматы)
*/

/*03/05/06 u00121**********************************************************************************************************************************/
find last sysc where sysc.sysc = 'OURBNK' no-lock no-error.
if avail sysc and sysc.chval <> 'TXB00' then
do:
	find last cmp no-lock no-error.
	if avail cmp then
		message "Изменение справочника возможно только из базы данных Алматы!" skip 
			"Текущий филиал : " cmp.name view-as alert-box.
	return.
end.
/*03/05/06 u00121**********************************************************************************************************************************/

def shared var g-lang as char.

def var v-change as log init false no-undo. /*03/05/06 u00121 если значение изменено на true, значит вносились изменения в справочник - нужно синхронизировать*/

{apbra.i

&start     = " "
&head      = "hol"
&headkey   = "hol"
&index     = "hol"

&formname  = "hol"
&framename = "hol"
&where     = "true"

&addcon    = "true"
&deletecon = "true"
&postdelete = "v-change = true. " /*03/05/06 u00121*/
&precreate = " "


&postadd   = " update hol.hol hol.name hol.stn
                      with frame hol.
		if hol.hol entered or hol.name entered  or hol.stn entered  then /*03/05/06 u00121*/
			v-change = true."
&prechoose = " message 'F4-выход,INS-дополн.,F10-удалить'. "
&display   = " hol.hol  hol.name hol.stn"

&highlight = " hol.hol hol.name hol.stn"


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
            then do transaction on endkey undo, leave:
            update hol.hol hol.name hol.stn with frame hol.
            end.
		if hol.hol entered or hol.name entered  or hol.stn entered  then /*03/05/06 u00121*/
			v-change = true.
		"

&end = "hide frame hol."
}
hide message.



if keyfunction(lastkey) = "end-error" and v-change then /*03/05/06 u00121*/
do:
	{r-branch.i &proc = synchol.p}
end.


