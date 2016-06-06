/* dirupl.p
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
        08/02/2005 kanat
 * CHANGES
        14/03/2005 kanat - добавил DFB парсер
        17/03/2005 kanat - изменил обработку платежей с очереди DRSTW 
        24/05/2005 kanat - перекомпиляция
        20/07/2005 kanat - добавил возможность выбора банка для отдельной его обработки в платежной системе
        17/08/2005 kanat - добавил условие по ЛОРО - счатам для БТА 
        20/03/2006 suchkov - переделал для возможности обработки только одного банка
*/

{global.i}
{lgps.i "new"}

define input parameter a-bank as character .
define temp-table cms-direct like direct_bank.
define variable v-unibank as char.

define variable v-excheq as decimal init 3000000.  /* входящие платежи Казначейства Минфина с суммой больше этой попадают на доп.контроль */

define variable card-gl as char.
define variable v-arplbi as char.

define variable v-uniacct as char.
define variable v-uniacct1 as char.

/* Счет ГК для пласт.карт. для автоматической проводки */
 find sysc where sysc.sysc eq "pscdgl" no-lock no-error.
 if avail sysc then card-gl = string(sysc.inval) .

/* Счета АРП, по которым надо автоматически делать проводку */
 find sysc where sysc.sysc = "ARPLBI" no-lock no-error.
 if avail sysc then v-arplbi = sysc.chval.


find sysc where sysc.sysc = "EXCHEQ" no-lock no-error.
if avail sysc then v-excheq = sysc.deval.

if a-bank = "ALL" then do:
        run direct_select.
        v-unibank = return-value.
end.
else v-unibank = a-bank .

find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:
if trim(direct_bank.ext[3]) <> "" then do:
v-uniacct = trim(direct_bank.ext[3]).
v-uniacct1 = trim(direct_bank.bank2).
end.
else do:
v-uniacct = direct_bank.bank2.
v-uniacct1 = v-uniacct.
end.
end.


/*        18/07/2005 kanat - добавил возможность выбора банка для отдельной его обработки в платежной системе*/
       for each que where que.pid = "DIRIN" or que.pid = "DRSTW" exclusive-lock,  
           each remtrz where remtrz.remtrz = que.remtrz and (remtrz.cracc = v-uniacct or remtrz.dracc = v-uniacct1 or v-unibank = "ALL") exclusive-lock.
/*        18/07/2005 kanat - добавил возможность выбора банка для отдельной его обработки в платежной системе*/

           que.rcod = "0".
  
            if remtrz.ptype = "7" and que.pid = "DIRIN" then do:
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
                else do: /* если не казначейский платеж */
                 find aaa where aaa.aaa = remtrz.cracc no-lock no-error.
                 if avail aaa then do :
                   if aaa.sta = "C" then do.           
                     que.rcod = "1".
                     v-text = remtrz.remtrz + " Счет закрыт.".
                     run lgps.
                   end.
                   else do :   /* если счет не закрыт */
                     find cif of aaa no-lock no-error.
                     if trim(cif.jss) ne 
                      substr(
                      (trim(remtrz.bn[1]) + trim(remtrz.bn[2]) +
                      trim(remtrz.bn[3]))
                      ,index(
                      (trim(remtrz.bn[1]) + trim(remtrz.bn[2]) +
                      trim(remtrz.bn[3])) 
                      ,"/RNN/") + 5 )
                     then do :
                      que.rcod = "1".
                      remtrz.crgl = 0.
                      remtrz.cracc = "".
                      v-text = remtrz.remtrz + " Ошибка в РНН.".
                      run lgps.
                     end.
                     else do. /* нормальный РНН */
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
                          else   /* есть ЕКНП */
                            /* тенговые платежи от/на нерезидентов для полки валютного контроля */
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
                 end. /* avail aaa */
                 else do:
                  find arp where arp.arp = trim(remtrz.ba) no-lock no-error.
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
/* Incoming DFB payments ... */  
/* ------------------------------------------------------------- */
                  else do:
                  find dfb where dfb.dfb = trim(remtrz.ba) no-lock no-error.
                  if avail dfb then do:
                            que.rcod = "1".
                            remtrz.crgl = 0.
                            remtrz.cracc = ''.
                            remtrz.rsub = 'dfb'.
                            v-text = remtrz.remtrz + " Счет DFB - Nostro".
                            run lgps.
                  end.  /* avail arp */
/* ------------------------------------------------------------- */
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
                             end.
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
                                 if remtrz.rsub <> "arp" then do:
                                    que.rcod = "1".
                                    v-text = remtrz.remtrz + 
                                            " Счет не найден(aaa,arp,fun).".
                                    run lgps.
                                 end.
                             end.
                  end. /* avail fun */
                 end.
                end.
                             /* aaa not avail    */
                end.  /* не платеж органов казначейства */
              remtrz.ref = remtrz.ref + "/" + "Z".
            end.

/*
         else do:
             que.rcod = "2". 
             v-text = remtrz.remtrz + " не прошел сверку ". 
             run lgps . 
             if remtrz.ptype = "7" then 
              remtrz.ref = remtrz.ref + "/" + "NZ".
         end. 
*/
         que.con = "F" .  
         /*  que.rcod = "0" . */
         v-text = que.remtrz + " was checked and sent by route rcod = " 
                   + que.rcod. 
         run lgps. 
       end.  /* for each que */


release remtrz.
release que.

find first bankl where bankl.bank = v-unibank no-lock no-error.
if avail bankl then 
message "Обработка платежей по " bankl.name " завершена" view-as alert-box title "Внимание".
else
message "Обработка платежей по всем банкам завершена" view-as alert-box title "Внимание".



procedure direct_select.
for each cms-direct:
delete cms-direct.
end.
  
for each direct_bank no-lock:
    do transaction on error undo, next:
        create cms-direct.
        buffer-copy direct_bank to cms-direct.
    end.
end.
        create cms-direct.
        update cms-direct.bank1 = "ALL"
               cms-direct.bank2 = "ALL"
               cms-direct.aux_string[1] = "Все банки".
        
define query q1 for cms-direct.
define browse b1 
    query q1 no-lock
    display 
        cms-direct.bank1 label "БИК" format "x(10)" 
        cms-direct.bank2 label "Корр. счет" format "x(10)" 
        cms-direct.aux_string[1] label  "Наименование" format 'x(50)'
        with 10 down title "Список банков".
                                         
define frame fr1 
    b1
    with no-labels centered overlay view-as dialog-box.  
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
                    
open query q1 for each cms-direct.
if num-results("q1") = 0 then
do:
    MESSAGE "Справочник пуст ?!"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return cms-direct.bank1.
end.

