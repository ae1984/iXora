/* r-lncif2.p
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
       21.08.2006 Natalya D. - процедура вообще не отрабатывала: увеличила число экстентов для переменных w-lonp и 
                               w-lonp до 22. Убрала жесткую привязку к индексам. Оптимизатор сам подцепляет нужные 
                               индексы.
*/

/* Кредитный рейтинг клиента

*/


{lonlev.i}
def var vyrst like txb.lon.opnamt extent 6 decimals 2.
def var summa like txb.jl.dam init 0.
def var vmost like vyrst.
def var vcu like vyrst.
def shared var  v-cif as char.
def shared var  koef_ust as decimal.
define shared var g-today  as date.

def var v-dat like txb.bal_cif.rdt.
def var stitle as char format "x(25)".
/*define new shared stream s1.*/
define variable bilance   as decimal format '->,>>>,>>9.99'.
def var vint as decimal format '->,>>>,>>9.99'.
def var vint1 like txb.jl.dam.
define variable npk       as integer.
define variable vprem like txb.lon.prem.
define variable kreditsp  as decimal format '->,>>>,>>9.99'.
define variable cifs      as character format 'x(6)' label 'Клиент'.
define variable v-name    as character.
define variable v-name1   as character.
def var v-cnt as int.
def var v-cntz as int.
def buffer jl2 for txb.jl.
define new shared temp-table w-amk
       field    nr   as integer
       field    dt   as date
       field    fdt  as date
       field    amt1 as decimal format '->>>,>>>,>>9.99'
       field    amt2 as decimal format '->>>,>>>,>>9.99'.
def var v-am1 as decimal init 0.
def var v-am2 as decimal init 0. 
define stream s3.
define variable f-datc     as character.
define variable f-deb      as decimal.
define variable f-kred     as decimal.
define variable f-dat1     as date.
define variable datums     as date.
define variable f-jh       like txb.jh.jh.
define variable f-who      like txb.jh.who.
define variable des as character extent 20.
define variable docs as character extent 10.
define variable gal as character.
define variable gal1 as character.
define variable sumzal as decimal format '->,>>>,>>9.99'.
define variable sumzalt as decimal format '->,>>>,>>9.99'.
def var cnt as decimal extent 4.
def var god as int.

v-dat = g-today.

def temp-table temp_jl
    field tjh like txb.jl.jh
    field tgl like txb.gl.gl 
    field sumjl like txb.jl.dam
    index tgl tjh tgl.

def temp-table temp_jl1
    field tgl like txb.gl.gl 
    field sumjl like txb.jl.dam
    index tgl tgl.


   find txb.cif where txb.cif.cif = v-cif no-lock no-error.



  cnt[1] = 0. cnt[2] = 0. cnt[3] = 0. cnt[4] = 0.  

summa = 0.
npk = 1.

/*расчет коэффициентов ------------------------------*/
    find last txb.bal_cif where txb.bal_cif.cif = v-cif and txb.bal_cif.nom begins 'a' 
            no-lock no-error.
      if avail txb.bal_cif then do:
          v-dat = txb.bal_cif.rdt.

      define var w-lona like txb.bal_cif.amount extent 27.
      define var w-lonp like txb.bal_cif.amount extent 22.
      define var w-lond like txb.bal_cif.amount extent 17.
      define var w-lonaold like txb.bal_cif.amount extent 27.
      define var w-lonpold like txb.bal_cif.amount extent 22.
      def var vk1 as deci.
      def var vk2 as deci.
      def var vk3 as deci.
      def var vk4 as deci.
      def var vk5 as deci.
      def var v-datold like txb.bal_cif.rdt.
      def var i as integer.
      def var k4 as deci.
      def var k5 as deci.
      def var sum1 like txb.bal_cif.amount.
      def var sum2 like txb.bal_cif.amount.
      def var sum1sum2 like txb.bal_cif.amount.

      v-datold = v-dat.
      
      do i = 1 to extent(w-lona):
         w-lona[i] = 0.
      end.
      do i = 1 to extent(w-lonp):
         w-lonp[i] = 0.
      end.
      do i = 1 to extent(w-lond):
         w-lond[i] = 0.
      end.
      do i = 1 to extent(w-lonaold):
         w-lonaold[i] = 0.
      end.
      do i = 1 to extent(w-lonpold):
         w-lonpold[i] = 0.
      end.


      i = 1.
      for each txb.bal_cif where txb.bal_cif.cif = v-cif and txb.bal_cif.rdt = v-dat 
          and txb.bal_cif.nom begins 'a' /*use-index nom*/ break by txb.bal_cif.nom by v-dat:
          if last-of(txb.bal_cif.nom) then do:
          w-lona[i] = txb.bal_cif.amount.
          i = i + 1.
          end.
      end.

      i = 1.
      for each txb.bal_cif where txb.bal_cif.cif = v-cif and txb.bal_cif.rdt = v-dat 
          and txb.bal_cif.nom begins 'p' /*use-index nom*/ break by txb.bal_cif.nom by v-dat:
          if last-of(txb.bal_cif.nom) then do:
            w-lonp[i] = txb.bal_cif.amount.
            i = i + 1.
          end.
      end.

      i = 1.
      for each txb.bal_cif where txb.bal_cif.cif = v-cif and txb.bal_cif.rdt = v-dat 
          and txb.bal_cif.nom begins 'd' /*use-index nom*/ break by txb.bal_cif.nom by v-dat:
          if last-of(txb.bal_cif.nom) then do:
            w-lond[i] = txb.bal_cif.amount.
            i = i + 1.
          end.
      end.

   /* Коэффициент текущей ликвидности */

   sum1 = w-lona[11] + w-lona[12] + w-lona[13] 
        + w-lona[14] + w-lona[15]
        + w-lona[16] + w-lona[17] + w-lona[18] 
        + w-lona[19] + w-lona[20] + w-lona[21] 
        + w-lona[22] + w-lona[23] + w-lona[24] 
        + w-lona[25] + w-lona[26] + w-lona[27].

   sum2 = w-lonp[11] + w-lonp[12] + w-lonp[13] + w-lonp[14]
        + w-lonp[15] + w-lonp[16] + w-lonp[17]
        + w-lonp[18] + w-lonp[19] + w-lonp[20]
        + w-lonp[21] + w-lonp[22].

   find first txb.bal_spr where txb.bal_spr.nom = 'K1'.
   if not avail txb.bal_spr then do:
      message 'Нет коэффициента К1'.
      pause 5.
      return.
   end.

   if (sum1 / sum2) / dec(bal_spr.rem[1]) > 1 then vk1 = 1 * dec(bal_spr.rem[2]).
      else if (sum1 / sum2) / dec(bal_spr.rem[1]) < 0 then vk1 = 0.
         else vk1 = (sum1 / sum2) / dec(bal_spr.rem[1]) * dec(bal_spr.rem[2]).

   if sum2 = 0 then vk1 = 1 * dec(bal_spr.rem[2]).
/* Коэффициент быстрой ликвидности */

   sum1 = w-lona[16] + w-lona[17] + w-lona[18] 
        + w-lona[19] + w-lona[20] + w-lona[21] 
        + w-lona[22] + w-lona[23] + w-lona[24] 
        + w-lona[25] + w-lona[26].

   find first bal_spr where bal_spr.nom = 'K2'.
   if not avail bal_spr then do:
      message 'Нет коэффициента К2'.
      pause 5.
      return.
   end.

   if (sum1 / sum2) / dec(bal_spr.rem[1]) > 1 then vk2 = 1 * dec(bal_spr.rem[2]).
      else if  (sum1 / sum2) / dec(bal_spr.rem[1]) < 0 then vk2 = 0.
         else vk2 = (sum1 / sum2) / dec(bal_spr.rem[1]) * dec(bal_spr.rem[2]).

   if sum2 = 0 then vk2 = 1 * dec(bal_spr.rem[2]).
/* Коэффициент кредитоспособности  */

   sum1 = w-lonp[8] + w-lonp[9] + w-lonp[10]
        + w-lonp[11] + w-lonp[12] + w-lonp[13] + w-lonp[14]
        + w-lonp[15] + w-lonp[16] + w-lonp[17]
        + w-lonp[18] + w-lonp[19] + w-lonp[20]
        + w-lonp[21] + w-lonp[22].

   sum2 = w-lonp[1] + w-lonp[2] + w-lonp[3] 
        + w-lonp[4] + w-lonp[5].

   find first bal_spr where bal_spr.nom = 'K3'.
   if not avail bal_spr then do:
      message 'Нет коэффициента К3'.
      pause 5.
      return.
   end.


   if (sum2 / sum1) / dec(bal_spr.rem[1]) > 1 then vk3 = 1 * dec(bal_spr.rem[2]).
     else if  (sum2 / sum1) / dec(bal_spr.rem[1]) < 0 then vk3 = 0.
          else vk3 = (sum2 / sum1) / dec(bal_spr.rem[1]) * dec(bal_spr.rem[2]).

   if sum2 = 0 then vk3 = 1 * dec(bal_spr.rem[2]).

   find last txb.bal_cif where txb.bal_cif.cif = v-cif and txb.bal_cif.rdt < v-dat 
          and txb.bal_cif.nom begins 'a' /*use-index cif-rdt*/ no-lock no-error.
    if avail txb.bal_cif then do:
      v-datold = txb.bal_cif.rdt.
      i = 1.
      for each txb.bal_cif where txb.bal_cif.cif = v-cif and txb.bal_cif.rdt = v-datold 
          and txb.bal_cif.nom begins 'a' /*use-index nom*/ break by txb.bal_cif.nom by v-dat :
          if last-of(txb.bal_cif.nom) then do:
            w-lonaold[i] = txb.bal_cif.amount.
            i = i + 1.
          end. 
      end.                    
    end.
    else do:
      do i = 1 to extent(w-lonaold):
         w-lonaold[i] = 0.
      end.
    end.

   find last txb.bal_cif where txb.bal_cif.cif = v-cif and txb.bal_cif.rdt < v-dat 
          and txb.bal_cif.nom begins 'p' /*use-index cif-rdt*/ no-lock no-error.
    if avail txb.bal_cif then do:
      v-datold = txb.bal_cif.rdt.
      i = 1.
      for each txb.bal_cif where txb.bal_cif.cif = v-cif and txb.bal_cif.rdt = v-datold 
          and txb.bal_cif.nom begins 'p' /*use-index nom*/ :
          w-lonpold[i] = txb.bal_cif.amount.
          i = i + 1.
      end.
    end.
    else do:
      do i = 1 to extent(w-lonpold):
         w-lonpold[i] = 0.
      end.
    end.

/* Коэффициет оборачиваемости т.м.з.   */

sum1 = w-lona[11] + w-lona[12] + w-lona[13] + w-lona[14] + w-lona[15]
     + w-lonaold[11] + w-lonaold[12] + w-lonaold[13] + w-lonaold[14] + w-lonaold[15].
 

find first bal_spr where bal_spr.nom = 'K4'.
if not avail bal_spr then do:
  message 'Нет коэффициента К4'.
  pause 5.
  return.
end.

k4 = (dec(bal_spr.rem[1]) / 12) * round((v-dat - v-datold) / 30,0).

   if (w-lond[2] / (sum1 / 2)) / k4 > 1 then vk4 = 1 * dec(bal_spr.rem[2]).
      else if (w-lond[2] / (sum1 / 2)) / k4 < 0 then vk4 = 0.
           else vk4 = (w-lond[2] / (sum1 / 2)) / k4 * dec(bal_spr.rem[2]).

   if sum1 = 0 then vk4 = 1 * dec(bal_spr.rem[2]).

/* Коэффициент оборач-ти дебит. задолж-ти   */

sum1 = w-lona[16] + w-lona[17] + w-lona[18] 
     + w-lona[19] + w-lona[20] + w-lona[21]
     + w-lona[22]    + w-lonaold[16] + w-lonaold[17] 
     + w-lonaold[18] + w-lonaold[19] + w-lonaold[20] 
     + w-lonaold[21] + w-lonaold[22]. 


find first bal_spr where bal_spr.nom = 'K5'.
if not avail bal_spr then do:
  message 'Нет коэффициента К5'.
  pause 5.
  return.
end.
k5 = (dec(bal_spr.rem[1]) / 12) * round((v-dat - v-datold) / 30,0).

   if (w-lond[1] / (sum1 / 2)) / k5 > 1 then vk5 = 1 * dec(bal_spr.rem[2]).
      else if (w-lond[1] / (sum1 / 2)) / k5 < 0 then vk5 = 0.
           else vk5 = (w-lond[1] / (sum1 / 2)) / k5 * dec(bal_spr.rem[2]).

   if sum1 = 0 then vk5 = 1 * dec(bal_spr.rem[2]).

sum1 = 0.
  for each txb.bal_cif where txb.bal_cif.cif = v-cif and txb.bal_cif.nom begins 's'. 
    sum1 = sum1 + txb.bal_cif.amount.
  end.

sum1sum2 = vk1 + vk2 + vk3 + vk4 + vk5 + sum1.
if sum1sum2 > 100 then sum1sum2 = 100.

 koef_ust  = sum1sum2.
 if koef_ust = ? then koef_ust = 0.
end.


