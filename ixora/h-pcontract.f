/* h-pcontract.f
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

/* h-pcontract.f Валютный контроль
   Форма к списку контрактов свободного поиска

   18.10.2002 nadejda создан
*/

def var v-cifname as char.

form 
    vccontrs.ctnum format "x(15)" label "НОМЕР" 
    vccontrs.ctdate format "99/99/99"
    v-cifname label "КЛИЕНТ" format "x(10)"
    vccontrs.expimp label "EI"
    vccontrs.cttype label "Т" format "x"
    vcpartners.name format "x(10)" label "ИНОПАРТНЕР"
    vccontrs.ctsum format ">>>,>>>,>>>,>>9.99"
    ncrc.code label "ВАЛ" 
    vccontrs.sts label "СТ" format "xx" 
  with row 5 centered scroll 1 down overlay frame pcontract.




