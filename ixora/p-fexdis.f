/* p-fexdis.f
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

display skip(1)
     space(10)
     "Orderis" v-fexp space(10) "Datums  :" fexp.regdt skip(1)
  " -------------------------------------------------------------------------- "
     skip
     space(5)
     "Debets   :" p-from help " C - Kase , A - Konts   " space(16)
     "KredЁts  :" p-to   help " C - Kase , A - Konts   " space(13) skip
     space(5)
     "DB-Konts :"fexp.facc space(13)
     "CR-Konts :"fexp.tacc space(8) skip
     space(5)
     "DB-Val­ta:" fexp.fcrc " " space(1) fcode space(15)
     "CR-Val­ta:" fexp.tcrc " " space(1) tcode  skip
     space(5)
     "Pirk-kur.:" frate
     format "9.9999" "Ls" "/" funit format "zzzz" space(2) v-fcode
     space(2)
     "P–rd-kur.:" trate
     format "9.9999" "Ls" "/" tunit format "zzzz" space(2) v-tcode
     skip
     space(5)
     "Iemaksa  :" fexp.amt format "z,zzz,zzz,zz9.99-" a-fcode space(2)
     "Izmaksa  :" fexp.payment format "z,zzz,zzz,zz9.99-" a-tcode skip
     skip
     space(5)
     "Aprakst  :" fexp.rem skip
     space(5)
     "Opr-num. :" fexp.jh skip
     space(5)
     "IzpildЁt.:" ofc.name skip
     space(5)
     "Akcepts  :" s-name skip(3)
  " -------------------------------------------------------------------------- "
     skip(15)
      with no-label title "VALUTAS  MAIјA ".
