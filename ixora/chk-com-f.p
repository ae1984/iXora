/* chk-com-f.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        выбираем тип оплаты комиссии
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
        BANK COMM TXB
 * AUTHOR
        17/07/2012 Luiza
 * CHANGES

*/


define input parameter vtype as char.
define input parameter vcif as char.
define input parameter vchet as char.
define input parameter vsum as decim.
define input parameter vsumk as decim.
define output parameter vst as int.
define output parameter vchetk as char.
define output parameter voplcom as char.

if vtype = "com" then do: /* оплата комиссии      */
    def var v-oplcom1 as char.
    voplcom = "1".
    vst = 0.
    def var I as int init 0.
    def var aaalist as char init "".
    /* тип оплаты комиссии-----------------------------------------------------*/
    repeat:
        vchetk = "".
        run sel1("Выберите вид оплаты комиссии", "1 - с кассы|2 - со счета").
        if keyfunction(lastkey) = "end-error" then return.
        v-oplcom1 = return-value.
        if v-oplcom1 = '' then return.
        voplcom = entry(1,v-oplcom1," ").
        if voplcom = "1" then leave.

        vchetk = "".
        FOR EACH txb.aaa where txb.aaa.cif = vcif and txb.aaa.crc = 1 no-lock.
            find txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
            if not available txb.lgr or txb.lgr.led = 'ODA' then next.
            if txb.aaa.sta <> "C" and txb.aaa.sta <> "E" then do:
                I = I + 1.
                if aaalist <> "" then aaalist = aaalist + "|".
                aaalist = aaalist + txb.aaa.aaa + " KZT " + string(txb.aaa.cbal - txb.aaa.hbal,"->>>>>>>>>>9.99").
            end.
        end.

        if I > 0 then do:
            run sel1("Выберите счет для снятия комиссии", aaalist).
            if keyfunction(lastkey) = "end-error" then undo.
            vchetk = entry(1,return-value," ").
        end.
        aaalist = "".

        find first txb.aaa where txb.aaa.aaa = vchetk no-lock no-error.
        if vchet = vchetk then do: /* если комиссия снимается с пополняемого счета */
            if vsumk > txb.aaa.cbal - txb.aaa.hbal + vsum then do:
                message "Ошибка, на выбранном счете недостаточно средств для снятия комиссии"  view-as alert-box error.
                undo.
            end.
            else leave.
        end.
        else do: /* если комиссия снимается с другого счета  */
            if vsumk > txb.aaa.cbal - txb.aaa.hbal then do:
                message "Ошибка, на выбранном счете недостаточно средств для снятия комиссии"  view-as alert-box error.
                if txb.aaa.hbal <> 0 then message "На выбранном счете имеются спец инструкции, ~nоплата комиссии возможна только с кассы"  view-as alert-box error.
                undo.
            end.
            else leave.
        end.
    end.  /* repeat */
    vst = 1.
end.

if vtype = "sum" then do: /* проверка суммы на счете  */
    find first txb.aaa where txb.aaa.aaa = vchet and txb.aaa.cif = vcif no-lock no-error.
    if vsum > txb.aaa.cbal - txb.aaa.hbal then do:
        message "Сумма на счете клиента меньше суммы пополнения, удаление невозможно!" view-as alert-box.
        vst = 0.
        return.
    end.
    vst = 1.
end.
