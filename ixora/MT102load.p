/* mt102load.p
 * MODULE
     Операции  
 * DESCRIPTION
        Загрузка мт102 во временную таблицу
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * BASES
        BANK            
 * AUTHOR
        18/05/2009 galina
 * CHANGES
*/

{global.i}

def input parameter v-fname as char no-undo.
/**/
def output parameter v-arp as char no-undo.
/**/
def shared temp-table t-mt no-undo
  field num as integer
  field sequence as char
  field id as char
  field id2 as char
  field str as char
  index idx is primary num.

for each t-mt: delete t-mt. end.

def stream r-in.
def var v-txt as char no-undo.
def var coun as integer no-undo.
def var v-id2 as char no-undo init ''.

def var v-sequence as char no-undo init ''.
/*message "error".
pause 2. */
input stream r-in from value(v-fname).

coun = 0.
repeat:
  import stream r-in unformatted v-txt.
  v-txt = right-trim(v-txt).
  if v-txt = "" then next.

  if v-txt = "-\}" then leave.

  if v-txt matches "\{*" then next.
   
  if v-txt begins ":59:" then v-arp = entry(3,v-txt,':').
  if v-txt matches ":*" then do:
    coun = coun + 1.
    create t-mt.
    t-mt.num = coun.
    t-mt.id = entry(2,v-txt,":").
    case t-mt.id:
     when "20" then assign v-sequence = "A" v-id2 = ''.
     when "21" then assign v-sequence = "B" v-id2 = entry(3,v-txt,":").
     when "32A" then assign v-sequence = "C" v-id2 = ''.
    end.
    t-mt.sequence = v-sequence.
    t-mt.id2 = v-id2.
    t-mt.str = substring(v-txt,length(":" + entry(2,v-txt,":") + ":") + 1).
    next.
  end.
  else do: t-mt.sequence = v-sequence. t-mt.id2 = v-id2. t-mt.str = t-mt.str + v-txt. end.

end.

input stream r-in close.

/*
for each t-mt no-lock:
displ t-mt.sequence format "x(1)" t-mt.id t-mt.id2 t-mt.str format "x(79)".
end.*/

