/* io-chpext.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Формирование выписок для корпоративных клиентов интернет-банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        COMM TXB
 * AUTHOR
         26.07.2010 k.gitalov
 * CHANGES
         16.05.2011 k.gitalov добавил возврат наименования клиента и рнн
         24/04/2012 evseev  - rebranding.БИК из sysc cleocod
         25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

define input param pCif as char.
define input param pAccount as char.
define input param pFromDate as date.
define input param pToDate as date.
define input param g_date as date.
define output param pUsr_name as char.
define output param pUsr_rnn as char.

def buffer b-cashpool for comm.cashpool.
def buffer b-cashpoolfill for comm.cashpool.

{nbankBik-txb.i}

def shared temp-table extract
             field ext_account as char     /*счет клиента*/
             field sender_account as char  /*счет отправителя*/
             field sender_bic as char      /*Бик банка отправителя*/
             field income as deci          /*Входящий остаток*/
             field outcome as deci         /*Исходящий остаток*/
             field oper_code as char       /*номер платежа*/
             field oper_date as date       /*Дата проведения платежа*/
             field num_doc as char         /*номер платежного поручения*/
             field deal_code as char       /*идентификатор документа rmz или jou*/
             field date_doc as date        /*дата создания документа*/
             field date_val as date        /*дата валютирования или дата проводки*/
             field plat_value as int       /*Признак исход-й или входящий платеж (0-исходящий 1-входящ)*/
             field name as char            /*Название получателя или отправителя если платеж входящий*/
             field account as char         /*счет получателя*/
             field debit as deci           /*сумма по дебету*/
             field credit as deci          /*сумма по кредиту*/
             field currency_code as char   /*код валюты платежа (KZT, USD, EUR, RUR)*/
             field knp as char             /*код назначения платежа*/
             field knp_name as char        /*Название кода  назначения платежа*/
             field bank_bic as char        /*бик банка получателя*/
             field bank_name as char       /*Наименование банка получателя*/
             field payment_details as char /*Детали платежа*/
             field create_time as int.     /*Время создания проводки*/

/*
           create extract.
              extract.ext_account = "KZ08470172203A018900".
             extract.sender_account = "KZ758215235555552500".
             extract.sender_bic = "45770".
              extract.income = 1000000.90.
              extract.outcome = 1111111.00.
              extract.oper_code = "23523".
             extract.oper_date = today.
              extract.num_doc = "235".
              extract.deal_code = "RMZ000354A".
              extract.date_doc = today.
             extract.date_val =  today.
             extract.plat_value = 0.
             extract.name = "Иванов И.И. ИП ".
             extract.account = "123456789012".
              extract.debit = 1111.11.
              extract.credit = 0.00.
             extract.currency_code = "KZT".
             extract.knp = "911".
             extract.knp_name = "Прочее".
             extract.bank_bic = "190501832".
             extract.bank_name = "АО \"СИТИБАНК\"".
              extract.payment_details = "УСЛУГИ ПО ДОСТАВКЕ 3 ОТ 31/03/08В Т.Ч.НДС (13%) - 252-72".
              extract.create_time = time.
*/

def buffer b-cif2 for txb.cif.
find b-cif2 where b-cif2.cif = pCif no-lock no-error.
if available b-cif2 then do:
   pUsr_name =  trim(trim(b-cif2.prefix) + " " + trim(b-cif2.name)).
   pUsr_rnn = b-cif2.jss .
end.
else do:
   pUsr_name = "NO NAME".
   pUsr_rnn = "NO RNN".
end.
/**********************************************************************************************************************/
function GetName returns char ( input AccNo as char):
       def buffer b-aaa for txb.aaa.
       def var Ret as char.
       find b-aaa where b-aaa.aaa = AccNo no-lock no-error.
       if not available b-aaa then
       do:
         def buffer b-arp for txb.arp.
         find b-arp where b-arp.arp = AccNo no-lock no-error.
         if avail b-arp then Ret = b-arp.des.
         else do:
          def buffer b-gl for txb.gl.
          find b-gl where b-gl.gl = integer(AccNo) no-lock no-error.
          if avail b-gl then Ret = b-gl.des.
          else Ret = "Not found ARP or GL name".
         end.
       end.
       else do:
          def buffer b-cif for txb.cif.
          find b-cif where b-cif.cif eq b-aaa.cif no-lock no-error.
          if not available b-cif then
          do:
              Ret = "No CIF Name".
          end.
          else do:
                Ret = trim(trim(b-cif.prefix) + " " + trim(b-cif.name)).
          end.
       end.
       return trim(Ret).
end function.
/**********************************************************************************************************************/
function GetKnpName returns char (input Knp as char):
     def buffer b-codfr for txb.codfr.
     def var Ret as char.
     find b-codfr where b-codfr.code = Knp and b-codfr.codfr = 'spnpl' and b-codfr.child = false and b-codfr.code <> 'msc' no-lock no-error.
     if avail b-codfr then Ret = b-codfr.name[1].
     else Ret = "".
     return trim(Ret).
end function.
/**********************************************************************************************************************/
function CrcCode returns char (input crc as int):
   def buffer b-crc for txb.crc.
   find last b-crc where b-crc.crc = crc no-lock no-error.
   if avail b-crc then return trim(b-crc.code).
   else return "XXX".
end function.
/**********************************************************************************************************************/
function CreateRec returns int ( input iCif as char, input iAcc as char):
   def buffer b-jl for txb.jl.
   def buffer b-jh for txb.jh.
   def var i as int.
   def var v-rem as char.
   def var sm as deci.
   def var sm1 as deci.

   run lonbal3('cif', iAcc, pFromDate - 1, "1", yes, output sm).
   run lonbal3('cif', iAcc, pToDate , "1", yes, output sm1).

   for each b-jl where b-jl.jdt >= pFromDate and b-jl.jdt <= pToDate and b-jl.acc = iAcc and b-jl.lev = 1 no-lock:
     if b-jl.lev <> 1 then next.
     if b-jl.rem[1] begins "O/D PROTECT" or b-jl.rem[1] begins "O/D PAYMENT" then next.

     create extract.

     extract.oper_code = string(b-jl.jh).
     extract.date_doc  = b-jl.jdt.
     extract.debit     = b-jl.dam.
     extract.credit    = b-jl.cam.
     extract.currency_code = CrcCode(b-jl.crc).
     extract.ext_account = iAcc.
     extract.income     = sm.
     extract.outcome    = sm1.

     if extract.debit > 0 then extract.plat_value = 0. /* Исходящий */
     else extract.plat_value = 1.                      /* Входящий  */

     /******************************************************/
     v-rem = b-jl.rem[1].
     do i = 1 to 5:
        if trim(b-jl.rem[i]) <> '' and trim(b-jl.rem[i]) <> trim(v-rem) then do:
            if v-rem <> '' then v-rem = v-rem + ''.
            v-rem = v-rem + b-jl.rem[i].
        end.
     end.
     extract.payment_details = v-rem.
     /******************************************************/

     find first b-jh where b-jh.jh = b-jl.jh no-lock no-error.
     if avail b-jh then do:


       extract.deal_code = b-jh.ref.
       extract.create_time = b-jh.tim.

       case b-jh.sub:
        when "RMZ" then do:
                find first txb.remtrz where txb.remtrz.remtrz = b-jh.ref no-lock no-error.
                if avail txb.remtrz then
                do:
				  find last netbank where netbank.rmz = txb.remtrz.remtrz and netbank.cif = iCif no-lock no-error.
				  if avail netbank then do:
				     extract.num_doc = netbank.rem[2].
				  end.
				  else  extract.num_doc = string(trim( substring( remtrz.sqn,19,8 )) ).



				  /****************************/
				  if extract.plat_value = 0 then  /*0-исходящий 1-входящ*/
                  do:
                    if txb.remtrz.bn[1] <> ? then extract.name = trim(txb.remtrz.bn[1]).
                    if txb.remtrz.bn[2] <> ? then extract.name = extract.name + " " + trim(txb.remtrz.bn[2]).
                    if txb.remtrz.bn[3] <> ? then extract.name = extract.name + " " + trim(txb.remtrz.bn[3]).

                    extract.bank_bic = txb.remtrz.rbank.
                    if txb.remtrz.bb[1] = "NONE" then do:
                      find first txb.bankl where txb.bankl.bank = txb.remtrz.rbank no-lock no-error.
                      if avail txb.bankl and txb.bankl.name <> "" then extract.bank_name = trim(txb.bankl.name).
                    end.
                    else extract.bank_name = trim(txb.remtrz.bb[1]) + " " + trim(txb.remtrz.bb[2]) + " " + trim(txb.remtrz.bb[3]).

                    extract.sender_account = trim(txb.remtrz.sacc).
                    extract.sender_bic = v-clecod.

                  end.
                  else do:
                    extract.name = txb.remtrz.ord.
                    find first txb.bankl where txb.bankl.bank = txb.remtrz.rbank no-lock no-error.
                    if avail txb.bankl and txb.bankl.name <> "" then
                    do:
                      extract.bank_name = trim(txb.bankl.name).
                      extract.bank_bic = v-clecod.
                    end.

                    extract.sender_account = trim(txb.remtrz.sacc).

                    if index(txb.remtrz.sbank,"TXB") = 0 then extract.sender_bic = txb.remtrz.sbank.
                    else extract.sender_bic = v-clecod.

                  end.
                  /****************************/



				  extract.account = trim(txb.remtrz.ba).

				  extract.date_val = txb.remtrz.valdt2.

				  extract.oper_date = txb.remtrz.valdt1.

				  extract.date_doc = txb.remtrz.rdt.

				  find txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = 'rmz' and txb.sub-cod.d-cod = 'eknp' and txb.sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
                  if avail txb.sub-cod then
                  do:
                    extract.knp = entry(3,txb.sub-cod.rcode,',').
                    extract.knp_name = GetKnpName(extract.knp).
                  end.
                  else do:
                    extract.knp = "979".  /* пока поставил Прочее */
                    extract.knp_name = GetKnpName(extract.knp).
                  end.
                end.

        end.
        when "JOU" then do:
           /*номер платежного поручения*/
           find first txb.joudoc where txb.joudoc.docnum = b-jh.ref no-lock no-error.
           if avail txb.joudoc then extract.num_doc = txb.joudoc.num.
           if extract.num_doc = "" then extract.num_doc = string(b-jl.jh).

            extract.oper_code = string(b-jl.jh).  /*номер платежа*/
            extract.deal_code = b-jh.ref. /*идентификатор документа rmz или jou*/
            find first txb.joudoc where txb.joudoc.docnum = b-jh.ref no-lock no-error.
            if avail txb.joudoc then
            do:

               /****************************/
				  if extract.plat_value = 0 then  /*0-исходящий 1-входящ*/
                  do:
                    extract.sender_account = txb.joudoc.cracc.
                    extract.account = txb.joudoc.dracc.
                    extract.name = GetName(extract.account).

                  end.
                  else do:
                    extract.sender_account = txb.joudoc.dracc.
                    extract.account = txb.joudoc.cracc.
                    extract.name = GetName(extract.sender_account).

                  end.
                  /****************************/
                  find first txb.bankl where txb.bankl.bank = b-cashpool.txb no-lock no-error.
                  if avail txb.bankl then extract.bank_name = txb.bankl.name.
                  else extract.bank_name = v-nbankru.
                  extract.sender_bic = v-clecod.
                  extract.bank_bic = v-clecod.
                  if extract.sender_account = "" then extract.sender_account = string(b-jl.gl).
                  if extract.account = "" then extract.account = string(b-jl.gl).

                  find txb.sub-cod where txb.sub-cod.acc = txb.joudoc.docnum and txb.sub-cod.sub = 'jou' and txb.sub-cod.d-cod = 'eknp' and txb.sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
                  if avail txb.sub-cod then
                  do:
                    extract.knp = entry(3,txb.sub-cod.rcode,',').
                    extract.knp_name = GetKnpName(extract.knp).
                  end.
                  else do:
                    extract.knp = "979".  /* пока поставил Прочее */
                    extract.knp_name = GetKnpName(extract.knp).
                  end.

                  extract.date_val = extract.date_doc.
                  extract.oper_date = extract.date_val.
            end.

        end.
        otherwise do:
                find last netbank where netbank.rmz = b-jh.ref and netbank.cif = iCif  no-lock no-error.
                if avail netbank then extract.num_doc = netbank.rem[2].
                else extract.num_doc =  string(b-jl.jh).

                extract.deal_code = string(b-jl.jh).

                find first txb.bankl where txb.bankl.bank = b-cashpool.txb no-lock no-error.
                if avail txb.bankl then extract.bank_name = txb.bankl.name.
                else extract.bank_name = v-nbankru.
                extract.bank_bic = v-clecod.
                extract.sender_bic = v-clecod.

                if extract.plat_value = 0 then  /*0-исходящий 1-входящ*/
                do:
                   extract.sender_account = b-jl.acc.
                   extract.account = string(b-jl.gl).
                   extract.name = GetName(extract.account).
                end.
                else do:
                   extract.sender_account = string(b-jl.gl).
                   extract.account = b-jl.acc.
                   extract.name = GetName(extract.sender_account).
                end.

                extract.knp = "979".  /* пока поставил Прочее */
                extract.knp_name = GetKnpName(extract.knp).
                extract.date_val = extract.date_doc.
                extract.oper_date = extract.date_val.
        end.
       end. /* case */



     end. /* if avail b-jh*/

   end. /*for each b-jl*/
  return 0.
end function.
/**********************************************************************************************************************/

      if pAccount = "" then  /* Все счета ГО */
      do:
           find first b-cashpool where b-cashpool.cif = pCif and b-cashpool.isgo = true no-lock no-error.
		   if avail b-cashpool then
		   do:
		      CreateRec( b-cashpool.cif, b-cashpool.acc).
		      for each b-cashpoolfill where b-cashpoolfill.cifgo = b-cashpool.cif and b-cashpoolfill.isgo = false and b-cashpoolfill.txb = b-cashpool.txb no-lock:
		        CreateRec(b-cashpoolfill.cif, b-cashpoolfill.acc).
		      end.
		   end.
      end.
      else do:
           find first b-cashpool where b-cashpool.acc = pAccount no-lock no-error.
           if avail b-cashpool then  CreateRec(b-cashpool.cif,pAccount).
           else CreateRec(pCif,pAccount).
      end.

/**********************************************************************************************************************/

procedure lonbal3.

define input  parameter p-sub like txb.trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like txb.jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def buffer b-aaa for txb.aaa.
def var i as integer.

res = 0.

if p-dt > g_date then p-dt = g_date. /*return.*/

if p-includetoday then do: /* за дату */
  if p-dt = g_date then do:
     for each txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc no-lock:
         if lookup(string(txb.trxbal.level), p-lvls) > 0 then do:

            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.trxbal.dam - txb.trxbal.cam.
	    else res = res + txb.trxbal.cam - txb.trxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

	    /* ------------------------------------------------------------ */
/*	    for each txb.jl where txb.jl.acc = p-acc
                          and txb.jl.jdt >= p-dt
                          and txb.jl.lev = 1 no-lock:
	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res - txb.jl.dam + txb.jl.cam.
            else res = res + txb.jl.dam - txb.jl.cam.
            end. */

         end.
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        find last txb.histrxbal where txb.histrxbal.subled = p-sub
                              and txb.histrxbal.acc = p-acc
                              and txb.histrxbal.level = integer(entry(i, p-lvls))
                              and txb.histrxbal.dt <= p-dt no-lock no-error.
        if avail txb.histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
	    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

        end.
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = integer(entry(i, p-lvls))
                                 and txb.histrxbal.dt < p-dt no-lock no-error.
       if avail txb.histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
	    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

       end.
   end.
end.



end.


