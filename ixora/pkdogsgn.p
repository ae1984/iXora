/* pkdogsgn.p
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
        06/09/2005 madiar - картинка с подписью - убрал полный путь, оставил только имя файла
        25/11/09 marinav - для нестандартной подписи в ЦО масштаб не указываем
*/

/* pkdogsgn.p ПотребКредит
   Нахождение файла факсимиле 

   13.02.2003 nadejda
*/

{global.i}
{pk.i}

{pk-sysc.i}
def var v-dcsign as char.
v-dcsign = get-pksysc-char ("dcsign").

find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "dcsign" no-lock no-error.
/* если стоит "yes" - подпись факсимильная, нет - живая */
if pksysc.loval then do:
  /* определение каталога временных файлов на локальной машине юзера */
  input through localtemp.
  repeat:
    import s-tempfolder.
  end.
  input close.
  pause 0.

  if substr(s-tempfolder, length(s-tempfolder), 1) <> "\\" then s-tempfolder = s-tempfolder + "\\".

  if s-ourbank = "TXB00" then s-dogsign = "<IMG border=""0"" src=""" + v-dcsign + """ v:shapes=""_x0000_s1026"">".
                         else s-dogsign = "<IMG border=""0"" src=""" + v-dcsign + """ width=""180"" height=""60"" v:shapes=""_x0000_s1026"">".
end.
else s-dogsign = "&nbsp;".
