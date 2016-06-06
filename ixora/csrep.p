/* csrep.p
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
        27.02.2012 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        07.06.2012 k.gitalov расширил формат номера проводки
        13.07.2012 Lyubov - перекомпиляция

*/

{classes.i}
{cm18_abs.i}

def var r-type as char.
def var r-type2 as char.
def var v-ofc as char.
def var v-dep as char.
def var v-ibh as int.
def var v-departs as char.
def var v-repwho as char.
def var repname as char.
def var v-safe as char.
def var KZT-dam as deci init 0.
def var USD-dam as deci init 0.
def var EUR-dam as deci init 0.
def var RUB-dam as deci init 0.
def var KZT-cam as deci init 0.
def var USD-cam as deci init 0.
def var EUR-cam as deci init 0.
def var RUB-cam as deci init 0.
def var tmp-dam as deci.
def var tmp-cam as deci.
def buffer b-jl for jl.
def buffer b-jh for jh.
def buffer b-sm18data for sm18data.
def var i-ind as int init 0.
def var v-detpay as char.
def stream rep.

def temp-table wrk no-undo
  field ind as int
  field v-trx as int
  field v-date as date
  field v-time as int
  field d-gl as int
  field c-gl as int
  field d-acc as char
  field c-acc as char
  field v-crc as char
  field dam as deci
  field cam as deci
  field safe-summ as deci
  field tempo-summ as deci
  field v-knp as char
  field v-detpay as char
  field v-safe as char
  field r-who as char
  field c-who as char
  field docno as char format "x(10)"
  field type as int.


def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var dt1 as date no-undo.
def var dt2 as date no-undo.


def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.

/**************************************************************************************/
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
           end.
         end.
      end.
      when "ujo" then do:
          find first trxcods where trxcods.trxh = integer(docno) and trxcods.trxln = 1 and trxcods.codfr = "spnpl" no-lock no-error.
          if available trxcods then res = trxcods.code.
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
function PrintAllSumm returns integer (input val as char, input d-summ as deci,input c-summ as deci).
   put stream rep unformatted
 "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td colspan=""4"">ИТОГО " val ":</td>" skip
    "<td >&nbsp;" string(d-summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
    "<td >&nbsp;" string(c-summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
    "<td colspan=""8"">&nbsp;</td>" skip
  "</tr>" skip.
    return 0.
end function.
/**************************************************************************************/
function PrintTempoSumm returns integer (input val as char, input d-summ as deci,input c-summ as deci).
   put stream rep unformatted
 "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td colspan=""4"">ИТОГО " val ":</td>" skip
    "<td >&nbsp;" string(d-summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
    "<td >&nbsp;" string(c-summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
    "<td colspan=""5"">&nbsp;</td>" skip
  "</tr>" skip.
    return 0.
end function.
/**************************************************************************************/

dt1 = g-today.
dt2 = g-today.
update dt1 label ' Период с ' format '99/99/9999'
       dt2 label ' по ' format '99/99/9999' skip
       with side-labels row 13 centered frame dat.
hide frame dat.

    run sel1("Тип отчета", "По исполнителю|По ЭК").
    r-type = return-value.
    if r-type = "" then return.
    case r-type:
      when "По исполнителю" then do:
      v-ofc = g-ofc.
       displ v-ofc label "ID" with side-label row 6 centered frame who.
       update v-ofc with frame who.

       find first ofc where ofc.ofc = v-ofc no-lock no-error.
       if avail ofc then do:
         /*выборка транзакций по конкретному пользователю*/
         v-repwho = ofc.name.

       end.
       else do: message "Не найден пользователь " v-ofc view-as alert-box. undo. end.
      end.
      when "По ЭК" then do:

        run SelectSafe(s-ourbank,Base:dep-id, output v-safe).
        if v-safe = "" then
        do:
            message "Нет доступного ЭК!" view-as alert-box.
            undo.
        end.
        if Base:dep-id = 1 then v-dep = '514'.
        else v-dep = "A" + string(Base:dep-id,'99').
        v-departs = Base:b-addr.
        v-repwho = v-safe + " " + v-departs.

      end.
    end case.


 for each jl where jl.gl = 100500 and jl.jdt >= dt1 and jl.jdt <= dt2 and jl.sts = 6 no-lock break by jl.jh:
   if first-of(jl.jh) then do:
     find first b-jh where b-jh.jh = jl.jh no-lock.
     find first b-sm18data where b-sm18data.jh = jl.jh and b-sm18data.state = 1 no-lock no-error.
     if v-ofc <> "" and (b-jh.who <> v-ofc and jl.teller <> v-ofc) then next.
     if not avail b-sm18data then do:
        /*Операции по миникассе*/
        find first b-jh where b-jh.jh = jl.jh no-lock.
         if v-ofc <> "" and (b-jh.who = v-ofc or jl.teller = v-ofc) then do:
            i-ind = i-ind + 1.
            create wrk.
            wrk.ind = i-ind.
            wrk.v-trx = b-jh.jh.
            wrk.v-date = jl.jdt. /*b-jh.whn.*/
            wrk.v-time = b-jh.tim.
            wrk.v-crc = GetCRC(jl.crc).
            wrk.dam = jl.dam.
            wrk.cam = jl.cam.
            wrk.v-detpay = trim(jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5]).
            wrk.v-knp =  GetKNP(b-jh.sub, b-jh.ref).
            wrk.r-who = b-jh.who.
            if wrk.r-who <> jl.teller then wrk.c-who = jl.teller.
            wrk.type = 2.
         end.
     end.
     else do:
        if v-safe <> "" and b-sm18data.safe <> v-safe then next.
         for each sm18data where sm18data.jh = jl.jh and sm18data.state = 1 no-lock:
           tmp-dam = 0.
           tmp-cam = 0.
           v-detpay = "".
           if sm18data.oper_id = 10 then do:
              /*Инкассация*/
               for each b-jl where b-jl.jh = jl.jh and b-jl.gl = jl.gl no-lock:
                      find first b-jh where b-jh.jh = jl.jh no-lock.
                      i-ind = i-ind + 1.
                      create wrk.
                      wrk.ind = i-ind.
                      wrk.v-trx = b-jh.jh.
                      wrk.v-date = jl.jdt. /*b-jh.whn.*/
                      wrk.v-time = b-jh.tim.
                      wrk.v-crc = GetCRC(b-jl.crc).
                      wrk.dam = b-jl.dam.
                      wrk.cam = b-jl.cam.
                      wrk.v-detpay = trim(b-jl.rem[1] + b-jl.rem[2] + b-jl.rem[3] + b-jl.rem[4] + b-jl.rem[5]).
                      wrk.v-safe = sm18data.safe.
                      wrk.v-knp =  GetKNP(b-jh.sub, b-jh.ref).
                      wrk.r-who = b-jh.who.
                      if wrk.r-who <> jl.teller then wrk.c-who = jl.teller.
                      wrk.safe-summ = sm18data.before_summ[b-jl.crc] - sm18data.after_summ[b-jl.crc].
                      wrk.tempo-summ = sm18data.tc_summ.
                      wrk.type = 1.
               end.
           end.
           else do:
               for each b-jl where b-jl.jh = jl.jh and b-jl.gl = jl.gl and b-jl.crc = sm18data.crc no-lock:
                 tmp-dam = tmp-dam + b-jl.dam.
                 tmp-cam = tmp-cam + b-jl.cam.
                 if length(v-detpay) > 0 then v-detpay = v-detpay + ", " + trim(b-jl.rem[1] + b-jl.rem[2] + b-jl.rem[3] + b-jl.rem[4] + b-jl.rem[5]).
                 else v-detpay = trim(b-jl.rem[1] + b-jl.rem[2] + b-jl.rem[3] + b-jl.rem[4] + b-jl.rem[5]).
               end.
               i-ind = i-ind + 1.
               create wrk.
                      wrk.ind = i-ind.
                      wrk.v-trx = b-jh.jh.
                      wrk.v-date = jl.jdt. /*b-jh.whn.*/
                      wrk.v-time = b-jh.tim.
                      wrk.v-crc = GetCRC(sm18data.crc).
                      wrk.dam = tmp-dam.
                      wrk.cam = tmp-cam.
                      wrk.v-detpay = v-detpay.
                      wrk.v-safe = sm18data.safe.
                      wrk.v-knp =  GetKNP(b-jh.sub, b-jh.ref).
                      wrk.r-who = b-jh.who.
                      if wrk.r-who <> jl.teller then wrk.c-who = jl.teller.
                      wrk.safe-summ = sm18data.sm_summ.
                      wrk.tempo-summ = sm18data.tc_summ.
                      wrk.type = 1.
           end.
         end.
     end.
   end.

   hide message no-pause.
   message "Поиск операций - " LN[i] .
   if i = 8 then i = 1.
   else i = i + 1.

 end.

hide message no-pause.
find first wrk no-lock no-error.
if not avail wrk then do:
  message "Нет данных за заданный период!" view-as alert-box.
  return.
end.

/******************************************************************************************************************/
repname = "rpt_" + s-ourbank + "_" + replace(string(dt1,"99/99/9999"),"/","-") + "_" +  replace(string(dt2,"99/99/9999"),"/","-") + ".htm".
output stream rep to value(repname).
put stream rep unformatted
    "<html><head><title>Реестр по проведенным операциям</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip
    "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
    "<tr><td><img width=""202"" height=""33"" src=""http://portal/_layouts/images/top_logo_bw.jpg"" /></td>" skip
    "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td colspan=""4""><div align=""center"">РЕЕСТР ПО ОПЕРАЦИЯМ ГК 100500</div></td>" skip
    "</tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td colspan=""4""><div align=""center"">" v-repwho "</div></td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td colspan=""4""><div align=""center"">"  "C " string(dt1,"99/99/9999") " по " string(dt2,"99/99/9999")  "</div></td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>" skip
    "<td><div align=""right""></div></td></tr>" skip
    "</table>" skip.



find first wrk where wrk.type = 1 no-lock no-error.
if avail wrk then do:
    put stream rep unformatted "<table width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.
    put stream rep unformatted "<tr style=""font:bold;font-size:12"" align=""center""><td colspan=""14"">Операции по ЭК</td></tr>" skip
    "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td>№</td>" skip
    "<td>Транзакция</td>" skip
    "<td>Дата</td>" skip
    "<td>Время</td>" skip
    "<td>Дебет</td>" skip
    "<td>Кредит</td>" skip
    "<td>ЭК</td>" skip
    "<td>Миникасса</td>" skip
    "<td>Валюта</td>" skip
    "<td>КНП</td>" skip
    "<td>Примечание</td>" skip
    "<td>Номер ЭК</td>" skip
    "<td>iD исполнителя</td>" skip
    "<td>iD контролёра</td>" skip
    "</tr>" skip.
end.

  i-ind = 1.
  for each wrk where wrk.type = 1 :

       put stream rep unformatted
        "<tr style=""font-size:10"">" skip
        "<td>&nbsp;" string(i-ind) "</td>" skip
        "<td>&nbsp;" string(wrk.v-trx,"9999999") "</td>" skip
        "<td>&nbsp;" string(wrk.v-date,"99/99/9999") "</td>" skip
        "<td>&nbsp;" string(wrk.v-time,"HH:MM:SS") "</td>" skip
        "<td>&nbsp;" string(wrk.dam,"->>>,>>>,>>>.99") "</td>" skip
        "<td>&nbsp;" string(wrk.cam,"->>>,>>>,>>>.99") "</td>" skip
        "<td>&nbsp;" string(wrk.safe-summ,"->>>,>>>,>>>.99") "</td>" skip
        "<td>&nbsp;" string(wrk.tempo-summ,"->>>,>>>,>>>.99")"</td>" skip
        "<td>&nbsp;" wrk.v-crc "</td>" skip
        "<td>&nbsp;" wrk.v-knp   "</td>" skip
        "<td>&nbsp;" replace(wrk.v-detpay,"<<"," ") "</td>" skip
        "<td>&nbsp;" wrk.v-safe "</td>" skip
        "<td>&nbsp;" wrk.r-who "</td>" skip
        "<td>&nbsp;" wrk.c-who "</td>" skip
        "</tr>" skip.


     case wrk.v-crc:
       when "KZT" then do:
         KZT-dam = KZT-dam + wrk.dam.
         KZT-cam = KZT-cam + wrk.cam.
       end.
       when "USD" then do:
         USD-dam = USD-dam + wrk.dam.
         USD-cam = USD-cam + wrk.cam.
       end.
       when "EUR" then do:
         EUR-dam = EUR-dam + wrk.dam.
         EUR-cam = EUR-cam + wrk.cam.
       end.
       when "RUB" or when "RUR" then do:
         RUB-dam = RUB-dam + wrk.dam.
         RUB-cam = RUB-cam + wrk.cam.
       end.
       otherwise do:
         message "Неизвестная валюта! " wrk.v-crc wrk.v-trx view-as alert-box.
       end.
     end case.
     i-ind = i-ind + 1.
  end.

    if KZT-dam <> 0 or KZT-cam <> 0 then PrintAllSumm("KZT",KZT-dam,KZT-cam).
    if USD-dam <> 0 or USD-cam <> 0 then PrintAllSumm("USD",USD-dam,USD-cam).
    if EUR-dam <> 0 or EUR-cam <> 0 then PrintAllSumm("EUR",EUR-dam,EUR-cam).
    if RUB-dam <> 0 or RUB-cam <> 0 then PrintAllSumm("RUB",RUB-dam,RUB-cam).

find first wrk where wrk.type = 1 no-lock no-error.
if avail wrk then put stream rep unformatted "</table>".

/*Миникасса*/
KZT-dam = 0.
USD-dam = 0.
EUR-dam = 0.
RUB-dam = 0.
KZT-cam = 0.
USD-cam = 0.
EUR-cam = 0.
RUB-cam = 0.

 if v-ofc <> "" then do:
  find first wrk where wrk.type = 2 no-lock no-error.
  if avail wrk then do:
    put stream rep unformatted "<br><br><br><table width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.
    put stream rep unformatted "<tr style=""font:bold;font-size:12"" align=""center""><td colspan=""11"">Операции по Миникассе</td></tr>" skip
    "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td>№</td>" skip
    "<td>Транзакция</td>" skip
    "<td>Дата</td>" skip
    "<td>Время</td>" skip
    "<td>Дебет</td>" skip
    "<td>Кредит</td>" skip
    "<td>Валюта</td>" skip
    "<td>КНП</td>" skip
    "<td>iD исполнителя</td>" skip
    "<td>iD контролёра</td>" skip
    "<td>Примечание</td>" skip
    "</tr>" skip.
   end.
      i-ind = 1.
      for each wrk where wrk.type = 2 :
         put stream rep unformatted
            "<tr style=""font-size:10"">" skip
            "<td>&nbsp;" string(i-ind) "</td>" skip
            "<td>&nbsp;" string(wrk.v-trx,"9999999") "</td>" skip
            "<td>&nbsp;" string(wrk.v-date,"99/99/9999") "</td>" skip
            "<td>&nbsp;" string(wrk.v-time,"HH:MM:SS") "</td>" skip
            "<td>&nbsp;" string(wrk.dam,"->>>,>>>,>>>.99") "</td>" skip
            "<td>&nbsp;" string(wrk.cam,"->>>,>>>,>>>.99") "</td>" skip
            "<td>&nbsp;" wrk.v-crc "</td>" skip
            "<td>&nbsp;" wrk.v-knp   "</td>" skip
            "<td>&nbsp;" wrk.r-who "</td>" skip
            "<td>&nbsp;" wrk.c-who "</td>" skip
            "<td>&nbsp;" replace(wrk.v-detpay,"<<"," ") "</td>" skip
            "</tr>" skip.

         case wrk.v-crc:
           when "KZT" then do:
             KZT-dam = KZT-dam + wrk.dam.
             KZT-cam = KZT-cam + wrk.cam.
           end.
           when "USD" then do:
             USD-dam = USD-dam + wrk.dam.
             USD-cam = USD-cam + wrk.cam.
           end.
           when "EUR" then do:
             EUR-dam = EUR-dam + wrk.dam.
             EUR-cam = EUR-cam + wrk.cam.
           end.
           when "RUB" or when "RUR" then do:
             RUB-dam = RUB-dam + wrk.dam.
             RUB-cam = RUB-cam + wrk.cam.
           end.
           otherwise do:
             message "Неизвестная валюта! " wrk.v-crc wrk.v-trx view-as alert-box.
           end.
         end case.
         i-ind = i-ind + 1.
      end.

      if KZT-dam <> 0 or KZT-cam <> 0 then PrintTempoSumm("KZT",KZT-dam,KZT-cam).
      if USD-dam <> 0 or USD-cam <> 0 then PrintTempoSumm("USD",USD-dam,USD-cam).
      if EUR-dam <> 0 or EUR-cam <> 0 then PrintTempoSumm("EUR",EUR-dam,EUR-cam).
      if RUB-dam <> 0 or RUB-cam <> 0 then PrintTempoSumm("RUB",RUB-dam,RUB-cam).

      find first wrk where wrk.type = 2 no-lock no-error.
      if avail wrk then put stream rep unformatted "</table>".
 end.

 put stream rep unformatted "</body></html>" skip.
 output stream rep close.
 unix silent value("cptwin " + repname + " excel").

