/* cifaaa.f
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
        16/10/2008 galina - явно указала ширину фрема
        16/02/2009 galina - увеличила ширину фрема
*/

form aaa.aaa label 'Счет'
     lgr.des label 'Группа' format 'x(16)'
     vbal label 'Остаток            ' 
         format 'zzz,zzz,zzz,zz9.99-'
  /*   vavl label ' Дост. остаток ' format "zzz,zzz,zzz,zz9.99-"*/
     vstat label 'Статус'
     with column 1 row 5 13 down title trim(trim(cif.prefix) + " " + trim(cif.name)) overlay width 69 frame cifaaa.
