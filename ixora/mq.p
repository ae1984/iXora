/* mq.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Сихронизация платежей для интернет-банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        29/04/11 id00004
 * CHANGES
*/


{global.i}
{srvcheck.i}

def stream str01.
def var v-s as char.
def var v-terminate as logi no-undo.
v-terminate = no.

define var consumerH       as handle.
define var replyMessage    as handle.
DEFINE VARIABLE ptpsession AS HANDLE.
DEFINE VARIABLE messageH AS HANDLE.
def new shared temp-table t_in   /*все платежи за день*/
field id as char format 'x(60)'
field sts  as char.

def new shared temp-table t_out  /*платежи кот не прошли проверку и нуждаются в синхронизации*/
field id as char format 'x(60)'
field realstatus  as char
field descr  as char
field tim  as integer
field datesend  as date
field typepeyment  as char.

def var zzxx as integer.
zzxx = 0.

/*Если были какие то перебои со связью или шлюзом*/
/*Стандартная java не работает изпользуем версию 1.5.0 из каталога tmp*/
input stream str01 through value("/tmp/jre1.5.0_11/bin/java  -classpath /tmp/ojdbc14.jar:/tmp/classes12.jar:/tmp/ Oralink")  no-echo.
repeat:
    import stream str01 unformatted v-s. /*получим имя файла*/
    if num-entries(v-s) = 2 then do:
        zzxx = zzxx + 1.
        create  t_in.
        t_in.id = ENTRY(1, v-s).
        t_in.sts = ENTRY(2, v-s).
    end.
end.

message "Количество платежей: " zzxx.

{r-branch.i &proc = "mqownr1"}

find last t_out no-lock no-error.
if not avail t_out then do:
    message "ВСЕ ДАННЫЕ КОРРЕКТНЫ !!!".
    pause.
    return.
end.

if avail t_out then do:
    message "ОБНАРУЖЕНЫ НЕСООТВЕТСТВИЯ СТАТУСОВ" skip "Сделать синхронизацию?" view-as alert-box question buttons yes-no title "" update v-ans as logical.
    if not v-ans then return.
end.

for each t_out:
    run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
    if isProductionServer() then run setbrokerurl in ptpsession ("172.16.3.5:2507").
    else run setbrokerurl in ptpsession ("172.16.2.77:2507").

    run setUser in ptpsession ("SonicClient").
    run setPassword in ptpsession ("SonicClient").
    RUN beginSession IN ptpsession.

    run createXMLMessage in ptpsession (output messageH).
    run setText in messageH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
    run appendText in messageH ("<DOC>").

    run appendText in messageH ("<" + t_out.typepeyment + ">").
    run appendText in messageH ("<ID>" + t_out.id + "</ID>").
    run appendText in messageH ("<STATUS>" + t_out.realstatus + "</STATUS>").
    run appendText in messageH ("<DESCRIPTION>" + t_out.descr + "</DESCRIPTION>").

    if t_out.tim = 0 then run appendText in messageH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
    else run appendText in messageH ("<TIMESTAMP>" + string(t_out.datesend) + " " + string(t_out.tim, "hh:mm:ss") +  "</TIMESTAMP>").

    run appendText in messageH ("</" + t_out.typepeyment + ">").
    run appendText in messageH ("</DOC>").

    RUN sendToQueue IN ptpsession ("SYNC2NETBANK", messageH, ?, ?, ?).
    RUN deleteMessage IN messageH.
    RUN deleteSession IN ptpsession.
end.

