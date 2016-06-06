/* scan.i
 * MODULE
        Работа со сканером штрих-кодов
 * DESCRIPTION
        В этой i-шке описание общих таблиц и переменных для модуля
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5.3.16
 * AUTHOR
        23.08.2004 suchkov
 * CHANGES
        18.07.2005 suchkov - поменял тип поля sum с integer на decimal
        05.10.2005 ten - добавил 28-ой extent
*/


define {1} shared temp-table t-rmz
    field tfld as character extent 28 format "x(50)"
    field terr as character label "Ошибки"
    field rmz  as character format "x(10)" label "REMTRZ" 
    field sum  as decimal label "Сумма"
    field tpri as logical initial yes.
