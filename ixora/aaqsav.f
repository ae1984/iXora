/* aaqsav.f
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

/* keyflt.f
*/
form
     "КIF# -" cif.cif  "VAL®TA " at 41 aaa.crc "  KONT# " aaa.aaa skip
     "VARDS:" cif.sname "  ТЕL : " cif.tel "ST…VOKLIS: " at 41 aaa.sta skip
     "GROSS   ATL:" grobal skip
     "HOLD    ATL:" at 41 aaa.hbal vdet skip
     "IZMANT  ATL:" avabal
     "PROC.PIESK.:" at 41 aaa.accrued
     format "z,zzz,zzz,zzz,zzz.99-"
     "КRED§T L§N.:" crline
     "PRC SMK NGS:" at 41 ytdint skip
     "KRED§T IZMN:" crused
			   "NODOK¶A ID.:" cif.pss at 41 skip
     "PЁD. DEBETS:" aaa.lstdb
			   "PЁD.DEB.DAT:" at 41 aaa.ddt skip
     "PЁD.KRED§TS:" aaa.lstcr
			   "PЁD.KRD.DAT:" at 41 aaa.cdt skip
			   "ATVER№. DAT:" at 41 aaa.regdt skip
     "SaistЁt konts:" vrel "Stop MAKS…№:" at 41 vstop skip(1)
"     FLOAT INFORM…CIJA  -------------------------------------------------"
     skip
     "     1" aaa.fbal[1] format "z,zzz,zzz,zzz,zzz.99"
     "4" aaa.fbal[4] format "z,zzz,zzz,zzz,zzz.99"
     "7" aaa.fbal[7] format "z,zzz,zzz,zzz,zzz.99" skip
     "     2" aaa.fbal[2] format "z,zzz,zzz,zzz,zzz.99"
     "5" aaa.fbal[5] format "z,zzz,zzz,zzz,zzz.99" skip
     "     3" aaa.fbal[3] format "z,zzz,zzz,zzz,zzz.99"
     "6" aaa.fbal[6] format "z,zzz,zzz,zzz,zzz.99"
     with title " KONTA INFORM…CIJA " centered row 3 no-label frame aaa.
