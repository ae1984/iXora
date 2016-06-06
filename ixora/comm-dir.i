/* comm-dir.i
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

def temp-table comm-dir
    field path as char
               format 'x(50)'
               label "Path"
    field fname as char
               format 'x(50)'
               label "File"
    field fullname as char
               format 'x(50)'
               label "Full name"
    field type as char
               format 'x(1)'
               label "Type"
    index typfn is primary type fullname ascending.

def buffer buffer-dir for comm-dir.

/* ---------------------------------------- */
/*      очистка таблицы comm-dir            */
/* ---------------------------------------- */
procedure comm-cleardir.
   for each comm-dir: delete comm-dir. end.
end procedure.


/* ---------------------------------------- */
/* загружает в таблицу dir список файлов    */
/* по заданной маске; возвращает количество */
/* найденных файлов (в return-value)        */
/* проверяет на файлы с именем ".", ".."    */
/* ---------------------------------------- */
/*  - количество директорий не учитывает! - */
/* ---------------------------------------- */
/* fdir0 - путь к файлам;                   */
/* может быть пустым = текущая директория   */
/* fmask0 - маска;                          */
/*   пустая = все найденные файлы           */
/*        * = для рекурсии всех каталогов   */
/*                                          */
/* ---------------------------------------- */
/* примеры:                                 */
/* comm-dir ("", "")                        */
/* comm-dir ("/data/import", "*")           */
/* comm-dir ("/data/import/", "")           */
/* comm-dir ("/data/import/", "df*.*")      */
/* ---------------------------------------- */
procedure comm-dir.

   def input parameter fdir0 as char.
   def input parameter fmask0 as char.
   def input parameter recursive as logical.
   def var fdir as char.
   def var fmask as char.
   def var fname as char.
   def var fcnt as integer init 0.
   def var fpos as integer.
   def var oldpath as char.


   /* вычистим таблицу с файлами */
   run comm-cleardir.

   /* параметр для поиска файлов: путь + маска */
   fdir = trim (fdir0). if fdir = "" then fdir = ".".
   fmask = trim (fmask0).

   if substring (fdir, length(fdir)) <> "/"
                then fdir = fdir + "/".
   oldpath = fdir.
   
   unix silent value ("ls " + fdir + fmask + " -1 -f > comm-dir.txt").
   unix silent value ("echo . >> comm-dir.txt").

   input from "comm-dir.txt".
  
   do while true on endkey undo, leave:
      import unformatted fname no-error.
      fname = trim(fname).

      fpos = index (fname, "/").
      if fpos <> 0 then do:

         fdir = "".

         /* если в есть двоеточие - отсечем его (это просто список) */
         if substring (fname, length(fname), 1) = ":"
            then do:
                     fdir = substring (fname, 1, length(fname) - 1).
                     fname = "".
                 end.       

         /* если это полное имя файла - разобьем его на части */
            else do:
                     do while fpos <> 0:
                         fdir = fdir + substring (fname, 1, fpos).
                         fname = substring (fname, fpos + 1).
                         fpos = index (fname, "/").
                     end.
                end.

      end.

      if fname <> "." and fname <> ".." then
      do:

         /* здесь: для директории fname = "", fdir = path_to   */
         /*        для файла fname = file_name, fdir = path_to */

         if substr (fdir, length(fdir)) <> "/" then fdir = fdir + "/".

         /* если без рекурсии, и сменили каталог, то выйдем */
         if not recursive and fdir <> oldpath then leave.

         create comm-dir.
         assign comm-dir.path = fdir
                comm-dir.fname = fname
                comm-dir.fullname = fdir + fname
                comm-dir.type = ?.

         file-info:file-name = comm-dir.fullname.
         if index (file-info:file-type, "D") <> 0 then comm-dir.type = "D".
         if index (file-info:file-type, "F") <> 0 then
            do:
               comm-dir.type = "F".
               fcnt = fcnt + 1.
            end.
         if comm-dir.type = "D" and comm-dir.fname = "" then comm-dir.fname = comm-dir.fullname.
         if comm-dir.type = "D" and comm-dir.fullname = oldpath
                               then do:
                                        if comm-dir.type = "F" then fcnt = fcnt - 1.
                                        delete comm-dir.
                               end.

      end.

   end.
   input close.

   unix silent value ("rm comm-dir.txt"). 

   /* очистим дубликаты */
   for each buffer-dir, each comm-dir where comm-dir.type = buffer-dir.type and
                                 comm-dir.fullname = buffer-dir.fullname and
                                 comm-dir.fname = buffer-dir.fname and
                                 comm-dir.path = buffer-dir.path:
        if rowid (buffer-dir) <> rowid (comm-dir)
           then do:
                    if comm-dir.type = "F" then fcnt = fcnt - 1.
                    delete comm-dir.
           end.
   end.

   return string (fcnt).
end.

