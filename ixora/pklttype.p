/* pklttype.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Виды писем для выбора в списке задолжников
 * RUN
        
 * CALLER
        pkletter.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-14-6
 * AUTHOR
        13.12.2003 nadejda
 * CHANGES
*/


def input-output parameter p-cod as char.

def shared var s-bookcod as char.
def shared var s-codemask as char. 


def shared var g-lang as char.
def var v-bookname as char.
def var v-name as char.
def var vans as logical.
def var v-result as char.

def var zv as int.
zv = 0.

def temp-table t-cods
  field code as char
  field name as char
  field choice as char 
  index sort is primary unique code.

find first bookref where bookref.bookcod = s-bookcod no-lock no-error.
if not avail bookref then do:
  message skip " Справочник " + s-bookcod + " не найден ! (uni_book) "
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

v-bookname = " " + caps(bookref.bookname) + " ".
 
for each bookcod where bookcod.bookcod = s-bookcod and 
         bookcod.code matches s-codemask no-lock:
  create t-cods.
  assign t-cods.code = substr(bookcod.code, 7)
         t-cods.name = bookcod.name
         t-cods.choice = "".
  if lookup(t-cods.code, p-cod) > 0 then do:
    t-cods.choice = "*".
    zv = zv + 1.
  end.
end.

v-result = "".


{jabr.i 

  &start     =  " "
  &head      =  "t-cods"
  &headkey   =  "code"
  &index     =  "sort"
  &formname  =  "pklttype"
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
                      /*if zv = 0 then t-cods.choice = '*'.*/
                      for each t-cods where t-cods.choice = '*':
                        if v-result <> '' then v-result = v-result + ','.
                        v-result = v-result + t-cods.code.
                      end.
                      p-cod = v-result.
                      leave upper.
                  end. "
  &end =        " hide frame uni_book. "
}

