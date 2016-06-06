/* qpay_state.p
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
        21/07/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/


def input param Transfer as char.   /*Номер перевода*/
def input param STrx as char.       /*Номер транзакции*/
def input param Operation as char.  /*0-прием,1-выдача,2-возврат*/
def output param p-mess as char.
def output param p-rez as log.

def var v-result as char.
def var v-line as char.
def var ret-val as int.

function GetParamValue returns char (input ParamData as char,input ParamName as char).
  if ParamData = "" then return "".
  def var p-int1 as int.
  def var p-int2 as int.
  def var c-par1 as char.
  def var c-par2 as char.

  c-par1 = "<" + ParamName + ">".
  c-par2 = "</" + ParamName + ">".

  p-int1 = index(ParamData,c-par1) + length(c-par1).
  p-int2 = index(ParamData,c-par2).

  if p-int1 <> 0 and p-int2 <> 0 then return substr(ParamData,p-int1,p-int2 - p-int1).
  else return "-1".
end function.


run savelog( "QpayState", "cRequestData: Transfer=" + Transfer + ", Trx=" + STrx + ", Operation=" + Operation ).

/***********************************************************************************/
def var FileName as char.
FileName = "/data/reports/qpay/" + Transfer + "_" + Operation + ".log".
output to value(FileName).
put unformatted "Request = qpay " + Transfer + " " + STrx + " " + Operation + "~n".
input through value("qpay " + Transfer + " " + STrx + " " + Operation).
repeat:
  import unformatted v-line.
  v-result = v-result + v-line.
end.
put unformatted v-result.
output close.
/***********************************************************************************/

ret-val = integer(GetParamValue(v-result,"Code")).

if index(v-result,"SOAP header missing") > 0 or index(v-result,"ConnectTimeoutException") > 0 then do:
  p-mess = "Ошибка обработки запроса!".
  p-rez = false.
  return.
end.

case ret-val:
  when 0 then do:
    p-mess = "Запрос успешно обработан!".
    p-rez = true.
  end.
  when 1066 then do:
    p-mess = "Недопустимая операция над переводом!".
    p-rez = false.
  end.
  otherwise do:
    p-mess = "Ошибка обработки запроса - " + string(ret-val).
    p-rez = false.
  end.
end case.

run savelog( "QpayState", "cResponseData: " + p-mess + ", Code=" + string(ret-val) ).

