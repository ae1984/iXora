/* kdmonnew.p 
 * MODULE
        Мониторинг Кредитного Досье
 * DESCRIPTION
      Редактирование / просмотр данных о заемщике
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.11.
 * AUTHOR
   25.02.2005 marinav
 * CHANGES
    

*/



{global.i}
{kd.i}
{kdmon.f}

define shared variable s-newrec as logical.
define var v-cod as char.
define buffer b-cif for cif.

on help of kdcifhis.lnopf in frame kdmon do:
   run h-codfr ("lnopf", output v-cod).
   find first codfr where codfr.codfr = "lnopf" and codfr.code = v-cod no-lock no-error.
   if avail codfr then assign kdcifhis.lnopf = v-cod  v-lnopf = codfr.name[1].
   displ kdcifhis.lnopf v-lnopf with frame kdmon.
end.

on help of kdcifhis.ecdivis in frame kdmon do:
   run h-codfr ("ecdivis", output v-cod).
   find first codfr where codfr.codfr = "ecdivis" and codfr.code = v-cod no-lock no-error.
   if avail codfr then assign kdcifhis.ecdivis = v-cod v-ecdivis = codfr.name[1].
   displ kdcifhis.ecdivis v-ecdivis with frame kdmon.
end.

find kdcifhis where kdcifhis.kdcif = s-kdcif and kdcifhis.nom = s-nom exclusive-lock no-error. 

if avail kdcifhis then do:
   find first codfr where codfr.codfr = "lnopf" and codfr.code = kdcifhis.lnopf no-lock no-error.
   if avail codfr then v-lnopf = codfr.name[1].
   find first codfr where codfr.codfr = "ecdivis" and codfr.code = kdcifhis.ecdivis no-lock no-error.
   if avail codfr then v-ecdivis = codfr.name[1].
                       
                       
    displ              
      s-kdcif kdcifhis.regdt kdcifhis.who kdcifhis.bank kdcifhis.mname
      kdcifhis.prefix kdcifhis.rnn  kdcifhis.name
      kdcifhis.fname kdcifhis.lnopf v-lnopf kdcifhis.ecdivis v-ecdivis kdcifhis.urdt 
      kdcifhis.urdt1 kdcifhis.regnom kdcifhis.addr[1]
      kdcifhis.addr[2] kdcifhis.tel kdcifhis.sotr kdcifhis.chief[1] kdcifhis.job[1]
      kdcifhis.docs[1] kdcifhis.rnn_chief[1] kdcifhis.chief[2]
      with frame kdmon.
      pause 0.

 
     if s-newrec eq true then do:
    
     define var v-name like kdcifhis.name.
     define var v-chief1 like kdcifhis.chief[1].
     define var v-chief2 like kdcifhis.chief[1].
     v-name = kdcifhis.name.
     v-chief1 = kdcifhis.chief[1].
     v-chief2 = kdcifhis.chief[2].
    
            update
             kdcifhis.mname 
         kdcifhis.rnn
         kdcifhis.prefix
         kdcifhis.name
         kdcifhis.fname
         kdcifhis.lnopf
         kdcifhis.ecdivis
         kdcifhis.urdt kdcifhis.urdt1 kdcifhis.regnom  kdcifhis.addr[1]
         kdcifhis.addr[2] kdcifhis.tel kdcifhis.sotr kdcifhis.chief[1]
         kdcifhis.job[1]
         kdcifhis.docs[1] kdcifhis.rnn_chief[1] kdcifhis.chief[2]
         with frame kdmon.
      s-newrec = false.

     end.
find current kdcifhis no-lock.
end.

