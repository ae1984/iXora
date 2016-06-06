/* proc_rp.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       29/08/06 u00121 заменил nawk на awk
*/

{global.i }
def new shared var v-hst as cha .
def new shared var v-log as cha .
def var s-remtrz like remtrz.remtrz . 
def var df as date . 
def var dt as date .
def var dfi  as date .
def var v-str as cha .
def var v-ofc like ofc.ofc .
def var t-pid like fproc.pid .
def var t-rmz like remtrz.remtrz .
def var t-pos as int format ">>>>>9" .
def var comm as cha format "x(20)" label "Команда печати" init "prit".
def temp-table trpt
  field pid like fproc.pid
  field dt as date format "99/99/9999"
  field crc like remtrz.fcrc 
  field prname as cha
  field rmz like remtrz.remtrz .
def stream main .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message "Отсутствует запись OURBNK в таблице SYSC!".
 pause .
 return .
end.
v-hst = trim(sysc.chval).

find sysc where sysc.sysc = "PS_LOG" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message "Отсутствует запись PS_LOG в таблице SYSC!".
 pause .
 return .
end.
v-log = trim(sysc.chval).

df = today . 
dt = today . 
s-remtrz = "" . 
update df label "Дата с" 
       dt label "Дата до"
       v-ofc label "Работник"
       comm
       with centered side-label 1 column row 5 frame qq .
v-ofc = trim(caps(v-ofc)) .

find first ofc where ofc.ofc = v-ofc no-lock no-error .
if not avail ofc and v-ofc <> "" then do :
 message "Ошибка! Не найден " + v-ofc + " в таблице OFC." . pause .
 return .
end .

output stream main to rpt.img .
put stream main unformatted "Дата        : " string(today,"99/99/9999") skip
  "Время       : " string(time,"hh:mm:ss") skip
  "Исполнитель : " g-ofc skip .
v-str = "Отчет по операциям. " + 
  (if v-ofc <> "" then "Работник " + ofc.name + "." else "") .
put stream main unformatted skip(2) 
  v-str at (39 - length(v-str) / 2)
  skip
  "за " + string(df,"99/99/9999") + " - " + string(dt,"99/99/9999") at 25
  skip(1) .

put stream main unformatted fill("-",70) skip .
put stream main "Код  Тип операции                              "
   "Вал      Дата    Кол-во" skip .
put stream main unformatted fill("-",70) skip .

    dfi = df . 
    if search("tmp.awk") = "tmp.awk" then do :
     unix silent value("rm tmp.awk") .  
    end .
    repeat :
     if dfi > dt then leave .
     display "Ждите..." dfi with centered frame qq1 no-label . pause 0 .
     if    search(v-log + trim(v-hst) + "_logfile.lg." +
       string(dfi,"99.99.9999")) =
       v-log + trim(v-hst) + "_logfile.lg." +
       string(dfi,"99.99.9999") then do :
      input through value("dd conv=ucase if=" +
        v-log + trim(v-hst) + "_logfile.lg." +
        string(dfi,"99.99.9999")  + "  2>/dev/null | " +
        "awk -v ofc='" + v-ofc + "' '\{ " +
        " if(((index($0,""SUPERMAN"") == 0) || (ofc == ""SUPERMAN"")) " +
        " && (($5 == ofc) || ($6 == ofc) || ($7 == ofc) || (ofc == """"))) " + 
        "\{ " +
        "  printf $1 "" "" $4 "" "" $5 "" ""; " +
        "  s = $0 ; " +
        "  i = index(s,""RMZ"") ; " +
        "  while(i != 0) \{ " +
        "   printf substr(s,i,10) "" "" ; " +
        "   s = substr(s,i+1,length(s)-i) ; " + 
        "   i = index(s,""RMZ"") \} " +
        "   print """" \} \} ' " ) . /*29/08/06 u00121 заменил nawk на awk*/
      repeat :
       import unformatted v-str .
       t-pid = entry(2,v-str," ") .
       t-pos = 4 .
       repeat while entry(t-pos,v-str," ") <> "" :
        t-rmz = entry(t-pos,v-str," ") .
        t-pos = t-pos + 1 .
        find first remtrz where remtrz.remtrz = t-rmz no-lock no-error .
        if avail remtrz then do :
         create trpt .
         trpt.pid = t-pid .
         trpt.rmz = t-rmz .
         find first ptyp where ptyp.ptype = remtrz.ptype no-lock no-error .
         if avail ptyp and ptyp.sender = "n" then
          trpt.crc = remtrz.tcrc .
         else
          trpt.crc = remtrz.fcrc .
         trpt.dt = date(entry(1,v-str," ")) .
         trpt.prname = entry(3,v-str," ") .
         leave .
        end .
       end .
      end .
     end .
     dfi = dfi + 1 .
    end .
    t-pos = 0 .
    for each trpt no-lock break 
      by trpt.pid
      by trpt.prname
      by trpt.dt
      by trpt.crc 
      by trpt.rmz .
     if last-of(trpt.rmz) then
      t-pos = t-pos + 1 .
     if last-of(trpt.crc) then do :
      find first fproc where substr(fproc.nprc,1,length(fproc.nprc) - 2)
        = trpt.prname no-lock no-error .
      if not avail fproc then
       find first fproc where fproc.pid = trpt.pid no-lock no-error .
      if avail fproc then do :
       find first crc where crc.crc = trpt.crc no-lock .
       put stream main 
         fproc.pid at 1
         fproc.des at 6
         crc.code at 48
         trpt.dt at 53
         t-pos at 65
         skip .
      end .
      t-pos = 0 .
     end .
    end .
    input close .
    output stream main close .
    unix value(comm + " rpt.img") .
    pause 0 .
