/* r-spgl.p
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
 * BASES
        BANK
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        25.05.10 marinav увеличено наименование
*/

/* r-spgl.p
   список счетов главной книги со всеми признаками
   18.04.00    */
   
{mainhead.i}
{functions-def.i}

def var v-dohdiv as char.
def var v-profitcn as char.

def stream m-out.
output stream m-out to rpt.img.
put stream m-out
FirstLine( 1, 1 ) format 'x(112)' at 2 skip(1)
'                             '
'СЧЕТА ГЛАВНОЙ КНИГИ '  skip
'                         '
'(по состоянию на  ' string(g-today) ')' skip(1)
FirstLine( 2, 1 ) format 'x(112)' at 2 skip.
put stream m-out  fill( '-', 112 ) format 'x(112)' at 2 skip.
put stream m-out
'  Счет '
'                          Название                             '
'Тип '
'Тип '
'Уро- '
'Итог '
' Итог '
' Итог ' 'Делить' ' Профит-центр '
 skip.
put stream m-out
'  Г/К  '
'                                         '
'сч. '
'с/с '
'вень '
'     '
' счет '
' уров.'
 skip.
put stream m-out  fill( '-', 112 ) format 'x(112)' at 2 skip(1).
for each gl no-lock.
  find sub-cod where sub-cod.acc = string(gl.gl) and sub-cod.sub = 'gld' and 
      sub-cod.d-cod = 'sproftcn' no-lock no-error.
  if available sub-cod then do:
    find codfr where codfr.codfr = 'sproftcn' and codfr.code = sub-cod.ccode no-lock no-error.
    v-profitcn = '(' + codfr.code + ') ' + codfr.name[1]. 
  end.
  else v-profitcn = ''.

  find sub-cod where sub-cod.acc = string(gl.gl) and sub-cod.sub = 'gld' and 
      sub-cod.d-cod = 'dohdiv' no-lock no-error.
  if available sub-cod then do:
    v-dohdiv = sub-cod.ccode.
  end.
  else v-dohdiv = ''.

  put stream m-out  ' ' 
    gl.gl format "zzzzz9" ' ' 
    gl.des format "x(62)" ' '  
    gl.type format "x(1)" '  '  
    gl.subled format "x(3)" '  '  
    gl.level format "z9" '   '  
    gl.totact  '  '
    gl.totgl format "999999"  '  '
    gl.totlev format "9 " 
    v-dohdiv format "x(3)" ' '
    v-profitcn format "x(50)"
    skip.   
end.
put stream m-out  fill( '-', 112 ) format 'x(112)' at 2 skip.
output stream m-out close.
if not g-batch then do:
   pause 0.
   run menu-prt( 'rpt.img' ).
end.
