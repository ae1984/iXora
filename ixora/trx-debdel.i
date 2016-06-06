/* trx-debdel.i
 * MODULE
        Генератор транзакций
 * DESCRIPTION
        Удаление проводок по дебиторам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        trxdel.p, trxstor.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        26/09/02 sasco
 * CHANGES
        23/12/03 sasco добавил обработку таблиц debop, debmon
        13/01/04 sasco обработка полей dost,djh,...
        05.03.2004 recompile
*/



def var deb-grp like debls.grp.
def var deb-ls like debls.ls.
def var deb-min like debhis.ost init ?.
def var deb-amt like debhis.amt init 0.0.
def var deb-damcam as logical.

define variable deb-dwhn like debhis.dwhn.
define variable deb-ctime like debhis.ctime.
define variable deb-djh like jh.jh.

define buffer bdebop for debop.

if vjh <> ? and vjh <> 0 then
do:
    /* проверим, была ли вообще такая проводка */
    find first debhis where debhis.jh = vjh use-index jh no-lock no-error.
    if avail debhis then
    do:
        /* запомним номер дебитора и итоговую сумму операции */
        deb-grp = debhis.grp.
        deb-ls = debhis.ls.

        /* ссылка на приход */
        deb-djh = debhis.djh.
        deb-ctime = debhis.ctime.
        deb-dwhn = debhis.date.

        /* приход или списание */
        if debhis.type = 1 or debhis.type = 2 then deb-damcam = yes.
                                              else deb-damcam = no.

        for each debhis where debhis.jh = vjh use-index jh no-lock:
            deb-amt = deb-amt + debhis.amt.
        end.

        deb-min = deb-amt.

        /* если был приход, то найти последний остаток, который */
        /* может без этого прихода уйти в минус                 */
        if deb-damcam then do:
           for each debhis where debhis.jh > vjh and debhis.grp = deb-grp and debhis.ls = deb-ls
               no-lock use-index jh:
               if deb-min > debhis.ost then deb-min = debhis.ost.
           end.

           if deb-min < deb-amt then do:
               rcode = 1.
               rdes = "Не могу удалить проводку по дебитору так как остаток уйдет в минус".
               return. 
           end.

        end.

        /* 1. debop - история операций */
        for each debop where debop.grp = deb-grp and debop.ls = deb-ls and debop.jh = vjh:

            /* если было списание, то проверим ссылку на приходы */
            if debop.refjh <> 0 and debop.type = 2 then do:
               for each bdebop where bdebop.grp = deb-grp and bdebop.ls = deb-ls and bdebop.jh = debop.refjh:
                   bdebop.ost = bdebop.ost + debop.amt.
                   bdebop.closed = FALSE.
               end.
            end.
            
            /* иначе если был приход - проверим все последующие списания */
            if debop.type = 1 then do:
                 find first bdebop where bdebop.grp = deb-grp and 
                                         bdebop.ls = deb-ls and 
                                         bdebop.type = 2 and 
                                         bdebop.refjh = debop.jh
                                         no-lock no-error.
                 if available bdebop then do:
                    message "Не могу удалить приход (проводка " + string(debop.jh) + ")~n"
                            "Сначала удалите проводку списания (" + string(bdebop.jh) + ")" view-as alert-box title ''.
                    rcode = 2.
                    rdes = "Не могу удалить проводку по дебитору! Сначала удалите " + string(bdebop.jh).
                    return.
                 end.
            end.

            delete debop.

        end.

        /* 2. debmon - записи для книги покупок */
        for each debmon where debmon.grp = deb-grp and debmon.ls = deb-ls and debmon.jh = vjh:
            delete debmon.
        end.

        /* 3. изменим остаток в последующих операциях */
        for each debhis where debhis.jh > vjh and debhis.grp = deb-grp and debhis.ls = deb-ls use-index jh:
            debhis.ost = if deb-damcam then debhis.ost - deb-amt  /* был приход */
                                       else debhis.ost + deb-amt. /* было списание */
        end.

        /* 4. удалим запись о проводке из карточки дебитора */
        for each debhis where debhis.jh = vjh use-index jh:
            delete debhis.
        end.

        /* 5. изменим остатки для списания в dost,djh,dwhn в debhis */
        for each debhis where debhis.grp = deb-grp and 
                              debhis.ls = deb-ls and
                              debhis.djh = deb-djh and 
                              debhis.date >= deb-dwhn:
            /* отсечение предыдущих за тот же день проводок */
            if debhis.date = deb-dwhn and debhis.ctime <= deb-ctime then next.
            if deb-damcam then debhis.dost = debhis.dost - deb-amt. /* был приход */
                          else debhis.dost = debhis.dost + deb-amt. /* было списание */
            if debhis.dost > 0 then debhis.dactive = yes.
                               else debhis.dactive = no.
        end.
                              

        find debls where debls.grp = deb-grp and debls.ls = deb-ls no-error.
        debls.amt = if deb-damcam then debls.amt - deb-amt
                                  else debls.amt + deb-amt.

    end.
end.
