/* jouhelp.f
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

/** jouhelp.f **/

def var p-amt like joudoc.dramt . 

form jouhelp.docnum label "Номер док."
    vtim1         label " Время   "
    jouhelp.jh     label "Транз.Nr." format "zzzzzzzz"
    vsts          label "СТС" format "z"
    vtim2         label "Время тран."
    p-amt  label "Сумма операции        " format "z,zzz,zzz,zzz,zz9.99"
    /*jouhelp.cramt label "Сумма кредита" format "z,zzz,zzz,zz9.99"
    jouhelp.comamt label "Сумма комиссии" format "z,zzz,zzz,zz9.99"*/
    with row 3 10 down  centered no-label overlay
    title " Документы исполнителя текущего дня " frame jouhelp.


form jouhelp.dracctype  label "Дебет " format "x(10)" 
    jouhelp.cracctype  label "Кредит " format "x(25)" at 40 skip
    jouhelp.dracc label "Счет " 
    jouhelp.cracc label "Счет  " at 40 skip
    jouhelp.dramt label "Сумма" format "zzz,zzz,zzz,zz9.99" dcrccode label "" 
    jouhelp.cramt label "Сумма " format "zzz,zzz,zzz,zz9.99" at 40 
    ccrccode     label " "
    with column 4 row 17 side-label 
    title "Детали операции   " overlay frame jouhelp1.



