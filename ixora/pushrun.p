/* pushrun.p
 * MODULE
        PUSH-отчеты
 * DESCRIPTION
        Запуск отчетов
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        28/03/05 sasco
 * CHANGES
        31/03/05 sasco Оптимизировал блок транзакции (добавил do transaction...)
        25/07/05 sasco Исправил поиск уже запущенных отчетов

        20.01.2012 aigul - отправка рассылки от ДВК
        24.01.2012 aigul - убрала рассылку от ДВК
        26.01.2012 aigul - отправка рассылки от ДВК
        06.02.2012 aigul - убрала рассылку от ДВК
*/


def shared var g-ofc as char.
def shared var g-today as date.

/*  окончание названия файла  */
def var fsuffix as char init "".

{push.i "new"}

/*  смещение по периоду  */
def var vdelta as int.


report_cycle:
for each pushrep no-lock:

    /* определение сдвига (по месяцу или по году) */
    if pushrep.params matches "*-*" then vdelta = -1.
    else
    if pushrep.params matches "*+*" then vdelta = 1.
                                    else vdelta = 0.

    vmont = vmont + vdelta.

    case pushrep.type:
         when "d" then do:
                          vdt = g-today + vdelta.
                          vd1 = g-today + vdelta.
                          vd2 = g-today + vdelta.
                          run update_dates (vd1).
                          fsuffix = "".
                          find pushrun where pushrun.id  = pushrep.id and
                                             pushrun.y = vyear and
                                             pushrun.m = vmont and
                                             pushrun.d = vdate
                                             no-lock no-error.
                          if avail pushrun then next report_cycle.
                      end.
         when "m" then do:
                          vdt = g-today.
                          vd1 = GenDate (vmont, vyear, "beg").
                          vd2 = GenDate (vmont, vyear, "end").
                          run update_dates (vd1).
                          find pushrun where pushrun.id  = pushrep.id and
                                             pushrun.y = vyear and
                                             pushrun.m = vmont
                                             no-lock no-error.
                          if avail pushrun then next report_cycle.
                      end.
         when "q" then do:
                          vdt = g-today.
                          vd1 = GenDate ((vquar - 1) * 3 + 1, vyear, "beg").
                          vd2 = GenDate (vquar * 3, vyear, "end").
                          run update_dates (vd1).
                          find pushrun where pushrun.id  = pushrep.id and
                                             pushrun.y = vyear and
                                             pushrun.q = vquar
                                             no-lock no-error.
                          if avail pushrun then next report_cycle.
                      end.
         when "y" then do:
                          vdt = g-today.
                          vd1 = GenDate (1, vyear, "beg").
                          vd2 = GenDate (12, vyear, "end").
                          run update_dates (vd1).
                          find pushrun where pushrun.id  = pushrep.id and
                                             pushrun.y = vyear
                                             no-lock no-error.
                          if avail pushrun then next report_cycle.
                      end.
    end case.

    vid = pushrep.id.
    vpath = pushrep.path.
    vprefix = pushrep.prefix.
    vproc = pushrep.proc.
    vfname = vpath + "/" + vprefix + "-" + string(vyear) + "-" + string(vmont) + "-" + string(vquar) + "-" + string(vdate) + ".html".

    run savelog ("pushrep", "Запуск отчета '" + pushrep.des + "' с ID= " + string(vid) +
                            " d= " + string (vdate) + " m= " + string (vmont) +
                            " q= " + string (vquar) + " y= " + string (vyear)).
    run value (vproc).

    run savelog ("pushrep", "Результат = " + string(vres)).

    if vres then if search (vfname) <> ? then do transaction:
       create pushrun.
       assign pushrun.id = vid
              pushrun.rdt = today
              pushrun.rtim = time
              pushrun.d = vdate
              pushrun.m = vmont
              pushrun.q = vquar
              pushrun.y = vyear
              pushrun.proc = vproc
              pushrun.fname = vfname
              no-error.
    end.

    if vres then run pushofc.

end.
