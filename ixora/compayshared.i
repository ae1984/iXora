/* compayshared.i
 * MODULE
        Название модуля - Инициализированы Shared параметры для программ коммунальных платежей.
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - compay2.p,compay3.p,compay4.p,compay5.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        27.02.2013 damir - Внесены изменения, вступившие в силу 01/02/2013.
*/
def {1} shared temp-table wrk
    field IdSub as inte
    field Invoice as char
    field docno as inte
    field Counter as inte
    field NamSub as char
    field Curr as deci decimals 6
    field Prev as deci decimals 6
    field Amount as deci decimals 6
    field Price as deci decimals 2
    field Unit as char
    field Duty as char
    field ForPay as deci decimals 2
    field Pay as deci decimals 2
    field sortOrder as inte
    field minTariffValue as deci
    field minTariffThreshold as deci
    field maxTariffValue as deci
    field middleTariffValue as deci
    field middleTariffThreshold as deci
    field tKoef as deci
    field lossesCount as deci
    field prevCountDate as date
    field lastCountDate as date
    field parValue as inte
    field FormulType as logi.




