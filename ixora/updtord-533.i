/* updtord-533.i
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

      /* KOVAL Закрыл редактирование наим. отпр. для типoв Customer & ARP в 5.3.3 */
      if remtrz.outcode = 3 or remtrz.outcode = 6 
         then displ remtrz.ord with frame remtrz.
         else update remtrz.ord validate(remtrz.ord ne "","Введите наименование") with frame remtrz.
      /* KOVAL */
