/* aaaq-csa.f
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

 /* aaaq-csa.f
*/
form
     "KIF#:" cif.cif skip
     "V…RDS: " cif.sname             "KONT#:" at 40 qaaa    skip
     "TEL: " cif.tel               "STATUS:      " at 40 aaa.sta skip
     "BRUTO   ATL:" grobal  "HOLD    ATL:" at 40 aaa.hbal vdet skip
     "IZMANT  ATL:" avabal
     "PROC. PIESK:" at 40 aaa.accrued format "zz,zzz,zzz.99-"  skip
     "PROCENTS  %:" intrat  "PRC MKS NGS:" at 40 ytdint  skip
                            "PRC MKS NGS:" at 40 ytdint  skip(1)
                            cif.pss at 40 skip
     "PЁDЁJ DEBET:" aaa.lstdb
                           "PЁD.DEB DAT.:" at 40 aaa.ddt skip
     "PЁDЁJKREDIT:" aaa.lstcr
                           "PЁD. KR DAT.:" at 40 aaa.cdt skip
                           "ATVЁR№. DAT.:" at 40 aaa.regdt skip(1)
     "SaistЁt K/T:" vrel /* "Stop Maks–Ѕ." at 40 vstop */ skip
     "FLOAT INFORM…CIJA:       1:" aaa.fbal[1] skip
     "2:" aaa.fbal[2]
     "3:" aaa.fbal[3]
     "4:" aaa.fbal[4] skip
     "5:" aaa.fbal[5]
     "6:" aaa.fbal[6]
     "7:" aaa.fbal[7] skip
     with title " KONTA INFORM…CIJA:  " centered row 3 no-label overlay frame aaa.
