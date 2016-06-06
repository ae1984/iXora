/* chbny-gld.p
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

output to gl.d.
for each gl:
  export gl.gl gl.des gl.sname gl.dname1 gl.dname2 gl.cname1 gl.cname2 gl.subled
     gl.level gl.grp gl.revgl gl.gl1
     gl.autogl gl.code.
end.
output close.
