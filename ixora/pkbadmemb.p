/* pkbadmemb.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Редактирование/просмотр данных одного человека в ЧЕРНОМ СПИСКЕ
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-6-10
 * AUTHOR
        10.04.2003 nadejda
 * CHANGES
        19.11.2003 nadejda  - добавила validate на РНН
        23.03.2004 tsoy     - Добавил поля Город Улица Дом Квартира
*/


{global.i}
{pk.i}


def input parameter p-rid as char.
def input parameter p-new as logical.

def temp-table t-member like pkbadlst.
def var v-ans as logical.
def var v-rnnlen as integer init 12.
def var v-msgerr as char.

def var v-city      as char init ''.
def var v-street    as char init ''.
def var v-house     as char init ''.
def var v-flat      as char init ''.
def var v-delim as char init "^".
def var v-str as char.



function chk-rnn returns logical (p-value as char).
  def var l as logical.

  if (length(p-value) <> v-rnnlen) and (length(p-value) <> 0) then do:
    v-msgerr = " РНН должен иметь длину " + string(v-rnnlen) + " символов !".
    return false.
  end.
  return true.
end.


form
  t-member.rnn label "РНН" format "999999999999" colon 15 
          validate (chk-rnn(t-member.rnn), v-msgerr) skip
  t-member.lname label "ФАМИЛИЯ" format "x(50)" colon 15 " " skip
  t-member.fname label "ИМЯ" format "x(50)" colon 15 skip
  t-member.mname label "ОТЧЕСТВО" format "x(50)" colon 15 skip
  t-member.bdt label "ДАТА РОЖД" format "99/99/9999" colon 15 
  t-member.ybdt label "ГОД РОЖД" format "9999" colon 15 
  v-city   label "Город"    format "x(50)" colon 15 skip
  v-street label "Улица"    format "x(50)" colon 15 skip
  v-house  label "Дом"      format "x(10)" colon 15 skip
  v-flat   label "Квартира" format "x(10)" colon 15 skip
  t-member.note label "ПРИМЕЧАНИЕ" format "x(50)" colon 15 skip
  with centered side-label overlay title " СВЕДЕНИЯ О ФИЗЛИЦЕ " row 7 frame f-member.


find sysc where sysc.sysc = "rnnlen" no-lock no-error.
if avail sysc then v-rnnlen = sysc.inval.

create t-member.

if not p-new then do:
  find pkbadlst where rowid(pkbadlst) = to-rowid(p-rid) no-lock no-error.
  buffer-copy pkbadlst to t-member.
  
  if NUM-ENTRIES(pkbadlst.rescha[1], "|") >= 4 then do:
       v-city   = ENTRY(1, pkbadlst.rescha[1], "|"). 
       v-street = ENTRY(2, pkbadlst.rescha[1], "|"). 
       v-house  = ENTRY(3, pkbadlst.rescha[1], "|"). 
       v-flat   = ENTRY(4, pkbadlst.rescha[1], "|"). 
  end.

end.

displ 
  t-member.rnn t-member.lname t-member.fname t-member.mname t-member.bdt t-member.ybdt t-member.docnum 
  v-city v-street v-house v-flat t-member.note
  with frame f-member.
  
update 
  t-member.rnn 
  with frame f-member.

if p-new then do:
       find cif where cif.jss = t-member.rnn no-lock no-error. 
       if avail cif then do:
           if NUM-ENTRIES(cif.dnb, "|") > 0 then do:
                v-str  = entry(2, cif.dnb, "|").
                if num-entries(v-str, v-delim) > 0 then v-city   = entry(1, v-str, v-delim).
                if num-entries(v-str, v-delim) > 1 then v-street = entry(2, v-str, v-delim).
                if num-entries(v-str, v-delim) > 2 then v-house  = entry(3, v-str, v-delim).
                if num-entries(v-str, v-delim) > 3 then v-flat   = entry(4, v-str, v-delim).
                displ  v-city v-street v-house v-flat   with frame f-member. 
           end.
           
           if num-entries(cif.name, " ") > 0 then t-member.lname = entry(1, cif.name, " ").           
           if num-entries(cif.name, " ") > 1 then t-member.fname = entry(2, cif.name, " ").           
           if num-entries(cif.name, " ") > 2 then t-member.mname = entry(3, cif.name, " ").           
               
           t-member.ybdt = year(t-member.bdt).

           displ t-member.bdt t-member.ybdt t-member.lname t-member.fname t-member.mname
               with frame f-member. 
       end.

end.

update 
  t-member.lname t-member.fname t-member.mname t-member.bdt 
  v-city v-street v-house v-flat
  with frame f-member.

if t-member.bdt <> ? then do:
  t-member.ybdt = year(t-member.bdt).
  displ t-member.ybdt with frame f-member.
end.

update 
  t-member.ybdt when t-member.bdt = ? t-member.docnum t-member.note
  with frame f-member.


if t-member.rnn      entered or
   t-member.lname    entered or
   t-member.fname    entered or
   t-member.mname    entered or
   t-member.bdt      entered or
   t-member.ybdt     entered or
   t-member.docnum   entered or
   t-member.note[1]  entered or
   v-city            entered or
   v-street          entered or
   v-house           entered or
   v-flat            entered then do:
  v-ans = yes.
  message skip "  Сохранить изменения?" 
    skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans.

  if v-ans then do transaction on error undo, return:
    if p-new then create pkbadlst.
             else find pkbadlst where rowid(pkbadlst) = to-rowid(p-rid) exclusive-lock no-error.
    t-member.lname = caps(t-member.lname).
    t-member.fname = caps(t-member.fname).
    t-member.mname = caps(t-member.mname).
    buffer-copy t-member to pkbadlst.
    pkbadlst.rescha[1] = v-city + "|" + v-street + "|" +  v-house + "|" + v-flat.
    if p-new then
      assign pkbadlst.source = "int"
             pkbadlst.bank = s-ourbank
             pkbadlst.sts = "A"
             pkbadlst.rdt = today
             pkbadlst.rwho = g-ofc.

    assign pkbadlst.udt  = today
           pkbadlst.uwho = g-ofc.
    find current pkbadlst no-lock.
    return string(rowid(pkbadlst)).
  end.
end.

