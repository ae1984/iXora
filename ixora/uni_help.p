/* uni_help.p
 * MODULE
        HELP
 * DESCRIPTION
        Форма вывода для множественного выбора из справочника по F2
 * RUN
        on help of <var> in frame <frame> do:
          run uni_help ("<codfr>", "<mask>", output <var>).
          displ <var> with frame <frame>. 
        end.
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        16.05.2003 nadejda
 * CHANGES
*/


{global.i}


def input parameter p-bookcod as char.
def input parameter p-codemask as char. 
def output parameter p-cod as char.

def var v-bookname as char.
def var v-name as char.
def var vans as logical.

def temp-table t-cods
  field code as char
  field name as char
  field choice as char 
  field treenode as char
  index sort is primary unique treenode code.

find first codific where codific.codfr = p-bookcod no-lock no-error.
if not avail codific then do:
  message skip " Справочник " + p-bookcod + " не найден ! (uni_help)"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

v-bookname = codific.name.
 
for each codfr where codfr.codfr = p-bookcod and 
         if p-codemask = '' then true else codfr.code matches p-codemask
         no-lock:
  create t-cods.
  assign t-cods.code = codfr.code
         t-cods.name = codfr.name[1]
         t-cods.choice = "".
  if trim(codfr.name[2]) <> "" then t-cods.name = t-cods.name + " (" + codfr.name[2] + ")".
  t-cods.treenode = t-cods.name.
end.

p-cod = "".

{jabr.i 

  &start     =  " "
  &head      =  "t-cods"
  &headkey   =  "code"
  &index     =  "sort"
  &formname  =  "uni_help"
  &framename =  "uni_book"
  &where     =  " true "
  &addcon    =  "false"
  &deletecon =  "false"
  &prechoose =  " "
  &predisplay = " "
  &display   =  " t-cods.choice t-cods.code t-cods.name "
  &highlight =  " t-cods.choice t-cods.code t-cods.name "
  &postkey   =  " else if keyfunction(lastkey) = 'insert-mode' then do:
                    if t-cods.choice = '' then t-cods.choice = '*'.
                                          else t-cods.choice = ''.
                    leave outer.
                  end.
                  else if keyfunction(lastkey) = 'return' then do:
                      t-cods.choice = '*'.
                      for each t-cods where t-cods.choice = '*':
                        if p-cod <> '' then p-cod = p-cod + ','.
                        p-cod = p-cod + t-cods.code.
                      end.
                      leave upper.
                  end. "
  &end =        " hide frame uni_book. "
}



