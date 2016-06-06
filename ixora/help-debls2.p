/* help-debls2.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Поиск дебиторов по всем группам
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
        01/06/2006 u00600
 * CHANGES
        02/06/2006 u00600 - изменила формат b-t-deb.name

*/

def input parameter v-grp like debgrp.grp.
def var choice as int format "9" init 2.
def var str as char format "x(60)".
def var str-rnn as char format "x(12)".

def shared temp-table t-deb 
    field grp  as integer format "z9"
    field ls   as integer  format "zzz9"
    field name as char format "x(37)".

def shared var l_tr as logical.  
def shared var l_int as int.

def var v-name as char no-undo.
def shared var ls like debls.ls.

l_tr = false. l_int = 0.

message "Поиск по номеру (1) поиск по части названия (2)  поиск по РНН (3)" update choice. 

if choice = 2 then do:
   message "Часть названия" update str.
   l_tr = true. l_int = 1.

   if v-grp = 0 then do:
   for each t-deb. delete t-deb. end.
     find first debls where index(debls.name, str) > 0 no-lock no-error.
     if avail debls then do:
       for each debls where index(debls.name, str) > 0 no-lock. /*поиск подобных*/

         create t-deb.
         assign t-deb.grp  = debls.grp
                t-deb.ls   = debls.ls
                t-deb.name = debls.name.

       end.
     end.
     else do: message "Дебитор не найден!"  VIEW-AS ALERT-BOX. return. end.
   end.
   else do:
     for each t-deb. delete t-deb. end.
       find first debls where debls.grp = v-grp and index(debls.name, str) > 0 no-lock no-error.
       if avail debls then do:
         for each debls where debls.grp = v-grp and index(debls.name, str) > 0 no-lock. /*поиск подобных*/

           create t-deb.
           assign t-deb.grp  = debls.grp
                  t-deb.ls   = debls.ls
                  t-deb.name = debls.name.

         end.
       end.
       else do: message "Дебитор не найден!"  VIEW-AS ALERT-BOX. return. end.
   end.

   def temp-table b-t-deb like t-deb.    /*Группировка по наименованию, для вывода на экран не повторяющихся*/
   for each t-deb break by t-deb.name.
     if first-of(t-deb.name) then do:
       create b-t-deb.
       assign b-t-deb.grp  = t-deb.grp
              b-t-deb.ls   = t-deb.ls
              b-t-deb.name = t-deb.name.
     end.
   end.

   define query q1 for b-t-deb.
   define browse b1 query q1 
   displ b-t-deb.grp  format "zzz9"  label "Группа"
         b-t-deb.ls   format "zzz9"  label "Дебитор"
         b-t-deb.name format "x(37)" label "Наименование"
   with 14 down.             

   define frame f1 b1 help "Нажмите ENTER для выбора дебитора"
   with row 1 centered no-label title "Список дебиторов".  

   on "return" of browse b1
   do:
         /*if avail t-deb then message 'Вы уверены?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
         if b then v-name = t-deb.name.*/
         v-name = b-t-deb.name. ls = b-t-deb.ls.
         apply "enter-menubar" to frame f1.
   end.

   open query q1 for each b-t-deb.    
   enable all with frame f1.               
   wait-for "enter-menubar" of frame f1.

   for each t-deb. delete t-deb. end.
   if v-grp = 0 then do:
   for each debls where debls.name = v-name no-lock.  /*поиск по равенству*/
      create t-deb.
      assign t-deb.grp  = debls.grp
             t-deb.ls   = debls.ls
             t-deb.name = debls.name.
   end.
   end.
   else do:
     for each debls where debls.grp = v-grp and debls.name = v-name no-lock.  /*поиск по равенству*/
       create t-deb.
       assign t-deb.grp  = debls.grp
              t-deb.ls   = debls.ls
              t-deb.name = debls.name.
     end.
   end.

end.

if choice = 1 then do:
message "Номер" update str.
   l_tr = true. l_int = 2.
   
for each t-deb. delete t-deb. end.
   if v-grp = 0 then do:
     find first debls where debls.ls = integer(str) no-lock no-error.
     if avail debls then do:
       for each debls where debls.ls = integer(str) no-lock.

         create t-deb.
         assign t-deb.grp = debls.grp
                t-deb.ls  = debls.ls
                t-deb.name = debls.name. 
       end.
     end.
     else do: message "Дебитор не найден!"  VIEW-AS ALERT-BOX. return. end.
   end.
   else do:
     find first debls where debls.grp = v-grp and debls.ls = integer(str) no-lock no-error.
     if avail debls then do:
       for each debls where debls.grp = v-grp and debls.ls = integer(str) no-lock.

         create t-deb.
         assign t-deb.grp = debls.grp
                t-deb.ls  = debls.ls
                t-deb.name = debls.name.
       end.
     end.
     else do: message "Дебитор не найден!"  VIEW-AS ALERT-BOX. return. end.

   end.

end. 

if choice = 3 then do:
message "РНН" update str-rnn.
   l_tr = true. l_int = 3.
   
for each t-deb. delete t-deb. end.
   if v-grp = 0 then do:
     find first debls where debls.rnn = str-rnn no-lock no-error.
     if avail debls then do:
       for each debls where debls.rnn = str-rnn no-lock.
         create t-deb.
         assign t-deb.grp = debls.grp
                t-deb.ls  = debls.ls
                t-deb.name = debls.name. 
       end.
     end.
     else do: message "Дебитор не найден!"  VIEW-AS ALERT-BOX. return. end.
   end.
   else do:
     find first debls where debls.grp = v-grp and debls.rnn = str-rnn no-lock no-error.
     if avail debls then do:
       for each debls where debls.grp = v-grp and debls.rnn = str-rnn no-lock.
         create t-deb.
         assign t-deb.grp = debls.grp
                t-deb.ls  = debls.ls
                t-deb.name = debls.name.
       end.
     end.
     else do: message "Дебитор не найден!"  VIEW-AS ALERT-BOX. return. end.
   end.
end. 

hide frame f1.              
  