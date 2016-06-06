/* tr-vcctd.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Триггер на удаление записи из vccontrs
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
        09.12.2002 nadejda
 * CHANGES
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
trigger procedure for delete of vccontrs.

do transaction:
    /* удалить все документы по контракту */
    for each vcps where vcps.contract = vccontrs.contract exclusive-lock:
        delete vcps.
    end.
    for each vcrslc where vcrslc.contract = vccontrs.contract exclusive-lock:
        delete vcrslc.
    end.
    for each vcdocs where vcdocs.contract = vccontrs.contract exclusive-lock:
        delete vcdocs.
    end.
    /* удалить сведения о снятых комиссиях по контракту */
    for each vcctcoms where vcctcoms.contract = vccontrs.contract exclusive-lock:
        delete vcctcoms.
    end.
    /* история */
    run vc2hisct(vccontrs.contract, "Контракт удален").
end.
