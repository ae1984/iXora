/* aaaq-rel.p
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
        02.02.10 marinav - расширение поля счета до 20 знаков
*/

/* aaa-rel.p    */

{global.i}

def new shared var s-toavail like jl.dam.
def new shared var s-aaa like aaa.aaa.
def var vbal like jl.dam.

find first aaa where aaa.cif = g-cif no-error.
if not available aaa then do:
   {mesg.i 0205}.
   pause 2.
   return.
end.

{itemlist.i
   &where = "aaa.cif = g-cif"
   &frame = "row 3 centered scroll 1 15 down width 90 overlay
             title "" Выбор из списка "" "
   &index = "cif"
   &chkey = "aaa"
   &chtype = "string"
   &file = "aaa"
   &flddisp =
      "aaa.aaa label 'СЧЕТ'
      lgr.des form ""x(15)"" label 'ГРУППА'
       aaa.cr[1] - aaa.dr[1] format ""z,zzz,zzz,zzz,zzz.99-"" label ""ОСТАТОК ""
       aaa.cbal label 'ТЕКУЩИЙ ОСТАТОК' "
   &findadd =
      "find lgr where lgr.lgr = aaa.lgr."
   &funadd = " if frame-value = "" "" then
                         do:
                             {imesg.i 9205}.
                             pause 1.
                             next.
                         end.
              g-aaa = frame-value.
              find lgr of aaa no-lock.
              if lgr.led eq ""DDA"" then run aaaq-dda.
              else if lgr.led eq ""SAV"" then run aaaq-sav.
              else if lgr.led eq ""CDA"" then run aaaq-cda.
              else if lgr.led eq ""CSA"" then run aaaq-csa.
              else bell.
              g-aaa = """"."
}
