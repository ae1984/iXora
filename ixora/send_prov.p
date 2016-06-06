/* ibfl_get_supp.p
 * MODULE
        ИБФЛ
 * DESCRIPTION
        Соник-сервис для обновления списка провайдеров ИБФЛ
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
        04/10/2013 Zhassulan
 * BASES
        BANK COMM TXB
 * CHANGES
*/

define variable long-replyText as longchar.
define variable v-err as character no-undo.

if not connected ("comm") then run conncom.

/*****************************************************************************************/
{ibfl.i}
{srvcheck.i}
/*****************************************************************************************/
define button save_button label "Сохранить".

define temp-table t-suppcom
       field t-name as char format 'x(50)'
       field t-ap_code as int
       field t-ap_type as int
       field t-ib_display as char.

for each comm.suppcom where type = 2 no-lock break by ap_type by ap_code:
    if first-of( ap_code ) then do:
        create t-suppcom.
        t-name = comm.suppcom.name.
        t-ap_code = comm.suppcom.ap_code.
        t-ap_type = comm.suppcom.ap_type.
        if comm.suppcom.ib_display = 1 then t-ib_display = "Да".
           else t-ib_display = "Нет".
    end.
end.

define query q_list for t-suppcom.
define browse b_list query q_list
        display t-suppcom.t-name label "Наименование"
                t-suppcom.t-ib_display label "Доступ в ИБФЛ"
        with title "Выбор поставщика услуг" 25 down centered overlay no-row-markers.

define frame f1 b_list skip save_button with centered overlay view-as dialog-box.

open query q_list FOR EACH t-suppcom no-lock.

enable b_list save_button with frame f1.

on return of b_list in frame f1 do:
    if t-suppcom.t-ib_display = "Да" then t-suppcom.t-ib_display = "Нет".
       else t-suppcom.t-ib_display = "Да".
    b_list:refresh().
end.

on choose of save_button in frame f1 do:
    for each t-suppcom no-lock:
        for each comm.suppcom where ap_type = t-suppcom.t-ap_type and ap_code = t-suppcom.t-ap_code exclusive-lock:
            if t-suppcom.t-ib_display = "Да" then comm.suppcom.ib_display = 1.
               else comm.suppcom.ib_display = 0.
        end.
    end.
    message "Обновления сохранены" view-as alert-box button OK.
end.

wait-for choose of save_button or window-close of frame f1 focus browse b_list.
/****************************************************************************************/

/*Отправляем сообщение в очередь*/
find first comm.txb where comm.txb.bank = "TXB16" and comm.txb.consolid = true no-lock no-error.
if avail comm.txb then do:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
end.

run ibfl_get_supp("", output long-replyText, output v-err).

DEFINE VARIABLE ptpsession AS HANDLE.
DEFINE VARIABLE messageH AS HANDLE.
RUN jms/ptpsession.p PERSISTENT SET ptpsession ("-H localhost -S 5162 ").

if isProductionServer() then do:
    RUN setBrokerURL IN ptpsession ("tcp://172.16.3.5:2507").
end.
else do:
    RUN setBrokerURL IN ptpsession ("tcp://172.16.2.77:2507").
end.

RUN setUser in ptpsession ('Administrator').
RUN setPassword in ptpsession ('Administrator').
RUN beginSession IN ptpsession.
RUN createXMLMessage in ptpsession (output messageH).

RUN setStringProperty IN messageH ("type", "updateProviders").

RUN setLongText IN messageH( long-replyText).

RUN sendToQueue IN ptpsession ("IBSELECT", messageH, ?, ?, ?).

RUN deleteMessage IN messageH.
RUN deleteSession IN ptpsession.
