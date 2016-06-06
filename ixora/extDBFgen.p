/* extDBFgen.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Формирование выписок в формате DBF
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
        18.05.2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/

{classes.i}


def input parameter pAccount as char.
def output parameter rcode as inte.
def output parameter rdes as char.


def new shared temp-table extract_tmp
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


def var pCif as char.
find first aaa where aaa.aaa = pAccount no-lock no-error.
if avail aaa then pCif = aaa.cif.
def var pFromDate as date no-undo .
def var pToDate as date no-undo .
def var pUsr_name as char no-undo.
def var pUsr_rnn as char no-undo.
def stream m-dbf.
def var FileName as char.
def var Sline as char.
def var SlineDos as char.

/*
pFromDate = date(5,26,2011).
pToDate = date(5,26,2011).
*/

if pFromDate = ? then pFromDate = g-today.
if pToDate = ? then pToDate = g-today.




FileName = "rep" + replace(string(today),"/","") + replace(string(time,"HH:MM:SS"),":","") + ".dbf".

/*******************************************************************************************************/
function ToDos returns char (input instr as char).
 def var res as char.
 def var a as char init "№ЙЦУКЕЁНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ".
 def var b as char init "N‰–“Љ…рЌѓ™‡•љ”›‚ЂЏђЋ‹„†ќџ—‘Њ€’њЃћ".
 def var in_len as int.
 def var cod_len as int.
 def var i as int.
 def var y as int.
 def var c as char.

 in_len = length(instr).
 cod_len = length(a).

 repeat i = 1 to in_len:
   c = substr(instr,i,1).
   repeat y = 1 to cod_len:
    if substr(a,y,1) = c then do: c = substr(b,y,1). leave. end.
   end.
   res = res + c.
 end.

 return res.
end function.
/*******************************************************************************************************/
function ToTestN returns char (input instr as char).
 def var res as char.
 def var in_len as int.
 def var cod_len as int.
 def var i as int.
 def var y as int.
 def var c as char.

 in_len = length(instr).

 repeat i = 1 to in_len:
   c = substr(instr,i,1).
   if c = '~n' then do: /*message c " в позиции " i view-as alert-box.*/ end.
   else  res = res + c.
 end.

 return res.
end function.
/*******************************************************************************************************/


def var pUsr_Rezident as char.
def var pUsr_Sector as char.

def var Other_Rezident as char.
def var Other_Sector as char.


def var UsrGlavBux as char.
def var UsrGenDir as char.
def var SenderPHH as char.
def var PoluchPHH as char.
def var EKP as char.


find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = pCif and sub-cod.d-cod = 'clnbk' and sub-cod.ccode = 'mainbk'  no-lock no-error.
if avail sub-cod then UsrGlavBux = sub-cod.rcode.
else UsrGlavBux = "Не предусмотрено".

find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = pCif and sub-cod.d-cod = 'clnchf' and sub-cod.ccode = 'chief'  no-lock no-error.
if avail sub-cod then UsrGenDir =  sub-cod.rcode.
else UsrGenDir = "Не предусмотрено".

find first cif where cif.cif = pCif no-lock no-error.
if avail cif then pUsr_Rezident = string(cif.irs).
else message "Не найдены данные резидентства для " pCif view-as alert-box.


find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "secek" and sub-cod.acc = pCif no-lock no-error.
if avail sub-cod then pUsr_Sector = sub-cod.ccode.
else message "Не найдены данные по сектору экономики для " pCif view-as alert-box.


empty temp-table extract_tmp.
run extcre( pCif , pAccount , pFromDate , pToDate , g-today ,output pUsr_name ,output pUsr_rnn).


/****** не формируем пустые выписки ********************************************************/
find first extract_tmp no-lock no-error.
if not avail extract_tmp then do:
   rcode = 2.
   /*rdes = "Не найден счет " + pAccount + "cif=" + pCif.*/
   rdes = "Нет данных для формирования выписки DBF для " + pAccount + " cif=" + pCif.
   return.
end.
/******************************************************************************************/

output stream m-dbf to value(FileName).


 for each extract_tmp:

   if extract_tmp.plat_value = 0 then do:
     find first cif where cif.cif = pCif no-lock no-error.
     if avail cif then SenderPHH = cif.jss.
     if extract_tmp.name <> pUsr_name and index(extract_tmp.name,"/RNN/") > 0 then PoluchPHH = substr(trim(substr(extract_tmp.name, index(extract_tmp.name, "/RNN/") + 5)), 1, 12).
     else PoluchPHH = "".

     find sub-cod where sub-cod.acc = extract_tmp.deal_code and sub-cod.sub = "RMZ" and sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
     if avail sub-cod then  do: /* если это rmz */
      /* message "отправитель " entry(1,sub-cod.rcode,',')  "получатель " entry(2,sub-cod.rcode,',') view-as alert-box.*/
       Other_Rezident = substr(entry(2,sub-cod.rcode,','),1,1).
       Other_Sector = substr(entry(2,sub-cod.rcode,','),2,1).

     end.
     else do:  /* это jou*/
        find first aaa where aaa.aaa = extract_tmp.account no-lock no-error.
        if avail aaa then do:
          find first cif where cif.cif = aaa.cif no-lock no-error.
          if avail cif then do:
             Other_Rezident = string(cif.irs).
             find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "secek" and sub-cod.acc = cif.cif no-lock no-error.
             if avail sub-cod then Other_Sector = sub-cod.ccode.
          end.
        end.
     end.

     /*видимо это внутренний счет*/
     if Other_Rezident = "" then Other_Rezident = "1".
     if Other_Sector = "" then Other_Sector = "4".

     EKP = pUsr_Rezident + pUsr_Sector + Other_Rezident + Other_Sector + extract_tmp.currency_code + extract_tmp.knp.

   end.
   else do:  /* входящий документ */
     find first cif where cif.cif = pCif no-lock no-error.
     if avail cif then PoluchPHH = cif.jss.
     if extract_tmp.name <> pUsr_name and index(extract_tmp.name,"/RNN/") > 0 then SenderPHH = substr(trim(substr(extract_tmp.name, index(extract_tmp.name, "/RNN/") + 5)), 1, 12).
     else SenderPHH = "".

     find sub-cod where sub-cod.acc = extract_tmp.deal_code and sub-cod.sub = "RMZ" and sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
     if avail sub-cod then  do: /* если это rmz */
      /* message "отправитель " entry(1,sub-cod.rcode,',')  "получатель " entry(2,sub-cod.rcode,',') view-as alert-box.*/
       Other_Rezident = substr(entry(1,sub-cod.rcode,','),1,1).
       Other_Sector = substr(entry(1,sub-cod.rcode,','),2,1).
     end.
     else do:  /* это jou*/
        find first aaa where aaa.aaa = extract_tmp.sender_account no-lock no-error.
        if avail aaa then do:
          find first cif where cif.cif = aaa.cif no-lock no-error.
          if avail cif then do:
             Other_Rezident = string(cif.irs).
             find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "secek" and sub-cod.acc = cif.cif no-lock no-error.
             if avail sub-cod then Other_Sector = sub-cod.ccode.
          end.
        end.
     end.

     /*видимо это внутренний счет*/
     if Other_Rezident = "" then Other_Rezident = "1".
     if Other_Sector = "" then Other_Sector = "4".

     EKP = Other_Rezident + Other_Sector + pUsr_Rezident + pUsr_Sector + extract_tmp.currency_code + extract_tmp.knp.

   end.




   extract_tmp.payment_details = ToTestN(extract_tmp.payment_details).

   /*AIM|AIM1*/
   if length(extract_tmp.payment_details) > 170 then Sline = substr(extract_tmp.payment_details,1,169) + "|" + substr(extract_tmp.payment_details,170,250) + "|".
   else Sline = extract_tmp.payment_details + "| |".


   /*BANKPLAT*/   /* 0-исходящий */
   Sline = Sline + extract_tmp.sender_bic + "|".
   /*
   if extract_tmp.plat_value = 0 then Sline = Sline + extract_tmp.sender_bic + "|".
   else Sline = Sline + extract_tmp.bank_bic + "|".
   */

   /*ACCOUNT*/
   /* так было
   if extract_tmp.plat_value = 0 then Sline = Sline + "00000" + extract_tmp.sender_account + "|".
   else Sline = Sline + "00000" + extract_tmp.account + "|".
    */
   if extract_tmp.plat_value = 0 then Sline = Sline + "00000" + extract_tmp.account + "|".
   else Sline = Sline + "00000" + extract_tmp.sender_account + "|".

   /*BANKPOL*/
    Sline = Sline + extract_tmp.bank_bic + "|".
    /*
   if extract_tmp.plat_value = 0 then Sline = Sline + extract_tmp.bank_bic + "|".
   else Sline = Sline + extract_tmp.sender_bic + "|".
   */
   /*CODPOL*/
   Sline = Sline + extract_tmp.ext_account + "|".

   /*CODOUT*/
   /* так было
   if extract_tmp.plat_value = 0 then Sline = Sline + extract_tmp.account + "|".
   else Sline = Sline + extract_tmp.sender_account + "|".
   */
   if extract_tmp.plat_value = 0 then Sline = Sline +  extract_tmp.sender_account + "|".
   else Sline = Sline + extract_tmp.account + "|".

   /*PAYMENT*/
   if extract_tmp.plat_value = 0 then Sline = Sline + string(extract_tmp.debit,">>>>>>>>>9.99") + "|".
   else Sline = Sline + string(extract_tmp.credit,">>>>>>>>>9.99") + "|".


    /*NDOK*/
     Sline = Sline + extract_tmp.oper_code /*extract_tmp.num_doc*/ + "|".
     /*KOPER*/
     if extract_tmp.knp <> "213" then Sline = Sline + "01" + "|".
     else Sline = Sline + "14" + "|".
     /*SEND*/
     Sline = Sline + "AC" + "|".
     /*DATLAST*/
     Sline = Sline + string(year(extract_tmp.oper_date),'9999') + string(month(extract_tmp.oper_date),'99') + string(day(extract_tmp.oper_date),'99') + "|".
     /*Sline = Sline + string(extract_tmp.oper_date) + "|".*/
     /*PAPKA*/
     Sline = Sline + "|".
     /*WORTH*/
     Sline = Sline + "S" + "|".
     /*USER*/
     Sline = Sline + "|".

     /*TAXESNUMA РНН плательщика*/
     Sline = Sline + SenderPHH + "|".
     /*TAXESNUM РНН получателя*/
     Sline = Sline + PoluchPHH + "|".

     /*REFER*/
     Sline = Sline + string(extract_tmp.num_doc,"x(15)") +  "|". /* extract_tmp.deal_code + "," + extract_tmp.oper_code + "," + extract_tmp.num_doc + "|".*/
     /*RF*/
     Sline = Sline + "|".
     /*KNP*/
     Sline = Sline + extract_tmp.knp + "|".
     /*BCLASSD*/
     Sline = Sline + "|".
     /*ELO*/
     Sline = Sline + "|".
     /*RECNO*/
     Sline = Sline + "|".

     /*PLATEL*/
     if extract_tmp.plat_value = 0 then Sline = Sline + pUsr_name + "|".
     else do:
       if index(extract_tmp.name,"/") > 0 then Sline = Sline + substr(extract_tmp.name,1,index(extract_tmp.name,"/") - 1 ) + "|".
       else Sline = Sline + extract_tmp.name + "|".
     end.
     /*POLUCH*/
     if extract_tmp.plat_value = 0 then do:
       if index(extract_tmp.name,"/") > 0 then  Sline = Sline + substr(extract_tmp.name,1,index(extract_tmp.name,"/") - 1 ) + "|".
       else Sline = Sline + extract_tmp.name + "|".
     end.
     else Sline = Sline + pUsr_name + "|".

     /*FIORUK*/
     Sline = Sline + UsrGenDir + "|".
     /*FIOGB*/
     Sline = Sline + UsrGlavBux + "|".
     /*SYMBOL*/
     Sline = Sline + "|".
     /*GROUPE*/
     Sline = Sline + "|".
     /*GROUPECR*/
     Sline = Sline + "|".
     /*PRIOR*/
     Sline = Sline + "|".
     /*ORDCAT*/
     Sline = Sline + "|".
     /*EKP*/
     Sline = Sline + EKP + "|".
     /*IN*/
     Sline = Sline + string(extract_tmp.income,">>>>>>>>>9.99") + "|".
     /*DB*/
     Sline = Sline + string(extract_tmp.debit,">>>>>>>>>9.99") + "|".
     /*CR*/
     Sline = Sline + string(extract_tmp.credit,">>>>>>>>>9.99") + "|".
     /*OUT*/
     Sline = Sline + string(extract_tmp.outcome,">>>>>>>>>9.99") .



     put stream m-dbf unformatted  ToDos(Sline) skip.
 end.

output stream m-dbf close.







   def var v as char init "".
   def var v-result as char.
   input through value("extract_dbf.pl " + FileName ).
   repeat:
    import unformatted v.
    v-result = v-result + v.
   end.

   if v-result <> "" then do:
      rdes = v-result.
      rcode = 1.
      run mail("id00205@metrocombank.kz", "info@metrocombank.kz", "ERROR DBF", v-result , "", "", "").
   end.
   else do:
      rdes = FileName.
      rcode = 0.
   end.



