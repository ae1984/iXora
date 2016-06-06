/* vccheckcont.i
 * MODULE
        Название модуля - Валютный контроль
 * DESCRIPTION
        Описание - Проверка на определенный на определенные типы контрактов.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - vccontrs.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        25.12.2012 damir - Внедрено Т.З. № 1306.
*/

def var s-dte as date.
s-dte = g-today.

if vccontrs.cttype = "11" then do:
    v-workcond = false.
    {vcdocsdiffcoll.i}

    {vcdocsdifferent.i}

    {vc_com_exp-cred.i &cttype = "11" &limitexp = "500000" &limitimp = "100000"}

    if v-workcond then message "Контракт подлежит получению РС в НБРК! " skip
                               "Введите данные РС в опцию РС/СУ!" view-as alert-box buttons ok.
end.