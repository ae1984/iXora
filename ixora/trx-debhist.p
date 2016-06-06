/* trx-debhist.p
 * MODULE
        Генератор транзакций
 * DESCRIPTION
        Запись истории по дебиторам
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
        31/12/99 pragma
 * CHANGES
        13/01/04 sasco - добавил обработку времени из debc
                       - добавил запись остатка прихода в debhis на момент проводки
        21/01/04 sasco - переделал присваивание debop.ls
        11/03/04 sasco - добавил обработку профит-центра
        16/08/2005 marinav добавлен фактический срок
*/

/* временные таблицы и переменные для обмена данными между процедурами */
{trx-debhist.i "shared"}

define shared variable g-today as date.
define shared variable g-ofc as character.
define shared variable s-jh as integer.

for each dtmp:

    dt-time = dt-time + 1.

    find debls where debls.grp = dtmp.grp and
                     debls.ls  = dtmp.ls.

    /* если надо - проставим дату создания дебитора */
    if debls.state = 0 then debls.created = g-today.

    /* если надо - активизируем дебитора */
    if dtmp.re-open then assign debls.last_opened = g-today
                                debls.state = 1.

    /* debhis */
    create debhis.
    assign debhis.date   = g-today
           debhis.grp    = dtmp.grp
           debhis.ls     = dtmp.ls
           debhis.amt    = dtmp.dam + dtmp.cam
           debhis.ost    = debls.amt - dtmp.dam + dtmp.cam
           debhis.ofc    = g-ofc
           debhis.ctime  = dt-time
           debhis.rem[1] = dtmp.rem[1]
           debhis.rem[2] = dtmp.rem[2]
           debhis.rem[3] = dtmp.rem[3]
           debhis.jh     = s-jh
           debhis.dactive = yes.

    debls.amt = debhis.ost.

    if dtmp.cam > 0 then debhis.type = if dtmp.re-open then 1 else 2.
    if dtmp.dam > 0 then debhis.type = if debhis.ost = 0 then 4 else 3.

    /* если надо - закроем дебитора */
    if debhis.ost = 0 then assign debls.last_closed = g-today
                                  debls.state = 2.

    /* debop - детали операции */
    create debop.
    assign debop.date = g-today
           debop.ctime = dt-time
           debop.grp = debhis.grp
           debop.ls = debhis.ls
           debop.who = g-ofc
           debop.amt = debhis.amt
           debop.ost = (if debhis.type < 3 then debhis.amt else 0.0)
           debop.type = (if debhis.type < 3 then 1 else 2)
           debop.closed = (if debhis.type < 3 then no else yes)
           debop.cdt = ?
           debop.jh = s-jh.

    /* проставим срок дебитора   +   ссылку на проводку (для списания) */
    if debhis.type > 2 then 
    do: /* списание */
       find debc where debc.grp = dtmp.grp and 
                       debc.ls = dtmp.ls
                       no-error.
       /* ссылка на приход в таблице операций */
       assign debop.refwhn = debc.date
              debop.refjh = debc.jh
              debop.period = debc.period
              .
       /* параметры остатка с прихода на момент проводки */
       assign debhis.dost = debc.ost
              debhis.dactive = not debc.closed
              debhis.dwhn = debc.date
              debhis.djh = debc.jh
              debhis.dtime = debc.ctime
              .
    end.
    else 
    do: /* приход */
       find month3 where month3.grp = dtmp.grp and 
                         month3.ls  = dtmp.ls
                         no-error.
       debop.period = month3.period.  /* срок */
       debop.attn = month3.attn.      /* профит-центр */
       /* ссылка на собственный приход  */
       assign debhis.dactive = yes
              debhis.djh = s-jh
              debhis.dwhn = g-today
              debhis.dtime = dt-time
              debhis.dost = dtmp.dam + dtmp.cam
              debhis.chval[1] = month3.fsrok
              .
    end.

    release debls.
    release debhis.

end.


/* обновим информацию по остаткам для списания */
for each debc:
    find debop where debop.grp = debc.grp and
                     debop.ls = debc.ls and
                     debop.type = 1 and
                     debop.closed = no and
                     debop.date = debc.date and
                     debop.jh = debc.jh
                     no-error.
    assign debop.ost = debc.ost
           debop.closed = debc.closed.
    if debop.ost = 0.0 then debop.cdt = g-today.
end.

/* ------------  КОНЕЦ ПРОГРАММЫ ----------- */



