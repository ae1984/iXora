/* kdcifnew.p Электронное кредитное досье
 * MODULE
        Кредитное досье
 * DESCRIPTION
      Редактирование / просмотр данных о заемщике
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.11.2
 * AUTHOR
   20.07.2003 marinav
 * CHANGES
   20.07.03 marinav
      30.09.2005 marinav - изменения для бизнес-кредитов
      07.04.06 marinav - do transaction
    05/09/06   marinav - добавление индексов
    05.08.2008 galina - добавила дату и орган выдачи уд.лич. для руководителя 
    11.09.2008 galina - в справочнике организационно-правовых форм не выводим "msc"

*/



{global.i}
{kd.i}
{kdcif.f}

define shared variable s-newrec as logical.
define var v-cod as char.
define buffer b-cif for cif.
def var v-pss as char format "x(9)".
def var v-issuredby as char format "x(9)".
def var v-pssdt as date format "99/99/9999".

form
   v-pss label "Номер" format "x(15)" validate(v-pss <> '', "Введите номер документа!") skip
   v-pssdt label "Дата" format "99/99/9999" validate(v-pssdt <> ?, "Введите дату регистрации документа!") skip
   v-issuredby label "Кем выдано" format "x(12)" skip
with side-label overlay row 19 column 24 title "НОМЕР ДОК" frame f-pass. 

on help of kdcif.lnopf in frame kdcif do:
   run h-codfr2 ("lnopf", output v-cod).
   find first codfr where codfr.codfr = "lnopf" and codfr.code = v-cod no-lock no-error.
   kdcif.lnopf = v-cod.  v-lnopf = codfr.name[1].
   displ kdcif.lnopf v-lnopf with frame kdcif.
end.

on help of kdcif.ecdivis in frame kdcif do:
   run h-codfr ("ecdivis", output v-cod).
   find first codfr where codfr.codfr = "ecdivis" and codfr.code = v-cod no-lock no-error.
   kdcif.ecdivis = v-cod. v-ecdivis = codfr.name[1].
   displ kdcif.ecdivis v-ecdivis with frame kdcif.
end.

on help of kdcif.manager in frame kdcif do: 
  run uni_book ("kdfu", "*", output v-cod).  
  kdcif.manager = entry(1, v-cod).
  displ kdcif.manager with frame kdcif.
end.

find kdcif where kdcif.kdcif = s-kdcif no-lock. 
   find first codfr where codfr.codfr = "lnopf" and codfr.code = kdcif.lnopf no-lock no-error.
   v-lnopf = codfr.name[1].
   find first codfr where codfr.codfr = "ecdivis" and codfr.code = kdcif.ecdivis no-lock no-error.
   v-ecdivis = codfr.name[1].


    displ 
      s-kdcif kdcif.regdt kdcif.who kdcif.bank kdcif.mname kdcif.manager
      kdcif.prefix kdcif.rnn  kdcif.name
      kdcif.fname kdcif.lnopf v-lnopf kdcif.ecdivis v-ecdivis kdcif.urdt 
      kdcif.urdt1 kdcif.regnom kdcif.addr[1]
      kdcif.addr[2] kdcif.tel kdcif.sotr kdcif.chief[1] kdcif.job[1]
      kdcif.docs[1] kdcif.rnn_chief[1] kdcif.chief[2]
      with frame kdcif.
      pause 0.

 
 if s-newrec eq true then do:

define var v-name like kdcif.name.
define var v-chief1 like kdcif.chief[1].
define var v-chief2 like kdcif.chief[1].
v-name = kdcif.name.
v-chief1 = kdcif.chief[1].
v-chief2 = kdcif.chief[2].

do transaction.

find current kdcif exclusive-lock.

         update
         kdcif.mname 
         kdcif.manager
         kdcif.rnn
         kdcif.prefix
         kdcif.name
         kdcif.fname
         kdcif.lnopf
         kdcif.ecdivis
         kdcif.urdt kdcif.urdt1 kdcif.regnom  kdcif.addr[1]
         kdcif.addr[2] kdcif.tel kdcif.sotr kdcif.chief[1]
         with frame kdcif.
 
   find first b-cif where caps(b-cif.name) = caps(kdcif.chief[1]) no-lock no-error. 
      if avail b-cif then do:
            if trim(kdcif.docs[1]) = "" then kdcif.docs[1] = b-cif.pss.
            if trim(kdcif.rnn_chief[1]) = "" then kdcif.rnn_chief[1] = b-cif.jss. 
      end. 

         update kdcif.job[1] with frame kdcif.
                     
         if kdcif.docs[1] <> '' then do:
           case num-entries(trim(kdcif.doc[1]),' '):
             when 1 then v-pss = kdcif.doc[1].
             when 2 then assign v-pss = entry(1,kdcif.docs[1], ' ') v-pssdt = date(entry(2,kdcif.docs[1],' ')).
             when 4 then assign v-pss = entry(1,kdcif.docs[1], ' ') v-pssdt = date(entry(2,kdcif.docs[1], ' ')) v-issuredby  = entry(3,kdcif.docs[1], ' ') + ' ' + entry(4,kdcif.docs[1], ' ').
           end.  
         end. 
         display v-pss v-pssdt v-issuredby with frame f-pass.
         update v-pss v-pssdt v-issuredby with frame f-pass.
         hide frame f-pass.
         kdcif.docs[1] = trim(v-pss) + ' ' + string(v-pssdt,'99/99/9999') + ' ' + trim(v-issuredby).
         display kdcif.docs[1] with frame kdcif. 
         
         update kdcif.rnn_chief[1] kdcif.chief[2] with frame kdcif.
      s-newrec = false.

find current kdcif no-lock.

if v-name ne kdcif.name then do:
   run kdpoisk(1,'').
end.

if v-chief1 ne kdcif.chief[1] then do:
   run kdpoisk(2, kdcif.chief[1]).
end.

end.

/*if v-chief2 ne kdcif.chief[2] then do:
   run kdpoisk(2, kdcif.chief[2]).
end.
*/

 end.

