/* 3-rej.p
 * MODULE
        Название Программного Модуля
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
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        25.02.2011 id00004 добавил параметр при отвержении платежа Интернет банкинга
        16.03.2011 id00004 добавил отправку причины отвержения в Sonic
        03.06.2011 id00004 исправил ошибку при формировании референса при повторном отвержении
        06.10.2011 id00004 - добавил обработку ситуации если запустили программу на тестовой базе
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        23/10/2012 id00810 - ТЗ 1554, объявление переменной reas как shared
        13/12/2012 id00810 - добавила в <DESCRIPTION> CDATA для отображения символьных данных
        10.04.2013 damir - Исправлена техническая ошибка.
        31.07.2013 Lyubov - ТЗ 1995, замена спец. символов во вводимой причине отказа
        02.08.2013 Lyubov - перекомпиляция
*/

/* 3-rej.p
   Отвержение платежа Internet-office
   изменение от 05.04.2001
   - проверка: если есть 1-ая транзакция,
               ее надо удалить прежде, чем посылать отказ */

{global.i}
{ps-prmt.i}
{lgps.i }
{srvcheck.i}

def shared var s-remtrz like remtrz.remtrz .
def shared var reas as char label "Причина отвержения " format "x(40)" no-undo.
def var reas1 as char no-undo.
def var yn as log initial false format "да/нет".
def var v-err as char.
def shared frame remtrz.
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def buffer b-remtrz for remtrz.
/*def var reas as char label "Причина отвержения " format "x(40)".*/
def var pi1 as cha .
def var ibhost as cha .

function info_name_replacer returns char (input info_name as char).
	info_name = replace (info_name, "&", "&amp;").
	info_name = replace (info_name, ">", "&gt;").
	info_name = replace (info_name, "<", "&lt;").
	info_name = replace (info_name, """", "&quot;").
	info_name = replace (info_name, "'", "&apos;").
	return(info_name).
end function.

{rmz.f}
find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
if not avail remtrz then return.
if remtrz.jh1 ne ? then do.
   message 'Необходимо сначала отменить транзакцию!'.
   pause 5.
   return.
end.
if remtrz.t_sqn ne  "" then do:
    Message " Вы уверены ? " update yn .

    if yn then do transaction :
        find first que where que.remtrz = s-remtrz exclusive-lock no-error.
        find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock.
        if avail que and ( que.pid ne m_pid or que.con eq "F" ) then  do:
            Message " Вы не владелец !! Обработать невозможно " . pause .
            return .
        end.

        update reas validate(trim(reas) <> "", "Причина ввода !") with side-label centered row 12 overlay frame res.
        hide frame res.

        v-text = reas.
        reas1 = info_name_replacer(reas).
        if remtrz.source = "IBH" then do :

            /*Новый интернет банкинг*/
            if m_pid = "3A" then do:
                find last netbank where netbank.rmz = remtrz.remtrz exclusive-lock no-error.
                if avail netbank then do:
                    def buffer b-crcc for crc.

                    DEFINE VARIABLE ptpsession AS HANDLE.
                    DEFINE VARIABLE messageH AS HANDLE.

                    run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
                    if isProductionServer() then run setBrokerURL in ptpsession ("tcp://172.16.3.5:2507").
                    else run setBrokerURL in ptpsession ("tcp://172.16.2.77:2507").
                    run setUser in ptpsession ("SonicClient").
                    run setPassword in ptpsession ("SonicClient").
                    RUN beginSession IN ptpsession.
                    run createXMLMessage in ptpsession (output messageH).
                    run setText in messageH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
                    run appendText in messageH ("<DOC>").
                    if remtrz.fcrc = 1 then run appendText in messageH ("<PAYMENT>").
                    else run appendText in messageH ("<CURRENCY_PAYMENT>").
                    run appendText in messageH ("<ID>" + netbank.id + "</ID>").
                    run appendText in messageH ("<STATUS>6</STATUS>").
                    run appendText in messageH ("<DESCRIPTION>" + substr(reas1,1,100) + "</DESCRIPTION>").
                    run appendText in messageH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
                    if remtrz.fcrc = 1 then run appendText in messageH ("</PAYMENT>").
                    else run appendText in messageH ("</CURRENCY_PAYMENT>").
                    run appendText in messageH ("</DOC>").
                    RUN sendToQueue IN ptpsession ("SYNC2NETBANK", messageH, ?, ?, ?).
                    RUN deleteMessage IN messageH.
                    RUN deleteSession IN ptpsession.

                    netbank.sts = "6".
                    netbank.rem[1] = "Отвергнут".
                end.
            end.

            find sysc where sysc.sysc = "IBHOST" no-lock no-error .
            if not avail sysc or sysc.chval = "" then do :
                v-text = "ОШИБКА !!! Записи IBHOST нет в sysc файле !! " .
                run lgps .
                return .
            end .
            ibhost = sysc.chval .
            if not connected("ib") then
            connect value(ibhost) no-error .
            if not connected("ib") then do:
                v-text = " ОШИБКА !! . INTERNET BANKING host не отвечает , нет связи ." .
                run lgps .
                return .
            end.
            create bank.reject .
            bank.reject.t_sqn = remtrz.t_sqn .
            remtrz.t_sqn = "IBNK " + remtrz.t_sqn .
            bank.reject.ref = remtrz.t_sqn + remtrz.sqn .
            bank.reject.whn = today.
            bank.reject.who = g-ofc.
            bank.reject.tim = time.
            run IBrej_ps(7,0,reas,remtrz.remtrz) .
            if connected("ib") then
            disconnect ib .
            v-err = "0" .
        end .
        else do :
            run ps-rej (input remtrz.t_sqn + remtrz.sqn, input remtrz.t_sqn, input remtrz.saddr, output v-err ).
            pause 1.
        end.

        if v-err = "0" then do :
            find first que where que.remtrz = s-remtrz exclusive-lock no-error.
            find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock.
            if remtrz.source = "IBH" then do:
                remtrz.sqn = remtrz.sqn + substr(remtrz.remtrz, 7,3).
            end.
            do:
                run delnbal.

                if avail que then do:
                    v-text = s-remtrz + " Отвержение отправлено успешно: " + reas.
                    /*        + s-remtrz + " " + remtrz.t_sqn + remtrz.sqn + " удален.". */
                    /*      delete remtrz . */
                    que.pid = "ARC".
                end.
                else do:
                    v-text = s-remtrz + "Отвержение отправлено успешно. НЕ МОГУ НАЙТИ que ДЛЯ remtrz!".
                    run lgps.
                end.
                clear frame remtrz all .
            end.
        end.
        else do :
            v-text = " Невозможно отправить " + s-remtrz + ". LASKA ERROR.".
            Message v-text .
            pause .
        end.
        run lgps.
    end .
end .
else do:
    Message " Ссылочный номер транспортной системы пустой ! " .
    pause .
end .
