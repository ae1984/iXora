/* operimp.p
 * MODULE
        Операционный департамент
 * DESCRIPTION
        Формирование писем для НБРК.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        oper1.p
 * MENU
        1-7-4-15
 * AUTHOR
        04.04.06 Tен
 * CHANGES
        09.06.06 Ten - закоментил сохранение папки НБРК в таблицу sysc.
        22/06/06 Ten - добавил возможность менеджеру самому удалять блокировку на формирование писем в НБРК.
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
*/

{global.i}
def var pathname as char init 'C:\\nb'.
  update  pathname format "x(40)" label "Введите полный путь к файлам" with side-labels centered frame pname.

hide frame pname.
pathname = caps(trim(pathname)).

def var v-vvv as char no-undo.
def var v-fexp as char no-undo.
def var v-pro as int no-undo.
def var v-fol as char no-undo.
def var v-str as char no-undo.
def var v-fol1 as char no-undo.
def var i  as integer init 0 no-undo.
def var ii  as integer init 0 no-undo.
def var v-bal as dec no-undo.
def var v-dop as log no-undo.
def var v-lock as char no-undo.
def var v-use-limit as dec no-undo.
def var v-limit as dec no-undo.
def var v-fil as char no-undo.
def var s  as char init '' no-undo.
def var ds as char INIT '' no-undo.
def var v-frst as char no-undo.
def var ts as char INIT '' no-undo.
def var v-cent as int no-undo.
def var v-docn as char no-undo.
def var v-cent1 as char no-undo.
def var logic as logic init false no-undo.
def var v-txt as char no-undo.
def var v-hop as logical init false no-undo.
def var dir as char no-undo.
def var v-rnn as char no-undo.
def stream r-in .
def var coun as integer no-undo.
def var v-city as char no-undo.
def var v-ofc as char no-undo.
def var v-adr as char no-undo.
def var v-who as char no-undo.
def var v-frst1 as char no-undo.
def var mailaddr as char no-undo.
def var v-from as char no-undo.
def var v-nb as char no-undo.
def var b as int no-undo.
def var v-org as char no-undo.
def var v-ind as int no-undo.
def var v-eng as char no-undo.
def var v-bic as char no-undo.
def var v-summawrd as char no-undo.
def var v-ent as int no-undo.
def var v-grep as log init false.
def var v-ent1 as int no-undo.
def var v-ex as logical init false no-undo.
def var v-na as char no-undo.
def var v-na1 as char no-undo.
def var v-gofc as char no-undo.
def var q as dec no-undo.
def var d as int no-undo.

def temp-table tf no-undo
    field id       as integer
    field filename as char format "x(25)" 
    field ts       as char format "x(15)"
    field descr    as char format "x(25)".

def temp-table tm no-undo
         field code as char
         field name1 as char
         field id as int
         field name as char.

def new shared temp-table temp no-undo
         field code as char
         field acc like aaa.aaa
         field val as char
         field id as int
         field name as char
         field rnn as char
         field name1 as char
         field bank as char
         field bic as char
         field docnum as char
         field val1 as char
         field bal1 as dec
         field bal as dec.
def new shared buffer btemp for temp .

def temp-table msgc no-undo
  field num as int
  field txt as char
  index num_idx is primary num. 


pathname = replace ( pathname , '/', '\\' ).
if index(substr(pathname,length(pathname) ,1), '~\') <= 0 
   then pathname = pathname + '~\'.

do trans:
input through value("rsh `askhost` dir /b '" + pathname + "*.txt '") no-echo.
    repeat:
      import unformatted s.
      if substr(caps(s),1,10) = 'THE SYSTEM' then do: 
         MESSAGE "Указан неверный путь к файлам: ~n" + pathname
         VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE " Внимание " .
         undo, return. 
      end.
      create tf.
      assign tf.id = i  
             tf.filename = s 
             tf.ts       = ts .
      assign ds = '' ts = '' .
   end.
input close.
end.
DEFINE QUERY q1 FOR tf.
def var fname as char init ''.

def browse b1 
    query q1 no-lock
    display tf.filename  label " Файл "       format "x(23)"
    with 14 down .
def frame fr1 
    b1 /*exit*/
    with centered overlay view-as dialog-box title " Файлы доступные для импорта ".
def stream r-in.


on return of b1 in frame fr1 do:
       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       logic = false.
       MESSAGE "Вы уверены, что " + pathname + caps(trim(tf.filename)) + " именно тот файл который Вам нужен?"
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "Внимание" UPDATE logic.
       case logic:
            when false then return.
       end.        
       assign
             fname = caps(trim(tf.filename))
             ts = trim(tf.ts).
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').
       UNIX SILENT value("cp -f " + fname + " " + trim(OS-GETENV("DBDIR")) + "/import/oper").
       unix silent value("cp -f " + trim(OS-GETENV("DBDIR")) + "/export/dpk/docs/pkdogsgn-lysenker.jpg" + " . ").
       apply "endkey" to frame fr1.
end.  



def var s-tempfolder as char.
input through localtemp.
repeat:
   import s-tempfolder.
end.
s-tempfolder = replace(s-tempfolder,"\\","/").
unix silent value("rcp pkdogsgn-lysenker.jpg `askhost`:" + s-tempfolder).




repeat:

for each tm.
delete tm.
end.
for each temp.
delete temp.
end.

v-rnn = "".
v-eng = "".
v-adr = "".
v-org = "".
v-who = "".
v-from = "".
v-nb = "". 
v-fil = "".
v-frst1 = "".
v-vvv = "".
v-ent = 0.
v-ent1 = 0.
v-fil = "".

open query q1 for each tf.

if num-results("q1")=0 then do:
    MESSAGE "В каталоге " + pathname + " файлы не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE " Внимание " .
    return.                 
end.

fname = "".


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL") .
ENABLE all with frame fr1 .
wait-for endkey of frame fr1.
hide frame fr1 .


if fname = "" then return.

{con-crd.i}
{comm-dir.i}
unix silent value("cat " + fname + " | win2koi > base1.d ").
UNIX SILENT value("cat base1.d | sed '1d' | tr '\011' '\174'  > base.d").

dir = " ./".

run comm-dir( dir,"base1.d",no).

for each comm-dir no-lock:
    input stream r-in from value(comm-dir.fname).
    import stream r-in unformatted v-txt.
    v-txt = trim(v-txt).
    v-frst = substring(v-txt,22).
    repeat:
          import stream r-in unformatted v-txt.
          v-txt = trim(v-txt).
          if v-txt <> "" then do:
             if v-txt begins  "2" then v-rnn = substring(v-txt,21). else
             if v-txt begins  "3" then v-eng = substring(v-txt,22). else
             if v-txt begins  "4" then v-adr = substring(v-txt,22). else
             if v-txt begins  "5" then v-org = substring(v-txt,22). else
             if v-txt begins  "6" then v-who = substring(v-txt,22). else
             if v-txt begins  "7" then v-from = substring(v-txt,22). else
             if v-txt begins  "8" then v-nb = substring(v-txt,22). else 
             if v-txt begins  "9" then v-fil = substring(v-txt,22).
             if v-frst <> "" then v-frst1 = v-frst.
                             else v-frst1 = v-eng.

             v-vvv = v-eng.

             coun = coun + 1.
             create msgc.
                    msgc.num = coun.
                    msgc.txt = v-txt.
          end.
    end.
end.
v-ent = num-entries(v-frst1).
v-ent1 = num-entries(v-rnn).

v-fil = v-fil + " ".
v-gofc = "operimp" + g-ofc.

do transaction:
find sysc where sysc.sysc eq v-gofc  and sysc.chval eq g-ofc exclusive-lock no-error.
if avail sysc then do:
   message "Вы хотите прервать ранее запущенный процесс?" update v-dop.
   if v-dop then do /*transaction */ : 
      delete sysc.
      create sysc.
             sysc.sysc = v-gofc.
             sysc.chval = g-ofc.
             sysc.des = "Отчет НБРК логин " + g-ofc.
   end.
   else return.
end.
else do /*transaction */:
     create sysc.
            sysc.sysc = v-gofc.
            sysc.chval = g-ofc.
            sysc.des = "Отчет НБРК логин " + g-ofc.
end.
end.

d = 0.                                                    	
repeat i = 1 to num-entries(v-vvv):
       d = d + 1.
       create tm.
              tm.code = "exp".
              tm.id = d.
              tm.name = entry(i,v-eng).
end.


d = 0.
repeat i = 1 to num-entries(v-frst1):
       d = d + 1.
       create temp.
              temp.code = "name".
              temp.name = entry(i,v-frst1).
              temp.id = d.
              temp.docnum = trim(v-nb).
end.

if v-ent = v-ent1 then do:
d = 0.
repeat i = 1 to num-entries(v-rnn):
       d = d + 1.
       create temp.
              temp.code = "rnn".
              temp.rnn = entry(i,v-rnn).
              temp.id = d.
              temp.docnum = trim(v-nb).
end.

v-ex = true.
for each temp where temp.code = "name" no-lock.
    find btemp where btemp.code = "rnn" and btemp.id eq temp.id exclusive-lock no-error.
    if avail btemp then btemp.name = temp.name.
end.
end.
else v-ex = false.
if v-ex = false then do:
   for each temp where temp.code = "name" exclusive-lock.
       temp.name1 = entry(1, temp.name, " ") + " " + entry(2, temp.name, " ").
   end.

   for each tm where tm.code = "exp" exclusive-lock.
       tm.name1 = entry(1, tm.name, " ") + " " + entry(2, tm.name, " ").
   end.

end.

if v-ex then do:
for each btemp where btemp.code = "rnn" exclusive-lock.
v-pro = 0.
for each card_status where rnn eq trim(btemp.rnn) no-lock.
    if not card_status.name matches "*clos*" then do:
       run get_cur_bal (card_status.account_number,
           output v-bal,
           output v-lock,
           output v-use-limit,
           output v-limit).

           if v-pro = 0 then do:
               v-pro = 1.
               find first month_clients where month_clients.contract_number eq card_status.contract_number no-lock no-error.
               if avail month_clients then do:
                  find first txb where txb.bank = month_clients.zip_code and txb.consolid no-lock no-error.
                  if avail txb then assign btemp.bank = substring(txb.info,3) btemp.bic = txb.mfo. 
                  else btemp.bank = "Алматы".
               end.
           end.

       create temp.
              temp.code = "cards".
              temp.acc = card_status.contract_number.
              temp.bal = v-bal.
       if index(string(temp.bal), ".") > 0 then
              temp.bal1 = dec(entry(2,string(temp.bal),".")).
       else
              temp.bal1 = 0.
              temp.name = btemp.name.
              temp.rnn = btemp.rnn.
       if card_status.aux_string[1] = "KZT"  then do: 
          temp.val = "тенге". 
          temp.val1 = "тиын". 
       end. 
       else do:
            if temp.bal = 1 then temp.val = "доллар США".
            else
            if temp.bal >= 2 and temp.bal < 5 then temp.val = "доллара США".
            else temp.val = "долларов США".
            if temp.bal1 = 1 then temp.val1 = "цент".
            else
            if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "центa".
            else do:
                 v-cent1 = entry(1, string(temp.bal1)).
                 v-cent = length(v-cent1).
                 if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                 temp.val1 = "цента".
                 else
                 temp.val1 = "центов".
            end.
       end.
    end.
end.
end.
end.
else do:
for each btemp where btemp.code = "name" exclusive-lock.
   find first tm where tm.code = "exp" and tm.id eq btemp.id no-lock no-error.
v-pro = 0.
for each card_status where short_name matches "*" + trim(tm.name1) + "*" no-lock.
    if not card_status.name matches "*clos*" then do:
       run get_cur_bal (card_status.account_number,
           output v-bal,
           output v-lock,
           output v-use-limit,
           output v-limit).

           if v-pro = 0 then do:
               v-pro = 1.
               btemp.rnn = card_status.rnn.
               find first month_clients where month_clients.contract_number eq card_status.contract_number no-lock no-error.
               if avail month_clients then do:
                  find first month_clients where month_clients.contract_number eq card_status.contract_number no-lock no-error.
                  if avail month_clients then do:
                      find first txb where txb.bank = month_clients.zip_code and txb.consolid no-lock no-error.
                      if avail txb then assign btemp.bank = substring(txb.info,3) btemp.bic = txb.mfo. 
                      else btemp.bank = "Алматы".
                  end.
               end.
           end.
       create temp.
              temp.code = "cards".          	
              temp.acc = card_status.contract_number.
              temp.bal = v-bal.
           if index(string(temp.bal), ".") > 0 then
              temp.bal1 = dec(entry(2,string(temp.bal),".")).
           else
              temp.bal1 = 0.
              temp.name = btemp.name.
       if card_status.aux_string[1] = "KZT"  then do:
              temp.val = "тенге". 
              temp.val1 = "тиын". 
       end. 
       else do:
            if temp.bal = 1 then temp.val = "доллар США".
            else
            if temp.bal >= 2 and temp.bal < 5 then temp.val = "доллара США".
            else temp.val = "долларов США".
            if temp.bal1 = 1 then temp.val1 = "цент".
            else
            if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "центa".
            else do:
                 v-cent1 = entry(1, string(temp.bal1)).
                 v-cent = length(v-cent1).
                 if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                 temp.val1 = "цента".
                 else
                 temp.val1 = "центов".
            end.
       end.
    end.
end.
find first temp where temp.code = "cards" and temp.name = btemp.name no-lock no-error.
if not avail temp then v-grep = true.
end.

if v-grep then do:
for each btemp where btemp.code = "name" exclusive-lock.
v-pro = 0.
for each card_status where short_name matches "*" + trim(btemp.name1) + "*" no-lock.
    if not card_status.name matches "*clos*" then do:
       run get_cur_bal (card_status.account_number,
           output v-bal,
           output v-lock,
           output v-use-limit,
           output v-limit).

           if v-pro = 0 then do:
               v-pro = 1.
               btemp.rnn = card_status.rnn.
               find first month_clients where month_clients.contract_number eq card_status.contract_number no-lock no-error.
               if avail month_clients then do:
                  find first month_clients where month_clients.contract_number eq card_status.contract_number no-lock no-error.
                  if avail month_clients then do:
                      find first txb where txb.bank = month_clients.zip_code and txb.consolid no-lock no-error.
                      if avail txb then assign btemp.bank = substring(txb.info,3) btemp.bic = txb.mfo. 
                      else btemp.bank = "Алматы".
                  end.
               end.
           end.
       create temp.
              temp.code = "cards".          	
              temp.acc = card_status.contract_number.
              temp.bal = v-bal.
           if index(string(temp.bal), ".") > 0 then
              temp.bal1 = dec(entry(2,string(temp.bal),".")).
           else
              temp.bal1 = 0.
              temp.name = btemp.name.
       if card_status.aux_string[1] = "KZT"  then do:
              temp.val = "тенге". 
              temp.val1 = "тиын". 
       end. 
       else do:
            if temp.bal = 1 then temp.val = "доллар США".
            else
            if temp.bal >= 2 and temp.bal < 5 then temp.val = "доллара США".
            else temp.val = "долларов США".
            if temp.bal1 = 1 then temp.val1 = "цент".
            else
            if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "центa".
            else do:
                 v-cent1 = entry(1, string(temp.bal1)).
                 v-cent = length(v-cent1).
                 if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                 temp.val1 = "цента".
                 else
                 temp.val1 = "центов".
            end.
       end.
    end.
end.
end.
end.
end.

for each temp where temp.code = "cards" .
q = q + 1.
end.

for each txb where txb.consolid = true no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + txb.path + " -H " + txb.host + " -S " + txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 	
    run oper1 (v-ex, txb.bank, txb.mfo).
end.
if connected ("txb")  then disconnect "txb".


mailaddr = trim(g-ofc) + "@elexnet.kz".

if v-ex = yes then do:
for each btemp where btemp.code = "aaa" no-lock.
    find first temp where temp.code = "rnn" and temp.rnn eq btemp.rnn no-error.
      if avail temp then do: 
         temp.bic = btemp.bic. 
         temp.bank = btemp.bank. 
      end.
end.


b = 0.
for each btemp where btemp.code = "rnn" no-lock.
    v-docn = btemp.docnum.
    b = b + 1.

    if b = 1  then output stream r-in to tt.htm.
    else 
    if b = 2 then output stream r-in to tt1.htm.
    else 
    if b = 3 then output stream r-in to tt2.htm.
    else
    if b = 4 then output stream r-in to tt3.htm.
    else 
    if b = 5 then output stream r-in to tt4.htm.

    find first temp where temp.rnn eq btemp.rnn and (temp.code = "aaa" or temp.code = "cards") no-lock no-error.
    if avail temp  then do:
      v-hop = true.
    end.   
    else v-hop = false.

    put stream r-in unformatted 
       "<table valign=""top""  width=""100%"">"   skip
       "<br><br><br><br><br>" skip
       "<td colspan = ""160""> </td>"   skip
       "    <td colspan = ""3"" align = ""left"" valign= ""top"">" v-adr "<br>" v-org "<br>"  v-who "<br>" v-from "<br>" skip
       "</table>"    skip.

    if v-hop = true then do:
       put stream r-in unformatted 
           "<table width=100%>" skip
           "<br><br><br>" skip
           "<tr><td align=left>&nbsp &nbsp &nbsp &nbsp  На запрос " v-fil "Национального Банка Республики Казахстан N " btemp.docnum " АО ""TEXAKABANK"" г." btemp.bank " БИК " btemp.bic    skip
           "подтверждает что " btemp.name ", РНН " btemp.rnn " является клиентом банка с остатком денег на " today "г."   skip.
       i = 0.
       ii = 0.
       for each temp where temp.code = "aaa" and temp.rnn eq btemp.rnn no-lock.
          i = i + 1.
       end.

       for each temp where temp.code = "aaa" and temp.rnn eq btemp.rnn no-lock.
          ii = ii + 1.
          run Sm-vrd (temp.bal,  output v-summawrd) .
          if temp.bal1 = 0 then do:
             if i = 1 then do:
                if q > 0 then put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")," skip.
                         else put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")." skip.
             end.
             else do:
                if ii = i then do:
                   if q > 0 then put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")," skip.
                            else put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")." skip.
                end.
                else put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")," skip.
             end.
          end.
          else do:
             if i = 1 then do:
                if q > 0 then put stream r-in unformatted "ИИК  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd " " temp.val " " temp.bal1 " " temp.val1 ")," skip.
                         else put stream r-in unformatted "ИИК  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd " " temp.val " " temp.bal1 " " temp.val1 ")." skip.
             end.
             else do:
                if ii = i then do:
                   i = 0.
                   if q > 0 then put stream r-in unformatted "ИИК  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd  " " temp.val " " temp.bal1 " " temp.val1 ")," skip.
                            else put stream r-in unformatted "ИИК  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd " " temp.val " " temp.bal1 " " temp.val1 ")." skip.
                end.
                else put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")," skip.
             end.
          end.
       end.

       i = 0.
       ii = 0.
       for each temp where temp.code = "cards" and temp.rnn eq btemp.rnn no-lock.
           i = i + 1.
       end.

       for each temp where temp.code = "cards" and temp.rnn eq btemp.rnn no-lock.
          ii = ii + 1.
          run Sm-vrd (temp.bal,  output v-summawrd) .
          if temp.bal1 = 0 then do:
             if i = 1 then
             put stream r-in unformatted "Карт-счет  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")." skip.
             else do:
                if ii = 1 then put stream r-in unformatted "Карт-счет  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")." skip.
                          else put stream r-in unformatted "Карт-счет  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")," skip.
             end.
          end.
          else do:
             if i = 1 then put stream r-in unformatted "Карт-счет  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd " " temp.val " " temp.bal1 " " temp.val1 ")." skip.
             else do:
                if ii = i then put stream r-in unformatted "Карт-счет  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd  " " temp.val " " temp.bal1 " " temp.val1 ")." skip.
                          else put stream r-in unformatted "Карт-счет  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd " " temp.val " " temp.bal1 " " temp.val1 ")," skip.
             end.
          end.
       end.
       put stream r-in unformatted
           "</td></tr></table>" skip
           "<table>" skip
           "<br><br><br><tr><td> Управляющий директор </td><td colspan=""150""></td><td> Лысенкер В.Л. </td></tr>"  skip
           "</table>"  skip.
    end.
    else do:
       put stream r-in unformatted 
           "<br><br><table width=100%>" skip
           "<tr><td align=left>&nbsp &nbsp &nbsp &nbsp На запрос " v-fil "Национального Банка Республики Казахстан N " btemp.docnum " сообщаем, что " btemp.name " , РНН" btemp.rnn skip
           " в списках клиентов АО ""TEXAKABANK"" не значится." skip
           "</td></tr></table>" skip
           "<table>" skip
           "<br><br><br><tr><td> Управляющий директор </td><td colspan=""50""></td><td colspan=""60""><img width=200 hight=600 src=""pkdogsgn-lysenker.jpg""></td><td> Лысенкер В.Л. </td></tr>"  skip
           "</table>"  skip.
    end.

    find ofc where ofc.ofc = g-ofc no-lock no-error.
    if avail ofc then v-ofc = ofc.name.

    put stream r-in unformatted 
        "<table>" skip
        "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"  skip
        "<tr><td> Исполнитель: </td>" skip
        "<td>" substring(v-ofc,1,index(v-ofc," ") + 1) ".</td></tr>" skip
        "<tr><td> Тел. </td><td> 50-00-60 </td></tr>" skip
        "</table>" skip.

    output stream r-in close.

    if b = 1 then unix silent cptwin tt.htm iexplore.
    else
    if b = 2 then unix silent cptwin tt1.htm iexplore.
    else
    if b = 3 then unix silent cptwin tt2.htm iexplore.
    else
    if b = 4 then unix silent cptwin tt3.htm iexplore.
    else
    if b = 5 then unix silent cptwin tt4.htm iexplore.

end.

end.
else do:
for each btemp where btemp.code = "aaa" no-lock.
    find first temp where temp.code = "name" and temp.rnn eq btemp.rnn no-error.
      if avail temp then do: 
         temp.bic = btemp.bic. 
         temp.bank = btemp.bank. 
      end.
end.
b = 0.
for each btemp where btemp.code = "name" no-lock.
v-docn = btemp.docnum.
b = b + 1.
if b = 1  then output stream r-in to tt.htm.
else 
if b = 2 then output stream r-in to tt1.htm.
else 
if b = 3 then output stream r-in to tt2.htm.
else 
if b = 4 then output stream r-in to tt3.htm.
else 
if b = 5 then output stream r-in to tt4.htm.

find first temp where temp.name eq btemp.name and (temp.code = "aaa" or temp.code = "cards") no-lock no-error.
if avail temp  then do:
v-hop = true.
end.
else v-hop = false.
put stream r-in unformatted 
   "<table valign=""top""  width=""100%"">"   skip
   "<br><br><br><br><br>"  skip
   "<td colspan = ""160""> </td>"   skip
   "    <td colspan = ""3"" align = ""left"" valign= ""top"">" v-adr "<br>" v-org "<br>"  v-who "<br>" v-from "<br>" skip
   "</table>"    skip.

if v-hop = true then do:
put stream r-in unformatted 
   "<table width=100%>" skip
   "<br><br><br>" skip
   "<tr><td align=left>&nbsp &nbsp &nbsp &nbsp На запрос " v-fil "Национального Банка Республики Казахстан N " btemp.docnum " АО ""TEXAKABANK"" г." btemp.bank " БИК " btemp.bic    skip
   "подтверждает что " btemp.name ", РНН " btemp.rnn " является клиентом банка с остатком денег на " today "г."   skip.

i = 0.
ii = 0.

for each temp where temp.code = "aaa" and temp.name eq btemp.name no-lock.
i = i + 1.
end.

for each temp where temp.code = "aaa" and temp.name eq btemp.name no-lock.
   ii = ii + 1.
   run Sm-vrd (temp.bal,  output v-summawrd) .
   if temp.bal1 = 0 then do:
   if i = 1 then do:
      if q > 0 then put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")," skip.
               else put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")." skip.
   end.
   else do:
      if ii = i then do:
         i = 0.
         if q > 0 then put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")," skip.
                  else put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")." skip.
      end.
      else put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")," skip.
   end.
end.
else do:
   if i = 1 then do:
      if q > 0 then put stream r-in unformatted "ИИК  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd " " temp.val "," temp.bal1 " " temp.val1 ")," skip.
               else put stream r-in unformatted "ИИК  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd " " temp.val "," temp.bal1 " " temp.val1 ")." skip.
   end.
   else do:
      if ii = i then do:
         if q > 0 then put stream r-in unformatted "ИИК  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd  " " temp.val "," temp.bal1 " " temp.val1 ")," skip.
                  else put stream r-in unformatted "ИИК  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd " " temp.val "," temp.bal1 " " temp.val1 ")." skip.
      end.
      else put stream r-in unformatted "ИИК  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")," skip.
   end.
end.
end.
i = 0.
ii = 0.
for each temp where temp.code = "cards" and temp.name eq btemp.name no-lock.
i = i + 1.
end.
for each temp where temp.code = "cards" and temp.name eq btemp.name no-lock break.
   ii = ii + 1.
   run Sm-vrd (temp.bal,  output v-summawrd) .
if temp.bal1 = 0 then do:
   if i = 1 then
   put stream r-in unformatted "Карт-счет  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")." skip.
   else do:
   if ii = i then
   put stream r-in unformatted "Карт-счет  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")." skip.
   else
   put stream r-in unformatted "Карт-счет  " temp.acc " - " temp.bal " (" v-summawrd " " temp.val ")," skip.
   end.
end.
else do:
   if i = 1 then
   put stream r-in unformatted "Карт-счет  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd " " temp.val "," temp.bal1 " " temp.val1 ")." skip.
   else do:
   if ii = i then
   put stream r-in unformatted "Карт-счет  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd  " " temp.val "," temp.bal1 " " temp.val1 ")." skip.
   else
   put stream r-in unformatted "Карт-счет  " temp.acc " - " string(temp.bal,"->,>>>,>>>,>>9.99") " (" v-summawrd " " temp.val "," temp.bal1 " " temp.val1 ")," skip.
   end.

end.
end.
put stream r-in unformatted
    "</td></tr></table>" skip
    "<table>" skip
    "<br><br><br><tr><td> Управляющий директор </td><td colspan=""150""></td><td> Лысенкер В.Л. </td></tr>"  skip
    "</table>"  skip.

end.
else do:
put stream r-in unformatted 
   "<table width=100%>" skip
   "<br><br><br>" skip
   "<tr><td align=left>&nbsp &nbsp &nbsp &nbsp На запрос " v-fil "Национального Банка Республики Казахстан N " btemp.docnum " сообщаем, что " btemp.name /*format "x(70)" */ skip
   " в списках клиентов АО ""TEXAKABANK"" не значится." skip
    "</td></tr></table>" skip
    "<table>" skip
    "<br><br><br><tr><td> Управляющий директор </td><td colspan=""50""></td><td colspan=""60""><img width=200 hight=600 src=""pkdogsgn-lysenker.jpg""></td><td> Лысенкер В.Л. </td></tr>"  skip
    "</table>"  skip.

end.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then v-ofc = ofc.name.

put stream r-in unformatted 
    "<table>" skip
    "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"  skip
    "<tr><td> Исполнитель: </td>" skip
    "<td>" substring(v-ofc,1,index(v-ofc," ") + 1) ".</td></tr>" skip
    "<tr><td> Тел. </td><td> 50-00-60 </td></tr>" skip
    "</table>" skip.

output stream r-in close.

if b = 1 then unix silent cptwin tt.htm iexplore.
else
if b = 2 then unix silent cptwin tt1.htm iexplore.
else
if b = 3 then unix silent cptwin tt2.htm iexplore.
else
if b = 4 then unix silent cptwin tt3.htm iexplore.
else
if b = 5 then unix silent cptwin tt4.htm iexplore.

end.

end.



v-docn = entry(1,v-docn,"/").
v-fol = "\\\\\\\\\\\\" + g-ofc + "\\\\\\\\" + v-docn + "\\\\\\\\".

unix silent value("rsh `askhost` dir /ad /b c:\\\\" + g-ofc + "\\\\" + trim(v-docn) + "\\" ).
                                                  
input through value("rsh `askhost` dir /ad /b c:\\\\" + g-ofc + "\\\\" + trim(v-docn) + "\\" ).
repeat:
  import v-str.
end.
pause 0.

if v-str eq "file" then unix silent value("rsh `askhost` mkdir C:" + v-fol).



/*
v-docn = entry(1,v-docn,"/").
v-fol = "\\\\\\\\\\\\" + g-ofc + "\\\\\\\\" + v-docn + "\\\\\\\\".
v-fol1 = g-ofc + v-docn.


find sysc where sysc.sysc eq v-fol1 and sysc.chval eq v-fol no-lock no-error.
if not avail sysc then do:
  do transaction: 
     create sysc.
            sysc.sysc = v-fol1.
            sysc.chval = v-fol.
            sysc.des = "Директория хранения папок с данными НБРК " + g-ofc.
  end.
  unix silent value("rsh `askhost` mkdir C:" + v-fol).
end.
*/

if b = 1 then do: 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt.htm").    
   unix silent value("rcp tt.htm `askhost`:C:" + v-fol).
   unix silent value("rm " + ' ./tt.htm' ).
   find first tm where tm.code = "exp" and tm.name <> "".
   if avail tm then do: 
      v-fexp = entry(1,tm.name," ").
      unix silent value("rsh `askhost` rename C:" + v-fol + "tt.htm " + v-fexp + "1.htm").
   end.
end.
else
if b = 2 then do: 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt.htm"). 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt1.htm").
   unix silent value("rcp tt.htm tt1.htm `askhost`:C:" + v-fol).
   unix silent value("rm " + ' ./tt.htm' ).
   unix silent value("rm " + ' ./tt1.htm' ).
   for each tm where tm.code = "exp" and tm.name <> "".
      if v-fexp = "" then v-fexp = entry(1,tm.name," ").
                     else v-fexp = v-fexp + " " + entry(1,tm.name," ").
   end.
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt.htm " + entry(1,v-fexp," ") + "1.htm").
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt1.htm " + entry(2,v-fexp," ") + "2.htm").
end.
else
if b = 3 then do: 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt.htm"). 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt1.htm").
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt2.htm"). 
   unix silent value("rcp tt.htm tt1.htm tt2.htm `askhost`:C:" + v-fol).
   unix silent value("rm " + ' ./tt.htm' ).
   unix silent value("rm " + ' ./tt1.htm' ).
   unix silent value("rm " + ' ./tt2.htm' ).
   for each tm where tm.code = "exp" and tm.name <> "".
      if v-fexp = "" then v-fexp = entry(1,tm.name," ").
                     else v-fexp = v-fexp + " " + entry(1,tm.name," ").
   end.

   unix silent value("rsh `askhost` rename C:" + v-fol + "tt.htm " + entry(1,v-fexp," ") + "1.htm").
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt1.htm " + entry(2,v-fexp," ") + "2.htm").
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt2.htm " + entry(3,v-fexp," ") + "3.htm").
end.
else
if b = 4 then do: 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt.htm"). 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt1.htm").
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt2.htm"). 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt3.htm"). 
   unix silent value("rcp tt.htm tt1.htm tt2.htm tt3.htm `askhost`:C:" + v-fol).
   unix silent value("rm " + ' ./tt.htm' ).
   unix silent value("rm " + ' ./tt1.htm' ).
   unix silent value("rm " + ' ./tt2.htm' ).
   unix silent value("rm " + ' ./tt3.htm' ).
   for each tm where tm.code = "exp" and tm.name <> "".
      if v-fexp = "" then v-fexp = entry(1,tm.name," ").
                     else v-fexp = v-fexp + " " + entry(1,tm.name," ").
   end.
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt.htm " + entry(1,v-fexp," ") + "1.htm").
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt1.htm " + entry(2,v-fexp," ") + "2.htm").
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt2.htm " + entry(3,v-fexp," ") + "3.htm").
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt3.htm " + entry(4,v-fexp," ") + "4.htm").
end.
else
if b = 5 then do: 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt.htm"). 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt1.htm").
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt2.htm"). 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt3.htm"). 
   run mail  ( mailaddr,"TEXAKABANK <abpk@elexnet.kz>","Анкета","Анкета","1","","tt4.htm"). 
   unix silent value("rcp tt.htm tt1.htm tt2.htm tt3.htm tt4.htm `askhost`:C:" + v-fol).
   unix silent value("rm " + ' ./tt.htm' ).
   unix silent value("rm " + ' ./tt1.htm' ).
   unix silent value("rm " + ' ./tt2.htm' ).
   unix silent value("rm " + ' ./tt3.htm' ).
   unix silent value("rm " + ' ./tt4.htm' ).
   for each tm where tm.code = "exp" and tm.name <> "".
      if v-fexp = "" then v-fexp = entry(1,tm.name," ").
                     else v-fexp = v-fexp + " " + entry(1,tm.name," ").
   end.
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt.htm " + entry(1,v-fexp," ") + "1.htm").
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt1.htm " + entry(2,v-fexp," ") + "2.htm").
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt2.htm " + entry(3,v-fexp," ") + "3.htm").
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt3.htm " + entry(4,v-fexp," ") + "4.htm").
   unix silent value("rsh `askhost` rename C:" + v-fol + "tt4.htm " + entry(5,v-fexp," ") + "5.htm").
end.

unix silent value("rm " + ' ./base.d' ).
unix silent value("rm " + ' ./base1.d' ).
unix silent value("rm " + ' ./' + fname ).

do transaction:
   find bank.sysc where bank.sysc.sysc eq v-gofc exclusive-lock no-error.
   if avail bank.sysc and bank.sysc.chval eq g-ofc then delete bank.sysc.
end.

for each temp.
   delete temp.
end.


end.
v-fil = "".
SESSION:DATE-FORMAT = "dmy".
return.

procedure savelog:
    return.
end.


