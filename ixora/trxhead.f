/* trxhead.f
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
        01/09/04 sasco русифицировал форму
        04/12/08 marinav - увеличение формы для IBAN
*/

form trxhead.system label "Тип"
     trxhead.code label "Код "
     trxhead.des format "x(66)" label "Описание транзакции    "
     vlines format "z9" label "Лн"
     with row 3 15 down centered frame trxhead.

form tmpsys format "x(3)"
     tmpcode format "zzz9"
     tmpdes format "x(57)" 
     with no-label no-box row 4 column 2 overlay frame trxhead1.

