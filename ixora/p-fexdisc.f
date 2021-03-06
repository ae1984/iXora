﻿/* p-fexdisc.f
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
"=============================================================================="
skip vcha1 skip
point.addr[1] skip
point.regno skip point.licno skip
fexp.jh  "Orderis :" v-fexp space(10) "Datums  :" fexp.regdt "      "
 string(time,"HH:MM")   skip

  " -------------------------------------------------------------------------- "
     skip
     space(5)

     "Debets G/G: " fexp.gl gl.sub space(6)
     "KredЁts G/G:" fexp.igl b-gl.sub  skip
     space(5)
     "DB-Konts  :"fexp.facc space(13)
     "CR-Konts  :"fexp.tacc space(8) skip
     space(5)
     "DB-Val­ta :" fexp.fcrc " " space(1) fcode space(15)
     "CR-Val­ta :" fexp.tcrc " " space(1) tcode  skip
     space(3)
      substr(fexp.party,12,40) format "x(40)"
     skip
     space(5)
     "Iemaksa   :" fexp.amt format "zzz,zzz,zzz,zz9.99-" a-fcode space(2)
     "Izmaksa :" fexp.payment format "zzz,zzz,zzz,zz9.99-" a-tcode skip
     skip
     space(5)
     "PiezЁmes  :" fexp.rem format "x(55)" skip
     space(5)
     "          :" trim(substring(fexp.rem,56,55)) format "x(55)" skip
     space(5)
/*     "Opr-num. :" fexp.jh skip
     space(5) */
     "IzpildЁja :" ofc.name skip
     space(5)
     "Akceptёja :" s-name skip(3)
  " -------------------------------------------------------------------------- "
     skip(15)
      with no-label title "VAL®TAS  MAIјA ".
