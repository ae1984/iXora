/* zatrat31.p
 * MODULE
        Зар плата + налог по всем департаментам
 * DESCRIPTION
        Зар плата + налог по всем департаментам
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
        25/01/2006 nataly добавила по департаменту depzl
        28/02/2006 nataly перекомпиляция
        22.06.06 nataly ускорила отчет 
*/


/* {pktncif.i "shared"} */
{name2sort.i}
{comm-txb.i}

def var v-dt as date NO-UNDO.
def var j as integer NO-UNDO.
def var i as integer NO-UNDO.
def var v-day as integer NO-UNDO.
def var v-col as integer NO-UNDO.
def var v-col1 as integer NO-UNDO.

{zatratdef.i }

def buffer b-temp for temp.

def var v-oklad as char NO-UNDO.
def var v-otpusk as char NO-UNDO.
def var v-nadb as char NO-UNDO.
def var v-prem as char NO-UNDO.
def var v-posob as char NO-UNDO.
def var v-hlp as char NO-UNDO.
def var v-nalog as char NO-UNDO.
def var v-otch as char NO-UNDO.

find sysc where sysc.sysc = 'k-okl' no-lock no-error.
if avail sysc  then v-oklad = sysc.chval.
find sysc where sysc.sysc = 'k-otp' no-lock no-error.
if avail sysc  then v-otpusk = sysc.chval.
find sysc where sysc.sysc = 'k-nadb' no-lock no-error.
if avail sysc  then v-nadb = sysc.chval.
find sysc where sysc.sysc = 'k-prem' no-lock no-error.
if avail sysc  then v-prem = sysc.chval.
find sysc where sysc.sysc = 'k-pos' no-lock no-error.
if avail sysc  then v-posob = sysc.chval.
find sysc where sysc.sysc = 'k-hlp' no-lock no-error.
if avail sysc  then v-hlp = sysc.chval.
/*find sysc where sysc.sysc = 'k-nalog' no-lock no-error.
if avail sysc  then v-nalog = sysc.chval.
find sysc where sysc.sysc = 'k-otch' no-lock no-error.
if avail sysc  then v-otch = sysc.chval.
  */
/*put stream rpt skip 
     " СВОД НАЧИСЛЕНИЙ/УДЕРЖАНИЙ ПО КОДАМ (всего) ПО ДЕПАРТАМЕНТУ " + v-name format 'x(80)' at 8  skip
         " ЗА "  + string(vgod) + " г. ( " + string(vmc1) + " - " + string(vmc2) + " )" format 'x(40)'  at 20.
  */
/*find pd  where pd.pd =  depzl no-lock no-error.*/
/*find pd  where pd.pd =  depzl no-lock no-error.
if not avail pd then message 'Данного департамента ' + v-name + ' нет в БД Зарплаты !!!'.
  */
do j = m1 to m2.
 run   mondays(j,y1,output v-day)  .
  /*собираем сотрудников из тек БД*/
 for each tn where /*tn.pd = depzl and*/ pdat <= date(j,v-day,y1) no-lock.
 find pd  where pd.pd = tn.pd no-lock no-error.
  if not avail pd then next. 
 create temp.
  assign 
     temp.tn   = tn.tn
     temp.name = tn.uzv
     temp.rnn = tn.persk
     temp.dep  = tn.pd
     temp.depname = pd.pdnos.
     temp.post   = tn.amats.
     temp.mon   = j. /*номер месяца за к-ый собираются данные*/
  find archiv  where archiv.tn = temp.tn and mc = j and god = y1 no-lock no-error. 
  if avail archiv then temp.dnf = archiv.dnf.
 end.
   /*собираем сотрудников среди уволенных*/
 for each tnd where /*tnd.pd = depzl and*/ tnd.atdat >= date(j,v-day,y1) no-lock.
  find  temp where temp.tn = tnd.tn and temp.mon = j no-error.
  if avail temp then next.
 find pd  where pd.pd = tnd.pd no-lock no-error.
  if not avail pd then next. 

 create temp.
  assign 
     temp.tn   = tnd.tn
     temp.name = tnd.uzv
     temp.rnn  = tnd.persk
     temp.dep  = tnd.pd
     temp.depname = pd.pdnos.
     temp.post   = tnd.amats.
     temp.mon   = j. /*номер месяца за к-ый собираются данные*/
  find archiv  where archiv.tn = temp.tn and mc = j and god = y1 no-lock no-error. 
  if avail archiv then temp.dnf = archiv.dnf.
 end.
end.  /*j*/

/*собираем все начисления за период*/

for each pd where /*pd.pd = depzl*/ . 
FOR EACH alga.tekrg where tekrg.god = y1 
    and tekrg.mc >= m1 and tekrg.mc <= m2 and tekrg.pd =  pd.pd no-lock
    BREAK by tekrg.schi by tekrg.sch:  
 find temp where temp.tn = tekrg.tn and temp.mon = tekrg.mc no-error.
if not avail temp then do: /*если были начисления по сотруднику, а его в списке нет*/
  find  tnd where tnd.tn  = tekrg.tn  no-lock no-error.
if avail tnd then do:
 create temp.
  assign 
     temp.tn   = tnd.tn
     temp.name = tnd.uzv
     temp.rnn  = tnd.persk
     temp.dep  = tnd.pd
     temp.depname = pd.pdnos
     temp.post   = tnd.amats.
     temp.mon   = tekrg.mc. /*номер месяца за к-ый собираются данные*/
    /*   message 'Сотрудника с номером ' tekrg.tn ' нет в базе сотрудников!' view-as alert-box. */
 end.
end.
 if  lookup(string(tekrg.sch),v-oklad) <> 0 then temp.oklad = temp.oklad + tekrg.summa.
  else if lookup(string(tekrg.sch),v-otpusk) <> 0 then temp.otpusk = temp.otpusk + tekrg.summa.
   else if lookup(string(tekrg.sch),v-nadb) <> 0 then temp.nadb = temp.nadb + tekrg.summa.
    else if lookup(string(tekrg.sch),v-prem) <> 0 then temp.prem = temp.prem + tekrg.summa.
     else if lookup(string(tekrg.sch),v-posob) <> 0 then temp.posob = temp.posob + tekrg.summa.
      else if lookup(string(tekrg.sch),v-hlp) <> 0 then temp.hlp = temp.hlp + tekrg.summa.
     temp.schi = 1. /*признак начисления- удержания*/

end.
/*собираем все удержания за период*/
do i = m1 to m2.
for each nalog no-lock where nalog.god = y1 and nalog.mc = i and nalog.pd = pd.pd.
  find temp where  temp.mon = nalog.mc and temp.tn = nalog.tn no-error .
  if avail temp then do:
    temp.nalog = nalog.sumstr.
    temp.otch  = nalog.SSOCNNAK.
  end.

end.
end.
end. /* for each pd*/

for each temp no-lock break by temp.mon by temp.dep.
  accum temp.tn (count by temp.mon by temp.dep).
  /*итого по департаменту*/
 if last-of(temp.dep) then do: 
   v-col1 = accum  count by temp.dep temp.tn.
  for each b-temp where b-temp.mon = temp.mon and b-temp.dep = temp.dep . 
   b-temp.tottndep = v-col1  . 
  end.
 end.
  /*итого по банку*/
  if last-of(temp.mon) then do: 
   v-col = accum  count by temp.mon temp.tn.
  for each b-temp where b-temp.mon = temp.mon . 
   b-temp.tottn = v-col  . 
  end.
 /*  message 'ИТОГО ПО БАНКУ' v-col. pause 300.*/
 end.
end.

/*перекидываем записи в таблицу доходов + создаем аналог таблицы temp - temp1*/
for each temp. 
 create temp2.

  assign 
     temp2.tn   = temp.tn
     temp2.name = temp.name
     temp2.rnn  = temp.rnn
     temp2.dep  = temp.dep
     temp2.depname = temp.depname
     temp2.post   = temp.post
     temp2.mon    =  temp.mon
     temp2.dnf    = temp.dnf
     temp2.tottn  =  temp.tottn
     temp2.tottndep = temp.tottndep .

 create temp1.
  assign 
     temp1.tn   = temp.tn
     temp1.name = temp.name
     temp1.rnn  = temp.rnn
     temp1.dep  = temp.dep
     temp1.depname = temp.depname
     temp1.post   = temp.post
     temp1.mon    =  temp.mon
     temp1.dnf    = temp.dnf
     temp1.tottn  =  temp.tottn
     temp1.tottndep = temp.tottndep .
end.

