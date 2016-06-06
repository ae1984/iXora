/* cif-rep.p
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
        02/02/2012 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        04/05/2012 evseev - изменил путь к логотипу
        13.07.2012 Lyubov - перекомпиляция

*/

{global.i}


def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var r-type as char.
def var r-type2 as char.
def var v-ofc as char.
def var v-dep as int.
def var v-ibh as int.
def var v-departs as char.
def var v-repwho as char.
def var repname as char.


def temp-table tmp-jh like jh.
def temp-table wrk no-undo
  field ind as int
  field oper-type as char /*операции*/
  field v-trx as int     /*# транзакции*/
  field v-oper as char    /*Вид операции*/
  field v-date as date    /*Дата*/
  field v-time as int     /*Время*/
  field cif-name as char  /*Наименование клиента*/
  field s-acc as char     /*счет отправителя*/
  field v-crc as char     /*вид валюты*/
  field v-summ as deci    /*сумма*/
  field r-acc as char     /*счет получателя*/
  field v-knp as char     /*КНП*/
  field v-detpay as char  /*Назначание платежа*/
  field r-who as char     /*iD исполнителя*/
  field c-who as char     /*iD котролера*/
  field docno as char format "x(10)"
  field d-gl as int
  field c-gl as int
  field sort-crc as int
  field gl-sort as int
  field gl-sort-name as char.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.

/**************************************************************************************/
function GetCRC returns char (input currency as integer).
  def var code as char format "x(3)".
  def buffer b-crc for crc.
   find b-crc where b-crc.crc = currency no-lock no-error.
   if avail b-crc then do:
     code = b-crc.code.
   end.
   else code = "?".
  return code.
end function.
/**************************************************************************************/
function GetTypePay returns integer (input v-jh as integer , input v-dt as date  , input v-who as char  ).
  def var rez as int init 0.
  def var dp as char.

  find first remtrz where remtrz.jh1 = v-jh and remtrz.valdt1 = v-dt and remtrz.jh2 <> ? /*and remtrz.rwho = v-who*/ no-lock no-error.
  if avail remtrz then do:


    if remtrz.sbank <> s-ourbank then return -1. /*Только платежи сформированные в этом филиале*/

    dp =  remtrz.detpay[1] + remtrz.detpay[2] + remtrz.detpay[3] + remtrz.detpay[4].
    if index(dp," И.Р ") > 0 or index(dp," ИР ") > 0  then return 3.
    if index(dp," ПТП ") > 0 then return 4.

    if remtrz.rwho  = "" and remtrz.cwho = "" then return - 1.

    if remtrz.rwho = "SUPERMAN" and remtrz.source <> "IBH"  then return -1.  /*убираем автоматические платежи */



    if remtrz.tcrc = 1 then return 1.
    else return 2.
  end.

  find first dealing_doc where dealing_doc.jh = v-jh and dealing_doc.whn_cr = v-dt  no-lock no-error.
  if avail dealing_doc then do:
   if dealing_doc.DocType = 1 or dealing_doc.DocType = 2 then return 5.
   if dealing_doc.DocType = 3 or dealing_doc.DocType = 4 then return 6.
   if dealing_doc.DocType = 5 or dealing_doc.DocType = 6 then return 7.
  end.

  return rez.
end function.
/**************************************************************************************/
function GetClientName returns char (input v-cif as char).
    find cif where cif.cif eq v-cif no-lock no-error.
    if not available cif then
    do:
      message "Не найден клиент " v-cif "в таблице CIF"  view-as alert-box.
      return "".
    end.
    else return  trim(trim(cif.prefix) + " " + trim(cif.name)).
end function.

function GetAccCif returns char (input AccNo as char).
   def var res as char init "".
   def buffer b-aaa for aaa.
   find b-aaa where b-aaa.aaa = AccNo no-lock no-error.
   if not available b-aaa then
   do:
     message "Счет" AccNo "не найден !" view-as alert-box.
   end.
   else do:
     def buffer b-cif for cif.
     find b-cif where b-cif.cif eq b-aaa.cif no-lock no-error.
     if not available b-cif then
     do:
       message "Не найден клиент " b-aaa.cif "в таблице CIF"  view-as alert-box.
     end.
     else res =  trim(trim(b-cif.prefix) + " " + trim(b-cif.name)).
   end.
   return res.
end function.
/**************************************************************************************/
function GetAccCRC returns char (input acc as char).
  def var code as char format "x(3)".
  def buffer b-crc for crc.
  def buffer b-aaa for aaa.
   find first b-aaa where b-aaa.aaa = acc  no-lock no-error.
   if avail b-aaa then do:
    find b-crc where b-crc.crc = b-aaa.crc no-lock no-error.
    if avail b-crc then do:
     code = b-crc.code.
    end.
    else code = "?".
   end.
  return code.
end function.
/**************************************************************************************/
function GetKNP returns char (input sub as char , input docno as char).
    def var res as char.

    case sub:
      when "rmz" then do:
           find sub-cod where sub-cod.acc = docno and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
           if avail sub-cod then  do:
             res = entry(3,sub-cod.rcode,',').
           end.
           /*else res = docno.  message "Не найден КНП по " docno view-as alert-box.*/
      end.
      when "jou" then do:
          find sub-cod where sub-cod.acc = docno and sub-cod.sub = 'jou' and sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
          if avail sub-cod then do:
            res = entry(3,sub-cod.rcode,',').
          end.
          else do:
           find first joudoc where joudoc.docnum = docno no-lock no-error.
           if avail joudoc then do:
            find first trxcods where trxcods.trxh = joudoc.jh and trxcods.trxln = 1 and trxcods.codfr = "spnpl" no-lock no-error.
            if available trxcods then res = trxcods.code.
            /*else res = docno. message "Не найден КНП JOU" view-as alert-box.*/
           end.
         end.
      end.
      when "ujo" then do:
          find first trxcods where trxcods.trxh = integer(docno) and trxcods.trxln = 1 and trxcods.codfr = "spnpl" no-lock no-error.
          if available trxcods then res = trxcods.code.
          /*else res = docno. message "Не найден КНП UJO"  view-as alert-box.*/
      end.
    end case.

    return res.
end function.
/**************************************************************************************/
function GetWhoTrx returns char (input p-jh as integer, input p-dt as date).
    find first jh where jh.jh = p-jh and jh.jdt = p-dt no-lock no-error.
    if avail jh then return jh.who.
    else return "".
end function.
/**************************************************************************************/
function GetWhoAccept returns char (input v-sub as char, input v-doc as char ).
   find last substs where substs.sub = v-sub and  substs.acc = v-doc  and substs.sts ne "new" use-index substs no-lock no-error .
   if avail substs then return substs.who.
   find last cursts where cursts.sub = v-sub and cursts.acc = v-doc  and cursts.sts ne "new" use-index subacc no-lock no-error .
   if avail cursts then return cursts.who.
   find first doc_who_create where doc_who_create.docno = v-doc no-lock no-error.
   if avail doc_who_create and doc_who_create.ref <> "" then return doc_who_create.ref.
   /*if avail doc_who_create and doc_who_create.ref = "" then return doc_who_create.who_cr.*/
   return "".
end function.
/**************************************************************************************/
function IsKass returns log (input v-ofc as char).
  find first ofc where ofc.ofc = v-ofc no-lock no-error.
  if avail ofc then do:
    if (lookup("p00007",ofc.expr[1]) > 0) or (lookup("p00008",ofc.expr[1]) > 0) then return true. /* Это кассир */
    else return false.
  end.
  else return false.
end function.
/**************************************************************************************/
/* функция проверки на наличие прав (пакета p00121) */
function chkbuh returns logical (usr as char).
    def var v-res as logical init no.
    def var j as integer.
    find first ofc where ofc.ofc = usr no-lock no-error.
    if avail ofc then do:
        do j = 1 to num-entries(ofc.expr[1]):
            if trim(entry(j,ofc.expr[1])) = "p00121" then do: v-res = yes. leave. end.
        end. /* do j = 1 */
    end.
    return v-res.
end.
/**************************************************************************************/

dt2 = g-today.
dt1 = dt2.

displ dt1 label " С " format "99/99/9999" validate( dt1 <= g-today, "Некорректная дата!") skip
      dt2 label " По" format "99/99/9999" validate( dt2 >= dt1, "Некорректная дата!") skip
with side-label row 6 centered frame dat.

update dt1 with frame dat.
update dt2 with frame dat.

hide frame dat.
/**************************************************************************************/

def var v-Cif as char.
  define frame Frame1
  v-Cif label  "ID клиента" skip
  with side-labels row 13 centered.
  on help of v-Cif in frame Frame1 do:
  def var phand AS handle.
    run h-cif PERSISTENT SET phand.
    hide frame xf.
    v-Cif = frame-value.
    displ  v-Cif with frame Frame1.
    DELETE PROCEDURE phand.
  end.
  DISPLAY v-Cif  WITH FRAME Frame1.
  update v-Cif WITH FRAME Frame1.
  find first cif where cif.cif = v-Cif no-lock no-error.
  if not avail cif then do:
     v-Cif = "".
     undo.
  end.
  if v-Cif = "" then undo.
  hide frame Frame1.

run sel1("Параметры отчета", "С платежами ИБ|Без платежей ИБ|Только платежи ИБ").
    r-type2 = return-value.
    if r-type2 = "" then return.
    if r-type2 = "С платежами ИБ" then v-ibh = 1.
    if r-type2 = "Без платежей ИБ" then v-ibh = 2.
    if r-type2 = "Только платежи ИБ" then v-ibh = 3.

/**************************************************************************************/
    v-repwho = GetClientName(v-Cif).

  for each aaa where aaa.cif = v-Cif no-lock , each jl where jl.acc = aaa.aaa and jl.jdt >= dt1 and jl.jdt <= dt2 no-lock break by jl.jh.
   if first-of(jl.jh) then do:
      find first jh where jh.jh = jl.jh no-lock.
      create tmp-jh.
           buffer-copy jh to tmp-jh.
   end.
  end.




def buffer b-tmp-jh for tmp-jh.
def buffer b-joudoc for joudoc.
def var tmp-c-gl as int.
def var tmp-d-gl as int.


def var TypePay as int.
def var spectrx as log.

 for each tmp-jh by tmp-jh.jdt:

  TypePay = GetTypePay(tmp-jh.jh,tmp-jh.jdt,tmp-jh.who).

  case TypePay:
    when -1 then do:
       /*автоматические платежи*/

       next.
    end.
    when 0 then do: /*Другие*/
      spectrx = false.
      for each jl where jl.jh = tmp-jh.jh no-lock:
       if LOOKUP(jl.trx,"uni0025,uni0068,uni0003,uni0031,uni0032,uni0033,uni0034,uni0058,uni0057,uni0088,uni0105,vnb0024,vnb00100,lon0079,lon0137,lon0138,lon0139,lon0133,lon0003,lon0130,lon0116,lon0070,lon0063") = 0 and jl.sts <> 6 then
       do:
         spectrx = true.
       end.
      end.

      find first jh where jh.jh = tmp-jh.jh no-lock.
      if jh.party begins "Storn" then spectrx = false.

      if spectrx then do: delete tmp-jh. next. end.

    end.
    when 1 then do: /*Платежи в тенге*/
         create wrk.
         wrk.ind = 1.
         wrk.oper-type = "Платежи в тенге".
         wrk.v-trx = tmp-jh.jh.
         wrk.v-date = tmp-jh.jdt.
         wrk.v-time = tmp-jh.tim.
    end.
    when 2 then do: /*Платежи в валюте*/
         create wrk.
         wrk.ind = 2.
         wrk.oper-type = "Платежи в валюте".
         wrk.v-trx = tmp-jh.jh.
         wrk.v-date = tmp-jh.jdt.
         wrk.v-time = tmp-jh.tim.
    end.
    when 3 then do: /*Оплата К2 ИР */
         create wrk.
         wrk.ind = 3.
         wrk.oper-type = "Оплата К2 (ИР)".
         wrk.v-trx = tmp-jh.jh.
         wrk.v-date = tmp-jh.jdt.
         wrk.v-time = tmp-jh.tim.

    end.
    when 4 then do: /*Оплата К2 ПТП*/
         create wrk.
         wrk.ind = 4.
         wrk.oper-type = "Оплата К2 (ПТП)".
         wrk.v-trx = tmp-jh.jh.
         wrk.v-date = tmp-jh.jdt.
         wrk.v-time = tmp-jh.tim.

    end.

    when 5 then do: /*Покупка валюты*/
         create wrk.
         wrk.ind = 5.
         wrk.oper-type = "Покупка валюты".
         wrk.v-trx = tmp-jh.jh.
         wrk.v-date = tmp-jh.jdt.
         wrk.v-time = tmp-jh.tim.
    end.
    when 6 then do: /*Продажа валюты*/
         create wrk.
         wrk.ind = 6.
         wrk.oper-type = "Продажа валюты".
         wrk.v-trx = tmp-jh.jh.
         wrk.v-date = tmp-jh.jdt.
         wrk.v-time = tmp-jh.tim.
    end.
    when 7 then do: /*Кросс-конвертация*/
         create wrk.
         wrk.ind = 7.
         wrk.oper-type = "Кросс-конвертация".
         wrk.v-trx = tmp-jh.jh.
         wrk.v-date = tmp-jh.jdt.
         wrk.v-time = tmp-jh.tim.
    end.
  end case.


   /*Другие*/
   if TypePay = 0 then do:

        find first b-joudoc where  b-joudoc.whn = tmp-jh.jdt and b-joudoc.jh = tmp-jh.jh and b-joudoc.who = tmp-jh.who and ( b-joudoc.cracctype begins("2") or b-joudoc.dracctype begins("2") ) no-lock no-error.
        if avail b-joudoc  then
        do:

         create wrk.

         find first jl where jl.jh = b-joudoc.jh and jl.dc = "d" use-index jhln no-lock.
         wrk.d-gl = jl.gl.
         find first jl where jl.jh = b-joudoc.jh and jl.dc = "c" use-index jhln no-lock.
         wrk.c-gl = jl.gl.

         if (wrk.d-gl = 100100 or wrk.d-gl = 100200) or (wrk.c-gl = 100100 or wrk.c-gl = 100200) then
         do:
           wrk.ind = 8.
           wrk.oper-type = "Наличные приходные/расходные операции".
         end.
         else do:
           wrk.ind = 9.
           wrk.oper-type = "Другие операции".
         end.


         wrk.v-trx = tmp-jh.jh.
         wrk.v-date = tmp-jh.jdt.
         wrk.v-time = tmp-jh.tim.

         wrk.v-detpay = trim(b-joudoc.remark[1] + b-joudoc.remark[2]).
         wrk.v-detpay  = wrk.v-detpay  +  b-joudoc.info.

         if b-joudoc.passp <> ? and b-joudoc.passp <> "" then wrk.v-detpay  = wrk.v-detpay  + " Паспорт: " + b-joudoc.passp.
         if string(b-joudoc.passpdt) <> ? then wrk.v-detpay  = wrk.v-detpay  + " " + string(b-joudoc.passpdt).
         if b-joudoc.perkod <> ? and b-joudoc.perkod <> "" then wrk.v-detpay  = wrk.v-detpay  + " РНН: " + b-joudoc.perkod.

         wrk.r-who = b-joudoc.who.

         wrk.c-who = GetWhoAccept ("jou", b-joudoc.docnum ).
         if wrk.c-who = wrk.r-who then wrk.c-who = "".
         if wrk.c-who = "" then do:
          find first jl where jl.jh = tmp-jh.jh no-lock no-error.
          if avail jl then wrk.c-who = jl.teller.
          if wrk.c-who = wrk.r-who then wrk.c-who = "".
         end.


         if not b-joudoc.cracctype begins("2") then do: /*дебетовая операция по счету клиента*/
           wrk.cif-name = GetAccCif(b-joudoc.dracc).
           wrk.s-acc = b-joudoc.dracc.
           wrk.v-summ = b-joudoc.cramt.
           wrk.v-crc = GetCRC(b-joudoc.drcur).
         end.
         else do:
           wrk.cif-name = GetAccCif(b-joudoc.cracc).
           wrk.s-acc = b-joudoc.cracc.
           wrk.v-summ = b-joudoc.dramt.
           wrk.v-crc = GetCRC(b-joudoc.crcur).
         end.

         if wrk.v-summ = 0 then do:
           wrk.v-summ = b-joudoc.comamt.
           if wrk.v-detpay = "" then do:
            find first tarif2 where tarif2.num + tarif2.kod = string(b-joudoc.comcode) and tarif2.stat = 'r' no-lock no-error.
            if avail tarif2 then wrk.v-detpay = tarif2.pakalp.
           end.
         end.


         find sub-cod where sub-cod.acc = b-joudoc.docnum and sub-cod.sub = 'jou' and sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
         if avail sub-cod then do:
            wrk.v-knp = entry(3,sub-cod.rcode,',').
         end.
         else do:

           find first trxcods where trxcods.trxh = b-joudoc.jh and trxcods.trxln = 1 and trxcods.codfr = "spnpl" no-lock no-error.
           if available trxcods then wrk.v-knp = trxcods.code.
           else wrk.v-knp = b-joudoc.docnum. /*message "Не найден КНП JOU" b-joudoc.docnum view-as alert-box.*/

         end.


        /* wrk.v-knp = GetKNP("jou", b-joudoc.docnum ).*/
         wrk.docno = b-joudoc.docnum.

        end.
        else do:
         /*проводки без jou документов или операции без открытия счета  */



          if tmp-jh.who <> "SUPERMAN" and tmp-jh.who <> "BANKADM" then
          do:


           find first jl where jl.jh = tmp-jh.jh and jl.dc = "d" use-index jhln no-lock no-error .
           if not avail jl then next.
           tmp-d-gl = jl.gl.
           find first jl where jl.jh = tmp-jh.jh and jl.dc = "c" use-index jhln no-lock no-error .
           if not avail jl then next.
           tmp-c-gl = jl.gl.


           if tmp-d-gl = 100100 and tmp-c-gl = 100100 then next.



           create wrk.
           wrk.d-gl = tmp-d-gl. /*jl.gl.*/
           wrk.c-gl = tmp-c-gl. /*jl.gl.*/

           if (wrk.d-gl = 100100 or wrk.d-gl = 100200) or (wrk.c-gl = 100100 or wrk.c-gl = 100200) then
           do:
             wrk.ind = 8.
             wrk.oper-type = "Наличные приходные/расходные операции".
           end.
           else do:
             wrk.ind = 9.
             wrk.oper-type = "Другие операции".
           end.


           wrk.v-trx = tmp-jh.jh.
           wrk.v-date = tmp-jh.jdt.
           wrk.v-time = tmp-jh.tim.


           find first jl where jl.jh = tmp-jh.jh and jl.acc <> "" /*and jl.sub = "arp"*/ no-lock no-error.
           if avail jl then do:
             wrk.s-acc = jl.acc.
           end.
           else do:
             find first jl where jl.jh = tmp-jh.jh and jl.dc = "d" no-lock no-error.
             if not avail jl then message tmp-jh.jh view-as alert-box.
           end.



           if jl.dam > 0 then wrk.v-summ = jl.dam.
           else wrk.v-summ = jl.cam.
           wrk.v-crc = GetCRC(jl.crc).

           wrk.r-who = tmp-jh.who.
           wrk.c-who = GetWhoAccept (tmp-jh.sub, tmp-jh.ref).
           if wrk.c-who = wrk.r-who then wrk.c-who = "".
           if wrk.c-who = "" then do:
              find first jl where jl.jh = tmp-jh.jh no-lock no-error.
              if avail jl then wrk.c-who = jl.teller.
              if wrk.c-who = wrk.r-who then wrk.c-who = "".
           end.


           wrk.v-detpay = trim(jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5]).

           if wrk.v-detpay = "" then do:
             find first jl where jl.jh = tmp-jh.jh and jl.rem[1] <> "" no-lock no-error.
             if avail jl then wrk.v-detpay = trim(jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5]).
           end.

           find first b-joudoc where  b-joudoc.whn = tmp-jh.jdt and b-joudoc.jh = tmp-jh.jh and b-joudoc.who = tmp-jh.who no-lock no-error.
           if avail b-joudoc  then
           do:
               wrk.v-detpay  = wrk.v-detpay  + " " + caps(b-joudoc.info).
               if b-joudoc.passp <> ? and b-joudoc.passp <> "" then wrk.v-detpay  = wrk.v-detpay  + " Паспорт: " + b-joudoc.passp.
               if string(b-joudoc.passpdt) <> ? then wrk.v-detpay  = wrk.v-detpay  + " " + string(b-joudoc.passpdt).
               if b-joudoc.perkod <> ? and b-joudoc.perkod <> "" then wrk.v-detpay  = wrk.v-detpay  + " РНН: " + b-joudoc.perkod.
           end.


           /*
           if jl.dam > 0 then wrk.v-summ = jl.dam.
           else wrk.v-summ = jl.cam.
           wrk.v-crc = GetCRC(jl.crc).

           wrk.r-who = tmp-jh.who.
           wrk.c-who = GetWhoAccept (tmp-jh.sub, tmp-jh.ref).
           if wrk.c-who = wrk.r-who then wrk.c-who = "".
           if wrk.c-who = "" then do:
              find first jl where jl.jh = tmp-jh.jh no-lock no-error.
              if avail jl then wrk.c-who = jl.teller.
              if wrk.c-who = wrk.r-who then wrk.c-who = "".
           end.
           */


            find trxcods where trxcods.trxh = jl.jh
                  and trxcods.trxln = jl.ln
                  and trxcods.codfr = "spnpl" no-lock no-error.
            if available trxcods then wrk.v-knp =  trxcods.code.
            if wrk.v-knp = "" then wrk.v-knp = GetKNP(tmp-jh.sub, tmp-jh.ref).



          end. /*if tmp-jh.who <> "SUPERMAN" and tmp-jh.who <> "BANKADM"*/

        end.

   end.


   /*Переводы*/
   if TypePay = 1 or TypePay = 2 or TypePay = 3 or TypePay = 4 then do:
         find first remtrz where remtrz.jh1 = tmp-jh.jh and remtrz.valdt1 = tmp-jh.jdt /*and remtrz.rwho = tmp-jh.who*/ no-lock no-error.
         if avail remtrz then do:
           if remtrz.source = "IBH" then  wrk.v-oper = "IBS".

           /*
           if remtrz.rwho = "superman" then do:
             find first doc_who_create where doc_who_create.docno = remtrz.remtrz no-lock no-error.
             if avail doc_who_create then wrk.r-who = doc_who_create.who_cr.
             else wrk.r-who = remtrz.rwho.
           end.
           else wrk.r-who = remtrz.rwho.
           */

           if (remtrz.rwho <> "superman" and remtrz.rwho <> "") and (remtrz.cwho <> "superman" and remtrz.cwho <> "") then
           do:
             wrk.r-who = remtrz.rwho.
             wrk.c-who = remtrz.cwho.
           end.
           else do:
               find first doc_who_create where doc_who_create.docno = remtrz.remtrz no-lock no-error.
               if avail doc_who_create then do:
                wrk.r-who = doc_who_create.who_cr.
                if remtrz.rwho <> "superman" and remtrz.rwho <> "" then wrk.c-who = remtrz.rwho.
               end.
               else do:
                 wrk.r-who = remtrz.rwho.
                 wrk.c-who = remtrz.cwho.
               end.
           end.


           if wrk.c-who = "" or wrk.c-who = "superman" then do:
             wrk.c-who = GetWhoAccept ("rmz", remtrz.remtrz).
             if wrk.c-who = "" then do:
               find first jh where jh.jh = remtrz.jh2 no-lock no-error.
               if avail jh and jh.who <> "superman" then wrk.c-who = jh.who.
             end.
           end.
           if wrk.r-who = "" or wrk.r-who = "superman" then do: wrk.r-who = wrk.c-who. wrk.c-who = "". end.
           if wrk.c-who = wrk.r-who then wrk.c-who = "".

           wrk.v-detpay = trim(remtrz.detpay[1] + remtrz.detpay[2] + remtrz.detpay[3] + remtrz.detpay[4]).
           wrk.v-crc = GetCRC(remtrz.tcrc).

           if remtrz.sacc = "" then wrk.s-acc = string(remtrz.svcgl).
           else wrk.s-acc = remtrz.sacc.

           wrk.cif-name = remtrz.ord.

           /* если нет счета получателя - берем счет бенефициара*/
           if remtrz.racc = "" then wrk.r-acc = remtrz.ba.
           else wrk.r-acc = remtrz.racc.

           find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
           if avail sub-cod then  do:
             wrk.v-knp = entry(3,sub-cod.rcode,',').
           end.
           else message "Не найден КНП по " remtrz.remtrz view-as alert-box.



           /*+ " " + remtrz.vcact*/  /*вал.кон. не нужен*/
          /* if wrk.c-who = "" then wrk.c-who = remtrz.remtrz. если нет контролера то ставим номер документа*/

          /* if wrk.c-who = "auto" then wrk.c-who = "".*/

           wrk.v-summ = remtrz.payment.
           wrk.docno = remtrz.remtrz.


           if index(wrk.r-acc,"/") = 1 then wrk.r-acc = substr(wrk.r-acc,2, length(wrk.r-acc)).
           if index(wrk.r-acc,"/") > 0 then wrk.r-acc = substr(wrk.r-acc,1,index(wrk.r-acc,"/")).
         end.
         else message "Не найден RMZ по проводке " tmp-jh.jh view-as alert-box.
   end.

   /*Конвертации*/
   if TypePay = 5 or TypePay = 6 or TypePay = 7 then do:

       find first dealing_doc where dealing_doc.jh = tmp-jh.jh and dealing_doc.whn_cr = tmp-jh.jdt  /*and dealing_doc.who_cr = tmp-jh.who*/ no-lock no-error.
       if avail dealing_doc then do:
          if dealing_doc.who_cr = "inbank" then wrk.v-oper = "IBS".
          case dealing_doc.DocType:
            when 1 then do:
              wrk.v-detpay = "Срочная покупка ин. валюты ЮЛ".
              wrk.v-crc = GetAccCRC(dealing_doc.tclientaccno).
              wrk.v-summ = dealing_doc.t_amount.
              wrk.cif-name = GetAccCif(dealing_doc.tclientaccno).
              wrk.s-acc = dealing_doc.tclientaccno.
              wrk.r-acc = dealing_doc.vclientaccno.

            end.
            when 2 then do:
              wrk.v-detpay = "Обычная покупка ин. валюты ЮЛ".
              find first b-tmp-jh where b-tmp-jh.jh = dealing_doc.jh2 exclusive-lock no-error.
              if avail b-tmp-jh then do: delete b-tmp-jh. /*message "OK". pause 1.*/ end.
              else message "Не найдена вторая проводка!" dealing_doc.docno dealing_doc.jh2 view-as alert-box.
              wrk.v-crc = GetAccCRC(dealing_doc.tclientaccno).
              wrk.v-summ = dealing_doc.t_amount.
              wrk.cif-name = GetAccCif(dealing_doc.tclientaccno).
              wrk.s-acc = dealing_doc.tclientaccno.
              wrk.r-acc = dealing_doc.vclientaccno.

            end.
            when 3 then do:
              wrk.v-detpay = "Срочная продажа ин. валюты ЮЛ".
              wrk.v-crc = GetAccCRC(dealing_doc.vclientaccno).
              wrk.v-summ = dealing_doc.v_amount.
              wrk.cif-name = GetAccCif(dealing_doc.vclientaccno).
              wrk.s-acc = dealing_doc.vclientaccno.
              wrk.r-acc = dealing_doc.tclientaccno.

            end.
            when 4 then do:
              wrk.v-detpay = "Обычная продажа ин. валюты ЮЛ".
              find first b-tmp-jh where b-tmp-jh.jh = dealing_doc.jh2 exclusive-lock no-error.
              if avail b-tmp-jh then do: delete b-tmp-jh. /*message "OK". pause 1.*/ end.
              else message "Не найдена вторая проводка!" dealing_doc.docno dealing_doc.jh2 view-as alert-box.
              wrk.v-crc = GetAccCRC(dealing_doc.vclientaccno).
              wrk.v-summ = dealing_doc.v_amount.
              wrk.cif-name = GetAccCif(dealing_doc.vclientaccno).
              wrk.s-acc = dealing_doc.vclientaccno.
              wrk.r-acc = dealing_doc.tclientaccno.

            end.
            when 5 then do:

              if GetAccCRC(dealing_doc.tclientaccno) = "KZT" then do:
                 wrk.ind = 5.
                 wrk.v-detpay = "Покупка валюты депозиты ФЛ".
              end.
              if GetAccCRC(dealing_doc.vclientaccno) = "KZT" then do:
                 wrk.ind = 6.
                 wrk.v-detpay = "Продажа валюты депозиты ФЛ".
              end.
              if GetAccCRC(dealing_doc.tclientaccno) <> "KZT" and GetAccCRC(dealing_doc.vclientaccno) <> "KZT" then wrk.v-detpay = "Кросс-конвертация депозитов ФЛ".


              wrk.v-crc = GetAccCRC(dealing_doc.tclientaccno).
              wrk.v-summ = dealing_doc.t_amount.
              wrk.cif-name = GetAccCif(dealing_doc.tclientaccno).
              wrk.s-acc = dealing_doc.tclientaccno.
              wrk.r-acc = dealing_doc.vclientaccno.


            end.
            when 6 then do:
              wrk.v-detpay = "Кросс-конвертация для ЮЛ и ФЛ".
              wrk.v-crc = GetAccCRC(dealing_doc.tclientaccno).
              wrk.v-summ = dealing_doc.t_amount.
              wrk.cif-name = GetAccCif(dealing_doc.tclientaccno).
              wrk.s-acc = dealing_doc.tclientaccno.
              wrk.r-acc = dealing_doc.vclientaccno.
            end.
          end case.

          wrk.r-who = dealing_doc.who_cr.
          wrk.c-who = dealing_doc.who_mod.
          if wrk.r-who = "inbank" then wrk.r-who = wrk.c-who.
          if wrk.r-who = wrk.c-who then wrk.c-who = "".

          wrk.v-knp = "213".

          wrk.docno = dealing_doc.docno.
       end.
       else message "Не найден документ на конвертацию по проводке " tmp-jh.jh view-as alert-box.


   end.

   hide message no-pause.
   message "Формирование отчета - " LN[i] .
   if i = 8 then i = 1.
   else i = i + 1.

 end. /*for each tmp-jh:*/

  hide message no-pause.

/* убираем служебние символы в примечании*/
 for each wrk:
  if index(wrk.v-detpay,"<<") > 0 then wrk.v-detpay = replace(wrk.v-detpay,"<<"," ").
 end.

/*Формирование отчета*/

if v-ofc <> "" then do:
   for each wrk:
     if /*wrk.c-who = v-ofc or*/ wrk.r-who = v-ofc then next.
     else delete wrk.
   end.
end.

if v-ibh = 2 then do:
   for each wrk:
     if wrk.v-oper = "IBS" then delete wrk.
   end.
end.

if v-ibh = 3 then do:
   for each wrk:
     if wrk.v-oper <> "IBS" then delete wrk.
   end.
end.

  /*Сортировка по валютам*/
  for each wrk:
    case wrk.v-crc:
       when "KZT" then wrk.sort-crc = 1.
       when "USD" then wrk.sort-crc = 2.
       when "EUR" then wrk.sort-crc = 3.
       when "RUB" then wrk.sort-crc = 4.
       when "GBP" then wrk.sort-crc = 5.
       when "SEK" then wrk.sort-crc = 6.
       when "AUD" then wrk.sort-crc = 7.
       when "CHF" then wrk.sort-crc = 8.
       otherwise do:
         message "Неизвестная валюта! " wrk.oper-type wrk.v-crc wrk.v-trx view-as alert-box.
       end.
     end case.

     /*подсортировка прочих*/
     if wrk.ind = 8 then do:

      if string(wrk.d-gl) begins("2206") or string(wrk.d-gl) begins("2207") or string(wrk.d-gl) begins("2215") or string(wrk.d-gl) begins("2217") or
         string(wrk.c-gl) begins("2206") or string(wrk.c-gl) begins("2207") or string(wrk.c-gl) begins("2215") or string(wrk.c-gl) begins("2217") then do:

        wrk.gl-sort = 1.
        wrk.gl-sort-name = "Операции по депозитам".
      end.

      if string(wrk.d-gl) begins("2203") or string(wrk.d-gl) begins("2204") or
         string(wrk.c-gl) begins("2203") or string(wrk.c-gl) begins("2204") or
         ( wrk.c-gl = 100100 and string(wrk.d-gl) begins("287031") )  then do:

        wrk.gl-sort = 2.
        wrk.gl-sort-name = "Операции по текущим счетам юридических лиц".
      end.

      if string(wrk.d-gl) begins("2205") or string(wrk.c-gl) begins("2205") then do:

        wrk.gl-sort = 3.
        wrk.gl-sort-name = "Операции по текущим счетам физических лиц".
      end.

      if ( wrk.d-gl = 100100 and string(wrk.c-gl) begins("2870") ) or
         ( wrk.c-gl = 100100 and string(wrk.d-gl) begins("1870") ) or
         ( wrk.d-gl = 100100 and wrk.c-gl = 255120 ) then do:

        wrk.gl-sort = 4.
        wrk.gl-sort-name = "Быстрые переводы".
      end.

      if wrk.gl-sort = ? or wrk.gl-sort = 0 then do:
       wrk.gl-sort = 5.
       wrk.gl-sort-name = "Прочие кассовые операции".
      end.



     end.

  end.
/******************************************************************************************************************/
def stream rep.
repname = "rpt_" + s-ourbank + "_" + replace(string(dt1,"99/99/9999"),"/","-") + "_" +  replace(string(dt2,"99/99/9999"),"/","-") + ".htm".
output stream rep to value(repname).

/*v-repwho*/
 put stream rep "<html><head><title>Реестр по проведенным операциям</title>" skip
                       "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                       "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
/*xx-small*/


 put stream rep unformatted
  "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
  "<tr><td><img width=""408"" height=""52"" src=""c://tmp/top_logo_bw.jpg"" /></td>" skip
    "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td colspan=""4""><div align=""center"">РЕЕСТР ПО ПРОВЕДЕННЫМ ОПЕРАЦИЯМ</div></td>" skip
    "</tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td colspan=""4""><div align=""center"">" v-repwho "</div></td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td colspan=""4""><div align=""center"">" "C " string(dt1,"99/99/9999") " по " string(dt2,"99/99/9999") "</div></td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td><div align=""right"">Таблица 1</div></td></tr>" skip
  "</table>" skip.



 put stream rep unformatted
 "<table width=""100%"" border=""1"" cellpadding=""0"" cellspacing=""0"" >" skip
  "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td width=""96"" >№ транзакции </td>" skip
    "<td width=""40"" >№ п/п </td>" skip
    "<td width=""82"">Вид операции </td>" skip
    "<td width=""37"">Дата</td>" skip
    "<td width=""51"">Время</td>" skip
    "<td width=""123"">Наименование клиента </td>" skip
    "<td width=""107"">Счет отправителя </td>" skip
    "<td width=""69"">Вид валюты </td>" skip
    "<td width=""52"">Сумма</td>" skip
    "<td width=""97"">Счет получателя </td>" skip
    "<td width=""30"">Кнп</td>" skip
    "<td width=""99"">Назначение платежа </td>" skip
    "<td width=""109"">ID исполнителя </td>" skip
    "<td width=""108"" >ID контролёра </td>" skip
  "</tr>" skip.



def var KZT-summ as deci init 0.
def var USD-summ as deci init 0.
def var EUR-summ as deci init 0.
def var RUB-summ as deci init 0.
def var GBP-summ as deci init 0.
def var SEK-summ as deci init 0.
def var AUD-summ as deci init 0.
def var CHF-summ as deci init 0.


def var i-pos as int init 1.
function PrintSumm returns integer (input val as char, input summ as deci).
   put stream rep unformatted
 "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td colspan=""8"">ИТОГО " val ":</td>" skip
    "<td colspan=""1"">&nbsp;" string(summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
    "<td colspan=""5"">&nbsp;</td>" skip
  "</tr>" skip.
    return 0.
end function.

function PrintSumm2 returns integer (input val as char, input summ as deci).
   put stream rep unformatted
 "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td colspan=""8"">ИТОГО " val ":</td>" skip
    "<td >&nbsp;" string(summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
    "<td colspan=""4"">&nbsp;</td>" skip
  "</tr>" skip.
    return 0.
end function.


  for each wrk break by wrk.ind by wrk.sort-crc /*wrk.v-crc*/ /*wrk.v-date*/:
   if wrk.ind = 8 or wrk.ind = 9 then next.
    if first-of(wrk.ind) then do:

     if KZT-summ > 0 then PrintSumm("KZT",KZT-summ).
     if USD-summ > 0 then PrintSumm("USD",USD-summ).
     if EUR-summ > 0 then PrintSumm("EUR",EUR-summ).
     if RUB-summ > 0 then PrintSumm("RUB",RUB-summ).
     if GBP-summ > 0 then PrintSumm("GBP",GBP-summ).
     if SEK-summ > 0 then PrintSumm("SEK",SEK-summ).
     if AUD-summ > 0 then PrintSumm("AUD",AUD-summ).
     if CHF-summ > 0 then PrintSumm("CHF",CHF-summ).

     KZT-summ = 0. USD-summ = 0. EUR-summ = 0. RUB-summ = 0. GBP-summ = 0. SEK-summ = 0. AUD-summ = 0. CHF-summ = 0 .

     put stream rep unformatted "<tr style=""font:bold;font-size:10""><td colspan=""14"" > <strong><em>" wrk.oper-type " </em></strong> </td></tr>" skip.

    end.
     put stream rep unformatted
     "<tr style=""font-size:10"">" skip
     "<td>&nbsp;" wrk.v-trx "</td>" skip
     "<td>&nbsp;" string(i-pos,"999") "</td>" skip
     "<td>&nbsp;" wrk.v-oper "</td>" skip
     "<td>&nbsp;" string(wrk.v-date,"99/99/9999") "</td>" skip
     "<td>&nbsp;" string(wrk.v-time,"HH:MM:SS") "</td>" skip
     "<td>&nbsp;" wrk.cif-name "</td>" skip
     "<td>&nbsp;" wrk.s-acc "</td>" skip
     "<td>&nbsp;" wrk.v-crc "</td>" skip
     "<td>&nbsp;" string(wrk.v-summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
     "<td>&nbsp;" wrk.r-acc "</td>" skip
     "<td>&nbsp;" wrk.v-knp "</td>" skip
     "<td>&nbsp;" wrk.v-detpay "</td>" skip
     "<td>&nbsp;" wrk.r-who "</td>" skip
     "<td>&nbsp;" wrk.c-who "</td>" skip
     "</tr>" skip.
      i-pos = i-pos + 1.
     case wrk.v-crc:
       when "KZT" then do: KZT-summ = KZT-summ + wrk.v-summ.
       end.
       when "USD" then do: USD-summ = USD-summ + wrk.v-summ.
       end.
       when "EUR" then do: EUR-summ = EUR-summ + wrk.v-summ.
       end.
       when "RUB" then do: RUB-summ = RUB-summ + wrk.v-summ.
       end.
       when "GBP" then do: GBP-summ = GBP-summ + wrk.v-summ.
       end.
       when "SEK" then do: SEK-summ = SEK-summ + wrk.v-summ.
       end.
       when "AUD" then do: AUD-summ = AUD-summ + wrk.v-summ.
       end.
       when "CHF" then do: CHF-summ = CHF-summ + wrk.v-summ.
       end.
       otherwise do:
         message "Неизвестная валюта! " wrk.oper-type wrk.v-crc wrk.v-trx view-as alert-box.
       end.
     end case.
     /*all-summ = all-summ + wrk.v-summ.*/
  end.

     if KZT-summ > 0 then PrintSumm("KZT",KZT-summ).
     if USD-summ > 0 then PrintSumm("USD",USD-summ).
     if EUR-summ > 0 then PrintSumm("EUR",EUR-summ).
     if RUB-summ > 0 then PrintSumm("RUB",RUB-summ).
     if GBP-summ > 0 then PrintSumm("GBP",GBP-summ).
     if SEK-summ > 0 then PrintSumm("SEK",SEK-summ).
     if AUD-summ > 0 then PrintSumm("AUD",AUD-summ).
     if CHF-summ > 0 then PrintSumm("CHF",CHF-summ).

/*
 put stream rep unformatted
 "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td colspan=""7"">ИТОГО:</td>" skip
    "<td colspan=""1"">&nbsp;" string(all-summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
    "<td colspan=""5"">&nbsp;</td>" skip
  "</tr>" skip.
*/


/*Убираем внебаланс*/
for each wrk where string(wrk.d-gl) begins("7303") or string(wrk.c-gl) begins("7303").
 delete wrk.
end.

 put stream rep unformatted "</table>".

 put stream rep unformatted
  "<p>&nbsp; </p><p><em><strong>Другие операции</strong></em></p>" skip
  "<table width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
  "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td>№ транзакции</td>" skip
    "<td>№ п/п</td>" skip
    "<td>Дата</td>" skip
    "<td>Время</td>" skip
    "<td>Счёт ГК Дт</td>" skip
    "<td>Счёт ГК Кт</td>" skip
    "<td>Счёт клиента</td>" skip
    "<td>Вид валюты</td>" skip
    "<td>Сумма</td>" skip
    "<td>КНП</td>" skip
    "<td>Назначение платежа</td>" skip
    "<td>iD исполнителя</td>" skip
    "<td>iD контролёра</td>" skip
  "</tr>" skip.

 /* all-summ = 0.*/
  KZT-summ = 0. USD-summ = 0. EUR-summ = 0. RUB-summ = 0. GBP-summ = 0. SEK-summ = 0. AUD-summ = 0. CHF-summ = 0 .

   for each wrk where wrk.ind = 8 or wrk.ind = 9 break by wrk.ind by wrk.gl-sort by wrk.sort-crc  /*wrk.v-crc*/ /*wrk.v-date*/:

    if first-of(wrk.ind) then do:

     if KZT-summ > 0 then PrintSumm2("KZT",KZT-summ).
     if USD-summ > 0 then PrintSumm2("USD",USD-summ).
     if EUR-summ > 0 then PrintSumm2("EUR",EUR-summ).
     if RUB-summ > 0 then PrintSumm2("RUB",RUB-summ).
     if GBP-summ > 0 then PrintSumm2("GBP",GBP-summ).
     if SEK-summ > 0 then PrintSumm2("SEK",SEK-summ).
     if AUD-summ > 0 then PrintSumm2("AUD",AUD-summ).
     if CHF-summ > 0 then PrintSumm2("CHF",CHF-summ).

     KZT-summ = 0. USD-summ = 0. EUR-summ = 0. RUB-summ = 0. GBP-summ = 0. SEK-summ = 0. AUD-summ = 0. CHF-summ = 0 .

     put stream rep unformatted "<tr style=""font:bold;font-size:10""><td colspan=""13"" > <strong><em>" wrk.oper-type " </em></strong> </td></tr>" skip.

    end.

    if first-of(wrk.gl-sort) and wrk.ind = 8 then do:
     put stream rep unformatted "<tr style=""font:bold;font-size:10""><td colspan=""13"" > <strong><em>" wrk.gl-sort-name " </em></strong> </td></tr>" skip.
    end.

    put stream rep unformatted
     "<tr style=""font-size:10"">" skip
     "<td>&nbsp;" wrk.v-trx "</td>" skip
     "<td>&nbsp;" string(i-pos,"999") "</td>" skip
     "<td>&nbsp;" string(wrk.v-date,"99/99/9999") "</td>" skip
     "<td>&nbsp;" string(wrk.v-time,"HH:MM:SS") "</td>" skip
     "<td>&nbsp;" string(wrk.d-gl) "</td>" skip
     "<td>&nbsp;" string(wrk.c-gl) "</td>" skip
     "<td>&nbsp;" wrk.s-acc "</td>" skip
     "<td>&nbsp;" wrk.v-crc "</td>" skip
     "<td>&nbsp;" string(wrk.v-summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
     "<td>&nbsp;" wrk.v-knp "</td>" skip
     "<td>&nbsp;" wrk.v-detpay "</td>" skip
     "<td>&nbsp;" wrk.r-who "</td>" skip
     "<td>&nbsp;" wrk.c-who "</td>" skip

    /* "<td>&nbsp;" wrk.cif-name "</td>" skip*/


    /* "<td>&nbsp;" wrk.r-acc "</td>" skip*/

     "</tr>" skip.
      i-pos = i-pos + 1.
     case wrk.v-crc:
       when "KZT" then do: KZT-summ = KZT-summ + wrk.v-summ.
       end.
       when "USD" then do: USD-summ = USD-summ + wrk.v-summ.
       end.
       when "EUR" then do: EUR-summ = EUR-summ + wrk.v-summ.
       end.
       when "RUB" then do: RUB-summ = RUB-summ + wrk.v-summ.
       end.
       when "GBP" then do: GBP-summ = GBP-summ + wrk.v-summ.
       end.
       when "SEK" then do: SEK-summ = SEK-summ + wrk.v-summ.
       end.
       when "AUD" then do: AUD-summ = AUD-summ + wrk.v-summ.
       end.
       when "CHF" then do: CHF-summ = CHF-summ + wrk.v-summ.
       end.
       otherwise do:
         message "Неизвестная валюта! " wrk.oper-type wrk.v-crc wrk.v-trx view-as alert-box.
       end.
     end case.

  /* all-summ = all-summ + wrk.v-summ.*/
  end.

     if KZT-summ > 0 then PrintSumm2("KZT",KZT-summ).
     if USD-summ > 0 then PrintSumm2("USD",USD-summ).
     if EUR-summ > 0 then PrintSumm2("EUR",EUR-summ).
     if RUB-summ > 0 then PrintSumm2("RUB",RUB-summ).
     if GBP-summ > 0 then PrintSumm2("GBP",GBP-summ).
     if SEK-summ > 0 then PrintSumm2("SEK",SEK-summ).
     if AUD-summ > 0 then PrintSumm2("AUD",AUD-summ).
     if CHF-summ > 0 then PrintSumm2("CHF",CHF-summ).

/*
 put stream rep unformatted
 "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td colspan=""7"">ИТОГО:</td>" skip
    "<td >&nbsp;" string(all-summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
    "<td colspan=""4"">&nbsp;</td>" skip
  "</tr>" skip.
*/

 put stream rep unformatted "</table>".




 put stream rep unformatted "</body></html>" skip.

 output stream rep close.
 unix silent value("cptwin " + repname + " excel").


/*if VALID-OBJECT(Usr)  then DELETE OBJECT Usr NO-ERROR .*/
/*if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR .*/



/*
<table width="100" border="1" cellpadding="0" cellspacing="0" >
  <tr style="font:bold;font-size:10">
    <td width="96" >№ транзакции </td>
    <td width="82">Вид операции </td>
    <td width="37">Дата</td>
    <td width="51">Время</td>
    <td width="123">Наименование клиента </td>
    <td width="107">Счет отправителя </td>
    <td width="69">Вид валюты </td>
    <td width="52">Сумма</td>
    <td width="97">Счет получателя </td>
    <td width="30">Кнп</td>
    <td width="99">Назначение платежа </td>
    <td width="109">ID исполнителя </td>
    <td width="108" >ID контролера </td>
  </tr>

  <tr style="font:bold;font-size:10">
    <td colspan="13" >тип платежа </td>
  </tr>
  <tr style="font:bold;font-size:10">
    <td >&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td >&nbsp;</td>
  </tr>
</table>
*/