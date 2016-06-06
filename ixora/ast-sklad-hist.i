/* ast-sklad-hist.i
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* sasco - for ASTREM.P - запишет историю движения */
/* товаров на складе - списание основных средств   */

if sk_total <> ? then 
do:

    /* найдем текущий склад - по группе и по датеПрихода */
    find skladc where skladc.sid = v-sid and
                      skladc.pid = v-pid and
                      skladc.cost = sk_cost and
                      skladc.dpr = v-dpr
                      no-error.
    if avail skladc then do:
    /* вычесть количество (по этой цене) */
        skladc.amt = skladc.amt - sk_amt.
        /* если ничего не осталось, то удалить запись */    
        if skladc.amt < 0 then
        message "Предупреждение! Количество на складе не может быть < 0 ("
                + "sid=" skladc.sid "pid=" skladc.pid "amt=" skladc.amt
                ")" view-as alert-box.
        else
            if skladc.amt = 0 then delete skladc.
    end.
    else message 
    "Предупреждение! Не найдена запись для skladc (sid=" v-sid " pid="
        v-pid " cost=" sk_cost " dpr=" v-dpr ")"
        view-as alert-box.
    
    /* создание истории проводок - списание со склада */
    CREATE skladh.
    assign skladh.sid = v-sid
           skladh.pid = v-pid
           skladh.whn = g-today
           skladh.who = g-ofc
           skladh.amt = sk_amt
           skladh.cost = sk_cost
           skladh.type = "S"
           skladh.dpr = v-dpr
           skladh.drarp = ""
           skladh.crarp = ""
           skladh.gl = v-gl
           skladh.jh = s-jh.
          
    find skladb where skladb.sid = v-sid and skladb.pid = v-pid no-lock no-error.
    skladh.rem = "Списание "+ skladb.des + " " + string(sk_amt) + "x" + string(sk_cost).

    /* ------------------------------------- */
    /*    Отнимеме остаток за текущую дату   */
    /*   ( TOTAL вычитание по всей группе )  */
    /* ------------------------------------- */
    FIND FIRST sklado where sklado.sid = v-sid and
                            sklado.pid = v-pid and
                            sklado.whn = g-today and
                            sklado.type = "T"
                            use-index www
                            no-error.
    if avail sklado then /* если нашли за текущую дату... */
       do: /* ...то отнять её значение */
           v-amt = sklado.amt.
           v-cost = sklado.cost.
       end.
    else do:
            /* нет - найти последний остаток по товару и минусовать */
            FIND FIRST sklado where sklado.sid = v-sid and
                                    sklado.pid = v-pid and
                                    sklado.type = "T"
                                    use-index www
                                    no-error.
            if avail sklado then /* нашли - запомнить остатки */
            do:
               v-amt = sklado.amt.
               v-cost = sklado.cost.
            end.
            else do: v-amt = 0. v-cost = 0.0. end.

            /* создать с текущей датой */
            CREATE sklado.
            sklado.sid = v-sid.
            sklado.pid = v-pid.
            sklado.whn = g-today.
            sklado.type = "T".
       end.

    sklado.amt = v-amt - sk_amt.
    sklado.cost = v-cost - sk_total.

    /* ------------------------------------- */
    /*    Отнимем остаток за текущую дату    */
    /*      (вычитание по товару )           */
    /* ------------------------------------- */
    FIND FIRST sklado where sklado.sid  = v-sid and
                            sklado.pid  = v-pid and
                            sklado.whn  = g-today and
                            sklado.dpr  = v-dpr and
                            sklado.cost = sk_cost and
                            sklado.type = "O"
                            use-index www
                            no-error.
    if avail sklado then /* если нашли за текущую дату... */
       /* ...то отнять её значение */
       v-amt = sklado.amt.
    else do:
            /* нет - найти последний остаток по товару и минусовать */
            FIND FIRST sklado where sklado.sid = v-sid and
                                    sklado.pid = v-pid and
                                    sklado.dpr = v-dpr and
                                    sklado.cost = sk_cost and
                                    sklado.type = "O"
                                    use-index www
                                    no-error.
            if avail sklado then /* нашли - запомнить остатки */
               v-amt = sklado.amt.
            else
               v-amt = 0.

            /* создать с текущей датой */
            CREATE sklado.
            sklado.sid = v-sid.
            sklado.pid = v-pid.
            sklado.whn = g-today.
            sklado.dpr = v-dpr.
            sklado.cost = sk_cost.
            sklado.type = "O".
       end.

    sklado.amt = v-amt - sk_amt.


end.

