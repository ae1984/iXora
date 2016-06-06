/* csprint.p
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
        15/05/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/

{classes.i}
{cm18.i}
{cm18_abs.i}

def input param v-safe as char.
def var v-repwho as char.
def var v-departs as char.
def var repname as char.
def var captrep as char.
def var v-type as log init false.

def var KZT-val as deci init 0.
def var USD-val as deci init 0.
def var EUR-val as deci init 0.
def var RUR-val as deci init 0.

def stream rep.
 find first wrk no-lock no-error.
 find first wrk_ext no-lock no-error.
  if not avail wrk and not avail wrk_ext then do:
    message "Нет данных о конфигурации сейфа!" view-as alert-box.
    return.
  end.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def temp-table prt_wrk no-undo
  field ind as int
  field num as char /*номер кассеты (как в сейфе)*/
  field cass as char /*Обозначение кассеты KZNA */
  field crc as char /*Валюта*/
  field nom as int /*Номинал*/
  field used as int /*занято*/
  field out as int  /*при выдаче*/
  field out_summ as int
  field summ as int. /*Сумма в кассете*/

  def var v-ind as int init 1.

  for each wrk where wrk.nom <> 0 no-lock:
    if wrk.out > 0 then v-type = true.
  end.
  for each wrk_ext no-lock:
    if wrk_ext.out > 0 then v-type = true.
  end.

  if v-type then do:
      for each wrk where wrk.nom <> 0 and wrk.out > 0 no-lock:
        create prt_wrk.
         prt_wrk.ind = v-ind.
         prt_wrk.num = wrk.num.
         prt_wrk.cass = string(GetCassNo(prt_wrk.num)).
         prt_wrk.crc = wrk.crc.
         prt_wrk.nom = wrk.nom.
         prt_wrk.used = wrk.out.
         prt_wrk.summ = prt_wrk.nom * prt_wrk.used.
         v-ind = v-ind + 1.
      end.
      for each wrk_ext where wrk_ext.out > 0 no-lock:
        create prt_wrk.
         prt_wrk.ind = v-ind.
         prt_wrk.num = wrk_ext.num.
         prt_wrk.cass = string(GetCassNo(prt_wrk.num)).
         prt_wrk.crc = wrk_ext.crc.
         prt_wrk.nom = wrk_ext.nom.
         prt_wrk.used = wrk_ext.out.
         prt_wrk.summ = prt_wrk.nom * prt_wrk.used.
         v-ind = v-ind + 1.
      end.
  end.
  else do:
      for each wrk where wrk.nom <> 0 no-lock:
        create prt_wrk.
         prt_wrk.ind = v-ind.
         prt_wrk.num = wrk.num.
         prt_wrk.cass = string(GetCassNo(prt_wrk.num)).
         prt_wrk.crc = wrk.crc.
         prt_wrk.nom = wrk.nom.
         prt_wrk.used = wrk.used.
         prt_wrk.summ = prt_wrk.nom * prt_wrk.used.
         v-ind = v-ind + 1.
      end.
      for each wrk_ext no-lock:
        create prt_wrk.
         prt_wrk.ind = v-ind.
         prt_wrk.num = wrk_ext.num.
         prt_wrk.cass = string(GetCassNo(prt_wrk.num)).
         prt_wrk.crc = wrk_ext.crc.
         prt_wrk.nom = wrk_ext.nom.
         prt_wrk.used = wrk_ext.used.
         prt_wrk.summ = prt_wrk.nom * prt_wrk.used.
         v-ind = v-ind + 1.
      end.
  end.

/**************************************************************************************/
function PrintAllSumm returns integer (input val as char, input d-summ as deci).
   put stream rep unformatted
 "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td colspan=""3"">ИТОГО " ":</td>" skip
    "<td >&nbsp;" string(d-summ,"->>>,>>>,>>>,>>>,>>>.99") "</td>" skip
    "<td >" val "</td>" skip
  "</tr>" skip.
    return 0.
end function.
/**************************************************************************************/
function GetDate returns char ( input dt as date):
  return replace(string(dt,"99/99/9999"),"/",".").
end function.
/**************************************************************************************/

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then do:
   v-repwho = ofc.name.
end.
v-departs = Base:b-addr.

if v-type then captrep = "Инкассация ЭК ".
else captrep = "Состояние ЭК ".
captrep = captrep + v-safe + " " + GetDate(today) + " " +  string(time,"HH:MM:SS").

repname = "rptsc.htm".
output stream rep to value(repname).
put stream rep unformatted
    "<html><head><title>Состояние электронного кассира</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


put stream rep unformatted "<table width=""600"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
put stream rep unformatted "<tr><td colspan=""5"" ><img width=""202"" height=""33"" src=""http://portal/_layouts/images/top_logo_bw.jpg"" /></td></tr>" skip
    "<tr><td colspan=""5"">&nbsp;</td></tr><tr><td colspan=""5"">" v-repwho "</td></tr>" skip
    "<tr><td colspan=""5"">" v-departs "</td></tr></table>" skip.
    put stream rep unformatted "<table width=""600"" border=""1"" cellspacing=""0"" cellpadding=""0""><tr style=""font:bold;font-size:12"" align=""center""><td colspan=""5"">" captrep "</td></tr>" skip
    "<tr style=""font:bold;font-size:10""bgcolor=""#C0C0C0"">" skip
    "<td>№ барабана</td>" skip
    "<td>Номинал</td>" skip
    "<td>Кол-во</td>" skip
    "<td>Сумма</td>" skip
    "<td>Валюта</td>" skip
    "</tr>" skip.

  for each prt_wrk.
    put stream rep unformatted
        "<tr style=""font-size:10"">" skip
        "<td>"  prt_wrk.cass  "</td>" skip
        "<td>"  string(prt_wrk.nom)  "</td>" skip
        "<td>"  string(prt_wrk.used)  "</td>" skip
        "<td>"  string(prt_wrk.summ,"->>>,>>>,>>>.99")  "</td>" skip
        "<td>"  prt_wrk.crc "</td>" skip
        "</tr>" skip.
      case prt_wrk.crc:
        when "KZT" then do:
          KZT-val = KZT-val + prt_wrk.summ.
        end.
        when "USD" then do:
          USD-val = USD-val + prt_wrk.summ.
        end.
        when "EUR" then do:
          EUR-val = EUR-val + prt_wrk.summ.
        end.
        when "RUR" then do:
          RUR-val = RUR-val + prt_wrk.summ.
        end.
      end case.
  end.

  if KZT-val > 0 then PrintAllSumm("KZT",KZT-val).
  if USD-val > 0 then PrintAllSumm("USD",USD-val).
  if EUR-val > 0 then PrintAllSumm("EUR",EUR-val).
  if RUR-val > 0 then PrintAllSumm("RUR",RUR-val).


 put stream rep unformatted "</table>".

 put stream rep unformatted "</body></html>" skip.
 output stream rep close.
 unix silent value("cptwin " + repname + " excel").
