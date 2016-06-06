/* dil-rep.p
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
        27/07/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/


{mainhead.i}


define new shared temp-table wrk
                field type as int
                field txb AS char
                field dt as date
                field tm as int
                field trx as int
                field Name as char
                field t-summ as deci
                field t-crc as int
                field v-summ as deci
                field v-crc as int
                field rate as deci
                field com_conv as deci
                field com_crc as int
                field who_cr as char.


def var dt1 as date no-undo.
def var dt2 as date no-undo.

dt2 = g-today.
dt1 = dt2.

displ dt1 label " С " format "99/99/9999" validate( dt1 <= g-today, "Некорректная дата!") skip
      dt2 label " По" format "99/99/9999" validate( dt2 >= dt1, "Некорректная дата!") skip
with side-label row 4 centered frame dat.

update dt1 with frame dat.
update dt2 with frame dat.

/**************************************************************************************/
function GetConvDocType returns char (input val as integer).
    case val:
      when 1 then do:
        return "Покупка".
      end.
      when 2 then do:
        return "Покупка".
      end.
      when 3 then do:
        return "Продажа".
      end.
      when 4 then do:
        return "Продажа".
      end.
      when 5 then do:
        return "Конвертация депозита".
      end.
      when 6 then do:
        return "Кросс-конвертация".
      end.
      otherwise do:
        return "Неизвестно".
      end.
    end case.
end function.
/**************************************************************************************/
function GetNormSumm returns char (input summ as deci ):
   def var ss1 as deci.
   def var ret as char.
   if summ >= 0 then
   do:
    ss1 = summ.
    ret = string(ss1,"->>>>>>>>>>>>>>>>9.99").
   end.
   else do:
    ss1 = - summ.
   ret = "-" + trim(string(ss1,"->>>>>>>>>>>>>>>>9.99")).
   end.

   return trim(replace(ret,".",",")).
end function.
/**************************************************************************************/
function GetCRC returns char (input currency as integer).
  def var code as char format "x(3)".
  def buffer b-crc for bank.crc.
   find b-crc where b-crc.crc = currency no-lock no-error.
   if avail b-crc then do:
     code = b-crc.code.
   end.
   else code = " ".
  return code.
end function.
/**************************************************************************************/
function GetBankName returns char (input val as char).
  def var res as char .
  find first comm.txb where comm.txb.bank = val no-lock.
  if avail comm.txb then res = comm.txb.info.
  return res.

end function.
/**************************************************************************************/
function GetDate returns char ( input dt as date):
  return replace(string(dt,"99/99/9999"),"/",".").
end function.
/****************************************************************************************************************/

   find sysc where sysc.sysc = 'OURBNK' no-lock no-error.
   if avail sysc then
   do:
     if sysc.chval = "TXB00" then
     do:
      {r-brfilial.i &proc="dil-rep1( dt1 , dt2 ) "}
     end.
     else do:
       find first comm.txb where comm.txb.bank = sysc.chval and comm.txb.consolid no-lock.
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run dil-rep1( dt1 , dt2 ).
        if connected ("txb") then disconnect "txb".
     end.
   end.
   else do: message "Нет переменной OURBNK" view-as alert-box. end.



    def stream rep.
    output stream rep to value("rpt_.htm").



    put stream rep "<html><head><title>Отчет по безналичной покупке/продажи ин.валюты</title>" skip
                           "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                           "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    def var Caption as char init "Отчет по безналичной покупке/продажи ин.валюты".
    Caption = Caption + " c " + GetDate(dt1) + " по " + GetDate(dt2).
    put stream rep unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""0"">" skip.
    put stream rep unformatted "<tr><td align=center colspan=12><font size=""5""><b><a name="" ""></a>" Caption "</b></font></td></tr>" skip.
    put stream rep unformatted "</table>".





 put stream rep unformatted "<table width=""100%"" border=""1"" cellpadding=""0"" cellspacing=""0"" >" skip
  "<tr style=""font:bold;font-size:14""bgcolor=""#C0C0C0"">" skip
    "<td width=""82"" rowspan=""2"">Вид операции </td>" skip
    "<td width=""37"" rowspan=""2"" >Дата</td>" skip
    "<td width=""96"" rowspan=""2"" >№ транзакции </td>" skip
    "<td width=""200""rowspan=""2"" >Наименование клиента </td>" skip
    "<td colspan=""2"">Покупка (по счету для зачисления средств)</td>" skip
    "<td colspan=""2"">Продажа (по счету для снятия средств)</td>" skip
    "<td colspan=""2"">Комиссия (по счету снятия)</td>" skip
    "<td width=""37"" rowspan=""2"" >Курс</td>" skip
    "<td width=""82"" rowspan=""2"">Примечание</td>" skip
  "</tr>" skip
  "<tr style=""font:bold;font-size:13""bgcolor=""#C0C0C0"">" skip
    "<td width=""60"" >Сумма</td>" skip
    "<td width=""30"" >Валюта</td>" skip
    "<td width=""60"" >Сумма</td>" skip
    "<td width=""30"" >Валюта</td>" skip
    "<td width=""60"" >Сумма</td>" skip
    "<td width=""30"" >Валюта</td>" skip
  "</tr>" skip.



  for each wrk break by wrk.txb by wrk.dt:

   if first-of(wrk.txb) then do:
    put stream rep unformatted  "<tr style=""font:bold;font-size:14""> <td colspan=""12"" align=""center"" bgcolor=""#D4D4D4"">" GetBankName(wrk.txb) "</td> </tr>" skip.
   end.

   put stream rep unformatted "<tr>" skip
    "<td>" GetConvDocType(wrk.type) "</td>" skip
    "<td>" string(wrk.dt ,"99/99/9999") "</td>" skip
    "<td> " string(wrk.trx) "</td>" skip
    "<td>" wrk.Name "</td>" skip.

    if wrk.type = 3 or wrk.type = 4 then do:
        put stream rep unformatted "<td>" GetNormSumm(wrk.t-summ) "</td>" skip
        "<td>" GetCRC(wrk.t-crc) "</td>" skip
        "<td>" GetNormSumm(wrk.v-summ) "</td>" skip
        "<td>" GetCRC(wrk.v-crc) "</td>" skip.
    end.
    else do:
        put stream rep unformatted "<td>" GetNormSumm(wrk.v-summ) "</td>" skip
        "<td>" GetCRC(wrk.v-crc) "</td>" skip
        "<td>" GetNormSumm(wrk.t-summ) "</td>" skip
        "<td>" GetCRC(wrk.t-crc) "</td>" skip.
    end.

        put stream rep unformatted "<td>" GetNormSumm(wrk.com_conv) "</td>" skip
        "<td>" GetCRC(wrk.com_crc) "</td>" skip.


    put stream rep unformatted "<td>" GetNormSumm(wrk.rate) "</td>" skip.

    if wrk.who_cr = "inbank" then put stream rep unformatted "<td> Интернет </td>" skip.
    else put stream rep unformatted "<td> Обычные </td>" skip.

    put stream rep unformatted "</tr>" skip.

  end.

  put stream rep unformatted "</table>".
  put stream rep unformatted "</body></html>" skip.

  output stream rep close.
  unix silent value("cptwin rpt_.htm excel").
 /* unix silent value("cptwin rpt_.htm iexplore").*/