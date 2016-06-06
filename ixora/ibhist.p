/* ibhist.p
 * MODULE
        Internet Office
 * DESCRIPTION
        Протокол работы пользователя
 * RUN
        
 * CALLER
        ibplm8.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.8.7
 * BASES
        BANK COMM IB
 * AUTHOR
        29/10/03 sasco
 * CHANGES

*/

{msg-box.i}

define variable i as int.
define variable j as int.

define variable v-id as integer format 'zzzz9'.

define variable dt1 as date initial today.
define variable dt2 as date initial today.

define temp-table tmp
            field dat as date
            field tim as character 
            field des as character
            field login as character format 'x(16)'
            field ip  as character format 'x(16)'
            field id_doc as character format 'x(16)'
            field changes as character format 'x(60)'
            index idx_tmp is primary dat tim.

define query q1 for tmp.
define browse b1 query q1
              displ tmp.dat label "Дата" format '99/99/99'
                    tmp.tim label "Время" format 'x(8)'
                    tmp.des label "Событие" format 'x(50)'
                    with row 1 centered 10 down title "ПРОТОКОЛ РАБОТЫ".
                    
define frame f1 b1 help "ENTER - Детали события"
             with row 4 centered overlay no-label no-box.

define frame fdet
             tmp.login label "Логин"
             tmp.ip label "IP"
             tmp.id_doc label "Документ"
             tmp.changes label "Детали"
             with 1 column row 7 centered overlay.

on "return" of b1 in frame f1 do:
   if not available tmp then leave.
   displ tmp.login 
         tmp.ip
         tmp.id_doc
         tmp.changes
         with frame fdet.
  pause.
  
  hide frame fdet. 
  pause 0.

end.

update v-id label 'Рег.номер...' skip
       dt1 label  'Период с....' skip
       dt2 label  'Период по...' skip
       with row 5 centered 1 column color messages frame getidFr.

hide frame getidFr.

define var ddd as date.

run SHOW-MSG-BOX ("Формирование отчета...").

do ddd = dt1 to dt2:
do i = 1 to 4:
   do j = 1 to 30:
      
      run SHOW-MSG-BOX ("Формирование отчета...(" + string( (i - 1) * 30 + j) + " из 120) за " + string(ddd)).
      
      for each ib.hist no-lock where ib.hist.wdate = ddd /*and 
                                     ib.hist.wdate <= dt2 */ and
                                     ib.hist.type1 = i and 
                                     ib.hist.type2 = j and 
                                     ib.hist.id_usr = v-id
                                     use-index idx_dt12:


        find supp where supp.type = 1 and supp.sub_id = 1000 + i * 100 + j no-lock no-error.

        create tmp.
        tmp.dat = ib.hist.wdate.
        tmp.tim = ib.hist.wtime.
        tmp.des = if avail supp then supp.vcha[4] else '<Событие не описано>'.
        tmp.login = ib.hist.login.
        tmp.ip = ib.hist.ip_addr.
        tmp.id_doc = string (ib.hist.id_doc).
        tmp.changes = ib.hist.changes.

      end.
   end.
end.
end.

find usr where usr.id = v-id no-lock no-error.

run SHOW-MSG-BOX ("Пользователь #" + string (v-id) + ", " + usr.cif + ", " + usr.bnkplc).
open query q1 for each tmp.
enable all with frame f1.
wait-for window-close of current-window or window-close of frame f1 focus browse b1.
