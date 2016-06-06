/* h-contract.f
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
       28.04.2008 galina - выводим два символа типа контракта
*/

/* h-contract.f Валютный контроль
   Форма к списку контрактов

   18.10.2002 nadejda создан
*/

form 
    vccontrs.ctdate format "99/99/99"
    vccontrs.ctnum format "x(20)" label "НОМЕР" 
    vccontrs.expimp label "EI"
    vccontrs.cttype label "Т" format "x(2)"
    vcpartners.name format "x(12)" label "ИНОПАРТНЕР"
    vccontrs.ctsum format ">>>,>>>,>>>,>>>,>>9.99"
    ncrc.code label "ВАЛ" 
    vccontrs.sts label "СТ" format "xx" 
  with width 80 row 5 centered scroll 1 down overlay frame contract.



