/* p_pkanlzd_all.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Загрузка push-отчета по кредитам физ.лиц консолидированно
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        30/12/2008 galina
 * BASES
        BANK
 * CHANGES
*/
{global.i}
{push.i}
run pkanlzd("all",vdt,vfname).
