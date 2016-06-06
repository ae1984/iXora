/* next-month.p
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
*/

/*------------------------------------------------------------------------------
 #3.Programma nosaka n–koЅo mёnesi uzdotajam datumam
 #4.Ieeja - parametrs p-dt1 (date)
 #5.Izeja - parametrs p-dt2 (date)
 #6.Rezult–ts:
    dd = day(p-dt1)
    mm = month(p-dt1)
    gg = year(p-dt1)
    * ja mm = 12,tad gg = gg + 1,mm = 1
    * ja mm = 1,gg - garais gads,dd > 29,tad mm = 2,dd = 29
    * ja mm = 1,gg - Ёsais  gads,dd > 28,tad mm = 2,dd = 28
    * ja mm = 3 vai 5 vai 8 vai 10,dd > 30,tad mm = mm + 1,dd = 30
    * p–rёjos gadЁjumos mm = mm + 1
    p-dt2 = date(mm,dd,gg)
------------------------------------------------------------------------------*/
define input parameter  p-dt1 as date.
define output parameter p-dt2 as date.
define variable         gd    as integer.
define variable         mn    as integer.
define variable         dn    as integer.

gd = year(p-dt1).
mn = month(p-dt1).
dn = day(p-dt1).
if mn = 12
then do:
     gd = gd + 1.
     mn = 1.
end.
else if mn = 1
     then do:
          mn = 2.
          if gd modulo 4 = 0
          then do:
               if dn > 29
               then dn = 29.
          end.
          else do:
               if dn > 28
               then dn = 28.
          end.
     end.
else if mn = 3 or mn = 5 or mn = 8 or mn = 10
     then do:
          mn = mn + 1.
          if dn > 30
          then dn = 30.
     end.
else mn = mn + 1.
p-dt2 = date(mn,dn,gd).
