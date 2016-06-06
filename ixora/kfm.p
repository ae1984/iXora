/* kfm.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Модуль фин. мониторинга операций
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
 * AUTHOR
        30/03/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        13/04/2010 madiyar - добавил новый статус "Удалена"
        29/04/2010 madiyar - возможность удаления подозрительных операций
        07/07/2010 madiyar - удаление операций доступно только сотрудникам комплаенс ЦО
        10/08/2010 madiyar - заполнение s-operType
        15/10/2010 madiyar - изменение в списке комплаенс
        19/01/2012 id00477 - заменил список комплаенс менеджеров на проверку наличия пакета Комплаенс-менеджера
        10/06/2013 Luiza   - ТЗ 1727 проверка на 30 млн тенге при расходе со счета клиента наличными
        05/08/2013 Luiza   - ТЗ 1728 проверка клиентов связан-х с банком
*/

{mainhead.i}

{kfm.i "new"}

def var v-sel as integer no-undo init 0.
run sel2 ("Выбор :", " 1. Операции по расходу со счета клиента | 2. Операции открытия счетов связ. лиц | 3. Операции, подлежащие фин.мониторингу | 4. Подозрительные операции | 5. Выход ", output v-sel).
if (v-sel < 1) or (v-sel > 4) then return.
if v-sel = 1 or v-sel = 2 then do:
    if v-sel = 1 then run kfm1.
    if v-sel = 2 then run kfm2.
end.
else do:
    v-sel = v-sel - 2.
    def var v-operType as char no-undo extent 2 init ['fm','su'].

    s-operType = v-operType[v-sel].

    def var kfmsave as logi no-undo.
    def var choice as logi no-undo.
    def var opErr as logi no-undo.
    def var opErrDes as char no-undo.

    define query q_oper for kfmoper,bookcod.
    def var v-rid as rowid.
    def var v-rid2 as rowid.
    def var v-oldsts as char no-undo.

    def buffer b-kfmoper for kfmoper.

    define browse b_oper query q_oper
           displ kfmoper.operId label "nn" format ">>>>>9"
                 kfmoper.operDoc label "Документ" format "x(14)"
                 kfmoper.jh label "Трз" format ">>>>>>9"
                 bookcod.name label "Статус" format "x(10)"
                 kfmoper.rwho label "КтоРег" format "x(7)"
                 kfmoper.rwhn label "ДатаРег" format "99/99/9999"
                 string(kfmoper.rtim, "hh:mm:ss") label "ВремяРег" format "x(8)"
                 kfmoper.cwho label "КтоАкц" format "x(7)"
                 kfmoper.cwhn label "ДатаАкц" format "99/99/9999"
                 kfmoper.repwhn label "ДатаОтпр" format "99/99/9999"
                 with 29 down overlay no-label title " Операции ".

    define button sendb label "Отправить проверенные".
    define frame f_oper b_oper help "<Enter>-Редакт. <F2>-Помощь" /*skip sendb*/ with width 110 row 3 overlay no-box.

    on "enter" of b_oper in frame f_oper do:
        if avail kfmoper then do:
            if kfmoper.sts <> -1 then do: /* правим только новые и проверенные, добавил отправленные - для просмотра */
                empty temp-table t-kfmoperh.
                empty temp-table t-kfmprt.
                empty temp-table t-kfmprth.

                for each kfmoperh where kfmoperh.bank = kfmoper.bank and kfmoperh.operId = kfmoper.operId no-lock:
                    create t-kfmoperh.
                    buffer-copy kfmoperh to t-kfmoperh.
                    t-kfmoperh.dataValueVis = getVisual(kfmoperh.dataCode,t-kfmoperh.dataValue).
                    find first kfmkrit where kfmkrit.dataCode = kfmoperh.dataCode and kfmkrit.priz = 0 no-lock no-error.
                    if avail kfmkrit then do:
                        assign t-kfmoperh.showOrder = kfmkrit.showOrder
                               t-kfmoperh.dataName = kfmkrit.dataName
                               t-kfmoperh.dataSpr = kfmkrit.dataSpr.
                    end.
                    else do:
                        assign t-kfmoperh.showOrder = 1000000
                               t-kfmoperh.dataName = "[" + kfmoperh.dataCode + "]"
                               t-kfmoperh.dataSpr = ''.
                    end.
                end.

                for each kfmprt where kfmprt.bank = kfmoper.bank and kfmprt.operId = kfmoper.operId no-lock:
                    create t-kfmprt.
                    buffer-copy kfmprt to t-kfmprt.
                end.

                for each kfmprth where kfmprth.bank = kfmoper.bank and kfmprth.operId = kfmoper.operId no-lock:
                    create t-kfmprth.
                    buffer-copy kfmprth to t-kfmprth.
                    t-kfmprth.dataValueVis = getVisual(kfmprth.dataCode,t-kfmprth.dataValue).
                    find first kfmkrit where kfmkrit.dataCode = kfmprth.dataCode and kfmkrit.priz = 1 no-lock no-error.
                    if avail kfmkrit then do:
                        assign t-kfmprth.showOrder = kfmkrit.showOrder
                               t-kfmprth.dataName = kfmkrit.dataName
                               t-kfmprth.dataSpr = kfmkrit.dataSpr.
                    end.
                    else do:
                        assign t-kfmprth.showOrder = 1000000
                               t-kfmprth.dataName = "[" + kfmprth.dataCode + "]"
                               t-kfmprth.dataSpr = ''.
                    end.
                end.

                kfmsave = no.

                repeat:
                    frame f_oper:visible = no.
                    run kfmfill_operh.
                    frame f_oper:visible = yes.
                    if kfmres or kfmoper.sts = 2 then do: kfmsave = yes. leave. end.
                    else do:
                        choice = no.
                        message "Изменения будут отменены, продолжить?" view-as alert-box question buttons yes-no update choice.
                        if choice then do: kfmsave = no. leave. end.
                    end.
                end.

                if kfmsave then do:
                    repeat:
                        frame f_oper:visible = no.
                        run kfmfill_part(kfmoper.operId).
                        frame f_oper:visible = yes.
                        if kfmres or kfmoper.sts = 2 then do: kfmsave = yes. leave. end.
                        else do:
                            choice = no.
                            message "Изменения будут отменены, продолжить?" view-as alert-box question buttons yes-no update choice.
                            if choice then do: kfmsave = no. leave. end.
                        end.
                    end.
                end.

                if kfmoper.sts = 2 then kfmsave = no.

                if kfmsave then do transaction:
                    for each kfmoperh where kfmoperh.bank = kfmoper.bank and kfmoperh.operId = kfmoper.operId exclusive-lock:
                        delete kfmoperh.
                    end.
                    for each kfmprt where kfmprt.bank = kfmoper.bank and kfmprt.operId = kfmoper.operId exclusive-lock:
                        delete kfmprt.
                    end.
                    for each kfmprth where kfmprth.bank = kfmoper.bank and kfmprth.operId = kfmoper.operId exclusive-lock:
                        delete kfmprth.
                    end.
                    for each t-kfmoperh where t-kfmoperh.bank = kfmoper.bank and t-kfmoperh.operId = kfmoper.operId no-lock:
                        create kfmoperh.
                        buffer-copy t-kfmoperh except t-kfmoperh.showOrder t-kfmoperh.dataName t-kfmoperh.dataSpr t-kfmoperh.dataValueVis to kfmoperh.
                    end.
                    for each t-kfmprt where t-kfmprt.bank = kfmoper.bank and t-kfmprt.operId = kfmoper.operId exclusive-lock:
                        create kfmprt.
                        buffer-copy t-kfmprt to kfmprt.
                    end.
                    for each t-kfmprth where t-kfmprth.bank = kfmoper.bank and t-kfmprth.operId = kfmoper.operId exclusive-lock:
                        create kfmprth.
                        buffer-copy t-kfmprth except t-kfmprth.showOrder t-kfmprth.dataName t-kfmprth.dataSpr t-kfmprth.dataValueVis to kfmprth.
                    end.
                end.
            end. /* if kfmoper.sts = 0 or kfmoper.sts = 1 */
            else message "Данные по операции не подлежат редактированию!" view-as alert-box error.
        end.
    end.

    on "insert" of b_oper in frame f_oper do:
        if avail kfmoper and kfmoper.sts = 0 then do:
            b_oper:set-repositioned-row(b_oper:focused-row, "always").
            v-rid = rowid(kfmoper).
            do transaction:
                find first b-kfmoper where rowid(b-kfmoper) = v-rid exclusive-lock.
                assign b-kfmoper.sts = 1 /* проверена */
                       b-kfmoper.cwho = g-ofc
                       b-kfmoper.cwhn = g-today.
                find current b-kfmoper no-lock.
            end.
            run savelog('kfmlog', "operID=" + string(b-kfmoper.operId) + " sts 0(нов)->1(провер)").
            open query q_oper for each kfmoper where kfmoper.operType = v-operType[v-sel] and kfmoper.bank = s-ourbank and (kfmoper.sts >= 0 and kfmoper.sts <= 2) no-lock use-index typebank,each bookcod where bookcod.bookcod = "kfmSts" and bookcod.code = string(kfmoper.sts,"99") no-lock.
            reposition q_oper to rowid v-rid no-error.
            b_oper:refresh().
        end.
    end.

    on "home" of b_oper in frame f_oper do:
        if avail kfmoper and kfmoper.sts = 2 then do:
            choice = no.
            message skip "Вернуть статус 'Проверена' по выбранной операции?" skip(1) view-as alert-box question buttons yes-no
                          title "Подтверждение" update choice.
            if choice then do:
                b_oper:set-repositioned-row(b_oper:focused-row, "always").
                v-rid = rowid(kfmoper).
                do transaction:
                    find first b-kfmoper where rowid(b-kfmoper) = v-rid exclusive-lock.
                    b-kfmoper.sts = 1. /* проверена */
                    find current b-kfmoper no-lock.
                end.
                run savelog('kfmlog', "operID=" + string(b-kfmoper.operId) + " sts 2(отпр)->1(провер)").
                open query q_oper for each kfmoper where kfmoper.operType = v-operType[v-sel] and kfmoper.bank = s-ourbank and (kfmoper.sts >= 0 and kfmoper.sts <= 2) no-lock use-index typebank,each bookcod where bookcod.bookcod = "kfmSts" and bookcod.code = string(kfmoper.sts,"99") no-lock.
                reposition q_oper to rowid v-rid no-error.
                b_oper:refresh().
            end.
        end.
    end.

    on "delete-character" of b_oper in frame f_oper do:
        if avail kfmoper and kfmoper.sts = 2 and kfmoper.operType = "su" then do:
            choice = no.
            message skip "Запретить проведение выбранной подозрительной операции?" skip(1) view-as alert-box question buttons yes-no
                          title "Подтверждение" update choice.
            if choice then do:
                b_oper:set-repositioned-row(b_oper:focused-row, "always").
                v-rid = ?.
                v-rid2 = rowid(kfmoper).
                get next q_oper.
                if not avail kfmoper then get last q_oper.
                if avail kfmoper then v-rid = rowid(kfmoper).
                do transaction:
                    find first b-kfmoper where rowid(b-kfmoper) = v-rid2 exclusive-lock.
                    assign b-kfmoper.sts = 98 /* запрещена */
                           b-kfmoper.blkwhn = g-today.
                    find current b-kfmoper no-lock.
                end.
                run savelog('kfmlog', "operID=" + string(b-kfmoper.operId) + " sts 2(отпр)->98(запр)").
                open query q_oper for each kfmoper where kfmoper.operType = v-operType[v-sel] and kfmoper.bank = s-ourbank and (kfmoper.sts >= 0 and kfmoper.sts <= 2) no-lock use-index typebank,each bookcod where bookcod.bookcod = "kfmSts" and bookcod.code = string(kfmoper.sts,"99") no-lock.
                if v-rid <> ? then reposition q_oper to rowid v-rid no-error.
                find first b-kfmoper where b-kfmoper.operType = v-operType[v-sel] and b-kfmoper.bank = s-ourbank and (b-kfmoper.sts >= 0 and b-kfmoper.sts <= 2) no-lock no-error.
                if avail b-kfmoper then b_oper:refresh().
            end.
        end.
    end.

    on "end" of b_oper in frame f_oper do:
        if avail kfmoper and kfmoper.sts = 2 then do:
            if kfmoper.operType = "su" then do:
                choice = no.
                message skip "Разрешить проведение выбранной подозрительной операции?" skip(1) view-as alert-box question buttons yes-no
                              title "Подтверждение" update choice.
            end.
            else choice = yes.
            if choice then do:
                b_oper:set-repositioned-row(b_oper:focused-row, "always").
                v-rid = ?.
                v-rid2 = rowid(kfmoper).
                get next q_oper.
                if not avail kfmoper then get last q_oper.
                if avail kfmoper then v-rid = rowid(kfmoper).
                do transaction:
                    find first b-kfmoper where rowid(b-kfmoper) = v-rid2 exclusive-lock.
                    assign b-kfmoper.sts = 99. /* завершена */
                    find current b-kfmoper no-lock.
                end.
                run savelog('kfmlog', "operID=" + string(b-kfmoper.operId) + " sts 2(отпр)->99(заверш)").
                open query q_oper for each kfmoper where kfmoper.operType = v-operType[v-sel] and kfmoper.bank = s-ourbank and (kfmoper.sts >= 0 and kfmoper.sts <= 2) no-lock use-index typebank,each bookcod where bookcod.bookcod = "kfmSts" and bookcod.code = string(kfmoper.sts,"99") no-lock.
                if v-rid <> ? then reposition q_oper to rowid v-rid no-error.
                find first b-kfmoper where b-kfmoper.operType = v-operType[v-sel] and b-kfmoper.bank = s-ourbank and (b-kfmoper.sts >= 0 and b-kfmoper.sts <= 2) no-lock no-error.
                if avail b-kfmoper then b_oper:refresh().
            end.
        end.
    end.

    on "go" of b_oper in frame f_oper do:
        if avail kfmoper and kfmoper.sts = 1 then do:
            choice = no.
            message skip "Выгрузить выбранную операцию в СДФО?" skip(1) view-as alert-box question buttons yes-no
                          title "Подтверждение" update choice.
            if choice then do:
                b_oper:set-repositioned-row(b_oper:focused-row, "always").
                v-rid = rowid(kfmoper).

                run kfmSendSdfo(kfmoper.operId,output opErr, output opErrDes).

                if opErr then message opErrDes view-as alert-box error.
                else do:
                    do transaction:
                        find first b-kfmoper where rowid(b-kfmoper) = v-rid exclusive-lock.
                        assign b-kfmoper.sts = 2 /* отправлена */
                               b-kfmoper.repwhn = g-today.
                        find current b-kfmoper no-lock.
                    end.
                    run savelog('kfmlog', "operID=" + string(b-kfmoper.operId) + " sts 1(провер)->2(отпр)").
                end.
                open query q_oper for each kfmoper where kfmoper.operType = v-operType[v-sel] and kfmoper.bank = s-ourbank and (kfmoper.sts >= 0 and kfmoper.sts <= 2) no-lock use-index typebank,each bookcod where bookcod.bookcod = "kfmSts" and bookcod.code = string(kfmoper.sts,"99") no-lock.
                reposition q_oper to rowid v-rid no-error.
                b_oper:refresh().
            end.
        end.
    end.

    on "delete-line" of b_oper in frame f_oper do:
        if avail kfmoper and (kfmoper.sts = 0 or kfmoper.sts = 1) /*and kfmoper.operType = "fm"*/ then do:
            choice = no.

            /* if lookup(g-ofc,"id00532,id00733") > 0 then */
            find first ofc where ofc.ofc = g-ofc no-lock no-error.
                if lookup("p00162",ofc.expr[1]) > 0 then                 /* а ты Комплаенс-менеджер? */
            message skip "Пометить выбранную операцию как удаленную?" skip(1) view-as alert-box question buttons yes-no
                          title "Подтверждение" update choice.
            else message skip "Удалить операцию могут только сотрудники Службы комплаенс ЦО!" skip(1) view-as alert-box error.
            if choice then do:
                if kfmoper.sts = 0 then v-oldsts = "sts 0(нов)". else v-oldsts = "sts 1(провер)".
                b_oper:set-repositioned-row(b_oper:focused-row, "always").
                v-rid = ?.
                v-rid2 = rowid(kfmoper).
                get next q_oper.
                if not avail kfmoper then get last q_oper.
                if avail kfmoper then v-rid = rowid(kfmoper).
                do transaction:
                    find first b-kfmoper where rowid(b-kfmoper) = v-rid2 exclusive-lock.
                    assign b-kfmoper.sts = 90. /* удалена */
                    find current b-kfmoper no-lock.
                end.
                run savelog('kfmlog', "operID=" + string(b-kfmoper.operId) + " operType=" + kfmoper.operType + " " + v-oldsts + "->90(удалена)").
                open query q_oper for each kfmoper where kfmoper.operType = v-operType[v-sel] and kfmoper.bank = s-ourbank and (kfmoper.sts >= 0 and kfmoper.sts <= 2) no-lock use-index typebank,each bookcod where bookcod.bookcod = "kfmSts" and bookcod.code = string(kfmoper.sts,"99") no-lock.
                if v-rid <> ? then reposition q_oper to rowid v-rid no-error.
                find first b-kfmoper where b-kfmoper.operType = v-operType[v-sel] and b-kfmoper.bank = s-ourbank and (b-kfmoper.sts >= 0 and b-kfmoper.sts <= 2) no-lock no-error.
                if avail b-kfmoper then b_oper:refresh().
            end.
        end.
    end.

    on "help" of b_oper in frame f_oper do:
        message skip "[Insert] - 'Проверена' (только по новым)                      ~n" +
                     "[F1]     - отправка в СДФО (только проверенные)               ~n" +
                     "[Home]   - возврат 'Проверена' (только по отправленным)       ~n" +
                     "[Delete] - 'Запрещена' (только по отправленным подозрительным)~n" +
                     "[End]    - 'Завершена' (только по отправленным)               ~n" +
                     "[Ctrl+D] - 'Удалена' (только по новым и проверенным пороговым)~n"
                     skip(1)
        view-as alert-box information title "Помощь".
    end.

    /*
    on choose of sendb in frame f_oper do:
        find first b-kfmoper where b-kfmoper.operType = v-operType[v-sel] and b-kfmoper.bank = s-ourbank and b-kfmoper.sts = 1 no-lock no-error.
        if not avail b-kfmoper then message "Нет проверенных операций для отправки!" view-as alert-box error.
        else do:
            run sendsdfo(
        end.
    end.
    */

    open query q_oper for each kfmoper where kfmoper.operType = v-operType[v-sel] and kfmoper.bank = s-ourbank and (kfmoper.sts <> -1) no-lock use-index typebank,each bookcod where bookcod.bookcod = "kfmSts" and bookcod.code = string(kfmoper.sts,"99") no-lock.
    enable all with frame f_oper.

    wait-for window-close of current-window.
end.


