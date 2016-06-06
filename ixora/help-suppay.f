/* help-suppay.f
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур - help-suppay.p
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        07.11.2012 damir - Внедрено Т.З. № 1365,1481,1538.
*/

form
    comm.suppcom.name label "Наименование"
    comm.suppcom.knp label "КНП"
with title "Выбор поставщика услуг" 10 down row 10 centered overlay frame F_Supp.


