/* lbin.p
 * MODULE
        Платежная система
 * DESCRIPTION
        автоматическая регистрация входящих платежей в тенге
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-9-3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        14.03.2001          - разбор поступлений от клиентов-нерезидентов
        28/02/2002          - автоматическое зачсиление платежей по карточкам sysc.sysc eq "pscdgl"
        05/06/2003 suchkov  - добавлен перенос входящих платежей по заемным счетам (812,813) на полку 451050
        19/06/2006 nadejda  - добавлено скидывание на полочку valcon платежей в тенге от/к физлицам и оба направления резидент-нерезидент и нерезидент-резидент
        19.08.2003 nadejda  - добавлены индексы во временную таблицу
        29.02.2004 nadejda  - обработка входящих платежей органов Казначейства - на полочку excheq
                              обработка входящих платежей из Депозитария на ностро-счет - сразу на очередь D
        03.03.2004 nadejda  - обработка параметра sysc=ARPLBI, счета АРП по этому списку проходят на автоматическую вторую проводку
        12.07.2004 saltanat - добавила для полочки valcon заполнение справочника rmzval
        20.10.2004 tsoy    - список файлов теперь не в переменной а во временной таблице
        28.10.2004 tsoy    - по умолчанию фокус на кнопку GET
        28.03.2005 kanat   - добавил обработку DFB Счетов для формирований остатков по DFB счетам 
        29.03.2005 kanat   - Вместо условия по arp в конце сверки - добавил условие на 451010 - так как это послений субтип 
                             для проверяемой транзакции.
        05.05.2005 kanat   - убрал обработку полочки DFB 
        22/02/2006 marinav - проверка РНН на филиале клиента 
*/

{global.i}
 def var method-return as logical no-undo.
 def var i as int no-undo. 
 def var j as int no-undo. 
 def var v-str as cha no-undo.
 def var v-strOK as cha no-undo.
 def var v-strALL as cha no-undo.
 def var v-dir  as cha no-undo. 
 def var n-buf AS CHA no-undo.
 DEF new shared VAR V-OK AS LOG . 
 def var exitcod as cha initial "" no-undo. 
 def var v-err as cha format "x(78)" no-undo. 
 def var yn as log no-undo. 
 def var num as cha extent 20 no-undo. 
 def new shared var v-inf as cha . 
 def new shared var f-name as cha . 
 def new shared var ir as int .
 def new shared var iv as int.
 def new shared var irt as int .
 def new shared var ivt as int.
 def new shared var totr-sum like remtrz.amt .
 def new shared var totv-sum like remtrz.amt.
 def new shared var n-pap as int .
 def new shared var n-sum like remtrz.amt .
 def new shared  var n-papv as int init 0 .    /*  for qqq  */
 def new shared  var n-sumv like remtrz.amt init 0 .   /*  or qqq  */
 def var list-name as cha no-undo. 
 def var v-cls as date no-undo.
 def var lbnum as int no-undo.
 def new shared var v-lbin as cha .
 def new shared var v-lbina as cha .
 def new shared var v-lbeks as cha .
 def new shared var v-lbhst as cha .
 def button uisend label " SEND " .
 def button lbget label " GET " . 
 def button spbank label " SPRAV " .
 def stream f-file . 
 def var t-str as cha no-undo. 
 def var v-lbtyp as char no-undo.
 def new shared var card-gl as char. 
 def var v-excheq as decimal init 3000000 no-undo.  /* входящие платежи Казначейства Минфина с суммой больше этой попадают на доп.контроль */
 def var v-nostro as char init "900161014" no-undo.
 def var v-arplbi as char no-undo.
 def var rmz_rnn as char no-undo.

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
 
 DEF NEW SHARED STREAM PROT .
 def var v-name as cha  view-as selection-list 
  INNER-CHARS 30 INNER-LINES 10 .
 def var v-narc as cha view-as selection-list
   INNER-CHARS 30 INNER-LINES 10 .

/*
 def frame finw v-name  with title  "Received Inwards " no-label column 4 row 2.
*/ 
 def var v-tar as cha view-as selection-list
  INNER-CHARS 15 INNER-LINES 12 SORT  .                       
 
 def frame ftar v-tar  with title  f-name  no-label centered  row 3.

/* 
 def frame farc v-narc skip 
   " LBI - queue : " lbnum 
   with title  "Archived Inwards " column 40 no-label  row 2.
*/

 def frame fhelp "<V> - view  <I> - import            " lbget uisend spbank 
  with row 18 column 5 no-box . 


/* 19.10.2004  tsoy  */

def temp-table t-qarc no-undo
    field fname as char.

def new shared temp-table t-qin
    field fname as char.

def query qarc for t-qarc.
def query qin  for t-qin.

def browse barc 
    query qarc no-lock 
    display 
        t-qarc.fname  format "x(35)"         
    with 10 down width 38 title "АРХИВ ПЛАТЕЖЕЙ" no-labels.

def browse bin 
    query qin no-lock 
    display 
        t-qin.fname  format "x(35)"         
    with 10 down width 34 title "НОВЫЕ ПЛАТЕЖИ" no-labels.

def frame farcch 
    barc help ""
  with column 40  no-label  row 2.

def frame fin 
    bin help ""
  with column 4  no-label  row 2.
/*-----------------------------------------------*/

{lgps.i new}

find sysc where sysc.sysc = "LBIN" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBIN in sysc file !! ".
 message v-text .
 run lgps.
 return .
end.
v-lbin = sysc.chval.

find sysc where sysc.sysc = "LBINA" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBINA in sysc file !! ".
 message v-text .
 run lgps.
 return .
end.
v-lbina = sysc.chval.

if v-lbin = v-lbina then do :
 v-text = " ERROR !!! Records LBIN and LBINA are equal !! ".
 message v-text .
 run lgps.
 return .
end .

find sysc where sysc.sysc = "LBTYP" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
  v-text = " ERROR !!! There isn't record LBTYP in sysc file !! ".
  message v-text .
  run lgps.
  return .
end.
v-lbtyp = sysc.chval.


find sysc where sysc.sysc = "LBEKS" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBEKS in sysc file !! ".
 message v-text .
 run lgps.
 return .
end.
v-lbeks = sysc.chval .

find sysc where sysc.sysc = "LBHST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBHST in sysc file !! ".
 message v-text .
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

 find sysc where sysc.sysc = "UNIFRM" no-lock no-error.  
 if not available sysc or sysc.chval = "" then 
   do :
    message  " There isn't record UNIFRM in sysc file !! ".
    pause . 
    return .
   end.
 v-inf = sysc.chval.          

  on tab next-frame .
 
 on any-printable of barc in frame farcch do:
 do j = barc:NUM-SELECTED-ROWS TO 1 by -1 transaction:
    method-return = barc:FETCH-SELECTED-ROW(j).
    GET CURRENT qarc NO-LOCK. 
    find current t-qarc.
 end.


  if keylabel(lastkey) = "v" then  
  do:
   v-dir = v-lbina . 
   f-name = entry(2,t-qarc.fname," ").
   if substr(f-name,index(f-name,".") + 1) ne "tar.Z" then
    unix value("joe -rdonly  " + v-dir + f-name ) .
     else
       if substr(f-name,index(f-name,".") - 3 ) eq "All.tar.Z" then
     do:
      list-name = ""  . 
      Message " Search ? " update list-name format "x(20)" . 
        num = "" .
        input through value("arcview " +  v-dir + "/" + f-name ) .
        repeat :
          import num .
          if trim(num[7]) = trim(list-name)  then 
           do:
            input close .  
            unix value("uttview " + v-dir + "/" 
             + f-name + " " + trim(num[7])).
            leave . 
           end .
        end.
        input close . 
        if trim(num[7]) ne  trim(list-name)
         then 
         do:  
           Message  " File not found " . pause . 
         end.
     end.
       if substr(f-name,index(f-name,".") - 2 ) eq "Ok.tar.Z" then
     do:
        num = "" .
        list-name = "" .
        input through value("arcview " +  v-dir + "/" + f-name ) .
        view frame ftar  .
        repeat :
         import num .
           list-name = list-name + 
           num[7] /* + " " + num[8] + " " +
                    num[3] + " " + num[4] + " "
                  + num[5] + " " + num[6] */ +  ","  .
        end.
        input close .
        pause 0 . 
        v-tar:list-items in frame ftar =
          substr(list-name,1,length(list-name) - 1) .
        v-tar:screen-value = entry(1,v-tar:list-items).
        v-tar:help = " <ENTER> - view  <F4> - leave " .
        enable v-tar with frame ftar  .
        wait-for close of this-procedure or leave of frame ftar  .
        disable v-tar .
     end.
  end.
 end.

  on default-action of v-tar in frame ftar 
  do:
   n-buf = v-tar:screen-value .
   unix value("uttview " + v-dir + "/" + f-name + " " + entry(1,n-buf," ")).
   v-tar:screen-value = n-buf .
   v-tar:help = " <ENTER> - view  <F4> - leave  " .
  end.

  on any-printable of bin in frame fin do:
  do j = bin:NUM-SELECTED-ROWS TO 1 by -1 transaction:
     method-return = bin:FETCH-SELECTED-ROW(j).
     GET CURRENT qin NO-LOCK. 
     find current t-qin.
  end.


   if keylabel(lastkey) = "v" then  
   do:
    v-dir = v-lbin . 
    f-name = entry(2,t-qin.fname," ").
    if substr(f-name,10,3) ne "gz" then 
     unix value("vfview " +
     v-lbin + entry(2,t-qin.fname," ")) .
     else
     if substr(f-name,10,3) = "gz" then 
     do:
      num = "" .
      list-name = "" .
      input through  value("gtar tvfz " + v-lbin + "/" + f-name) .
      repeat :
        import num .
        list-name = list-name + num[8] + " " + 
         STRING(num[3],"XXXXXXXXXXX") + " " + num[4] + " " 
         + num[5] + " " + 
         num[6] + " " + num[7] + " " +  ","  .
      end.
      input close .
      v-tar:list-items in frame ftar = 
      substr(list-name,1,length(list-name) - 1) .
      v-tar:screen-value = entry(1,v-tar:list-items).
      v-tar:help = " <ENTER> - view <F4> - leave " .  
      enable v-tar with frame ftar  .
      wait-for close of this-procedure or
      leave of frame ftar  .
      disable v-tar .
     end. 
   end.

   if keylabel(lastkey) = "i" then 
   do:
    f-name = entry(2,t-qin.fname," ").
    if substr(f-name,10,3) = "log" then return .
     
    Message "Are you sure ? " update yn . 
    if yn then 
    do:
      if f-name matches "*.*" then 
      do:
       f-name = "" .
       for each t-qin.
        if entry(2,t-qin.fname," ") matches "*.*" then
          f-name = f-name + entry(2,t-qin.fname," ") + "," .
       end .     /*   repeat   */
       output stream prot to value(v-lbin + substr(string(g-today),1,2) +
         substr(string(g-today),4,2) + substr(string(g-today),7,2) + ".log") 
              append.
       v-ok = false .
       run inw_LB_ps.
       output stream prot close . 
       
       if v-ok then do:
        Message " Inward Import OK "  . pause . 
       end.
       else do:
        Message " Anything wrong .., look at LOG file " .
        pause .       
       end.
      end.
     end.    /*   f-name matches "*.*" */
    end.  /*  if yn    */
   end.   /*  lastkey = "i"    */
                                                
  on choose of lbget in frame fhelp 
  do :
   Message "Are you sure ? " update yn . 
   if yn then 
   do:
    message "Transfering..." .
    input through value("lbget """ + v-lbin + """ """
     + v-lbhst + ":" + v-lbeks + "transit/in/0/"
     + """ ;echo $?" ) .
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
 /*    v-text = "Remote EKS DIR " + v-lbhst + ":" +
      v-lbeks + " wasn't found ".  */ 
    repeat:
     message v-text .
     pause .
     leave.
    end.
     leave .
    end. 
   end .  /*  if yn   */
   pause 0.
  end .    /*   on choose lbget   */

  on choose of spbank in frame fhelp
  do :
     Message "Are you sure ? " update yn .
     if yn then
     do:
          message "Processing..." .
          f-name = "" .
             if entry(2,t-qin.fname," ") matches "*.exp" then
             f-name = entry(2,t-qin.fname," "). 
             v-ok = false .
             run spbank. 
          pause 0.
     end.
  end.      /*  on choose spbank   */

 /*-----------------------------------------*/
  on choose of uisend in frame fhelp do:  /* обработка SEND */
     yn = false . 
     Message "Are you sure ? " update yn .
     if yn then do:
        Message " Сверка ... "  .
        f-name = "" .
        for each t-qin.
          if entry(2,entry(1,t-qin.fname)," ") matches "*.exp" or entry(2,t-qin.fname," ") matches "*.err" then
             f-name = entry(2,t-qin.fname," ").
          end .
 
          v-ok = false .
          run lb-check.   /* сверка */

        v-ok = true .
        if v-ok then do:
           hide frame uuu . 
           yn = false . 
           MESSAGE "" . pause 0 . 
           display 
              "Total doc stmt inward " + 
              string(n-pap) + ", summ " + string(n-sum)
              + " Total doc LBI " + string(irt ) + ", summ " + 
              string(totr-sum) format "x(78)" 
              with no-box overlay row 20 frame f20   .   
           display
              "Total doc stmt outward " + 
              string(n-papv) + ", summ " + string(n-sumv)
              + " Total doc STW " + string(ivt) + ", summ " +
              string(totv-sum) format "x(78)" 
              with no-box overlay row 21 frame f21 . 
           
           Message " Send ? " update yn .
           clear frame f21 . 
           clear frame f20 . 
           if not yn then leave .

           Display  " Sending LBI -> I , wait ... " 
                    with row 22 no-box frame sss. 
           pause 0 .
           f-name = "" . 

           /* найти минимальную сумму для полочки excheq */
           find sysc where sysc.sysc = "EXCHEQ" no-lock no-error.
           if avail sysc then v-excheq = sysc.deval.

           /* найти ностро-счет для отбивки платежей из Депозитария */
           find sysc where sysc.sysc = "lbnstr" no-lock no-error.
           if avail sysc then v-nostro = sysc.chval.

           do transaction : 
              v-strOk = "lb" + substr(string(year(g-today)),3)
                        + string(month(g-today),"99")
                        + string(day(g-today),"99") + "Ok.tar" .
              v-strALL = "lb" + substr(string(year(g-today)),3)
                         + string(month(g-today),"99")
                         + string(day(g-today),"99") + "ALL.tar" .
       for each que where que.pid = "LBI" or que.pid = "STW" exclusive-lock,  
           each remtrz where remtrz.remtrz = que.remtrz exclusive-lock ,
           each qrr where qrr.sqn = remtrz.t_sqn exclusive-lock .
 
  
         if qrr.ff and que.pid = "LBI" and 
             index(f-name,entry(1,remtrz.ref,"/")) = 0 
             then  f-name = f-name + entry(1,remtrz.ref,"/") + " " .  

         if qrr.ff then do:
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

/* 28.03.2005 - kanat - обработка DFB счетов ... */

/*
                             else do:
                             find first dfb where dfb.dfb = trim(remtrz.ba) no-lock no-error.
                             if avail dfb then do:
                                      que.rcod = "1".
                                      remtrz.crgl = 0.
                                      remtrz.cracc = ''.
                                      remtrz.rsub = 'dfb'.
                                      v-text = remtrz.remtrz + " Счет DFB - Nostro (для чистой позиции)".
                             run lgps.
                             end.  
*/

/* avail dfb ... */

/* 28.03.2005 - kanat - обработка DFB счетов ... */

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

/* 29/03/2005 kanat - заменил if remtrz.rsub <> "451050" then do: на if remtrz.rsub <> "451050" then do:  - так 
   как раньше последнее условие было на нахождение ARP - до сегодняшего дня добавились еще несколько групп счетов:
   dfb, fun, deal итд. 
 */
                                 if remtrz.rsub <> "451050" then do:
                                    que.rcod = "1".
                                    v-text = remtrz.remtrz + 
                                            " Счет не найден(aaa,arp,fun,dfb).".
                                    run lgps.
                                 end.
                             end.
                             end.
/*
                  end.
*/
                 end.
                             /* aaa not avail    */
                end.  /* не платеж органов казначейства */
              end. /* не ностро-счет */

              remtrz.ref = remtrz.ref + "/" + v-strOK .
            end.

         end.      /*  qrr.ff = true  */ 
         else do:
             que.rcod = "2" . /*  have not been reconsilated  */ 
             v-text = remtrz.remtrz + " не прошел сверку " . 
             run lgps . 
             if remtrz.ptype = "7" then 
              remtrz.ref = remtrz.ref + "/" + v-strALL.
         end. 
         que.con = "F" .  
         /*  que.rcod = "0" . */
         v-text = que.remtrz + " was checked and send by route rcod= " 
                   + que.rcod. 
         run lgps . 
       end.  /* for each que */
       for each qrr break by qrr.fname . 
           if first-of(qrr.fname) and qrr.ff then do:
              f-name = f-name + " " + qrr.fname . 
           end.  
       end.
       output to fn_arc . 
       put unformatted  f-name skip .
       output close .         
       
       input through value("lbtoarc "  + v-lbin + " " + v-strOK +  
                           " " + v-strALL +  " " + 
                           v-lbina + " fn_arc > qq; echo $?") . 
           
       repeat :
         import unformatted exitcod .
       end .
       if exitcod <> "0" then do :
          message "Ошибка при создании архива платежей, прошедших сверку !"
          "Код возврата = " exitcod  .
          pause . 
          yn = false .
          Message "Продолжить ? " update yn .
          if not yn then undo,leave . 
       end . 
     end . /* do transaction */


     if exitcod = "0" then do:
        v-text = " Сверка проведена : " + 
                 "Total doc stmt inward " + 
                 string(n-pap) + ", summ " + string(n-sum) +
                 " Total doc LBI " + string(irt) + ", summ " +
                 string(totr-sum) + 
                 "Total doc stmt outward " + string(n-papv) +
                 ",              summ " + string(n-sumv) + 
                 " Total doc STW " +     
                 string(ivt) +  ", summ " + string(totv-sum) +
                 " Stmt Inward summa  - Total summa LBI = " + 
                 string(n-sum - totr-sum) . 
        run lgps . 
        repeat:
          hide frame sss . 
          Message "OK" . pause .
          leave.
        end.
     end.
   end. /* if v-ok */
   else do:
     Message "Anything wrong , look at recons.err file " . pause .
     undo,leave .
   end.
 end. /* repeat */  
 end. /* if yn */

repeat : 
 lbnum = 0 .
 for each que where que.pid = m_pid no-lock . 
  lbnum = lbnum + 1 .
 end.

 num = "" .
 list-name = "" . 
 for each t-qin: delete t-qin. end.
 input through value("/bin/ls -lt " + v-lbin + "*.*" ) .

 
 repeat : 
  import num .
  if search(num[9]) eq num[9]  then do: 
  input stream f-file from value(num[9]) .
   import stream f-file t-str .
   if t-str begins "\{1:" then 
  repeat: 
   t-str = "0er" .
   import stream f-file t-str .
   if t-str begins "\{2:" then 
   do: 
       t-str = substr(t-str,5,3) . 
       leave . 
    end. 
  end.  
  else t-str = "0tx" . 
  input stream f-file close . 
  end.
  else 
  do : 
    do i = 1 to 20 : 
     v-text = v-text + " "  + num[i] . 
    end.    
   if not v-text matches "*No such file or directory*" then 
    do:
    repeat:
     message "Error " + v-text  . 
     pause .
     leave.
    end. 
    return  . 
   end.
   else num = "" .
  end. 

 if lookup(t-str,v-lbtyp) eq 0 then next .
 
 list-name = list-name +  t-str + " " + 
   substr(num[9],length(v-lbin) + 1 ) + " " + 
   num[6] + num[7] + " " + num[8] +  ","  . 

 create t-qin.
        t-qin.fname = t-str + " " + substr(num[9],length(v-lbin) + 1 ) + " " + num[6] + num[7] + " " + num[8] +  ",". 

 end.
 input close . 

 for each t-qarc: delete t-qarc. end.
 
 input through value("/bin/ls -lt " + v-lbina + "/"   
  + "*.*" + " 2> /dev/null" ) .
 repeat : 
 import num . 

 create t-qarc.
        t-qarc.fname = substr(num[9],length(v-lbina + "/") + 1 ) + " " +  num[6] + " " + num[7] + " " + num[8] + ",". 
 end.
 input close .

       open query qarc for each t-qarc.
       open query qin for each t-qin.
       apply "VALUE-CHANGED" to BROWSE barc.
       apply "VALUE-CHANGED" to BROWSE bin.

       view frame fin. 
       view frame farcch.
       view frame fhelp.

       enable lbget  with frame fhelp  .
       enable uisend with frame fhelp  .
       enable spbank with frame fhelp.
       enable barc  with frame farcch .
       enable bin   with frame fin   .
 

       wait-for close of this-procedure 
            or any-printable of barc in frame farcch
            or any-printable of bin in frame fin
            or choose  of uisend in frame fhelp
            or choose  of lbget in frame fhelp 
            or choose  of spbank in frame fhelp focus lbget. 

            disable v-name v-narc uisend lbget spbank.  

 end.

