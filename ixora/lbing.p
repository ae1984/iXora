/* lbing.p
 * MODULE
        Платежная система
 * DESCRIPTION
        автоматическая регистрация входящих платежей в тенге по gross в течении дня
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * BASES
        bank
 * AUTHOR
        25/01/2008 marinav
 * CHANGES
        19/03/08 marinav - убраны message, запускается в виде процесса ПС
*/


{global.i}
 def new shared var v-lbin as cha .
 def new shared var v-lbina as cha .
 def new shared var v-lbeks as cha .
 def new shared var v-lbhst as cha .
 def var v-lbtyp as char no-undo.
 def var exitcod as cha initial "" no-undo. 
 def new shared var v-ok as log . 
 def new shared var card-gl as char. 
 def var v-excheq as decimal init 3000000 no-undo.  /* входящие платежи Казначейства Минфина с суммой больше этой попадают на доп.контроль */
 def var v-nostro as char init "400161370" no-undo.
 def var v-arplbi as char no-undo.
 def var v-cls as date no-undo.
 def var num as cha extent 20 no-undo. 
 def stream f-file . 
 def var t-str as cha no-undo. 
 def var t-gro as cha no-undo. 
 def new shared var f-name as cha . 
 def var yn as log no-undo. 
 DEF NEW SHARED STREAM PROT .
 def new shared var n-pap as int .
 def new shared var n-sum like remtrz.amt .
 def new shared  var n-papv as int init 0 .    /*  for qqq  */
 def new shared var irt as int .
 def new shared var totr-sum like remtrz.amt .
 def new shared var totv-sum like remtrz.amt.
 def new shared  var n-sumv like remtrz.amt init 0 .   /*  or qqq  */
 def new shared var ivt as int.
 def var rmz_rnn as char no-undo.
 def var i as int no-undo. 

 def new shared  temp-table qrr
     field remtrz like remtrz.remtrz
     field pid like que.pid     
     field amt like remtrz.amt
     field bank like remtrz.rbank
     field sqn like remtrz.t_sqn
     field fname as char
     field ff as log init no
     index sqn is primary sqn
     index fname fname
     index ff ff.
 

def temp-table t-qarc no-undo
    field fname as char.

def new shared temp-table t-qin
    field fname as char.

{lgps.i new}


find sysc where sysc.sysc = "LBIN" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBIN in sysc file !! ".
/* message v-text .*/
 run lgps.
 return .
end.
v-lbin = sysc.chval.

find sysc where sysc.sysc = "LBINA" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBINA in sysc file !! ".
/* message v-text .*/
 run lgps.
 return .
end.
v-lbina = sysc.chval.

if v-lbin = v-lbina then do :
 v-text = " ERROR !!! Records LBIN and LBINA are equal !! ".
/* message v-text .*/
 run lgps.
 return .
end .

find sysc where sysc.sysc = "LBTYP" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
  v-text = " ERROR !!! There isn't record LBTYP in sysc file !! ".
/*  message v-text .*/
  run lgps.
  return .
end.
v-lbtyp = sysc.chval.


find sysc where sysc.sysc = "LBEKS" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBEKS in sysc file !! ".
/* message v-text .*/
 run lgps.
 return .
end.
v-lbeks = sysc.chval .

find sysc where sysc.sysc = "LBHST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBHST in sysc file !! ".
/* message v-text .*/
 run lgps.
 return .
end.
v-lbhst = sysc.chval.

/* Счет ГК для пласт.карт. для автоматической проводки */
 find sysc where sysc.sysc eq "pscdgl" no-lock no-error.
 if avail sysc then card-gl = string(sysc.inval) .

/* Счета АРП, по которым надо автоматически делать проводку */
 find sysc where sysc.sysc = "ARPLBI" no-lock no-error.
 if avail sysc then v-arplbi = sysc.chval.

 v-cls = g-today . 

 m_pid = "LBI".
 u_pid = "lbin" .        



/* GET  - копирование на сервер всех файлов */

    input through value("lbget """ + v-lbin + """ """ + v-lbhst + ":" + v-lbeks + "out/" + """ ;echo $?" ) .
    i = 0 . 
    repeat :
       import unformatted exitcod .
       if i = 0 then do:
        v-text = exitcod . 
        i = 1 . 
       end.
    end .
    if exitcod <> "0" then 
    do :
       repeat:
        /* message v-text .
         pause .       */
         run lgps.
         leave.
       end.
     leave .
    end. 


/* Создание списка файлов для загрузки */

       num = "" .
       
       for each t-qin: delete t-qin. end.
       input through value("/bin/ls -lt " + v-lbin + "*.*" ) .
       
       repeat : 
          t-gro = "".
          import num .
          if search(num[9]) eq num[9]  then do: 
             find first lbinf where lbinf.rdt = g-today and lbinf.name = num[9] no-lock no-error.
             if not avail lbinf then do:  
                 input stream f-file from value(num[9]) .
                 import stream f-file t-str .
                 if t-str begins "\{1:" then 
                 repeat: 
                     import stream f-file t-str .
                     if t-str begins "\{2:" then 
                     do: 
                       t-gro = substr(t-str,19,5) .
                       t-str = substr(t-str,5,3) . 
                       leave . 
                     end. 
                 end.  
                 input stream f-file close . 

                 if lookup(t-str,v-lbtyp) eq 0 then next .
                 if t-gro = 'GROSS' then do:
                        create t-qin.
                        t-qin.fname = t-str + " " + substr(num[9],length(v-lbin) + 1 ) + " " + num[6] + num[7] + " " + num[8] +  ",".
                        create lbinf . 
                        assign lbinf.rdt = g-today 
                               lbinf.name = num[9]                   
                               lbinf.gc = 'gross' 
                               lbinf.who = g-ofc
                               lbinf.whn = today
                               lbinf.tim = time.
 
                 end.
             end.
          end.
       end.
       input close . 




/* i - создание REMTRZ по списку */
    find first t-qin no-lock no-error.
    if not avail t-qin then return.
 
  /*  Message "Обработать платежи  ? " update yn . */
    yn = yes. 
    if yn then  do:
        f-name = "" .
        for each t-qin.
          if entry(2,t-qin.fname," ") matches "*.*" then
              f-name = f-name + entry(2,t-qin.fname," ") + "," .
        end .  
        output stream prot to value(v-lbin + substr(string(g-today),1,2) + substr(string(g-today),4,2) + substr(string(g-today),7,2) + ".log") append.
        v-ok = false .

        run inw_LB_ps.

        output stream prot close . 
       /*
        if v-ok then do:
           Message " Import OK "  . pause . 
        end.
        else do:
           Message " Anything wrong .., look at LOG file " .
           pause .       
        end.
       */

      /* SEND */  

      /* Display  " Sending LBI , wait ... "  with row 22 no-box frame sss. */
       pause 0 .
       f-name = "" . 

       /* найти минимальную сумму для полочки excheq */
       find sysc where sysc.sysc = "EXCHEQ" no-lock no-error.
       if avail sysc then v-excheq = sysc.deval.

       /* найти ностро-счет для отбивки платежей из Депозитария */
       find sysc where sysc.sysc = "lbnstr" no-lock no-error.
       if avail sysc then v-nostro = sysc.chval.

       do transaction :           

       for each que where que.pid = "LBI" exclusive-lock,  
           each remtrz where remtrz.remtrz = que.remtrz and remtrz.cover = 2 and remtrz.fcrc = 1 exclusive-lock .
 
  
         if  index(f-name,entry(1,remtrz.ref,"/")) = 0 
             then  f-name = f-name + entry(1,remtrz.ref,"/") + " " .  

            que.rcod = "0" .

            if remtrz.ptype = "7" then do :
              /* если счет получателя = ностро-счет -> переложить на очередь D */
              if remtrz.racc = v-nostro then do:
                que.rcod = "3".
                v-text = remtrz.remtrz + " Платеж для Казначейства - доп.контроль".
                run lgps.
              end.
              else do:
                /* проверка по счету отправителя - платежи Казначейства с суммой больше v-excheq попадают на доп.контроль */ 
                find bankl where bankl.bank = remtrz.sbank no-lock no-error.
                if avail bankl and bankl.name matches "*казнач*" and 
                  (remtrz.sacc matches "...120..." or 
                   remtrz.sacc matches "...130..." or 
                   remtrz.sacc matches "...132...") and 
                  remtrz.amt > v-excheq then do:

                  que.rcod = "1".
                  remtrz.crgl = 0.
                  remtrz.rsub = "excheq".
                  v-text = remtrz.remtrz + " Контроль платежных документов органов казначейства Министерства Финансов".
                  run lgps.
                end.
                else do:
                 find aaa where aaa.aaa = remtrz.cracc no-lock no-error.
                 if avail aaa then do :
                   if aaa.sta = "C" then do.           
                     que.rcod = "1".
                     v-text = remtrz.remtrz + " Счет закрыт.".
                     run lgps.
                   end.
                   else do :
/* 22/02/2006 marinav */
                     rmz_rnn = substr((trim(remtrz.bn[1]) + trim(remtrz.bn[2]) + trim(remtrz.bn[3])),
                                index((trim(remtrz.bn[1]) + trim(remtrz.bn[2]) + trim(remtrz.bn[3])), "/RNN/") + 5 ).  
                     find cif of aaa no-lock no-error.
                     if trim(cif.jss) ne rmz_rnn
                     then do :
                      find first clfilials where clfilials.cif = cif.cif and clfilials.rnn = rmz_rnn no-lock no-error.
                      if not avail clfilials then do:
                         que.rcod = "1".
                         remtrz.crgl = 0.
                         remtrz.cracc = "".
                         v-text = remtrz.remtrz + " Ошибка в РНН.".
                         run lgps.
                      end. 
                     end.
/* 22/02/2006 marinav */
                     else do.
                          find sub-cod where sub-cod.acc = remtrz.remtrz
                                         and sub-cod.sub = "rmz"
                                         and sub-cod.d-cod = 'eknp' 
                                         and sub-cod.ccode = 'eknp' 
                                         no-lock no-error.
                          if not avail sub-cod then do.
                             que.rcod = "1".
                             remtrz.crgl = 0.
                             remtrz.cracc = "".
                             v-text = remtrz.remtrz + " Нет ЕКНП.".
                             run lgps.
                          end.
                          else
                            /* тенговые платежи от/на нерезидентов кидаем на полочку валютного контроля */
                            if (remtrz.fcrc = 1 or remtrz.tcrc = 1) then do:
                              if substr(sub-cod.rcod,1,1) = '2' and
                                  substr(sub-cod.rcod,4,1) = '1' then do.
                                  que.rcod = "1".
                                  remtrz.crgl = 0.
                                  remtrz.cracc = "".
                                  remtrz.rsub = "valcon".
                                  v-text = remtrz.remtrz +
                                           " Отправитель - нерезидент.".
                                  run lgps.
                                end.  
                              if substr(sub-cod.rcod,1,1) = '1' and
                                  substr(sub-cod.rcod,4,1) = '2' then do.
                                  que.rcod = "1".
                                  remtrz.crgl = 0.
                                  remtrz.cracc = "".
                                  remtrz.rsub = "valcon".
                                  v-text = remtrz.remtrz +
                                           " Получатель - нерезидент.".
                                  run lgps.
                                end.  
                              /* Заполнение справочника Принадлежности к Вал.контролю */
                              find sub-cod where sub-cod.acc = remtrz.remtrz
                                             and sub-cod.sub = "rmz"
                                             and sub-cod.d-cod = "rmzval" no-error.
                              if avail sub-cod then 
                                  sub-cod.ccode = "valcon".
                              else do:
                                  create sub-cod.
                                  assign sub-cod.acc = remtrz.remtrz
                                         sub-cod.sub = "rmz"
                                         sub-cod.d-cod = "rmzval" 
                                         sub-cod.ccode = "valcon". 
                              end.      
                          end.
                     end. 
                   end.
                 end.
                 else do :
                  find arp where arp.arp = trim(remtrz.ba) no-lock no-error.
                    /* 28/02/02 */
                  if avail arp then do:
                    find sub-cod where sub-cod.acc = arp.arp
                                  and sub-cod.sub = "arp"
                                  and sub-cod.d-cod = 'clsa'
                                  no-lock no-error.
                    if not avail sub-cod or sub-cod.ccode <> 'msc' then do.
                      que.rcod = "1".
                      v-text = remtrz.remtrz + " Счет-карточка ARP закрыт".
                      run lgps.
                    end.
                    else do:
                      if (string(remtrz.crgl) = card-gl or lookup(arp.arp, v-arplbi) > 0) then do:
                            que.rcod = "0".  
                            remtrz.rsub = "arp". 
                            v-text = remtrz.remtrz + if string(remtrz.crgl) = card-gl then " Счет ГК по пласт.картам"
                                                     else " Счет получателя - транзитный счет Деп.Казначейства".
                            run lgps.
                      end.
                      else do:
                            que.rcod = "1".
                            remtrz.crgl = 0.
                            remtrz.cracc = ''.
                            remtrz.rsub = 'arp'.
                            v-text = remtrz.remtrz + " Счет-карточка ARP".
                            run lgps.
                      end.
                    end.
                  end.  /* avail arp */
                  else do:
                             find fun where fun.fun = trim(remtrz.ba) no-lock no-error.
                             if avail fun then do:
                             
                                find sub-cod where sub-cod.acc = fun.fun
                                          and sub-cod.sub = "fun"
                                          and sub-cod.d-cod = 'clsa'
                                          no-lock no-error.
                                if avail sub-cod and sub-cod.ccode <> 'msc' then do:
                                   que.rcod = "1".
                                   v-text = remtrz.remtrz + " Счет МБК закрыт .".
                                   run lgps.   
                                end.
                                else do.
                                   que.rcod = "1".
                                   remtrz.crgl = 0.
                                   remtrz.cracc = "".
                                   remtrz.rsub = '451050'.
                                   v-text = remtrz.remtrz + " Счет МБК.".
                                   run lgps.
                                end.
                             end.   /* avail fun ... */

                             else do:
                             /* 05/06/2003 - suchkov begin */
                                 find deal where deal.deal = trim(remtrz.ba) no-lock no-error.
                                 if avail deal then do:

                                      que.rcod = "1".
                                      remtrz.crgl = 0.
                                      remtrz.cracc = "".
                                      remtrz.rsub = '451050'.
                                      v-text = remtrz.remtrz + " платежи по займам.".
                                      run lgps.
                                 end.
                                 else
                             /* 05/06/2003 - suchkov end */

                                 if remtrz.rsub <> "451050" then do:
                                    que.rcod = "1".
                                    v-text = remtrz.remtrz + 
                                            " Счет не найден(aaa,arp,fun,dfb).".
                                    run lgps.
                                 end.
                             end.
                   end.
                 end.
                             /* aaa not avail    */
                end.  /* не платеж органов казначейства */
              end. /* не ностро-счет */

            end.

         que.con = "F" .  
         /*  que.rcod = "0" . */
         v-text = que.remtrz + " was checked and send by route rcod= "  + que.rcod. 
         run lgps . 
       end.  /* for each que */
     end . /* do transaction */


 end. /* Обработать платежи  ?" */
