/* Get_Nal1.p
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

 * BASES
        BANK COMM
 * CHANGES
                14/05/2012 Luiza
                04/06/2012 Luiza - отменила вывод на печать
                23/07/2013 Luiza  - ТЗ 1883 исключение повторных RMZ при пополнении ПК
                24/07/2013 Luiza - перекомпиляция
                25/07/2013 Luiza - перекомпиляция
*/
    {global.i}
    define input parameter vv-joudoc as char no-undo format "x(10)".
    define input parameter vv-nomer as character no-undo.
    define variable ss-jh like jh.jh.
    find joudoc where joudoc.docnum eq vv-joudoc no-lock .

    def var v-errmsg as char init "".
    def var v-rez as logic init false.
    ss-jh = joudoc.jh.
    run csstampf(ss-jh, vv-nomer, output v-errmsg, output v-rez ).
    if  v-errmsg <> "" or not v-rez then do:
        if v-errmsg <> "" then message  v-errmsg view-as alert-box error.
        undo, return.
    end.
    do transaction:
        find first joudop where joudop.docnum = vv-joudoc and joudop.type = "EK7" no-lock no-error.
        if available joudop then do:
            find first jh where jh.sub = 'jou' and jh.ref = vv-joudoc no-lock no-error.
            if avail jh then do:
                {pcpay.i}
            end.
        end.
    end.
    message "Проводка отштампована " view-as alert-box.
    /*run printord(ss-jh,"").*/
