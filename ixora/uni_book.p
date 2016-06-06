/* uni_book.p
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

/* uni_book.p
   Вывод общих справочников comm - для вызова по F2, в основном

   24.01.2003 nadejda

   11.07.2003 sasco откорректировал обработку ENTER

*/

def input parameter p-bookcod as char.
def input parameter p-codemask as char. 
def output parameter p-cod as char.

def shared var g-lang as char.
def var v-bookname as char.
def var v-name as char.
def var vans as logical.

def var zv as int.
zv = 0.

def temp-table t-cods
  field code as char
  field name as char
  field choice as char 
  field treenode as char
  index sort is primary unique treenode.

find first bookref where bookref.bookcod = p-bookcod no-lock no-error.
if not avail bookref then do:
  message skip " Справочник " + p-bookcod + " не найден ! (uni_book) "
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

v-bookname = bookref.bookname.
 
for each bookcod where bookcod.bookcod = p-bookcod and 
         if p-codemask = '' then true else bookcod.code matches p-codemask
         no-lock:
  create t-cods.
  assign t-cods.code = bookcod.code
         t-cods.name = bookcod.name
         t-cods.choice = ""
         t-cods.treenode = bookcod.treenode.
end.

p-cod = "".
displ '    INSERT - отметить/снять отметку, ENTER - продолжить   ' with row 3 centered overlay no-label frame infofr. 

{jabr.i 

  &start     =  " "
  &head      =  "t-cods"
  &headkey   =  "code"
  &index     =  "sort"
  &formname  =  "uni_book"
  &framename =  "uni_book"
  &where     =  " true "
  &addcon    =  "false"
  &deletecon =  "false"
  &prechoose =  " "
  &predisplay = " "
  &display   =  " t-cods.choice t-cods.code t-cods.name "
  &highlight =  " t-cods.choice t-cods.code t-cods.name "
  &postkey   =  " else if keyfunction(lastkey) = 'insert-mode' then do:
                    if t-cods.choice = '' then assign t-cods.choice = '*' 
                                                      zv = zv + 1.
                                          else assign t-cods.choice = '' 
                                                      zv = zv - 1.
                    leave outer.
                  end.
                  else if keyfunction(lastkey) = 'return' then do:
                      if zv = 0 then t-cods.choice = '*'.
                      for each t-cods where t-cods.choice = '*':
                        if p-cod <> '' then p-cod = p-cod + ','.
                        p-cod = p-cod + t-cods.code.
                      end.
                      leave upper.
                  end. "
  &end =        " hide frame uni_book. hide frame infofr. "
}

