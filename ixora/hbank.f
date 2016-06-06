/* hbank.f
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

/**** hbank.f ****/

form     
    bankl.bank label "КОД БАНКА (МФО)"
    bankl.name label "НАИМЕНОВАНИЕ"
    bankl.cbank label "БАНК-КОРРЕСП"
    with frame hbank overlay row 4 12 down centered title "  СПРАВОЧНИК БАНКОВ  ".


