/* cfsprav.p
 * MODULE
        кредиты
 * DESCRIPTION
        Отчет по гарантиям за отчетный месяц для эксопрта в "Кредитный регистр"
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.13
 * AUTHOR
        20.08.2003 nataly
 * CHANGES
*/

{vc.i}
{global.i}
{comm-txb.i}

def new shared var s-vcourbank as char.
def new shared var v-god as integer format "9999".
def new shared var v-month as integer format "99".
def new shared var v-dtb as date.
def new shared var v-dte as date.
def  new shared var v-pass as char.

def var v-name as char.
def var vi as integer.

def new shared temp-table t-cif 
  field jh as char
  field creditor as char
  field nss as char
  field name as char
  field regdt as date
  field kodbank as char
  field kodgbank as char
  field rnn as char format "x(14)"
  field ur_phis as char format "x(1)"
  field vid_ob as char 
  field datevyd as date
  field datekon as date
  field sum_ob as decimal 
  field val_ob as char 
  field plat_vyd as decimal 
  field vid_obes as char 
  field st_obes as decimal 
  field num_obyz as char 
  field naim_ban as char 
  field naim_ben as char 
  field adr_ben as char    
  field ost_ob as decimal    .

def new  shared temp-table t-cif2 
  field jh as char
  field nss as char
  field name as char
  field regdt as date
  field rnn as char format "x(14)"
  field sum_ob as decimal. 

def new shared var prz as integer.

s-vcourbank = comm-txb().
for each sysc where sysc.sysc="SYS1" no-lock.
v-pass = ENTRY(1,sysc.chval).
end.

v-god = year(g-today).
v-month = month(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-god = v-god - 1.
end.
else v-month = v-month - 1.

update skip(1) 
   v-month label "     Месяц " skip 
   v-god label   "       Год " skip(1) 
   with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".

def button  btn1  label "Обязательства".
   def button  btn2  label "Кредиты".
   def button  btn3  label "Выход".
   def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберете тип операций:" row 5 .

  on choose of btn1,btn2,btn3 do:
    if self:label = "Обязательства" then prz = 0.
    else
    if self:label = "Кредиты" then prz = 1.
    else prz = 2.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.
    if prz = 1 then do: 
        message 'Данный режим находится на стадии разработки'
        view-as alert-box.
        return.
     end.
    if prz = 2 then return.
 hide  frame frame1.

message "  Формируется отчет...".

v-dtb = date(v-month, 1, v-god).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then vi = 31.
  when 4 or when 6 or when 9 or when 11 then vi = 30.
  when 2 then do:
    if v-god mod 4 = 0 then vi = 29.
    else vi = 28.
  end.
end case.
v-dte = date(v-month, vi, v-god).

/* коннект к нужному банку */
run comm-con.
run zabal2.p.

hide message no-pause.

  run zabalout.p ("zabal.htm", false, "", false, "", false).

pause 0.

