/* hlpcods.f
 * MODULE
        Файл фреймов для ввода   департамента и кодов доходов/расходов
 * DESCRIPTION
        Файл фреймов для ввода   департамента и кодов доходов/расходов
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
        01/04/05 nataly
 * CHANGES
        16.06.05 nataly увеличена разрядность для описания кода
        30/03/06 nataly поменяла frame
*/

/*define frame hdep
    codfr.code no-label
    codfr.name[1]  format 'x(40)' no-label  
     with title "Выберите из списка, F4 - отмена"
    side-labels  row 5 column 5 overlay 8 down.
  */
form codfr.code no-label
    codfr.name[1]  format 'x(40)' no-label  
     with overlay    column 5  row 5 8 down
      title "Выберите из списка, F4 - отмена"  frame hdep .

form cods.code    format 'x(8)' label "Код" 
    cods.dep     format 'x(4)' label "Подр"
    cods.gl      format 'zzzzz9'label "Счет ГК" 
    cods.acc     format 'x(9)' label "Доп приз"
    cods.des   format 'x(45)' label   "Наименование"
     with overlay   column 1 row 3 15 down
      title "Выберите из списка, F4 - отмена"  frame hcode .

