/* vcreason.f
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Форма к справочникам Основание закрытия контракта, Основание оформления доп.листа
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
     28.03.2008 galina   
 * CHANGES
*/


form codfr.code LABEL "КОД" 
     codfr.name[1] LABEL "ОПИСАНИЕ"  format "x(60)"
     with  centered row  3 down frame vcreason.
