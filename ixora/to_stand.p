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
*/

{srvcheck.i}

def input parameter ClientIP as char.
def input parameter tmpl as char.
def input parameter Res as char.

/************************************************************************************/

if ClientIP = "" then do:
 message "Не найден адрес получателя!" view-as alert-box.
 return.
end.

if index(ClientIP,".") > 0 then ClientIP = substr(ClientIP,1,index(ClientIP,".") - 1).

def var q_name as char init "ScreenMap".

def var ptpsession as handle.
def var messageh as handle.

run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").

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

