/* to_screen.p
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
        10/12/2011 k.gitalov
 * BASES
        BANK
 * CHANGES
        25.04.2012 k.gitalov изменил коннект к сонику
        19.09.2012 dmitriy - для TXB12 вывод не через ST00277
        28.11.2012 dmitriy - для TXB08 (Астана) и TXB00 (ЦО) вывод не через ST00277
        10/12/2012 k.gitalov - изменения по ТЗ 1603
        11.04.2013 dmitriy - проверка на подключение филиалов к экрану клиента через справочник CifScr
*/


{srvcheck.i}

def input parameter tmpl as char.
def input parameter Res as char.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
/************************************************************************************/
def var ClientIP as char.

/*потом убрать*/

find first sysc where sysc.sysc = "CifScr" no-lock no-error.
if avail sysc and lookup(substr(s-ourbank, 4), sysc.chval, "|") = 0 then ClientIP = "ST00277".

/*            */

if ClientIP = "" then do:
  input through askhost.
  import ClientIP.
end.

run savelog( "ScreenMap", "ClientIP = " + ClientIP + ", tmpl = " + tmpl + ", Res = " + Res ).
/*потом убрать*/
if ClientIP = "st00848.metrobank.kz" then ClientIP = "ST00277".
/*            */

if ClientIP = "" then do:
 message "Не найден адрес получателя!" view-as alert-box.
 return.
end.

if index(ClientIP,".") > 0 then ClientIP = substr(ClientIP,1,index(ClientIP,".") - 1).

def var q_name as char init  "ScreenMap".

def var ptpsession as handle.
def var messageh as handle.


/******************************************************************/

run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").

/******************************************************************/
run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").

run beginsession in ptpsession.


run createtextmessage in ptpsession (output messageh).
run settext in messageh ("tmpl=" + tmpl + "&" + Res).
run setStringProperty in messageh("FILTERING",CAPS(ClientIP)).
run sendtoqueue in ptpsession (q_name, messageh, ?, ?, ?).
run deletemessage in messageh.

run deleteConsumer in ptpsession no-error.
run deleteSession in ptpsession.


