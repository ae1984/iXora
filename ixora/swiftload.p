/* swiftload.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
 * AUTHOR
        03.10.2012 evseev
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

define input parameter swmt as char format "x(3)".

run savelog( "swiftload", "27. Начало....................... " + swmt).

def var v-source    as char no-undo.
def var v-destination    as char no-undo.

v-source = '/swift/out/'.
v-destination = "/data/import/_mt" + swmt + "/".

def var v-swt       as char no-undo.
def var v-files0    as char no-undo.
def var v-files     as char no-undo.
def var i           as int  no-undo.
def var v-str       as char no-undo.
def var v-exist1    as char no-undo.
def var v-filename  as char no-undo.
def var v-isAdd     as logical no-undo.

def var v-countmess    as int  no-undo.
def var swift_id       as int  no-undo.
def stream r-in.

def temp-table t-swt no-undo
    field num as decimal
    field str as char format "x(100)"
    index idx is primary num.

def var v-txt       like t-swt.str no-undo.
def var v-num       like t-swt.num no-undo.


function GetSwiftId returns integer.
    do transaction:
        find first pksysc where pksysc.sysc = "swift_id" exclusive-lock no-error.
        if avail pksysc then
           pksysc.chval = string(int(pksysc.chval) + 1).
        else do:
           create pksysc.
           pksysc.sysc = "swift_id".
           pksysc.chval = "1".
        end.
        find first pksysc where pksysc.sysc = "swift_id" no-lock no-error.
    end.
    return int(pksysc.chval).
end function.

v-swt = ''.
find first pksysc where pksysc.credtype = '' and pksysc.sysc = 'swtpath' no-lock no-error.
if avail pksysc then v-swt = pksysc.chval.


input through value( "find " + v-destination + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-destination).
    unix silent value("chmod 777 " + v-destination).
end.

v-destination = v-destination + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
input through value( "find " + v-destination + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-destination).
    unix silent value("chmod 777 " + v-destination).
end.

v-files0 = ''.
input through value( 'grep  -Elis "\{2:O' + swmt + '" ' + v-source + '*.txt').

repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    if v-str <> '' then do:
        v-str = entry(num-entries(v-str,"/"),v-str,"/").
        if v-files0 <> "" then v-files0 = v-files0 + "|".
        v-files0 = v-files0 + v-str.
    end.
end.
if v-files0 = '' then return.
run savelog( "swiftload", "66. v-files0 = " + v-files0).


v-files = ''.
do i = 1 to num-entries(v-files0,"|"):
    find first swift where  swift.file = entry(i,v-files0,"|") and swift.mt = swmt and swift.io = "O" and swift.dt > today - 11 no-lock no-error.
    if not avail swift then do:
        if v-files <> "" then v-files = v-files + "|".
        v-files = v-files + entry(i,v-files0,"|").
    end. else do:
        run savelog( "swiftload", "77.  Файл был загружен! " + entry(i,v-files0,"|")).
    end.
end.
if v-files = '' then return.
run savelog( "swiftload", "81.  v-files = " + v-files).

do i = 1 to num-entries(v-files, "|"):
    v-str = ''.
    input through value('cp ' + v-source  + entry(i, v-files, "|") + ' ' + v-destination + ' ;echo $?').
    import unformatted v-str.
    if v-str <> "0" then do:
        run savelog( "swiftload", "89. Ошибка копирования swift-файлов!").
        return.
    end.
end.




do i = 1 to num-entries(v-files, "|"):
   v-filename = entry(i, v-files, "|").
   empty temp-table t-swt.
   v-num = 0.
   unix silent value('echo "" >> ' + v-destination + v-filename). /* на случай если нет возврата каретки в последней строке - добавляем */
   input stream r-in from value(v-destination + v-filename).
   repeat:
       import stream r-in unformatted v-txt.
       v-num = v-num + 1.
       run savelog( "swiftload", "145. " + string(v-num,">>>9") + "  " + v-txt).
       if  v-txt matches '*\{5:*' and v-txt matches '*\{1:*' then do:
           create t-swt. assign t-swt.num = v-num  t-swt.str = substr(v-txt, 1, index(v-txt,chr(3)) - 1).
           create t-swt. assign t-swt.num = v-num + 0.1 t-swt.str = substr(v-txt, index(v-txt,'\{1:'), length(v-txt)).
       end. else do:
           create t-swt. assign t-swt.num = v-num  t-swt.str = v-txt.
       end.
   end.
   input stream r-in close.

   v-countmess = 0.
   v-isAdd = false.
   for each t-swt.
       if  t-swt.str matches '*\{1:*' then v-countmess = v-countmess + 1.
       if  t-swt.str matches '*\{2:O' + swmt + '*' then do:
          v-isAdd = true.
          swift_id = GetSwiftId().
          do transaction:
              create swift.
              assign
                 swift.swift_id = swift_id
                 swift.dt = today
                 swift.tm  = time
                 swift.usr = g-ofc
                 swift.io  = 'O'
                 swift.file = v-filename
                 swift.num  = v-countmess
                 swift.mt = swmt
                 swift.rmz = "".
          end.
          run InsSwiftSts(swift_id, "SWIFT-документ загружается " + string(swift_id) + " ...","loading").
          run savelog( "swiftload", "167. Загружается.. swift_id=" + string(swift_id)).
       end.
       if v-countmess > 0 and v-isAdd then do:
          do transaction:
              create swift_det.
              swift_det.swift_id = swift_id.
              swift_det.line = int(t-swt.num).
              if trim(t-swt.str) matches ':...:*' or trim(t-swt.str) matches ':..:*' then  swift_det.fld = trim(entry(2, t-swt.str, ":")).
              swift_det.val = t-swt.str.
          end.
          if  t-swt.str matches '*\{5:*' then do:
              v-isAdd = false.
              run InsSwiftSts(swift_id, "SWIFT-документ загружен " + string(swift.swift_id),"new").
              run savelog( "swiftload", "189. Загружен! swift_id=" + string(swift_id)).
          end.
       end.
   end.
end. /* do */

run savelog( "swiftload", "195. Файл загружен....................... " + swmt).