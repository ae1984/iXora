/* clrrmzg.p
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
        31/12/99 pragma
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

{mainhead.i}
{lgps.i "new"}
def var k1 as  int.
def var k2  as int.
def var nbank as inte.
def var vsum as deci format "zzz,zzz,zzz,zzz.99".
def var sum1 as deci format "zzz,zzz,zzz,zz9.99" label "Минимальная" init 0.0.
def var sum2 as deci format "zzz,zzz,zzz,zz9.99" label "Максимальная" init 0.0.
define buffer chktbl for remtrz.
def var nk as inte.
def new shared var ddat as date.
def new shared var s-datt as date.
def var vvans as logi initial false.
def new shared var s-num like clrdoc.pr.
def new shared var s-remtrz like remtrz.remtrz.
def new shared var vnum like clrdoc.pr init 1.
def  var v_num like clrdoc.pr  init  1.
def new shared var vvsum as deci.
def var otv as log init false.
def new shared var nnsum as inte.
def var msgg1 as char initial
"Enter-выбор;1-печ.сопр.док-ов;2-печ.плат.пор;3-свод по контр;4-клиринг;9-монитор пачки;F4-выход".
def var lbnstr as cha .
def var veids as  log .
def var bbcod as char.
def var depart as char.
def new shared temp-table ree
    field npk as inte format "zz9"
    field bank as char format "x(9)"
    field bbic like bankl.bic
    field quo as inte format "zzzzz9"
    field kopa as deci format "zzz,zzz,zzz,zzz.99".

/* timur ********************************/
def var mt102_cnt as int init 0.
def var mt102_max as int init 150.
/* timur ********************************/

find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if not avail sysc then
  do:
     message  "Отсутствует запись LBNSTR в таблице SYSC!".
     pause .
     return.
  end.
  lbnstr = trim(sysc.chval) .
  
find sysc where sysc.sysc = "CLECOD" no-lock no-error.
   if not avail sysc then do:
     v-text = " Записи CLECOD нет в файле sysc  " .  run lgps.
     return .
   end.
bbcod = substr(trim(sysc.chval),1,6).

/* KOVAL Убрал выбор очереди т.к. их больше нет
run menu-LB(output depart).
if depart = '*' then return.
if depart = '' then m_pid = 'LBG'.
else m_pid = 'LBG-' + depart.*/

m_pid = 'LBG'.
ddat = g-today.
clear frame ans.
update "Дата:" ddat with row 3 no-label frame dat.
find first clrdog where clrdog.rdt = ddat no-lock no-error.
/******************/

if available clrdog then do:                              
    repeat:
      find first clrdog where clrdog.rdt = ddat and clrdog.pr = vnum no-lock no-error.
          if available clrdog then  vnum = vnum + 1. 
          else leave.
    end. 
    
    v_num = vnum -  1.

    update "Номер пачки по SGROSS00 ?" vnum format "zz9  " with row 3 column 19 no-label frame ans. 

    find first clrdog where clrdog.rdt = ddat and clrdog.pr = vnum no-lock no-error.
    if available clrdog and vnum = v_num  then do:
        if ddat = g-today then
        disp caps(g-ofc) + ", Вам переформировать ? " with frame ans. update vvans with no-label frame ans. 
    end.
    else do:
       if vnum < v_num then vvans = false. else vvans = true.
    end.
end.   /*  if avail clrdog   */
else vvans = true.

if ddat <> g-today then vvans = false. 
    
if vvans = true  then do:   

    update sum1 sum2 with centered side-labels frame sumf title "Интервал сумм".

    veids = true . 
                     
    find first clrdog where clrdog.rdt = ddat and clrdog.pr = vnum no-lock no-error.      
    if available clrdog then do:
        if clrdog.maks = true then do:
            update "SGROSS00 сегодня уже сформирован. Переформировать ?" otv
            with no-label frame ans.
        end.
        else otv = true.
        if otv = false then undo, retry.
    end.   
   find first  clrdog where clrdog.rdt = ddat and clrdog.pr = vnum no-lock no-error. 
   message " Ж д и т е ...".
       
   main: do transaction:
       
   for each clrdog where clrdog.rdt = ddat and clrdog.pr = vnum: 
     /*do transact:*/
        find remtrz where remtrz.remtrz = clrdog.rem exclusive-lock.
        find que where que.remtrz = clrdog.rem exclusive-lock.
        que.pid = m_pid.
        que.con = "W" .
        v-text = remtrz.remtrz + " have returned -> " + m_pid.
        run lgps.
        delete clrdog.
     /*end.    do transaction     */
   end.  /*  for each clrdog  */
   k1 =  0.
   k2 = 0.
                   
   for each que where que.pid = m_pid 
     use-index fprc,  
    each remtrz of  que where  
              remtrz.cracc = lbnstr    
              and remtrz.cover = 2 
              and remtrz.jh1 <> ? 
              and remtrz.payment >= sum1
              and remtrz.payment <= sum2
              no-lock break by remtrz.rbank:

    find first clrdog where clrdog.rdt = ddat 
        and clrdog.rem eq remtrz.remtrz  use-index rem no-lock no-error.
    if not available clrdog then do: /*transaction*/
        k1 = k1 + 1.
        disp "Обработано " remtrz.remtrz k1 "код очереди = " + m_pid with no-label centered no-box frame aaa.
        pause 0.
        create clrdog.
        clrdog.rem = remtrz.remtrz. 

        clrdog.bank = remtrz.rbank.
        clrdog.amt = remtrz.payment.
        if remtrz.ba begins '/'  then clrdog.tacc = substring(remtrz.ba,2). else clrdog.tacc = remtrz.ba.
        clrdog.facc = remtrz.sacc.
        clrdog.rdt = ddat.
        clrdog.pr = vnum.
        clrdog.maks = false.
        s-remtrz = remtrz.remtrz.
        run LBG_ps(m_pid).  

        find first chktbl where
        remtrz.remtrz <> chktbl.remtrz and
        remtrz.rdt = chktbl.rdt and
        substring(remtrz.sqn, 19, 8) = substring(chktbl.sqn, 19, 8) and
        remtrz.payment = chktbl.payment and
        remtrz.sbank = chktbl.sbank and
        remtrz.dracc = chktbl.dracc and
        remtrz.rbank = chktbl.rbank and
        remtrz.ba = chktbl.ba no-lock no-error.
/*        if avail chktbl then do:
            message "Найдены дубликаты платежей, сумма:" + 
            string(remtrz.payment) + " тг.~n" + 
            remtrz.remtrz + "~n" +
            chktbl.remtrz + "~n" + 
            "Продолжить формирование пачки?" view-as
            alert-box buttons yes-no title "Внимание" update choice as logical.
            if not choice then undo main, return.
        end.
*/                                           
        end.
    end.
    
    end. /* of transaction */ 
/*
    for each que where que.pid = 'F' 
    use-index fprc,  
    each remtrz of  que where  
              remtrz.cracc = lbnstr
              and remtrz.cover ne 4     
              and remtrz.jh2 <> ? 
              no-lock break by remtrz.rbank:
     if veids then do:
       find first bankl where bankl.bank = remtrz.rbank no-lock .
       if bankl.bic = ? or bankl.bic = "" then do:
         do transact:
           que.pid = m_pid.
           que.con = "W" .
           v-text = remtrz.remtrz + " have returned -> " + m_pid.
           run lgps.
         end.
         next.
       end.
     end.
     find first clrdog where clrdog.rdt = ddat 
       and clrdog.rem eq remtrz.remtrz  use-index  rem no-lock no-error.
     if not available clrdog then 
     do transaction:
        k2 = k2 + 1.
        disp "Обработано  " remtrz.remtrz k2 "код очереди = F" 
        with no-label centered no-box frame bbb.
        pause 0.
        create clrdog.
        clrdog.rem = remtrz.remtrz. 
        if remtrz.rbank begins bbcod then 
         clrdog.bank = remtrz.rbank.
        else do:
         if remtrz.rbank begins 'lat' then
          clrdog.bank = substr(remtrz.rbank,4,3).
         else clrdog.bank =  remtrz.rbank.
        end. 
         clrdog.amt = remtrz.payment.
         clrdog.facc = remtrz.sacc.
         if remtrz.ba begins '/'  then
          clrdog.tacc = substring(remtrz.ba,2).
         else clrdog.tacc = remtrz.ba.
          clrdog.rdt = ddat.
          clrdog.pr = vnum.
          clrdog.maks = false.
          s-remtrz = remtrz.remtrz.
      end.
    end.
*/
   u_pid =  ''.
   v-text = " SGROSS00 номер  " +
   string(vnum)  + " сформирован ".
   run lgps.
end.

/* timur ******************************************************/

mt102_cnt = 0.
for each clrdog where clrdog.rdt = ddat and clrdog.pr = vnum 
    and substr(clrdog.tacc,1,9) = '000080000' and clrdog.bank = '190501008':
    mt102_cnt = mt102_cnt + 1.
    if mt102_cnt > mt102_max then clrdog.pr = vnum + 1.
end.
find first clrdog where clrdog.rdt = ddat and clrdog.pr = vnum + 1 no-lock no-error.
if available clrdog then 
   message "Часть платежей 000080000/190501008 переведена в пачку " vnum + 1 view-as alert-box.

/* timur ******************************************************/

/* Формирование ведомости платежей в разрезе банков получателей */
for each clrdog where clrdog.rdt = ddat and clrdog.pr = vnum no-lock break by clrdog.bank:     
    nbank = nbank + 1.
    vsum = vsum + clrdog.amt.
    if last-of(clrdog.bank) then do:
       nk = nk + 1.
       create ree.
       ree.npk = nk.
       ree.bank = clrdog.bank.
       ree.quo = nbank.
       ree.kopa = vsum.
       vvsum = vvsum + vsum.
       nnsum = nnsum + nbank.
       nbank = 0.
       vsum = 0.
    end.
end.

/* KOVAL Формирование и отправка на различные мыла ведомости платежей в разрезе банков отправителей */
run clrrmzm(vnum,"mailps",m_pid).

s-num = vnum.
s-datt = ddat.

hide frame aaa.
hide  frame bbb.

{jabre.i
&start = "disp vvsum nnsum with frame kopp."
&head = "ree"
&headkey = "npk"
&where = "true"
&formname = "clrdoc"
&frameparm = "new" 
&framename = "clrdoc"
&addcon = "false"
&deletecon = "false"
&prechoose = "message msgg1."
&display = "
ree.npk ree.bank ree.quo ree.kopa"
&highlight = "ree.npk ree.bank ree.quo ree.kopa"
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
             run clrrmz1g(ree.bank, ddat, vnum).
              vvsum = vvsum - ree.kopa.
              nnsum = nnsum - ree.quo.
              for each clrdog where clrdog.rdt = ddat and clrdog.pr = vnum and
                clrdog.bank = ree.bank no-lock:
                nbank = nbank + 1.
                vsum = vsum + clrdog.amt.
              end.
                ree.quo = nbank.
                ree.kopa = vsum.
             
              nbank = 0.
              vsum = 0.
              vvsum = vvsum + ree.kopa.
              nnsum = nnsum + ree.quo.  
              disp ree.bank ree.quo ree.npk
              ree.kopa with frame clrdoc.
              disp vvsum nnsum with frame kopp. 
            end.
            else if keyfunction(lastkey)='1' then do:
       /*        if ddat = g-today then do :
                message 'Ж д и т е ...'.
                run unimt100 (vnum).
                run unireg (vnum).
                pause 0.
               end.*/
               run clrrmzp1.
            end.
            else if keyfunction(lastkey) = '2' then do:
               run clrrmzp2('*').
            end.
            else if keyfunction(lastkey) = '3' then do:
               message "" Ж д и т е ..."".
               run crmzusrg.
               disp ree.bank ree.quo ree.npk
                    ree.kopa with frame clrdoc.
               disp vvsum nnsum with frame kopp.
            end.
            else if keyfunction(lastkey) = '4' then do:
             run lbtog.
             view  frame mainhead.
             pause 0 .
             view frame dat .
             view frame ans .
             pause 0 .
             view frame clrdoc .
             view frame kopp .
            end.
            else if keyfunction(lastkey) = '9' then do:
		run clrrmzm(vnum,'menu-prt',ddat,m_pid).               
            end."
&end = "hide frame clrdoc. hide frame ans. hide frame dat. hide frame kopp.
hide message."
}
