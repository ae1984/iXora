/* lbing.p
 * MODULE
        Платежная система
 * DESCRIPTION
        автом формирование платежей по пенсиям и пособиям по МТ-102
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * BASES
        BANK
 * AUTHOR
        25/07/2008 marinav
 * CHANGES
 */


  def var v-rmz  like remtrz.remtrz no-undo.
  def var v-rmz1 like remtrz.remtrz no-undo.
  def var bnk as char.
  def new shared var s-jh like jh.jh.
  def var vdel as char initial "^".
  def var vparam as char.
  def var rcode as inte.
  def var rdes as char.
  def var v-arp  as char init 'KZ82470142860A000100'.
  
  find first t-102 where t-102.account = v-arp and t-102.ff = no no-lock no-error.
  if avail t-102 then do:
  
  
  find first arp where arp.arp = v-arp no-lock no-error.
  if avail arp then do:
      find first trxbal where trxbal.sub = 'arp' and trxbal.acc = v-arp and trxbal.lev = 1 no-lock no-error.
      if avail trxbal and trxbal.cam - trxbal.dam > 0 then do:

           for each t-102 where t-102.account = v-arp and t-102.ff = no.
              find first remtrz where remtrz.remtrz = t-102.rem no-lock no-error.
              if avail remtrz and remtrz.jh2 <> ? then do:
    /*iban*/
                 bnk = "TXB" + substr(t-102.racc,19,2).
                 if bnk = "TXB00" then do:
                       t-102.rbank = 'TXB00'.
                       s-jh = 0.
                       vparam = string(t-102.ndoc) + vdel + string(t-102.sum) + vdel + "1" + vdel + v-arp + vdel + t-102.racc + vdel + t-102.nplin + vdel + "1" + vdel + t-102.knp .
                       run trxgen("jou0033", vdel, vparam, "", "", output rcode,output rdes, input-output s-jh). 
                       if rcode ne 0 then do:
                           run savelog( "gcvp102", "Платеж не сделан : " + string(t-102.sum) + "  " + t-102.racc + " " + rdes ).
                           next.
                       end. 
                       run savelog( "gcvp102", "Платеж сделан : " + string(t-102.sum) + "  " + t-102.racc + " " + string(s-jh) ).
                       t-102.ff = yes.
                       run jou.
                  end.    
                  else do:
                       t-102.rbank = bnk .
                       run rmzcre (	
                            t-102.ndoc    ,        
                            t-102.sum     ,     
                            t-102.account ,
                            t-102.rnn     ,
                            t-102.fio     ,
                            t-102.rbank   ,
                            t-102.racc    ,
                            t-102.bn[1]   ,
                            t-102.bnrnn   ,
                            t-102.kb      ,
                            t-102.bud     ,
                            t-102.knp     ,
                            t-102.kod     ,
                            t-102.kbe     ,
                            t-102.nplin   ,
                            t-102.pid     ,
                            t-102.prn     ,
                            t-102.cov     ,
                            t-102.date    ).

                        v-rmz = return-value.
                        find first remtrz where remtrz.remtrz = v-rmz exclusive-lock no-error.
                        if avail remtrz then do:
                            remtrz.source = 'P'.
                            remtrz.ordins[1] = "ЦО ".
                            remtrz.ordins[2] = " ".
                            remtrz.valdt1 = g-today.
                            remtrz.valdt2 = g-today.
                            t-102.ff = yes.
                            run savelog( "gcvp102", "Платеж сделан : " + string(t-102.sum) + "  " + t-102.racc + " " + t-102.rbank ).
                        end.
                        else do:
                          run savelog( "gcvp102", "Платеж не сделан : " + string(t-102.sum) + "  " + t-102.racc + " " + t-102.rbank ).
                          next.
                        end.
                 end.

              end.  
           end.
  
      end.
  end.
    
  end.