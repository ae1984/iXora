/* prc-last.p
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
       07.03.2004 sasco   - поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       30.03.2004 nadejda - для совместимости поля в w-amk
       24/08/2004 madiar - для совместимости поля в w-amk
       09/12/2005 madiar - добавил для совместимости поля в шаренной таблице w-amk
       04.07.2011 aigul - добавилa для совместимости поля в шаренной таблице w-amk
*/

define input  parameter p-lon    like lon.lon.
define input  parameter p-dt1    as date.
define output parameter p-apr    as decimal.
define output parameter p-dzes   as decimal.
define output parameter p-dt2    as date.

define variable sm    as decimal.
define variable sm0   as decimal.
define variable v-fdt as date.
define variable v-tdt as date.

define new shared temp-table w-amk
       field  nr       as integer
       field  dt       as date
       field  fdt      as date
       field  tdt      as date
       field  prn      as decimal
       field  rate     as decimal
       field  amt1     as decimal
       field  amt2     as decimal
       field  amt3     as decimal
       field  amt4     as decimal
       field  dc       as char /* --date-- madiar */
       field  trx      as char
       field  who      as char
       field    acc as int /*aigul - corr acc*/
       field    note as char. /*aigul - note*/

     find lon where lon.lon = p-lon no-lock.
     run prc-sad(p-lon).
     p-apr = 0.
     p-dzes = 0.
     for each w-amk by w-amk.nr:
         if w-amk.dt < p-dt1
         then p-dzes = p-dzes + w-amk.amt2.
         else leave.
     end.
     p-dt2 = ?.
     v-fdt = ?.
     v-tdt = ?.
     for each w-amk by w-amk.nr:
         if w-amk.fdt <> ? and w-amk.tdt <> ?
         then do:
              if w-amk.fdt >= p-dt1
              then leave.
              if v-fdt <> ? and v-tdt <> ?
              then do:
                   if w-amk.fdt <> v-fdt and w-amk.tdt <> v-tdt
                   then do:
                        if p-apr > p-dzes and p-dt2 = ?
                        then do:
                             if p-dzes = 0
                             then p-dt2 = lon.rdt - 1.
                             else if p-dzes > 0 and sm0 > 0
                             then p-dt2 = v-tdt - integer((p-apr - p-dzes) /
                                         sm0).
                             else p-dt2 = v-fdt - 1.
                        end.
                    end.
              end.
              v-fdt = w-amk.fdt.
              v-tdt = w-amk.tdt.
              sm0 = w-amk.amt1 / (w-amk.tdt - w-amk.fdt + 1).
              if w-amk.tdt > p-dt1
              then sm = sm0 * (p-dt1 - w-amk.fdt).
              else sm = w-amk.amt1.
              p-apr = p-apr + sm.
         end.
     end.
     if p-dt2 = ?
     then do:
          if p-apr > p-dzes
          then do:
               if p-dzes = 0
               then p-dt2 = lon.rdt.
               else if p-dzes > 0 and sm0 > 0
               then p-dt2 = v-tdt - integer((p-apr - p-dzes) / sm0).
               else p-dt2 = v-fdt.
          end.
          else p-dt2 = v-tdt.
     end.
