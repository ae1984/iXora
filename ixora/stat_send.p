/* stat_send.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        25.09.2013 damir - Внедрено Т.З. № 1869..
*/
def output parameter v-result as char.

{global.i}
{srvcheck.i}
{stat.i}

def var v-terminate as logi no-undo.
def var ptpsession as handle.
def var consumerH as handle.
def var requesth as handle.
def var q_name as char init "stat_queue".

DEFINE NEW GLOBAL SHARED VAR JMS-MAXIMUM-MESSAGES AS INTEGER INIT 500.
run jms/ptpsession.p PERSISTENT set ptpsession("-h localhost -s 5162").
if isProductionServer() then run setBrokerURL in ptpsession("tcp://172.16.1.22:2507").
else run setBrokerURL in ptpsession("tcp://172.16.1.12:2507").
run setUser in ptpsession("Administrator").
run setPassword in ptpsession("Administrator").
run beginSession in ptpsession no-error.
run createXMLMessage in ptpsession(output requesth) no-error.
run createMessageConsumer in ptpsession(THIS-PROCEDURE,"replyhandler",output consumerH) no-error.
run startReceiveMessages in ptpsession no-error.
/*------------------------------------------------------------------------*/
run setStringProperty in requesth("oracleHost",oracleHost).
run setStringProperty in requesth("oracleDb",oracleDb).
run setStringProperty in requesth("oracleUser",oracleUser).
run setStringProperty in requesth("oraclePassword",oraclePassword).
/*------------------------------------------------------------------------*/
run setStringProperty in requesth("ReportType",ReportType).
run setStringProperty in requesth("id_form",id_form).
run setStringProperty in requesth("d_report",string(d_report,"99/99/9999")).
run setStringProperty in requesth("d_rep_file",d_rep_file).
run setStringProperty in requesth("pr_period",pr_period).
run setStringProperty in requesth("zo",zo).
run setStringProperty in requesth("status",status_).
/*------------------------------------------------------------------------*/
run setText in requesth("<?xml version=""1.0"" encoding=""UTF-8""?>").
run appendText in requesth("<root>").
run appendText in requesth("<datas>").
for each t-stat no-lock:
    run appendText in requesth("<data>").
    run appendText in requesth("<id_pokaz>" + string(t-stat.id_pokaz) + "</id_pokaz>").
    run appendText in requesth("<znac>" + trim(string(t-stat.znac,"->>>>>>>>>>>>>>>>>>>9.99")) + "</znac>").
    run appendText in requesth("<stroka>" + t-stat.stroka + "</stroka>").
    run appendText in requesth("<line>" + t-stat.line + "</line>").
    run appendText in requesth("<pr_spr>" + string(t-stat.pr_spr,"true/false") + "</pr_spr>").
    run appendText in requesth("<tname_spr>" + t-stat.tname_spr + "</tname_spr>").
    run appendText in requesth("<field_spr>" + t-stat.field_spr + "</field_spr>").
    run appendText in requesth("<znac_spr>" + t-stat.znac_spr + "</znac_spr>").
    run appendText in requesth("</data>").
end.
run appendText in requesth("</datas>").
run appendText in requesth("</root>").
/*------------------------------------------------------------------------*/
run requestReply in ptpsession(q_name,requesth,?,consumerH,?,60000,?).
run deleteMessage in requesth no-error.
pause 10.
wait-for u1 of this-procedure.
run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deleteSession in ptpsession no-error.

procedure replyhandler:
    def input parameter requestH as handle.
    def input parameter msgconsumerH as handle.
    def output parameter replyH as handle.

    def var v-PropName as char.
    def var v-res as char.

    v-PropName = DYNAMIC-FUNCTION('getPropertyNames':u in requestH).
    v-res = DYNAMIC-FUNCTION('getText':u in requestH).
    if lookup("RESULT",v-PropName) > 0 then v-result = DYNAMIC-FUNCTION("getCharProperty":u in requestH,"RESULT").

    run deleteMessage in requestH.

    apply "u1" to this-procedure.
end procedure.



