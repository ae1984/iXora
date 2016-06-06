/* x-ofcblk.p
 * MODULE
        Управление офицерами Прагмы
 * DESCRIPTION
        Синхронизация сведений о временной блокировке офицеров
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9.1.5.8
 * AUTHOR
        07.05.2004 nadejda
 * CHANGES
        21.07.2004 suchkov добавлена проверка признака увольнения
	28.06.2005 u00121   - при блокировке сотрудника более чем на 30 дней, либо при его увольнении удаляются все права сотрудника , после предварительного вопроса конечно же
*/

{yes-no.i}
def input parameter p-ofc as char.       /* логин офицера на текущей базе */
def input parameter p-ofcfil as char.    /* логин офицера на других базах (у офицеров ЦО на филиалах бывают другие лоигны) */
def input parameter p-fdtold as date.    /* дата начала периода старой блокировки, если меняем период */
def input parameter p-tdtold as date.    /* дата конца периода старой блокировки, если меняем период */
def input parameter p-fdt as date.       /* дата начала периода блокировки */
def input parameter p-tdt as date.       /* дата конца периода блокировки */
def input parameter p-sts as character.  /* статус - b - блокирован, u - уволен, c - очистка статуса увольнения */
def input parameter p-who as character.  /* логин администратора АБПК */
def input parameter p-del as log.        /* признак удаления прав 28.06.2005 u0012*/


case p-sts: 
    when "u" then do:
        find txb.ofcblok where txb.ofcblok.ofc = p-ofc and txb.ofcblok.sts = p-sts no-lock no-error.
        if available txb.ofcblok then return.
        if p-fdt = ? then p-fdt = today.
        if p-tdt = ? then p-tdt = today.
        else do transaction:
            create txb.ofcblok .
            assign txb.ofcblok.ofc = p-ofc
                   txb.ofcblok.sts = "u"
                   txb.ofcblok.rwho = p-who
                   txb.ofcblok.rdt = today
                   txb.ofcblok.fdt = p-fdt
                   txb.ofcblok.tdt = p-tdt.
		
        end. 
	    /*28.06.2005 u00121********************************************************************************************************************************************************************/
		if p-del then 
			run delsecauto(txb.ofcblok.ofc).
	    /*28.06.2005 u00121********************************************************************************************************************************************************************/
        return.
    end.

    when "b" then do:
        find bank.ofcblok where bank.ofcblok.ofc = p-ofc and bank.ofcblok.fdt = p-fdt and bank.ofcblok.tdt = p-tdt no-lock no-error.
        if not avail bank.ofcblok then return.

        /* поискать офицера на филиале - если есть, будем менять */
        find txb.ofc where txb.ofc.ofc = p-ofcfil no-lock no-error.
        if not avail txb.ofc then return.

        do transaction:
          /* удалить запись о старом периоде блокировки */
          find txb.ofcblok where txb.ofcblok.ofc = p-ofcfil and txb.ofcblok.fdt = p-fdtold and txb.ofcblok.tdt = p-tdtold exclusive-lock no-error.
          if avail txb.ofcblok then delete txb.ofcblok.

          /* поискать запись с новым периодом (на всякий случай) */
          find txb.ofcblok where txb.ofcblok.ofc = p-ofcfil and txb.ofcblok.fdt = p-fdt and txb.ofcblok.tdt = p-tdt no-lock no-error.
          if avail txb.ofcblok then return.

          /* создать запись о периоде блокировки */
          create txb.ofcblok.
          buffer-copy bank.ofcblok to txb.ofcblok.
          if p-ofc <> p-ofcfil then txb.ofcblok.ofc = p-ofcfil.
	
	    /*28.06.2005 u00121********************************************************************************************************************************************************************/
		  /*блокировать прова доступа в случае если период блокировки равен или привышает 30 дней*/
	  	  if p-del then 
			run delsecauto(txb.ofcblok.ofc).
	    /*28.06.2005 u00121********************************************************************************************************************************************************************/	
        end.
    end.
   
    when "c" then do:
        for each txb.ofcblok where txb.ofcblok.ofc = p-ofc and txb.ofcblok.sts = "u" .
            do transaction:
                assign txb.ofcblok.ofc = p-ofc
                       txb.ofcblok.sts = "c"
                       txb.ofcblok.rwho = p-who
                       txb.ofcblok.rdt = today
                       txb.ofcblok.fdt = p-fdt
                       txb.ofcblok.tdt = p-tdt.
            end. 
        end.
        return.
    end.

end case. 

