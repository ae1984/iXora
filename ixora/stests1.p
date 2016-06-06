/* stests1.p
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


{lgps.i}

def shared var oi-name as char.
def var s-b as char.
def var s-c as char.
def shared var v-ordins as char format "x(11)".
def var v-swn as char extent 50.
def var v-string as char.
def var v-name as char.
def var i as int.
def var j as int.
def var v-coun as char.
def var v-city as char.
def var v-addr as char.
def var pa as int.
def var v-ers as char.
/*
update v-ordins with frame ss.
*/

input through value 
 ("/usr/local/bin/bintutil/bintser -b" + substr(trim(v-ordins),1,4) +
  " -c" + substr(trim(v-ordins),5,2) + " -r" + substr(trim(v-ordins),7,2) +
  " ; echo $?" ).

  v-swn = "".
  repeat:
    import unformatted v-swn.
    leave.
  end.

  if v-swn[1] = "0" then do:
     v-text = "Банк " + trim(v-ordins) + " не найден в bint файле ".
     run lgps.
     return. 
  end.
  else v-ers = v-swn[1].

   j = 0.
   pa = 0.
   repeat:
     j = j + 1.
     if j > 11 then leave.
     v-swn = "".
     i = 0.
     import unformatted v-swn.
     /*
     display v-swn[1] format "x(40)". pause.
     */
     v-string = "".
      repeat:
        i = i + 1 . if i > 50 then leave .
        if v-swn[i] = "" then next . 
        v-string = v-string + v-swn[i] + " " .
      end.
      if v-string begins "Name :"  then v-name = substr(v-string,7) .
      else
      if v-string begins "Country :" then v-coun = substr(v-string,10).
      else 
      if v-string begins "City :" then v-city = substr(v-string,7).
      else 
      if v-string begins "Address :" then do :
         v-addr = substr(v-string,10). 
         pa = 1.
      end.
      else 
      if v-string begins "" then
      do :
       if pa > 0 then do :
         pa = pa + 1.
         v-addr = trim(v-addr) + " " + trim(v-string).
       end.
      end.
      if pa > 3 then pa = 0.
   end.

 input close.

 oi-name = trim(v-name) + " " + trim(v-coun) + " " +
        trim(v-city) + " " + trim(v-addr).
 if oi-name eq "" then do :
  /*
 display oi-name format "x(60)" with frame dd.
 else
 */ 
  v-text = "Ошибка BINTSER !!! " + trim(v-ers). 
  run lgps.
 end.

