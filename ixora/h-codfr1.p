/* h-codfr1.p
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
        18.03.2004 marinav
 * CHANGES
*/

def input parameter p-bookcod as char.
def input parameter p-codemask as char. 
def output parameter p-cod as char.

def shared var g-lang as char.
def var v-codname as char.
def var v-name as char.
def var vans as logical.

def var zv as int.
zv = 0.

def temp-table t-cods
  field code as char
  field name1 as char
  field name2 as char
  field choice as char 
  index sort code .

find codific where codific.codfr = p-bookcod no-lock no-error.
if not avail codific then do:
  message skip " Справочник " + p-bookcod + " не найден ! (codfr) "
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

v-codname = codific.name.
 
for each codfr where codfr.codfr = p-bookcod and 
         if p-codemask = '' then true else codfr.papa matches p-codemask
         no-lock:
  create t-cods.
  assign t-cods.code = codfr.code
         t-cods.name1 = codfr.name[1]
         t-cods.name2 = codfr.name[2]
         t-cods.choice = "".
end.

p-cod = "".
displ '    INSERT - отметить/снять отметку, ENTER - продолжить   ' with row 3 centered overlay no-label frame infofr. 

{jabr.i 

  &start     =  " "
  &head      =  "t-cods"
  &headkey   =  "code"
  &index     =  "sort"
  &formname  =  "h-codfr1"
  &framename =  "h-cod"
  &where     =  " true "
  &addcon    =  "false"
  &deletecon =  "false"
  &prechoose =  " "
  &predisplay = " "
  &display   =  " t-cods.choice t-cods.code t-cods.name1 t-cods.name2 "
  &highlight =  " t-cods.choice t-cods.code t-cods.name1 t-cods.name2 "
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
  &end =        " hide frame h-cod. hide frame infofr. "
}

