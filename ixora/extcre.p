/* extcre.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        31/05/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        27/04/2012 evseev  - повтор
        12.02.2013 damir   - Внедрено Т.З. № 1698.
*/

{classes.i}
{nbankBik.i}
{sysc.i}


define input param pCif as char.
define input param pAccount as char.
define input param pFromDate as date.
define input param pToDate as date.
define input param g_date as date.
define output param pUsr_name as char.
define output param pUsr_rnn as char.


def var KOd as char.
def var KBe as char.

def shared temp-table extract_tmp
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


def buffer b-cif2 for cif.
find b-cif2 where b-cif2.cif = pCif no-lock no-error.
if available b-cif2 then do:
   pUsr_name =  trim(trim(b-cif2.prefix) + " " + trim(b-cif2.name)).
   pUsr_rnn = b-cif2.jss .
end.
else do:
   pUsr_name = "NO NAME".
   pUsr_rnn = "NO RNN".
end.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
/**********************************************************************************************************************/
function GetName returns char ( input AccNo as char):
       def buffer b-aaa for aaa.
       def var Ret as char.
       find b-aaa where b-aaa.aaa = AccNo no-lock no-error.
       if not available b-aaa then
       do:
         def buffer b-arp for arp.
         find b-arp where b-arp.arp = AccNo no-lock no-error.
         if avail b-arp then Ret = b-arp.des.
         else do:
          def buffer b-gl for gl.
          find b-gl where b-gl.gl = integer(AccNo) no-lock no-error.
          if avail b-gl then Ret = b-gl.des.
          else Ret = "Not found ARP or GL name".
         end.
       end.
       else do:
          def buffer b-cif for cif.
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
     def buffer b-codfr for codfr.
     def var Ret as char.
     find b-codfr where b-codfr.code = Knp and b-codfr.codfr = 'spnpl' and b-codfr.child = false and b-codfr.code <> 'msc' no-lock no-error.
     if avail b-codfr then Ret = b-codfr.name[1].
     else Ret = "".
     return trim(Ret).
end function.
/**********************************************************************************************************************/
function CrcCode returns char (input crc as int):
   def buffer b-crc for crc.
   find last b-crc where b-crc.crc = crc no-lock no-error.
   if avail b-crc then return trim(b-crc.code).
   else return "XXX".
end function.
/**********************************************************************************************************************/
function GetOtherAcc returns char ( input jhno as int , input jlln as int ).
   def buffer b-jl1 for jl.
   find first b-jl1 where b-jl1.jh = jhno and b-jl1.ln = jlln + 1 no-lock no-error.
   if avail b-jl1 then return b-jl1.acc.
   else return "".
end function.
/**********************************************************************************************************************/
function CreateRec returns int ( input iCif as char, input iAcc as char):
   def buffer b-jl for jl.
   def buffer b-jh for jh.
   def var i as int.
   def var v-rem as char.
   def var sm as deci.
   def var sm1 as deci.

   run lonbal3('cif', iAcc, pFromDate - 1, "1", yes, output sm).
   run lonbal3('cif', iAcc, pToDate , "1", yes, output sm1).

   for each b-jl where b-jl.jdt >= pFromDate and b-jl.jdt <= pToDate and b-jl.acc = iAcc and b-jl.lev = 1 no-lock:
     if b-jl.lev <> 1 then next.
     if b-jl.rem[1] begins "O/D PROTECT" or b-jl.rem[1] begins "O/D PAYMENT" then next.

     create extract_tmp.

     extract_tmp.oper_code = string(b-jl.jh).
     extract_tmp.date_doc  = b-jl.jdt.
     extract_tmp.debit     = b-jl.dam.
     extract_tmp.credit    = b-jl.cam.
     extract_tmp.currency_code = CrcCode(b-jl.crc).
     extract_tmp.ext_account = iAcc.
     extract_tmp.income     = sm.
     extract_tmp.outcome    = sm1.

     if extract_tmp.debit > 0 then extract_tmp.plat_value = 0. /* Исходящий */
     else extract_tmp.plat_value = 1.                      /* Входящий  */

     /******************************************************/
     v-rem = b-jl.rem[1].
     do i = 1 to 5:
        if trim(b-jl.rem[i]) <> '' and trim(b-jl.rem[i]) <> trim(v-rem) then do:
            if v-rem <> '' then v-rem = v-rem + ''.
            v-rem = v-rem + b-jl.rem[i].
        end.
     end.
     if v-rem begins("RMZ") then extract_tmp.payment_details = trim(substr(v-rem,11,length(v-rem))).
     else  extract_tmp.payment_details = v-rem.
     /******************************************************/

     find first b-jh where b-jh.jh = b-jl.jh no-lock no-error.
     if avail b-jh then do:


       extract_tmp.deal_code = b-jh.ref.
       extract_tmp.create_time = b-jh.tim.

       case b-jh.sub:
        when "RMZ" then do:
                find first remtrz where remtrz.remtrz = b-jh.ref no-lock no-error.
                if avail remtrz then
                do:
				  find last netbank where netbank.rmz = remtrz.remtrz and netbank.cif = iCif no-lock no-error.
				  if avail netbank then do:
				     extract_tmp.num_doc = netbank.rem[2].
				  end.
				  else  extract_tmp.num_doc = string(trim( substring( remtrz.sqn,19,8 )) ).



				  /****************************/
				  if extract_tmp.plat_value = 0 then  /*0-исходящий 1-входящ*/
                  do:
                    if remtrz.bn[1] <> ? then extract_tmp.name = trim(remtrz.bn[1]).
                    if remtrz.bn[2] <> ? then extract_tmp.name = extract_tmp.name + " " + trim(remtrz.bn[2]).
                    if remtrz.bn[3] <> ? then extract_tmp.name = extract_tmp.name + " " + trim(remtrz.bn[3]).

                    extract_tmp.bank_bic = remtrz.rbank.
                    if remtrz.bb[1] = "NONE" then do:
                      find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
                      if avail bankl and bankl.name <> "" then extract_tmp.bank_name = trim(bankl.name).
                    end.
                    else extract_tmp.bank_name = trim(remtrz.bb[1]) + " " + trim(remtrz.bb[2]) + " " + trim(remtrz.bb[3]).

                    extract_tmp.sender_account = trim(remtrz.sacc).
                    extract_tmp.sender_bic = v-clecod.

                  end.
                  else do:
                    extract_tmp.name = remtrz.ord.
                    find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
                    if avail bankl and bankl.name <> "" then
                    do:
                      extract_tmp.bank_name = trim(bankl.name).
                      extract_tmp.bank_bic = v-clecod.
                    end.

                    extract_tmp.sender_account = trim(remtrz.sacc).

                    if index(remtrz.sbank,"TXB") = 0 then extract_tmp.sender_bic = remtrz.sbank.
                    else extract_tmp.sender_bic = v-clecod.

                  end.
                  /****************************/
                  extract_tmp.account = trim(remtrz.ba).
				  extract_tmp.date_val = remtrz.valdt2.
				  extract_tmp.oper_date = b-jl.jdt.
                  /*extract_tmp.oper_date = remtrz.valdt1.*/
				  extract_tmp.date_doc = remtrz.rdt.

				  find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
                  if avail sub-cod then
                  do:
                    extract_tmp.knp = entry(3,sub-cod.rcode,',').
                    extract_tmp.knp_name = GetKnpName(extract_tmp.knp).
                  end.
                  else do:
                    extract_tmp.knp = "979".  /* пока поставил Прочее */
                    extract_tmp.knp_name = GetKnpName(extract_tmp.knp).
                  end.
                end.

        end.
        when "JOU" then do:
           /*номер платежного поручения*/
           find first joudoc where joudoc.docnum = b-jh.ref no-lock no-error.
           if avail joudoc then extract_tmp.num_doc = joudoc.num.
           if extract_tmp.num_doc = "" then extract_tmp.num_doc = string(b-jl.jh).

            extract_tmp.oper_code = string(b-jl.jh).  /*номер платежа*/
            extract_tmp.deal_code = b-jh.ref. /*идентификатор документа rmz или jou*/
            find first joudoc where joudoc.docnum = b-jh.ref no-lock no-error.
            if avail joudoc then
            do:

               /****************************/
				  if extract_tmp.plat_value = 0 then  /*0-исходящий 1-входящ*/
                  do:
                    extract_tmp.sender_account = joudoc.cracc.
                    extract_tmp.account = joudoc.dracc.
                    extract_tmp.name = GetName(extract_tmp.account).

                  end.
                  else do:
                    extract_tmp.sender_account = joudoc.dracc.
                    extract_tmp.account = joudoc.cracc.
                    extract_tmp.name = GetName(extract_tmp.sender_account).

                  end.
                  /****************************/
                  find first bankl where bankl.bank = s-ourbank no-lock no-error.
                  if avail bankl then extract_tmp.bank_name = bankl.name.
                  else extract_tmp.bank_name = v-nbankru.
                  extract_tmp.sender_bic = v-clecod.
                  extract_tmp.bank_bic = v-clecod.
                  if extract_tmp.sender_account = "" then extract_tmp.sender_account = string(b-jl.gl).
                  if extract_tmp.account = "" then extract_tmp.account = string(b-jl.gl).

                  find sub-cod where sub-cod.acc = joudoc.docnum and sub-cod.sub = 'jou' and sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
                  if avail sub-cod then
                  do:
                    extract_tmp.knp = entry(3,sub-cod.rcode,',').
                    extract_tmp.knp_name = GetKnpName(extract_tmp.knp).
                  end.
                  else do:
                    extract_tmp.knp = "979".  /* пока поставил Прочее */
                    extract_tmp.knp_name = GetKnpName(extract_tmp.knp).
                  end.
                  extract_tmp.date_val = extract_tmp.date_doc.
                  extract_tmp.oper_date = b-jl.jdt.
                  /*extract_tmp.oper_date = extract_tmp.date_val.*/
            end.

        end.
        otherwise do:
                find last netbank where netbank.rmz = b-jh.ref and netbank.cif = iCif  no-lock no-error.
                if avail netbank then extract_tmp.num_doc = netbank.rem[2].
                else extract_tmp.num_doc =  string(b-jl.jh).

                extract_tmp.deal_code = string(b-jl.jh).

                find first bankl where bankl.bank = s-ourbank no-lock no-error.
                if avail bankl then extract_tmp.bank_name = bankl.name.
                else extract_tmp.bank_name = v-nbankru.
                extract_tmp.bank_bic = v-clecod.
                extract_tmp.sender_bic = v-clecod.

                if extract_tmp.plat_value = 0 then  /*0-исходящий 1-входящ*/
                do:
                   extract_tmp.sender_account = GetOtherAcc( b-jl.jh , b-jl.ln ).
                   extract_tmp.account = b-jl.acc.
                   extract_tmp.name = GetName(extract_tmp.account).
                end.
                else do:
                   extract_tmp.sender_account = b-jl.acc.
                   extract_tmp.account =  GetOtherAcc( b-jl.jh , b-jl.ln ).
                   extract_tmp.name = GetName(extract_tmp.sender_account).
                end.

                run GetEKNP(b-jl.jh, b-jl.ln, b-jl.dc, input-output KOd, input-output KBe, input-output extract_tmp.knp).

                if extract_tmp.knp = "" or extract_tmp.knp = ? then extract_tmp.knp = "979".  /* пока поставил Прочее */
                extract_tmp.knp_name = GetKnpName(extract_tmp.knp).
                extract_tmp.date_val = extract_tmp.date_doc.
                extract_tmp.oper_date = b-jl.jdt.
                /*extract_tmp.oper_date = extract_tmp.date_val.*/
        end.
       end. /* case */



     end. /* if avail b-jh*/

   end. /*for each b-jl*/
  return 0.
end function.
/**********************************************************************************************************************/

      CreateRec(pCif,pAccount).


/**********************************************************************************************************************/

procedure lonbal3.

define input  parameter p-sub like trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def buffer b-aaa for aaa.
def var i as integer.

res = 0.

if p-dt > g_date then p-dt = g_date. /*return.*/

if p-includetoday then do: /* за дату */
  if p-dt = g_date then do:
     for each trxbal where trxbal.subled = p-sub and trxbal.acc = p-acc no-lock:
         if lookup(string(trxbal.level), p-lvls) > 0 then do:

            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find trxlevgl where trxlevgl.gl     eq b-aaa.gl
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + trxbal.dam - trxbal.cam.
	    else res = res + trxbal.cam - trxbal.dam.

	    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
	                   and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available sub-cod and sub-cod.ccode eq "01" then res = - res.

	    /* ------------------------------------------------------------ */
/*	    for each jl where jl.acc = p-acc
                          and jl.jdt >= p-dt
                          and jl.lev = 1 no-lock:
	    if gl.type eq "A" or gl.type eq "E" then res = res - jl.dam + jl.cam.
            else res = res + jl.dam - jl.cam.
            end. */

         end.
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        find last histrxbal where histrxbal.subled = p-sub
                              and histrxbal.acc = p-acc
                              and histrxbal.level = integer(entry(i, p-lvls))
                              and histrxbal.dt <= p-dt no-lock no-error.
        if avail histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find trxlevgl where trxlevgl.gl     eq b-aaa.gl
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + histrxbal.dam - histrxbal.cam.
	    else res = res + histrxbal.cam - histrxbal.dam.

	    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
	                   and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available sub-cod and sub-cod.ccode eq "01" then res = - res.

        end.
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last histrxbal where histrxbal.subled = p-sub and histrxbal.acc = p-acc and histrxbal.level = integer(entry(i, p-lvls))
                                 and histrxbal.dt < p-dt no-lock no-error.
       if avail histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find trxlevgl where trxlevgl.gl     eq b-aaa.gl
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + histrxbal.dam - histrxbal.cam.
	    else res = res + histrxbal.cam - histrxbal.dam.

	    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
	                   and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available sub-cod and sub-cod.ccode eq "01" then res = - res.

       end.
   end.
end.



end.


