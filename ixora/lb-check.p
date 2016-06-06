/* lb-check.p
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
        20.10.2004 tsoy    - список файлов теперь не в переменной а во временной таблице
        19/08/2013 galina - ТЗ1871 добавила сверку для СМЭП

*/

/* lb-check.p
   сверка входящих и исходящих платежей с финальными формами МТ950 и МТ970
   изменения от 16.05.2001
   - чистая позиция по клирингу, отображаемая в МТ950, исключается из сверки
   - включена проверка даты финальных форм

   19.08.2003 nadejda - добавлены индексы во временные таблицы

   */


{global.i }
{lgps.i new }

def input parameter v-cover as char.

def shared temp-table t-qin  field fname as char.

def var v-79 as log init false .
def  shared  var v-lbin as cha .
def  shared  var v-lbina as cha .
def  shared  var v-lbeks as cha .
def  shared  var v-lbhst as cha .
def  shared  var v-ok as log .
def  shared  var n-pap as int init 0 .    /*  for qqq inw */
def  shared  var n-sum like remtrz.amt init 0 .   /*  for qqq inw */
def  shared  var n-papv as int init 0 .    /*  for qqq out */
def  shared  var n-sumv like remtrz.amt init 0 .   /*  for qqq  out */

n-pap  =  0 . n-sum = 0 .
n-papv = 0.   n-sumv = 0.
def stream err .
def var v-okk as log init true .
def var blok4 as log initial false .
def var v-str as cha .

def var v-clecod as char.
def var k1 as int.
def var k2 as int.
def var sum as char.
def var num as cha extent 100 .
def var v-err as cha format "x(70)".
def shared var irt as int.
def shared var ivt as int.
def shared  var ir as int.                 /* for qrr  */
def shared var iv as int.
def  shared  var totr-sum as decimal.      /* for qrr   */
def shared var totv-sum as decimal.
def var ourbank as char.
def var itogD like remtrz.amt init 0.
def var itogC like remtrz.amt init 0.
def var kolD as integer init 0.
def var kolC as integer init 0.
def var v-form as char format 'x(4)'.
def var otv as logical.
ir = 0 . totr-sum = 0 .
iv = 0.  totv-sum = 0.
irt = 0 . ivt = 0 .
def temp-table rrr
  field sqn like remtrz.sqn format "x(20)"
  field fname as char
  field vform as char format "x(5)"
  field amt like remtrz.amt
  field ff as log
  field dc as cha
  field bank like remtrz.rbank
  index sqn is primary sqn
  index fname fname.

def  shared  temp-table qrr
     field remtrz like remtrz.remtrz
     field pid like que.pid
     field amt like remtrz.amt
     field bank like remtrz.rbank
     field sqn like remtrz.t_sqn
     field fname as char            /* statement file name  */
     field ff as log init no
     index sqn is primary sqn
     index fname fname
     index ff ff.


def var dattim as cha .
dattim = string(today) + " " + string(time,"hh:mm:ss") + " " .
find last cls no-lock no-error.
     g-today = if available cls then cls.cls + 1 else today.
for each qrr .
    delete qrr .
end .
for each rrr .
    delete rrr .
end .

find sysc where sysc.sysc = "CLECOD" no-lock no-error.
if not avail sysc then do :
  v-text = " Записи CLECOD (МФО банка) нет в таблице sysc!".
  message v-text . pause 5.
  run lgps.
  return.
end.
v-clecod = trim(sysc.chval).

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Записи OURBNK (код банка) нет в таблице sysc!".
 message v-text . pause 5.
 run lgps.
 return .
end.
ourbank = sysc.chval.

output stream err to value(v-lbin + "recons.err") append .
put stream err " " + string(today) + ", " +  string(time,"hh:mm:ss" ) +
               ", " + g-ofc format "x(78)" skip
               " Протокол сверки платежей за " + string(g-today)
               format "x(78)" skip(2) .

for each t-qin.
        num[1] = entry(2,t-qin.fname, " ") .
        num[2] = v-lbin + num[1] .

  input through value("lbarc " + num[2] ) .
  blok4 = false .
  repeat :
    v-str = "".
    import unformatted v-str .

    if  length(v-str) = 0 or  v-str begins "\}" then leave .
    if v-str begins "\{2:"  then blok4 = true .
    if not ( v-str begins "\{1:" ) and not blok4  then leave.
    if  v-str begins "\{2:" then do.
        if  substr(v-str,4,4) ne "O950" and  substr(v-str,4,4) ne "O970"  then leave.
        else v-form = substr(v-str,4,4).
    end.
    if v-str begins ":23:" and substr(v-str,5,5) ne "FINAL" then leave.

    if v-str begins ":60F:" and
       date(int(substr(v-str,9,2)),
            int(substr(v-str,11,2)),
            int(substr(string(year(today)),1,2) + substr(v-str,7,2)))
       ne g-today then do.
       run yn(" Внимание! ","Форма МТ" + substr(v-form,2,3) + "(" + num[1] + ")",
                  " не за " +  string(g-today ),"Продолжить?",output otv).

       put stream err unformatted
           " Внимание! Форма МТ" + substr(v-form,2,3) + "(" + num[1] + ")" + " не за " +  string(g-today ) skip.

       if not otv then  return.
    end.

    if v-str begins ":61:" then do :

       v-79 = true .
       if trim(v-str) ne "" then do :
          substr(v-str,1,4) = "" .

          create rrr.
          rrr.vform = 'MT' + substr(v-form,2,3).
          if substr(v-str,5,1) ne "E" then
             rrr.dc = substr(v-str,5,1).
          else
             rrr.dc = substr(v-str,6,1).
      /*iban*/
          rrr.bank = substr(v-str,index(v-str,",") + 7,8).
          k1 = index(v-str,"KZT") + 3.
          k2 = index(v-str,"S1") - k1.
          sum = substr(v-str,k1,k2).
          rrr.amt = decimal(replace(sum , "," , ".")).
          if substr(v-str,5,1) ne "E" then do :
      /*iban*/
             if index(v-str,"//") ne 0 then
                rrr.sqn = substr(v-str,index(v-str,",") + 16,
                          index(v-str,"//") - (index(v-str,",") + 16) ).
             else
                rrr.sqn = substr(v-str,index(v-str,",") + 16).
          end.
          else do :
      /*iban*/
             if index(v-str,"//") ne 0 then
                rrr.sqn = substr(v-str,index(v-str,",") + 17,
                          index(v-str,"//") - (index(v-str,",") + 17)).
             else
                rrr.sqn = substr(v-str,index(v-str,",") + 17).
          end.
          rrr.fname = num[1].
          if rrr.dc = "C" then do :
             n-pap = n-pap + 1.
             n-sum = n-sum + rrr.amt.
          end.
          else do :
             n-papv = n-papv + 1.
             n-sumv = n-sumv + rrr.amt.

          end.
       end. /* if trim(v-str) ne "" */
    end . /* if v-str begins ":61:" */

/* Чистая позиция по клирингу - исключаем из сверки по Гроссу */
    if  v-cover = 'clear' then do:
        if v-str begins ":62F:" and v-form eq 'O970' then do :
              k1 = index(v-str,"KZT") + 3.
              k2 = index(v-str,",") + 2 .
              sum = substr(v-str,k1,k2).
              if substr(v-str,6,1) = 'D' then itogD = itogD + decimal(replace(sum ,"," , ".")).
                                         else itogC = itogC + decimal(replace(sum ,"," , ".")).

              find first lbinf where lbinf.rdt = g-today and lbinf.name = num[2]  and lbinf.gc = 'clear' exclusive-lock  no-error.
              if avail lbinf then do:
                       lbinf.info[2] = '970'.
                       lbinf.amt =  itogD + itogC.
                       if itogD > 0 then lbinf.info[1] = 'D'. else lbinf.info[1] = 'C'.
              end.
              itogD = 0. itogC = 0.
        end.

        if v-str begins ":62F:" and v-form eq 'O950' then do :
              find first lbinf where lbinf.rdt = g-today  and lbinf.gc = 'clear' and lbinf.info[2] = '970' exclusive-lock  no-error.
              if avail lbinf then do:
                       if lbinf.info[1] = 'D' then assign itogD = lbinf.amt kolD = 1.
                                              else assign itogC = lbinf.amt kolC = 1.
              end.
        end.
    end.

  /*  if not(v-79) then next .  */
  end .  /*  repeat  */
  input close.
end.    /* repeat */

/* for gross */
if v-cover = "gross" then do:
    for each remtrz where remtrz.cover = 2 no-lock:
        find first que where que.remtrz = remtrz.remtrz no-lock no-error.
        if avail que then do:
             if  (que.pid = "STW" and remtrz.tcrc = 1 ) or
                 (remtrz.source = "LBI" and remtrz.rdt = g-today and remtrz.fcrc = 1 ) then do:
                 find first qrr where qrr.sqn = remtrz.t_sqn no-error.
                 if not avail qrr then do  :
                    create qrr.
                    assign qrr.pid = que.pid
                           qrr.remtrz = remtrz.remtrz
                           qrr.sqn = remtrz.t_sqn
                           qrr.bank = remtrz.rbank
                           qrr.fname = remtrz.ref .
                    if que.pid = "STW" then ivt = ivt + 1.
                    else irt = irt + 1.
                 end .
                 if que.pid = "STW" then do :
                    iv = iv + 1 .
                    totv-sum = totv-sum + remtrz.payment.
                    qrr.amt = qrr.amt + remtrz.payment.
                 end.
                 else do :
                    ir = ir + 1 .
                    totr-sum = totr-sum + remtrz.amt.
                    qrr.amt = qrr.amt + remtrz.amt.
                 end.
             end.
         end.
    end.
end.
/* for clear */
if v-cover = 'clear' then do:
    for each que where que.pid = "STW" or que.pid = "LBI" no-lock :
        find first remtrz where remtrz.remtrz = que.remtrz no-lock no-error.
         if ( que.pid = "STW" and remtrz.tcrc = 1 and remtrz.cover = 1) or
            ( que.pid = "LBI" and remtrz.fcrc = 1 and remtrz.cover = 1 ) then  do :
            find first qrr where qrr.sqn = remtrz.t_sqn no-error.
            if not avail qrr then do  :
               create qrr.
               assign qrr.pid = que.pid
                      qrr.remtrz = remtrz.remtrz
                      qrr.sqn = remtrz.t_sqn
                      qrr.bank = remtrz.rbank
                      qrr.fname = remtrz.ref .
                if que.pid = "STW" then ivt = ivt + 1.
                else irt = irt + 1.
             end .
              if que.pid = "STW" then do :
                 iv = iv + 1 .
                 totv-sum = totv-sum + remtrz.payment.
                 qrr.amt = qrr.amt + remtrz.payment.
              end.
              else do :
                 ir = ir + 1 .
                 totr-sum = totr-sum + remtrz.amt.
                 qrr.amt = qrr.amt + remtrz.amt.
              end.
         end.
    end.
end.
/*for SMEP*/
if v-cover = 'smep' then do:
    for each remtrz where remtrz.cover = 6 and remtrz.tcrc = 1 no-lock:
        find first que where que.remtrz = remtrz.remtrz no-lock no-error.
        if avail que and (que.pid  = 'STW' or que.pid  = 'LBI' ) then do:
             find first qrr where qrr.sqn = remtrz.t_sqn no-error.
             if not avail qrr then do  :
               create qrr.
               assign qrr.pid = que.pid
                      qrr.remtrz = remtrz.remtrz
                      qrr.sqn = remtrz.t_sqn
                      qrr.bank = remtrz.rbank
                      qrr.fname = remtrz.ref .
                if que.pid = "STW" then ivt = ivt + 1.
                else irt = irt + 1.
             end .
             if que.pid = "STW" then do :
                 iv = iv + 1 .
                 totv-sum = totv-sum + remtrz.payment.
                 qrr.amt = qrr.amt + remtrz.payment.
              end.
              else do :
                 ir = ir + 1 .
                 totr-sum = totr-sum + remtrz.amt.
                 qrr.amt = qrr.amt + remtrz.amt.
             end.

        end.
    end.
end.


/*   form qrr   */
if v-cover = 'clear' then do:
    v-err = dattim + " Сумма чистой позиции по клирингу = "  + string(itogD + itogC) .
    put stream err unformatted v-err skip .
end.

for each rrr break by rrr.fname :
    v-err = "".

    find first qrr where trim(qrr.sqn) = trim(rrr.sqn) no-error.
    if not avail qrr then do :

       v-err = dattim + rrr.vform + ' ' + rrr.fname +
               " Ошибка сверки. Ref "
               + rrr.sqn + " банк " + rrr.bank + " Сумма = " + string(rrr.amt) + " не найдены в ПС " .
        put stream err unformatted v-err skip .
    end.
    else do :
        qrr.fname = rrr.fname.
        qrr.ff = yes.
        find first remtrz where remtrz.remtrz = qrr.remtrz no-lock no-error.
        if avail remtrz then do :
           if remtrz.rcbank = ourbank and rrr.dc ne "C" then do :
              v-err = dattim + " Ошибка сверки. В ПС " + remtrz.remtrz +
                      " - входящий "  + qrr.fname + " . В реестре " +
                      " " + qrr.sqn + " Признак " + rrr.dc. .
              put stream err unformatted v-err skip .
              qrr.ff = no .
           end.
           else if remtrz.scbank = ourbank and rrr.dc ne "D" then do :
                v-err = dattim + " Ошибка сверки. В ПС " + remtrz.remtrz +
                        " - исходящий "  + qrr.fname + " . В реестре " +
                        " " + qrr.sqn + " Признак " + rrr.dc. .
                put stream err unformatted v-err skip .
                qrr.ff = no .
           end.
        end.
        if qrr.amt ne rrr.amt then do:
           v-err = dattim + " Ошибка сверки. В ПС " +
                 " сумма " + string(qrr.amt) + " не равна сумме в реестре " +
                 qrr.fname + " " +
                 string(rrr.amt) + " " + qrr.sqn + " " + qrr.remtrz  +  " " +
                 remtrz.ref .
           put stream err unformatted v-err skip .
           qrr.ff = no.
        end .
    end.  /*  if avail  qrr  */
    if last-of(rrr.fname)
       then put stream err unformatted
               " Обработан реестр  " + rrr.fname + " " + rrr.vform skip.
end.        /*  for each rrr   */


for each qrr where qrr.ff = false :
 find first rrr where rrr.sqn = trim(qrr.sqn) no-error.
 if not avail rrr then do :
    v-err = dattim + qrr.fname + " Ошибка сверки. " + qrr.remtrz
            + " Ref " + qrr.sqn + " банк "
            + qrr.bank + " сумма " + string(qrr.amt) +
            " не найдены в реестре." .
    put stream err unformatted v-err skip .
 end.
end. /*  for each qrr   */


put stream err unformatted skip(1)
  "Всего входящих платежей по выписке    = " + string(n-pap - kolC)                        skip
  "Общая сумма входящих                  = " + string(n-sum - itogC, 'z,zzz,zzz,zzz,zz9.99-')  skip
  "Зарегистрировано на  LBI - всего      = " string(ir) " (" string(irt) ")"               skip
  "Сумма платежей на очереди LBI         = " string(totr-sum, 'z,zzz,zzz,zzz,zz9.99-')         skip
  "Всего входящие   - Всего LBI          = " string(n-sum - itogC - totr-sum, 'z,zzz,zzz,zzz,zz9.99-')   skip(1)

  "Всего исходящих платежей по выписке   = " + string(n-papv - kolD)  skip
  "Общая сумма исходящих                 = " + string(n-sumv - itogD, 'z,zzz,zzz,zzz,zz9.99-') skip
  "Ожидает сверки на очереди STW         = " string(iv) " (" string(ivt) ")"  skip
  "Сумма платежей для сверки на STW      = " string(totv-sum, 'z,zzz,zzz,zzz,zz9.99-') skip
  "Всего исходящие  - Всего STW          = " string(n-sumv - itogD - totv-sum, 'z,zzz,zzz,zzz,zz9.99-') skip(2)
  "---------------------------------------------------------------" skip(2).
output stream err close .
v-ok = v-okk .

