/* dil_irej.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM IB
 * AUTHOR
        24/12/09 id00004
 * CHANGES
        28/07/2011 id00004 добавил причину отказа в xml сообщение
*/

{srvcheck.i}
{lgps.i new}
{global.i}

def input parameter dnum as char.
def var ph as handle.
def var c_rej as char.

DEFINE VARIABLE ptpsession AS HANDLE.
DEFINE VARIABLE messageH AS HANDLE.

update c_rej format "x(60)" with no-labels row 7 centered frame frej title "Причина отказа" overlay.
hide frame frej.
if c_rej <> "" then do:
    MESSAGE "Отправить отказ и удалить заявку?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Отказ" UPDATE choice as logical.
    if choice then do:
        do transaction:
            find first dealing_doc where DocNo = dnum exclusive-lock.
            find last netbank where netbank.rmz = dnum /* dealing_doc.docno*/ exclusive-lock no-error.

            if avail netbank then do:

                run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").

                if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.3.5:2507").
                else run setbrokerurl in ptpsession ("tcp://172.16.2.77:2507").

                run setUser in ptpsession ("SonicClient").
                run setPassword in ptpsession ("SonicClient").
                RUN beginSession IN ptpsession.

                run createXMLMessage in ptpsession (output messageH).
                run setText in messageH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
                run appendText in messageH ("<DOC>").
                run appendText in messageH ("<CURRENCY_EXCHANGE>").
                run appendText in messageH ("<ID>" + netbank.id + "</ID>").
                run appendText in messageH ("<STATUS>6</STATUS>").
                /* run appendText in messageH ("<DESCRIPTION>Отвергнут</DESCRIPTION>"). */
                run appendText in messageH ("<DESCRIPTION>" + c_rej + "</DESCRIPTION>").
                run appendText in messageH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
                run appendText in messageH ("</CURRENCY_EXCHANGE>").
                run appendText in messageH ("</DOC>").
                RUN sendToQueue IN ptpsession ("SYNC2NETBANK", messageH, ?, ?, ?).
                RUN deleteMessage IN messageH.
                netbank.sts = "6".
                netbank.rem[1] = "Отвергнут" .
            end.

            v-text = " Заявка No" + DocNo + " отвергнута. Причина: " + c_rej.
            delete dealing_doc.
            run lgps.
        end.
        hide all.
    end.
end.

