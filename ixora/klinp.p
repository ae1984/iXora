/* klinp.p
 * MODULE
        СПРАВОЧНИКИ
 * DESCRIPTION
	Синхронизация справочника банков головного банка с филиалами
 * RUN
	{r-branch.i &proc = klinp}	
 * CALLER
        Список процедур, вызывающих этот файл
	spbank.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	07.03.2004 - sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
	10.08.2004 - suchkov - добавил пару проверок для подстраховки.
	05.05.2005 - u00121 полная смена алгоритма 
	23.06.2005 - u00121 ТЗ ї 47 от 08.06.2005 введен стату банка: 0 - открыт; 1 - открыт, закрыты активные операции; 2 - закрыт.
*/


def shared temp-table t-bankl /*временная таблица формируется в программе spbank.p сразу после обновления справочника банков*/
	field bank like txb.bankl.bank
	field acct like txb.bankl.acct
	field name like txb.bankl.name
	field crbank like txb.bankl.crbank
	field addr like txb.bankl.addr
	field mntrm like txb.bankl.mntrm
	field nu like txb.bankl.nu
	field attn like txb.bankl.attn
	field tel like txb.bankl.tel
	field fax like txb.bankl.fax
	field tlx like txb.bankl.tlx
	field bic like txb.bankl.bic
	field fid like txb.bankl.fid
	field stn like txb.bankl.stn
	field frbno like txb.bankl.frbno
	field sts like txb.bankl.sts /*u00121 23.06.2005 ТЗ ї 47 от 08.06.2005*/ .

/*код головного банка **************************************************/
find txb.sysc where txb.sysc.sysc = "clcen" no-lock no-error .
if not avail txb.sysc or txb.sysc.chval = "" then do:
	Message " This isn't record CLEARING in sysc file !!".
	pause.
	return .
end.

/*****Удаляем старые БИКи******************************************************************/
for each txb.bankl where txb.bankl.bank begins "19".
    delete txb.bankl.
end. 
for each txb.bankt where txb.bankt.cbank begins "19".
    delete txb.bankt.
end. 

for each t-bankl  no-lock. 
	find first txb.bankl where txb.bankl.bank = t-bankl.bank exclusive-lock no-error. /*есть ли банк в справочнике филиала?*/
	if avail txb.bankl then
	do: /*если есть то обновляем соответсвующие поля*/
		txb.bankl.bank   = t-bankl.bank. /*БИК банка*/
		txb.bankl.name   = t-bankl.name. /*Название банка*/
		txb.bankl.crbank = t-bankl.crbank. /*признак работы по клирингу "clear"*/
		txb.bankl.mntrm  = t-bankl.mntrm. /*Код терминал*/
		txb.bankl.frbno  = t-bankl.frbno. /*Страна*/
		txb.bankl.sts    = t-bankl.sts. /*Статус банка u00121 23.06.2005 ТЗ ї 47 от 08.06.2005*/
		if not txb.bankl.acct begins "TXB" then
			txb.bankl.acct = t-bankl.acct. /*Код терминала клиринговой организации, для наших филиалов всегда равен код головного банка в АБПК ПРАГМА (TXB00)*/
	end.
	else
	do: /*если банка в справочнике не наблюдается, создаем его*/
		create txb.bankl.
			txb.bankl.bank   = t-bankl.bank.
			txb.bankl.name   = t-bankl.name.
			txb.bankl.crbank = t-bankl.crbank.
			txb.bankl.mntrm  = t-bankl.mntrm.
			txb.bankl.nu 	 = t-bankl.nu.
			txb.bankl.addr[1] = t-bankl.addr[1].
			txb.bankl.addr[2] = t-bankl.addr[2].
			txb.bankl.addr[3] = t-bankl.addr[3].			
			txb.bankl.attn   = t-bankl.attn.
			txb.bankl.tel    = t-bankl.tel.
			txb.bankl.fax    = t-bankl.fax.
			txb.bankl.tlx    = t-bankl.tlx.
			txb.bankl.bic    = t-bankl.bic.
			txb.bankl.stn    = t-bankl.stn.
         		txb.bankl.frbno  = t-bankl.frbno. /*Страна*/
			txb.bankl.fid    = t-bankl.fid.
			txb.bankl.cbank  = txb.sysc.chval. /*для филиалов кор счет всегда равен код головного банка принятый в АБПК ПРАГМА, на текущий момент (05.05.2005) равен TXB00*/
			txb.bankl.sts    = t-bankl.sts. /*u00121 23.06.2005 ТЗ ї 47 от 08.06.2005*/
	end.
	release txb.bankl.
end.

