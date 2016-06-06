/* crl-m.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Статус SMS-информирования
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16.2.2.10
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK
 * CHANGES
        13.06.2013 damir - Внедрено Т.З. № 1876.
*/
{mainhead.i}

run sel("ВЫБЕРИТЕ","1. Отчет по SMS - уведомлениям|2. Отправка SMS - уведомления (повторно)").
case trim(return-value):
    when "1" then run crl-sms.
    when "2" then run crl-ss.
end case.

procedure crl-ss:
    def var v-batchid as inte.

    def buffer b-smspool for smspool.

    def frame crl-ss
        v-batchid label "ID-sms" format "zzzzzzzzzzzzzzzzzz9" validate(can-find(b-smspool where b-smspool.batchid = v-batchid no-lock),"Уведомление не найдено!Повторите ввод!") skip
    with side-labels centered row 10 title "ВВЕДИТЕ".

    on "end-error" of frame crl-ss do:
        hide frame crl-ss.
        return.
    end.

    update v-batchid with frame crl-ss.
    displ v-batchid with frame crl-ss.

    find b-smspool where b-smspool.batchid = v-batchid exclusive-lock no-error.
    if avail b-smspool and b-smspool.source = "CredLimit" then do:
        b-smspool.state = 2.
        find current b-smspool no-lock no-error.
        hide frame crl-ss.
    end.
    pause 0.
end procedure.

pause 0.