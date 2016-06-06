/* ibfn-usac.p
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
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	20.03.2006 u00121 - исправлен column-label из-за ошибки в работе shared library (SYSTEM ERROR: Memory violation. (49)), исправлено по рекемендации ProKb (KB-P25563: Error 49 running a 4GL procedure, stack trace shows umLitGetFmtStr)
        01.02.10 marinav - расширение поля счета до 20 знаков
*/

/*

    14.08.2000
    ibfind-usr-acc.p
    Поиск клиента ИО по счету...
    Пропер С.В.
*/
      
def var cSoob   as char init '[ Сообщение ]'.
def var cWarn   as char init '[ Предупреждение ]'.
def var cError  as char init '[ Ошибка ]'.
def var usracc  as char format "x(20)".
def var usrtb   as char.

repeat:

    update 
    usracc  column-label '!Счет!клиента'
    with centered row 05 frame aa title '[ Поиск клиента ]'
    overlay .
 
    find first bank.aaa where bank.aaa.aaa = usracc
    no-lock no-error.
    if not avail bank.aaa then do:
       message '~n ' +
       'Нет такого счета...~n '
       view-as alert-box title cWarn.
       next.
    end.
                                    
    find first bank.cif where bank.cif.cif = bank.aaa.cif
    no-lock no-error.
    if not avail cif then do:
       message '~n ' +
       'Нет такого клиента!~n ' +
       'Обратитесь к Администратору!!!~n '
       view-as alert-box title cError.
       next.
    end.

    find first ib.usr where ib.usr.cif = cif.cif
    no-lock no-error.
    if not avail ib.usr then do:
       message '~n ' +
       'Такого клиента в сервисе Internet Office нет...~n '
       view-as alert-box title cSoob.
       next.
    end.

    find first ib.otktd where ib.otktd.id_usr = ib.usr.id and ib.otktd.state >0
    no-lock no-error.
    usrtb = if avail ib.otktd then string( ib.otktd.tnum ) else 'Таблицы нет'.

    display
    ib.usr.id            column-label '!Код!клиента'
    ib.usr.login         column-label '!Имя!клиента'
    usrtb format 'x(11)' column-label '!Таблица'
    with frame aa
    .

end.

hide frame aa.
return.

/***/
