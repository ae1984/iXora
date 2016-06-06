/* dcls14.p
 * MODULE
           daily interest accr
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
       01.08.2003 nadejda - небольшая оптимизация
       15.12.2003 nataly изменен алгоритм начисления %% по МБД
       19.12.2003 nataly vm10 = v-bal * fun.intrate / 100 / days * (s-target - g-today) + fun.m10.
       22.12.2003 nataly изменен алгортим по РЕПО
       01.06.2004 nadejda - убран выход после ошибки при проведении проводки
       17/08/06   Тен - отправка сообщений на мыло о наступление периода формирование МРТ
       12/05/09 marinav - в поле fun.m10 теперь хранится значение с третьего знака после запятой 
	   27.03.2013 id00477 - увеличил количество разрядок для "% За день"
*/

{proghead.i "DAILY INTEREST ACCRUAL"}
define  shared var s-target as date.
define  shared var s-bday as log.
define  shared var s-intday as int.
define new shared var s-jh  like jh.jh.
define new shared var s-consol like jh.consol initial false.
define var intrat like pri.rate.
define var voldacc like aaa.accrued label "OLD-ACC".
define var voldint as dec decimals 2.
define var vnewint as dec decimals 2.
define var vtotair as dec decimals 2.
define var vln as int initial 1.
define var vcnt as int.
define var vm as dec decimals 2 .
define var vm10 as dec decimals 10 . 
define var factor as int.
def var v-weekbeg as int.
def var v-weekend as int.
def buffer a-gl for gl . 
def buffer r-gl for gl .
/*def buffer trxlevgl11 for trxlevgl . */

def var v-gltype as char.
def var v-gldes as char.
def var w-today as date . 
def var vm-conv as dec decimals 2 . 
def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int .
def var rdes1  as cha .
def var rcode1  as int .
def var vparam as cha .
def var vsum as cha .
def var shcode as cha .
def var v-rate1 as decimal.
def var v-rate9 as decimal.
def var v-grp as char.

def var v-nolevgl as logical.



/* Тен - отправка сообщений на мыло о формирование МРТ */
/* 
find sysc where sysc.sysc eq "minrtd" exclusive-lock no-error.
if avail sysc then do:
   if g-today < date(sysc.chval) and s-target >= date(sysc.chval) then do:
      run mail  ( "id00172@metrocombank.kz","BANK <abpk@metrocombank.kz>","МРТ","Наступила дата формирования МРТ","1","",""). 
      run mail  ( "id00005@metrocombank.kz","BANK <abpk@metrocombank.kz>","МРТ","Наступила дата формирования МРТ","1","","").
      sysc.chval = string(date(sysc.chval) + 14).
   end.
end.
*/
/* for trxgen end   */

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

find sysc where sysc.sysc = 'repogr' no-lock no-error.
if avail sysc then v-grp = sysc.chval.

{image1.i rptfun.img}
{image2.i}
  
{report1.i 59}
find sysc where sysc.sysc eq "dayacr".
if sysc.loval eq false then return.


  w-today = g-today . 
  repeat:
    find hol where hol.hol eq w-today  no-error.
    if not available hol and
   weekday(w-today) ge v-weekbeg and
   weekday(w-today) le v-weekend
    then leave.
    else w-today = w-today + 1.
  end.


for each fun where (fun.duedt > g-today and fun.duedt ne ?) or fun.iddt > g-today /*fun.dam[1] ne fun.cam[1] 01.08.2003 nadejda внесла поиск внутрь цикла 
                       and */ 
       /*, each gl where gl.gl = fun.gl no-lock ,  01.08.2003 nadejda внесла поиск внутрь цикла */
       /*each crc where crc.crc = fun.crc no-lock ,      01.08.2003 nadejda внесла поиск внутрь цикла */
       /*first trxlevgl where  trxlevgl.gl = fun.gl and
             trxlevgl.sub = "fun" and trxlevgl.lev = 2 no-lock , 
       first trxlevgl11 where  trxlevgl11.gl = fun.gl and  
           trxlevgl11.sub = "fun" and trxlevgl11.lev = 11 no-lock 01.08.2003 nadejda */
               break by fun.crc by fun.gl /*by gl.type*/ :

  
 if first-of(fun.crc) then do: 
   find first crc where crc.crc = fun.crc no-lock no-error. 
   v-rate1 = crc.rate[1].
   v-rate9 = crc.rate[9].

   vtitle = "Протокол ежд.начисления процентов (FUN)  за  
    (" + string(g-today) + ")" + "    Валюта   - " + crc.des.
           {report2.i 132}  
   end. 


 if first-of(fun.gl) then do:
  find gl where gl.gl = fun.gl no-lock no-error.
  v-gltype = gl.type.
  v-gldes = gl.des.
  s-jh = 0.

  find first trxlevgl where  trxlevgl.gl = fun.gl and trxlevgl.sub = "fun" and trxlevgl.lev = 2 no-lock no-error.
  v-nolevgl = (not avail trxlevgl).

  find first trxlevgl where  trxlevgl.gl = fun.gl and trxlevgl.sub = "fun" and trxlevgl.lev = 11 no-lock no-error.
  v-nolevgl = v-nolevgl or (not avail trxlevgl).
 end.


 if fun.dam[1] = fun.cam[1] or v-nolevgl then next.


   {report2.i 132}   

/* 15.12.03 nataly */
DEF VAR days AS INT FORMAT "999" LABEL "DAYS " INITIAL 0.
def var v-bal as decimal.
 days = 0. v-bal = 0.

 find deal where deal.deal = fun.fun no-lock no-error.
 if avail deal then do:
       if deal.intamt > 0 and deal.prn > 0 and deal.intrate > 0 and  deal.trm > 0
           then do: days = deal.prn * deal.intrate * deal.trm / (100 * deal.intamt).
           end.
 end.
 if days > 0 then do: /*новый алгортим расчета начисленных %%*/
     find gl where gl.gl = fun.gl no-lock no-error.
     if gl.type = 'A' then v-bal = fun.dam[1] - fun.cam[1].
                      else v-bal = fun.cam[1] - fun.dam[1].

     vm10 = v-bal * fun.intrate / 100 / days * (s-target - g-today) + fun.m10.
     vm = round(vm10, 2) .      
     fun.m10 = vm10 - vm.  
 end.
 else do: /*расчет идем по старому алгоритму + РЕПО*/
    if  lookup(string(deal.grp), v-grp) = 0 then do:
        vm10 = fun.interest * (s-target - g-today) / (fun.duedt - fun.rdt) + fun.m10.
        vm = round(vm10, 2) .      
        fun.m10 = vm10 - vm.  
    end. 
    else do: /*РЕПО*/
        if fun.iddt = ? then do: /*непродленные РЕПО*/
           vm10 = deal.yield / deal.trm * (s-target - g-today)  + fun.m10.
           vm = round(vm10, 2) .      
           fun.m10 = vm10 - vm.  
        end.
        else do:  /*продленные РЕПО*/
             find first deallong where deallong.deal  = fun.fun and deallong.matured = fun.iddt no-lock no-error.
             if not avail deallong then next.
             vm10 = deallong.yield / deallong.trm * (s-target - g-today)  + fun.m10.
             vm = round(vm10, 2) .      
             fun.m10 = vm10 - vm.  
        end.
     end. /*РЕПО*/
 end.

  vm-conv = vm10 * v-rate1 / v-rate9.

if v-gltype eq "A"  then do: 
   factor = 1 . 
   if fun.crc = 1 then do:
    vparam =  string(vm) + vdel + fun.fun .
    shcode = "mar0001" .
   end . 
   else do:
    vparam =  string(vm) + vdel + fun.fun + vdel + string(vm-conv) .
    shcode = "mar0003" .
   end.
   end. 
   else if v-gltype eq "L"  then do:
      factor = - 1 . 
   if fun.crc = 1 then do:
    vparam =  string(vm) + vdel + fun.fun .
    shcode = "mar0002" .
   end . 
   else do:
    vparam =  string(vm) + vdel + fun.fun + vdel + string(vm-conv) .
    shcode = "mar0004" .
   end.
   end. 

   run trxgen(shcode,vdel,vparam,"fun",fun.fun,output rcode,
           output rdes,input-output s-jh).
         if rcode ne 0 then 
               do:
                put unformatted rdes + " " + fun.fun . 
                output close . 
                message rdes + fun.fun .
                pause .
               end.

   if first-of(fun.gl) then do:
           find first jh where jh.jh = s-jh . 
           jh.party = "Начисление процентов ( FUN )".
           jh.jdt = w-today .
           for each jl of jh . 
            jl.jdt = jh.jdt . 
           end.
     display "Счет Г/К : " fun.gl format '999999' " - " v-gldes format 'x(30)' "TRX: " string(s-jh)
              with no-label no-box frame crc.
        end.
   
  display fun.fun label " Счет " "(" + v-gltype + ")"
          fun.amt 
          label "Сумма сделки" 
          fun.intrate
          label "% ставка "
          days
          label "Кол-во дней"
         (fun.dam[1] - fun.cam[1]) * factor
          label "Остаток " format "z,zzz,zzz,zzz,zz9.99CR"
          (sub-total by  fun.crc by fun.gl)
          vm label "% За день " format "z,zzz,zz9.99CR" 
          (sub-total by fun.crc by fun.gl)          
          if lookup(v-gltype,"L,O,R") ne  0 then fun.cam[2] else fun.dam[2] 
          label "Начисленный %" format "zzz,zzz,zz9.99CR"
          if lookup(v-gltype,"L,O,R") eq  0 then fun.cam[2] else fun.dam[2]
          label "Полученный %" format "zzz,zzz,zz9.99CR"
          with width 132 down frame acc.
 if last-of(fun.crc) then   
    do:
      find first jl where jl.jh = s-jh no-error . 
      if avail jl then do:
      run trxsts(s-jh, 6, output rcode, output rdes).
             if rcode ne 0 then do:
                   put unformatted rdes + " " + fun.fun .
                   output close .
                   message rdes + fun.fun .
                   pause .
               end.
     end.          
    end.
 end. /* for each fun */
{report3.i}
{image3dcl.i}
