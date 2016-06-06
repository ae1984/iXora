/* aaal-rel.p
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
        20/07/2011 lyubov - исключила из выводимого списка счетов счета О/Д
*/

/* aaa-rel.p
*/

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
   &frame = "row 3 centered scroll 1 15 down overlay
             title "" Выбрать из списка "" "
   &index = "cif"
   &chkey = "aaa"
   &chtype = "string"
   &file = "aaa"
   &predisp = "if avail lgr then "
   &flddisp =
      "aaa.aaa lgr.des form ""x(15)""
       aaa.cr[1] - aaa.dr[1] format ""z,zzz,zzz,zzz,zzz.99-"" label ""BALANCE ""
       aaa.cbal"
   &findadd =
      "find lgr where lgr.lgr = aaa.lgr and lgr.led ne ""ODA"" no-lock no-error."
   &funadd = " if frame-value = "" "" then
                         do:
                             {imesg.i 9205}.
                             pause 1.
                             next.
                         end.
              g-aaa = frame-value.
              find lgr of aaa no-lock.
              if lgr.led eq ""DDA"" then run aaal-dda.
              else if lgr.led eq ""SAV"" then run aaal-sav.
              else if lgr.led eq ""CDA"" then run aaal-cda.
              else if lgr.led eq ""CSA"" then run aaal-csa.
              else bell.
              g-aaa = """"."
}
